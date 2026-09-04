unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, WebGPU4Delphi, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    // WebGPU Core Objects
    FInstance: WGPUInstance;   // The root object of the WebGPU API
    FAdapter: WGPUAdapter;    // Represents a physical GPU device
    FDevice: WGPUDevice;      // Represents a logical GPU device (the context for commands)
    FQueue: WGPUQueue;        // The queue used to submit command buffers to the GPU
    FSurface: WGPUSurface;    // The target surface on the window where the GPU will draw

    // Assets required to draw a 3D cube
    FShaderModule: WGPUShaderModule;     // The compiled WGSL shader code (vertex and fragment)
    FPipeline: WGPURenderPipeline;       // The pipeline state (shaders, vertex layout, depth testing, etc.)
    FVertexBuffer: WGPUBuffer;           // GPU buffer containing the cube's vertex data (position, color)
    FIndexBuffer: WGPUBuffer;            // GPU buffer containing the indices to form triangles from vertices
    FDepthTexture: WGPUTexture;          // Texture used for depth testing (z-buffer)
    FDepthTextureView: WGPUTextureView;  // View into the depth texture for the render pass
    FAssetsCreated: Boolean;             // Flag to ensure assets are only created once

    procedure InitWebGPUContext;   // Initializes WebGPU instance, adapter, device, and surface
    procedure ReleaseWebGPUContext; // Frees all WebGPU resources to prevent memory leaks
    procedure CreateCubeAssets;    // Creates buffers, shaders, pipeline, and depth texture
    procedure DrawCubeFrame;       // Encodes and submits a draw command for a single frame
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

// -----------------------------------------------------------------------------
// WGSL Shader Code
// This shader is written in WebGPU Shading Language (WGSL).
// It rotates the cube slightly and applies a hard-coded camera offset (z = 3.0).
// -----------------------------------------------------------------------------
const
  SHADER_CODE: AnsiString =
    'struct VOut {' +
    '  @builtin(position) pos: vec4<f32>,' +
    '  @location(0) color: vec3<f32>' +
    '};' +
    '@vertex' +
    'fn vs_main(@location(0) in_pos: vec3<f32>, @location(1) in_color: vec3<f32>) -> VOut {' +
    '  var out: VOut;' +
    // Hardcoded rotation around the Y-axis to show that the vertex shader is manipulating geometry
    '  let angle: f32 = 0.8;' +
    '  let c: f32 = cos(angle); let s: f32 = sin(angle);' +
    '  let rotated_x: f32 = in_pos.x * c - in_pos.z * s;' +
    '  let rotated_z: f32 = in_pos.x * s + in_pos.z * c;' +
    // Apply the rotation and move the cube 3.0 units away from the camera
    '  out.pos = vec4<f32>(rotated_x, in_pos.y, rotated_z + 3.0, 1.0);' +
    '  out.color = in_color;' +
    '  return out;' +
    '}' +
    '@fragment' +
    'fn fs_main(in: VOut) -> @location(0) vec4<f32> {' +
    '  return vec4<f32>(in.color, 1.0);' + // Output the interpolated color
    '}';

// Data structure for a single vertex. Matches the layout in the shader.
type
  TVertex = record
    X, Y, Z: Single; // Position (3 floats = 12 bytes)
    R, G, B: Single; // Color    (3 floats = 12 bytes)
  end;
  TIndex = UInt16;   // Index format (Unsigned 16-bit integer)

// Definition of the 8 corners of a cube. Each corner gets a distinct color.
const
  VERTICES: array[0..7] of TVertex = (
    (X:-1; Y:-1; Z:-1; R:1; G:0; B:0), (X: 1; Y:-1; Z:-1; R:0; G:1; B:0),
    (X: 1; Y: 1; Z:-1; R:0; G:0; B:1), (X:-1; Y: 1; Z:-1; R:1; G:1; B:0),
    (X:-1; Y:-1; Z: 1; R:1; G:0; B:1), (X: 1; Y:-1; Z: 1; R:0; G:1; B:1),
    (X: 1; Y: 1; Z: 1; R:1; G:0; B:0), (X:-1; Y: 1; Z: 1; R:0; G:0; B:1)
  );
  // Indices defining the 12 triangles (2 per side) that make up the cube surface.
  INDICES: array[0..35] of TIndex = (
    0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7,
    0, 4, 7, 0, 7, 3, 1, 5, 6, 1, 6, 2,
    3, 6, 2, 3, 7, 6, 0, 5, 4, 0, 1, 5
  );

// -----------------------------------------------------------------------------
// Asynchronous Callback Targets
// WebGPU requests (like Adapter/Device) are asynchronous. We use global vars
// to catch the result from the callback.
// -----------------------------------------------------------------------------
var
  FCallbackAdapter: WGPUAdapter = nil;
  FCallbackDevice: WGPUDevice = nil;

// Callback for wgpuInstanceRequestAdapter. Triggered when the GPU adapter is found.
procedure AdapterRequestCallback(Status: WGPURequestAdapterStatus;
  Adapter: WGPUAdapter; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;
begin
  if Status = WGPURequestAdapterStatus_Success then
    FCallbackAdapter := Adapter;
end;

// Callback for wgpuAdapterRequestDevice. Triggered when the logical device is created.
procedure DeviceRequestCallback(Status: WGPURequestDeviceStatus;
  Device: WGPUDevice; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;
begin
  if Status = WGPURequestDeviceStatus_Success then
    FCallbackDevice := Device;
end;

// -----------------------------------------------------------------------------
// RAW MEMORY HELPER FUNCTIONS
// Because Delphi records can have different padding/alignment than C-structs,
// we construct complex WebGPU descriptors using raw byte arrays. These helper
// functions write Pointers, UInt64s, UInt32s, and Strings directly into memory
// at specific offsets, mimicking the exact C-struct memory layout.
// -----------------------------------------------------------------------------

procedure PutPtr(P: Pointer; Offset: NativeUInt; V: Pointer);
begin
  Move(V, (PByte(P) + Offset)^, 8); // Pointers are 8 bytes in 64-bit
end;

procedure PutU64(P: Pointer; Offset: NativeUInt; V: UInt64);
begin
  Move(V, (PByte(P) + Offset)^, 8);
end;

procedure PutU32(P: Pointer; Offset: NativeUInt; V: UInt32);
begin
  Move(V, (PByte(P) + Offset)^, 4);
end;

// Writes a WGPUStringView (Pointer + Length) into memory. Used for "EntryPoint" names.
procedure PutStr(P: Pointer; Offset: NativeUInt; const S: AnsiString);
var
  StrPtr: PAnsiChar;
  Len: NativeUInt;
begin
  StrPtr := PAnsiChar(S);
  Len := Length(S);
  Move(StrPtr, (PByte(P) + Offset)^, 8);      // Write string pointer
  Move(Len, (PByte(P) + Offset + 8)^, 8);     // Write string length
end;

// -----------------------------------------------------------------------------
// BUTTON 1: Initialize WebGPU
// -----------------------------------------------------------------------------
procedure TForm2.Button1Click(Sender: TObject);
begin
  InitWebGPUContext;
end;

procedure TForm2.InitWebGPUContext;
var
  InstanceDesc: WGPUInstanceDescriptor;
  AdapterOptions: WGPURequestAdapterOptions;
  DeviceDesc: WGPUDeviceDescriptor;
  AdapterCBInfo: WGPURequestAdapterCallbackInfo;
  DeviceCBInfo: WGPURequestDeviceCallbackInfo;
  SurfaceDesc: WGPUSurfaceDescriptor;
  SurfaceSource: WGPUSurfaceSourceWindowsHWND;
  SurfaceConfig: WGPUSurfaceConfiguration;
begin
  // Load the wgpu_native.dll dynamically
  if not InitWebGPU then Exit;

  // 1. Create the WebGPU Instance (Root context)
  FillChar(InstanceDesc, SizeOf(InstanceDesc), 0);
  FInstance := wgpuCreateInstance(InstanceDesc);

  // 2. Request an Adapter (Physical GPU)
  FillChar(AdapterOptions, SizeOf(AdapterOptions), 0);
  AdapterOptions.FeatureLevel := WGPUFeatureLevel_Core;
  AdapterOptions.PowerPreference := WGPUPowerPreference_HighPerformance; // Ask for dedicated GPU

  FillChar(AdapterCBInfo, SizeOf(AdapterCBInfo), 0);
  AdapterCBInfo.Mode := WGPUCallbackMode_AllowProcessEvents;
  AdapterCBInfo.Callback := AdapterRequestCallback;

  FCallbackAdapter := nil;
  wgpuInstanceRequestAdapter(FInstance, AdapterOptions, AdapterCBInfo);
  // WebGPU requests are async. We pump the Windows message queue to allow the callback to fire.
  Application.ProcessMessages; Sleep(100); Application.ProcessMessages;
  FAdapter := FCallbackAdapter;

  // 3. Request a Device (Logical GPU context)
  FillChar(DeviceDesc, SizeOf(DeviceDesc), 0);
  FillChar(DeviceCBInfo, SizeOf(DeviceCBInfo), 0);
  DeviceCBInfo.Mode := WGPUCallbackMode_AllowProcessEvents;
  DeviceCBInfo.Callback := DeviceRequestCallback;

  FCallbackDevice := nil;
  wgpuAdapterRequestDevice(FAdapter, DeviceDesc, DeviceCBInfo);
  Application.ProcessMessages; Sleep(100); Application.ProcessMessages;
  FDevice := FCallbackDevice;

  // Get the default command queue from the device
  FQueue := wgpuDeviceGetQueue(FDevice);

  // 4. Create the Surface (Ties rendering to the Form's window handle)
  FillChar(SurfaceSource, SizeOf(SurfaceSource), 0);
  SurfaceSource.Chain.SType := WGPUSType_SurfaceSourceWindowsHWND;
  SurfaceSource.Hinstance := Pointer(hInstance);
  SurfaceSource.Hwnd := Pointer(Self.Handle); // Render directly to TForm2

  FillChar(SurfaceDesc, SizeOf(SurfaceDesc), 0);
  SurfaceDesc.NextInChain := @SurfaceSource;
  FSurface := wgpuInstanceCreateSurface(FInstance, SurfaceDesc);

  // 5. Configure the Surface (Set format, size, and V-Sync)
  FillChar(SurfaceConfig, SizeOf(SurfaceConfig), 0);
  SurfaceConfig.Device := FDevice;
  SurfaceConfig.Format := WGPUTextureFormat_BGRA8Unorm; // Standard Windows color format
  SurfaceConfig.Usage := $0000000000000010;             // RenderAttachment flag
  SurfaceConfig.Width := ClientWidth;
  SurfaceConfig.Height := ClientHeight;
  SurfaceConfig.PresentMode := WGPUPresentMode_Fifo;   // V-Sync enabled
  wgpuSurfaceConfigure(FSurface, SurfaceConfig);

  ShowMessage('Init ok');
end;

// -----------------------------------------------------------------------------
// BUTTON 2: Clear Screen (Draw a blank frame)
// -----------------------------------------------------------------------------
procedure TForm2.Button2Click(Sender: TObject);
var
  SurfaceTexture: WGPUSurfaceTexture;
  TextureView: WGPUTextureView;
  Encoder: WGPUCommandEncoder;
  RenderPass: WGPURenderPassEncoder;
  ColorAttachment: WGPURenderPassColorAttachment;
  PassDesc: WGPURenderPassDescriptor;
  ViewDesc: WGPUTextureViewDescriptor;
  CmdBuffer: WGPUCommandBuffer;
begin
  if FSurface = nil then Exit;

  // Get the next texture from the swap chain (the screen buffer)
  wgpuSurfaceGetCurrentTexture(FSurface, SurfaceTexture);
  if SurfaceTexture.Texture = nil then Exit;

  // Create a view into the texture so the render pass can write to it
  FillChar(ViewDesc, SizeOf(ViewDesc), 0);
  ViewDesc.Format := WGPUTextureFormat_BGRA8Unorm;
  ViewDesc.Dimension := WGPUTextureViewDimension_2D;
  ViewDesc.Aspect := WGPUTextureAspect_All;
  ViewDesc.MipLevelCount := 1;
  ViewDesc.ArrayLayerCount := 1;
  TextureView := wgpuTextureCreateView(SurfaceTexture.Texture, @ViewDesc);

  // Create a Command Encoder to record GPU commands
  Encoder := wgpuDeviceCreateCommandEncoder(FDevice, nil);

  // Setup the Color Attachment: Tell it to clear the screen to blue
  FillChar(ColorAttachment, SizeOf(ColorAttachment), 0);
  ColorAttachment.View := TextureView;
  ColorAttachment.DepthSlice := $FFFFFFFF;
  ColorAttachment.LoadOp := WGPULoadOp_Clear;  // Clear the buffer at the start of the pass
  ColorAttachment.StoreOp := WGPUStoreOp_Store; // Store the result to the screen
  ColorAttachment.ClearValue.R := 0.0;
  ColorAttachment.ClearValue.G := 0.2;
  ColorAttachment.ClearValue.B := 1.0;
  ColorAttachment.ClearValue.A := 1.0;

  FillChar(PassDesc, SizeOf(PassDesc), 0);
  PassDesc.ColorAttachmentCount := 1;
  PassDesc.ColorAttachments := @ColorAttachment;

  // Start the render pass, immediately end it (no draw commands = just a clear screen)
  RenderPass := wgpuCommandEncoderBeginRenderPass(Encoder, @PassDesc);
  wgpuRenderPassEncoderEnd(RenderPass);
  wgpuRenderPassEncoderRelease(RenderPass);

  // Finish recording, submit the command buffer to the GPU queue
  CmdBuffer := wgpuCommandEncoderFinish(Encoder, nil);
  wgpuCommandEncoderRelease(Encoder);
  wgpuQueueSubmit(FQueue, 1, @CmdBuffer);
  wgpuCommandBufferRelease(CmdBuffer);

  // Present the drawn texture to the screen
  wgpuSurfacePresent(FSurface);
  wgpuTextureViewRelease(TextureView);
end;

// -----------------------------------------------------------------------------
// CREATE CUBE ASSETS (Buffers, Pipeline, Depth Texture)
// -----------------------------------------------------------------------------
procedure TForm2.CreateCubeAssets;
var
  BufDesc: WGPUBufferDescriptor;
  TexDesc: WGPUTextureDescriptor;
  ViewDesc: WGPUTextureViewDescriptor;

  // Raw byte arrays to hold struct data manually, bypassing Delphi's alignment rules
  WGSLSource: array[0..31] of Byte;
  ShaderDesc: array[0..23] of Byte;
  Attrs: array[0..1] of array[0..19] of Byte;
  BufLayout: array[0..31] of Byte;
  VertexState: array[0..71] of Byte;
  PrimState: array[0..23] of Byte;
  DepthStencil: array[0..95] of Byte;
  MultisampleState: array[0..23] of Byte;
  ColorTarget: array[0..23] of Byte;
  FragmentState: array[0..71] of Byte;
  PipelineDesc: array[0..311] of Byte;
  ShaderPtr: Pointer;
  PipelinePtr: Pointer;
begin
  // 1. Create Vertex Buffer
  FillChar(BufDesc, SizeOf(BufDesc), 0);
  BufDesc.Usage := WGPUBufferUsage_Vertex or WGPUBufferUsage_CopyDst; // GPU reads as vertex, CPU writes to it
  BufDesc.Size := Length(VERTICES) * SizeOf(TVertex);
  FVertexBuffer := wgpuDeviceCreateBuffer(FDevice, BufDesc);
  // Upload the vertex data from CPU to GPU
  wgpuQueueWriteBuffer(FQueue, FVertexBuffer, 0, @VERTICES[0], BufDesc.Size);

  // 2. Create Index Buffer
  BufDesc.Usage := WGPUBufferUsage_Index or WGPUBufferUsage_CopyDst;
  BufDesc.Size := Length(INDICES) * SizeOf(TIndex);
  FIndexBuffer := wgpuDeviceCreateBuffer(FDevice, BufDesc);
  wgpuQueueWriteBuffer(FQueue, FIndexBuffer, 0, @INDICES[0], BufDesc.Size);

  // 3. Create Shader Module using raw memory layout
  FillChar(WGSLSource, SizeOf(WGSLSource), 0);
  PutU32(@WGSLSource[0], 8, UInt32(WGPUSType_ShaderSourceWGSL)); // SType identifier
  PutStr(@WGSLSource[0], 16, SHADER_CODE);                       // The WGSL code string

  FillChar(ShaderDesc, SizeOf(ShaderDesc), 0);
  PutPtr(@ShaderDesc[0], 0, @WGSLSource[0]); // Pointer to the WGSLSource chain

  ShaderPtr := @ShaderDesc[0];
  FShaderModule := wgpuDeviceCreateShaderModule(FDevice, WGPUShaderModuleDescriptor(ShaderPtr^));

  // 4. Define Vertex Attributes (How the GPU reads our TVertex data)
  // Attribute 0: Position (3x Float32) at offset 0
  FillChar(Attrs, SizeOf(Attrs), 0);
  PutU32(@Attrs[0][0], 0, UInt32(WGPUVertexFormat_Float32x3));
  PutU64(@Attrs[0][0], 8, UInt64(0));   // Memory offset in the vertex
  PutU32(@Attrs[0][0], 16, 0);         // Shader location index

  // Attribute 1: Color (3x Float32) at offset 12 (after 3 floats)
  PutU32(@Attrs[1][0], 0, UInt32(WGPUVertexFormat_Float32x3));
  PutU64(@Attrs[1][0], 8, UInt64(12));
  PutU32(@Attrs[1][0], 16, 1);

  // 5. Define Vertex Buffer Layout
  FillChar(BufLayout, SizeOf(BufLayout), 0);
  PutU32(@BufLayout[0], 0, UInt32(WGPUVertexStepMode_Vertex)); // Advance per vertex
  PutU64(@BufLayout[0], 8, UInt64(SizeOf(TVertex)));           // Stride (bytes per vertex)
  PutU64(@BufLayout[0], 16, UInt64(2));                      // 2 attributes
  PutPtr(@BufLayout[0], 24, @Attrs[0][0]);                   // Pointer to attributes array

  // 6. Define Vertex State (Links shader and vertex buffer layout)
  FillChar(VertexState, SizeOf(VertexState), 0);
  PutPtr(@VertexState[0], 8, FShaderModule);        // Shader module pointer
  PutStr(@VertexState[0], 16, 'vs_main');          // Entry point function name
  PutU64(@VertexState[0], 40, UInt64(1));         // 1 buffer layout
  PutPtr(@VertexState[0], 48, @BufLayout[0]);     // Pointer to the layout

  // 7. Define Primitive State (How to draw triangles and cull backfaces)
  FillChar(PrimState, SizeOf(PrimState), 0);
  PutU32(@PrimState[0], 8, UInt32(WGPUPrimitiveTopology_TriangleList)); // Draw independent triangles
  PutU32(@PrimState[0], 16, UInt32(WGPUFrontFace_CCW));                 // Front face is counter-clockwise
  PutU32(@PrimState[0], 20, UInt32(WGPUCullMode_Back));                 // Hide back faces

  // 8. Define Depth Stencil State (Enables the Z-Buffer so 3D geometry draws correctly)
  FillChar(DepthStencil, SizeOf(DepthStencil), 0);
  PutU32(@DepthStencil[0], 8, UInt32(WGPUTextureFormat_Depth32Float)); // Format of depth texture
  PutU32(@DepthStencil[0], 12, 1);                                   // DepthWriteEnabled = True
  PutU32(@DepthStencil[0], 16, UInt32(WGPUCompareFunction_Less));     // Closer pixels overwrite further ones

  // 9. Define Multisample State (Disabled here, 1 sample per pixel)
  FillChar(MultisampleState, SizeOf(MultisampleState), 0);
  PutU32(@MultisampleState[0], 8, 1); // Sample count = 1

  // 10. Define Color Target State (Output format must match the surface format)
  FillChar(ColorTarget, SizeOf(ColorTarget), 0);
  PutU32(@ColorTarget[0], 8, UInt32(WGPUTextureFormat_BGRA8Unorm));
  PutU64(@ColorTarget[0], 16, $000000000000000F); // WriteMask: All colors (RGBA)

  // 11. Define Fragment State (Links shader to the color output)
  FillChar(FragmentState, SizeOf(FragmentState), 0);
  PutPtr(@FragmentState[0], 8, FShaderModule);
  PutStr(@FragmentState[0], 16, 'fs_main'); // Fragment entry point
  PutU64(@FragmentState[0], 40, UInt64(1)); // 1 color target
  PutPtr(@FragmentState[0], 48, @ColorTarget[0]);

  // 12. Assemble the final Render Pipeline Descriptor
  FillChar(PipelineDesc, SizeOf(PipelineDesc), 0);
  // The pipeline descriptor contains inline structs. We copy our raw byte arrays into the exact offsets.
  Move(VertexState[0], PipelineDesc[16], 72);      // Offset 16: Vertex State
  Move(PrimState[0], PipelineDesc[88], 24);        // Offset 88: Primitive State
  PutPtr(@PipelineDesc[0], 112, @DepthStencil[0]); // Offset 112: Pointer to Depth State
  Move(MultisampleState[0], PipelineDesc[120], 24);// Offset 120: Multisample State
  PutPtr(@PipelineDesc[0], 144, @FragmentState[0]); // Offset 144: Pointer to Fragment State

  // Create the pipeline
  PipelinePtr := @PipelineDesc[0];
  FPipeline := wgpuDeviceCreateRenderPipeline(FDevice, WGPURenderPipelineDescriptor(PipelinePtr^));

  // 13. Create Depth Texture (Matches the size of the window)
  FillChar(TexDesc, SizeOf(TexDesc), 0);
  TexDesc.Usage := WGPUTextureUsage_RenderAttachment;
  TexDesc.Dimension := 2;
  TexDesc.Size.Width := ClientWidth;
  TexDesc.Size.Height := ClientHeight;
  TexDesc.Size.DepthOrArrayLayers := 1;
  TexDesc.Format := WGPUTextureFormat_Depth32Float;
  TexDesc.MipLevelCount := 1;
  TexDesc.SampleCount := 1;
  FDepthTexture := wgpuDeviceCreateTexture(FDevice, TexDesc);

  // Create a view into the depth texture
  FillChar(ViewDesc, SizeOf(ViewDesc), 0);
  ViewDesc.Format := WGPUTextureFormat_Depth32Float;
  ViewDesc.Dimension := WGPUTextureViewDimension_2D;
  ViewDesc.Aspect := WGPUTextureAspect_DepthOnly; // We only care about the depth aspect
  ViewDesc.MipLevelCount := 1;
  ViewDesc.ArrayLayerCount := 1;
  FDepthTextureView := wgpuTextureCreateView(FDepthTexture, @ViewDesc);

  FAssetsCreated := True;
end;

// -----------------------------------------------------------------------------
// DRAW THE 3D CUBE
// -----------------------------------------------------------------------------
procedure TForm2.DrawCubeFrame;
var
  SurfaceTexture: WGPUSurfaceTexture;
  TextureView: WGPUTextureView;
  Encoder: WGPUCommandEncoder;
  RenderPass: WGPURenderPassEncoder;
  ColorAttachment: WGPURenderPassColorAttachment;
  DepthAttachment: WGPURenderPassDepthStencilAttachment;
  PassDesc: WGPURenderPassDescriptor;
  ViewDesc: WGPUTextureViewDescriptor;
  CmdBuffer: WGPUCommandBuffer;
begin
  if FSurface = nil then Exit;

  // 1. Get the screen texture
  wgpuSurfaceGetCurrentTexture(FSurface, SurfaceTexture);
  if SurfaceTexture.Texture = nil then Exit;

  // Create a view for the screen texture
  FillChar(ViewDesc, SizeOf(ViewDesc), 0);
  ViewDesc.Format := WGPUTextureFormat_BGRA8Unorm;
  ViewDesc.Dimension := WGPUTextureViewDimension_2D;
  ViewDesc.Aspect := WGPUTextureAspect_All;
  ViewDesc.MipLevelCount := 1;
  ViewDesc.ArrayLayerCount := 1;
  TextureView := wgpuTextureCreateView(SurfaceTexture.Texture, @ViewDesc);

  // 2. Start recording commands
  Encoder := wgpuDeviceCreateCommandEncoder(FDevice, nil);

  // 3. Setup Color Attachment (Clear screen to dark grey)
  FillChar(ColorAttachment, SizeOf(ColorAttachment), 0);
  ColorAttachment.View := TextureView;
  ColorAttachment.DepthSlice := $FFFFFFFF;
  ColorAttachment.LoadOp := WGPULoadOp_Clear;
  ColorAttachment.StoreOp := WGPUStoreOp_Store;
  ColorAttachment.ClearValue.R := 0.1;
  ColorAttachment.ClearValue.G := 0.1;
  ColorAttachment.ClearValue.B := 0.1;
  ColorAttachment.ClearValue.A := 1.0;

  // 4. Setup Depth Attachment (Clear depth buffer to 1.0 = far away)
  FillChar(DepthAttachment, SizeOf(DepthAttachment), 0);
  DepthAttachment.View := FDepthTextureView;
  DepthAttachment.DepthLoadOp := WGPULoadOp_Clear;
  DepthAttachment.DepthStoreOp := WGPUStoreOp_Store;
  DepthAttachment.DepthClearValue := 1.0; // Max depth
  DepthAttachment.DepthReadOnly := 0;
  DepthAttachment.StencilLoadOp := WGPULoadOp_Clear;
  DepthAttachment.StencilStoreOp := WGPUStoreOp_Discard;
  DepthAttachment.StencilClearValue := 0;
  DepthAttachment.StencilReadOnly := 1;

  // 5. Begin the Render Pass
  FillChar(PassDesc, SizeOf(PassDesc), 0);
  PassDesc.ColorAttachmentCount := 1;
  PassDesc.ColorAttachments := @ColorAttachment;
  PassDesc.DepthStencilAttachment := @DepthAttachment;

  RenderPass := wgpuCommandEncoderBeginRenderPass(Encoder, @PassDesc);

  // 6. Bind the Pipeline and Buffers
  wgpuRenderPassEncoderSetPipeline(RenderPass, FPipeline);
  wgpuRenderPassEncoderSetVertexBuffer(RenderPass, 0, FVertexBuffer, 0, Length(VERTICES) * SizeOf(TVertex));
  wgpuRenderPassEncoderSetIndexBuffer(RenderPass, FIndexBuffer, WGPUIndexFormat_Uint16, 0, Length(INDICES) * SizeOf(TIndex));

  // 7. Issue the Draw Command! (36 indices = 12 triangles = 1 cube)
  wgpuRenderPassEncoderDrawIndexed(RenderPass, Length(INDICES), 1, 0, 0, 0);

  // 8. End Pass, finish encoding, submit to GPU
  wgpuRenderPassEncoderEnd(RenderPass);
  wgpuRenderPassEncoderRelease(RenderPass);

  CmdBuffer := wgpuCommandEncoderFinish(Encoder, nil);
  wgpuCommandEncoderRelease(Encoder);
  wgpuQueueSubmit(FQueue, 1, @CmdBuffer);
  wgpuCommandBufferRelease(CmdBuffer);

  // 9. Present to screen
  wgpuSurfacePresent(FSurface);
  wgpuTextureViewRelease(TextureView);
end;

// -----------------------------------------------------------------------------
// BUTTON 3: Trigger Cube Drawing
// -----------------------------------------------------------------------------
procedure TForm2.Button3Click(Sender: TObject);
begin
  // Create the pipeline and buffers if they don't exist yet
  if not FAssetsCreated then
    CreateCubeAssets;

  DrawCubeFrame;
end;

// -----------------------------------------------------------------------------
// CLEANUP: Free all WebGPU resources to avoid memory leaks
// -----------------------------------------------------------------------------
procedure TForm2.ReleaseWebGPUContext;
begin
  // Free Assets first
  if FAssetsCreated then
  begin
    if FDepthTextureView <> nil then wgpuTextureViewRelease(FDepthTextureView);
    if FDepthTexture <> nil then wgpuTextureRelease(FDepthTexture);
    if FPipeline <> nil then wgpuRenderPipelineRelease(FPipeline);
    if FShaderModule <> nil then wgpuShaderModuleRelease(FShaderModule);
    if FIndexBuffer <> nil then wgpuBufferRelease(FIndexBuffer);
    if FVertexBuffer <> nil then wgpuBufferRelease(FVertexBuffer);
  end;

  // Free Core context objects in reverse order of creation
  if FSurface <> nil then
  begin
    wgpuSurfaceUnconfigure(FSurface);
    wgpuSurfaceRelease(FSurface);
    FSurface := nil;
  end;
  if FQueue <> nil then
  begin
    wgpuQueueRelease(FQueue);
    FQueue := nil;
  end;
  if FDevice <> nil then
  begin
    wgpuDeviceRelease(FDevice);
    FDevice := nil;
  end;
  if FAdapter <> nil then
  begin
    wgpuAdapterRelease(FAdapter);
    FAdapter := nil;
  end;
  if FInstance <> nil then
  begin
    wgpuInstanceRelease(FInstance);
    FInstance := nil;
  end;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  ReleaseWebGPUContext;
  ReleaseWebGPU; // Unload the DLL
end;

end.
