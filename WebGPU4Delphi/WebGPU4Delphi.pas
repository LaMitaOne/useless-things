unit WebGPU4Delphi;

// Force 8-byte alignment for records to match the C-ABI used by the wgpu_native.dll.
// This ensures that Delphi's memory layout matches exactly what the C-library expects.
{$ALIGN 8}
{$MINENUMSIZE 4}

interface

uses
  System.SysUtils;

type
  // Base WebGPU Types (Opaque pointers representing GPU objects)
  WGPUBool = UInt32;
  WGPUFlags = UInt64;

  WGPUAdapter = type Pointer;
  WGPUBindGroup = type Pointer;
  WGPUBindGroupLayout = type Pointer;
  WGPUBuffer = type Pointer;
  WGPUCommandBuffer = type Pointer;
  WGPUCommandEncoder = type Pointer;
  WGPUComputePassEncoder = type Pointer;
  WGPUComputePipeline = type Pointer;
  WGPUDevice = type Pointer;
  WGPUInstance = type Pointer;
  WGPUPipelineLayout = type Pointer;
  WGPUQuerySet = type Pointer;
  WGPUQueue = type Pointer;
  WGPURenderBundle = type Pointer;
  WGPURenderBundleEncoder = type Pointer;
  WGPURenderPassEncoder = type Pointer;
  WGPURenderPipeline = type Pointer;
  WGPUSampler = type Pointer;
  WGPUShaderModule = type Pointer;
  WGPUSurface = type Pointer;
  WGPUTexture = type Pointer;
  WGPUTextureView = type Pointer;

  // WebGPU uses StringViews (pointer + length) instead of null-terminated strings
  WGPUStringView = record
    Data: PAnsiChar;
    Length: NativeUInt;
  end;

  // Enumerations representing WebGPU constants
  WGPUSType = (
    WGPUSType_Invalid = $00000000,
    WGPUSType_ShaderSourceWGSL = $00000002,
    WGPUSType_SurfaceSourceWindowsHWND = $00000005
  );

  // Chained structs are used by WebGPU to extend base descriptors.
  // IMPORTANT: Using a typed pointer prevents Delphi from adding padding.
  WGPUChainedStruct = record
    Next: ^WGPUChainedStruct;
    SType: WGPUSType;
  end;

  WGPUCallbackMode = (WGPUCallbackMode_AllowProcessEvents = $00000002);
  WGPUBackendType = (WGPUBackendType_Undefined = $00000000);
  WGPUFeatureLevel = (WGPUFeatureLevel_Core = $00000002);
  WGPUPowerPreference = (WGPUPowerPreference_HighPerformance = $00000002);
  WGPURequestAdapterStatus = (WGPURequestAdapterStatus_Success = $00000001);
  WGPURequestDeviceStatus = (WGPURequestDeviceStatus_Success = $00000001);

  // Supported Texture Formats
  WGPUTextureFormat = (
    WGPUTextureFormat_BGRA8Unorm = $00000017, // Standard 8-bit color format for Windows surfaces
    WGPUTextureFormat_Depth32Float = $0000002A // 32-bit float format used for depth buffers
  );

  WGPUPresentMode = (WGPUPresentMode_Fifo = $00000001); // V-Sync mode
  WGPULoadOp = (WGPULoadOp_Clear = $00000002, WGPULoadOp_Load = $00000001);
  WGPUStoreOp = (WGPUStoreOp_Store = $00000001, WGPUStoreOp_Discard = $00000002);
  WGPUTextureViewDimension = (WGPUTextureViewDimension_2D = $00000002);
  WGPUTextureAspect = (WGPUTextureAspect_All = $00000001, WGPUTextureAspect_DepthOnly = $00000003);
  WGPUVertexStepMode = (WGPUVertexStepMode_Vertex = $00000002);
  WGPUVertexFormat = (WGPUVertexFormat_Float32x3 = $0000001E); // Vector of 3 floats
  WGPUPrimitiveTopology = (WGPUPrimitiveTopology_TriangleList = $00000004);
  WGPUFrontFace = (WGPUFrontFace_CCW = $00000001); // Counter-Clockwise winding
  WGPUCullMode = (WGPUCullMode_Back = $00000003);  // Cull back-facing triangles
  WGPUCompareFunction = (WGPUCompareFunction_Less = $00000002);
  WGPUIndexFormat = (WGPUIndexFormat_Uint16 = $00000001);
  WGPUBufferUsage = type WGPUFlags;

const
  // Buffer usage flags. Used when creating buffers to tell the GPU how they will be used.
  WGPUBufferUsage_Vertex = $0000000000000020;
  WGPUBufferUsage_Index  = $0000000000000010;
  WGPUBufferUsage_CopyDst = $0000000000000008; // CPU can write data to this buffer
  WGPUBufferUsage_Uniform = $0000000000000040;
  WGPUTextureUsage_RenderAttachment = $0000000000000010; // Texture can be rendered to (used as a target)

type
  // WebGPU Capability Descriptors
  WGPUInstanceCapabilities = record
    NextInChain: ^WGPUChainedStruct;
    TimedWaitAnyEnable: WGPUBool;
    TimedWaitAnyMaxCount: NativeUInt;
  end;

  WGPUInstanceDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Capabilities: WGPUInstanceCapabilities;
  end;

  // Options used when requesting a physical GPU Adapter
  WGPURequestAdapterOptions = record
    NextInChain: ^WGPUChainedStruct;
    FeatureLevel: WGPUFeatureLevel;
    PowerPreference: WGPUPowerPreference;
    ForceFallbackAdapter: WGPUBool;
    BackendType: WGPUBackendType;
    CompatibleSurface: WGPUSurface;
  end;

  WGPUQueueDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView; // Label for debugging
  end;

  // Descriptor for creating a logical Device
  WGPUDeviceDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
    RequiredFeatureCount: NativeUInt;
    RequiredFeatures: ^UInt32;
    RequiredLimits: Pointer;
    DefaultQueue: WGPUQueueDescriptor;
    DeviceLostCallbackInfo: Pointer;
    UncapturedErrorCallbackInfo: Pointer;
  end;

  // Callback definitions for asynchronous Adapter/Device requests
  WGPURequestAdapterCallback = procedure(Status: WGPURequestAdapterStatus;
    Adapter: WGPUAdapter; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;
  WGPURequestDeviceCallback = procedure(Status: WGPURequestDeviceStatus;
    Device: WGPUDevice; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;

  // Info structs passed to the request functions containing the callback pointer
  WGPURequestAdapterCallbackInfo = record
    NextInChain: ^WGPUChainedStruct;
    Mode: WGPUCallbackMode;
    Callback: WGPURequestAdapterCallback;
    Userdata1: Pointer;
    Userdata2: Pointer;
  end;

  WGPURequestDeviceCallbackInfo = record
    NextInChain: ^WGPUChainedStruct;
    Mode: WGPUCallbackMode;
    Callback: WGPURequestDeviceCallback;
    Userdata1: Pointer;
    Userdata2: Pointer;
  end;

  // Surface creation struct specifically for Windows (uses HWND)
  WGPUSurfaceSourceWindowsHWND = record
    Chain: WGPUChainedStruct;
    Hinstance: Pointer;
    Hwnd: Pointer;
  end;

  WGPUSurfaceDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
  end;

  // Configuration for the Swap Chain (Surface)
  WGPUSurfaceConfiguration = record
    NextInChain: ^WGPUChainedStruct;
    Device: WGPUDevice;
    Format: WGPUTextureFormat;
    Usage: WGPUFlags;
    Width: UInt32;
    Height: UInt32;
    ViewFormatCount: NativeUInt;
    ViewFormats: ^WGPUTextureFormat;
    AlphaMode: UInt32;
    PresentMode: WGPUPresentMode;
  end;

  WGPUSurfaceGetCurrentTextureStatus = (WGPUSurfaceGetCurrentTextureStatus_SuccessOptimal = $00000001);

  // Holds the texture retrieved from the surface before drawing
  WGPUSurfaceTexture = record
    NextInChain: ^WGPUChainedStruct;
    Texture: WGPUTexture;
    Status: WGPUSurfaceGetCurrentTextureStatus;
  end;

  WGPUColor = record
    R, G, B, A: Double;
  end;

  // Attachment defining what happens to the color buffer during a render pass
  WGPURenderPassColorAttachment = record
    NextInChain: ^WGPUChainedStruct;
    View: WGPUTextureView;
    DepthSlice: UInt32;
    ResolveTarget: WGPUTextureView;
    LoadOp: WGPULoadOp;   // What to do at the start (Clear or Load)
    StoreOp: WGPUStoreOp; // What to do at the end (Store or Discard)
    ClearValue: WGPUColor;// Color to clear to
  end;

  // Attachment defining what happens to the depth buffer during a render pass
  WGPURenderPassDepthStencilAttachment = record
    View: WGPUTextureView;
    DepthLoadOp: WGPULoadOp;
    DepthStoreOp: WGPUStoreOp;
    DepthClearValue: Single; // Usually 1.0 (far plane)
    DepthReadOnly: WGPUBool;
    StencilLoadOp: WGPULoadOp;
    StencilStoreOp: WGPUStoreOp;
    StencilClearValue: UInt32;
    StencilReadOnly: WGPUBool;
  end;

  WGPURenderPassDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
    ColorAttachmentCount: NativeUInt;
    ColorAttachments: ^WGPURenderPassColorAttachment;
    DepthStencilAttachment: ^WGPURenderPassDepthStencilAttachment;
    OcclusionQuerySet: WGPUQuerySet;
    TimestampWrites: Pointer;
  end;

  WGPUTextureViewDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
    Format: WGPUTextureFormat;
    Dimension: WGPUTextureViewDimension;
    BaseMipLevel: UInt32;
    MipLevelCount: UInt32;
    BaseArrayLayer: UInt32;
    ArrayLayerCount: UInt32;
    Aspect: WGPUTextureAspect;
    Usage: WGPUFlags;
  end;

  // 3D Extent struct for texture sizes
  WGPUExtent3D = record
    Width: UInt32;
    Height: UInt32;
    DepthOrArrayLayers: UInt32;
  end;

  WGPUTextureDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
    Usage: WGPUFlags;
    Dimension: UInt32;
    Size: WGPUExtent3D;
    Format: WGPUTextureFormat;
    MipLevelCount: UInt32;
    SampleCount: UInt32;
    ViewFormatCount: NativeUInt;
    ViewFormats: ^WGPUTextureFormat;
  end;

  WGPUCommandEncoderDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
  end;

  WGPUBufferDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
    Usage: WGPUBufferUsage;
    Size: UInt64;
    MappedAtCreation: WGPUBool;
  end;

  // Struct to pass WGSL code to the shader module creation
  WGPUShaderSourceWGSL = record
    Chain: WGPUChainedStruct;
    Code: WGPUStringView;
  end;

  WGPUShaderModuleDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
  end;

// IMPORTANT: Turn off Delphi's automatic alignment for vertex structs.
// The C-API expects these fields to be tightly packed without padding bytes.
{$A-}
  WGPUVertexAttribute = record
    Format: WGPUVertexFormat;
    Offset: UInt64;
    ShaderLocation: UInt32;
  end;

  WGPUVertexBufferLayout = record
    StepMode: WGPUVertexStepMode;
    ArrayStride: UInt64;
    AttributeCount: NativeUInt;
    Attributes: ^WGPUVertexAttribute;
  end;
{$A+}

  // Pipeline state structs
  WGPUVertexState = record
    NextInChain: ^WGPUChainedStruct;
    Module: WGPUShaderModule;
    EntryPoint: WGPUStringView;
    ConstantCount: NativeUInt;
    Constants: Pointer;
    BufferCount: NativeUInt;
    Buffers: ^WGPUVertexBufferLayout;
  end;

  WGPUPrimitiveState = record
    NextInChain: ^WGPUChainedStruct;
    Topology: WGPUPrimitiveTopology;
    StripIndexFormat: WGPUIndexFormat;
    FrontFace: WGPUFrontFace;
    CullMode: WGPUCullMode;
    UnclippedDepth: WGPUBool;
  end;

  WGPUStencilFaceState = record
    Compare: WGPUCompareFunction;
    FailOp: UInt32;
    DepthFailOp: UInt32;
    PassOp: UInt32;
  end;

  WGPUDepthStencilState = record
    NextInChain: ^WGPUChainedStruct;
    Format: WGPUTextureFormat;
    DepthWriteEnabled: WGPUBool;
    DepthCompare: WGPUCompareFunction;
    StencilFront: WGPUStencilFaceState;
    StencilBack: WGPUStencilFaceState;
    StencilReadMask: UInt32;
    StencilWriteMask: UInt32;
    DepthBias: Int32;
    DepthBiasSlopeScale: Single;
    DepthBiasClamp: Single;
  end;

  WGPUMultisampleState = record
    NextInChain: ^WGPUChainedStruct;
    Count: UInt32;
    Mask: UInt32;
    AlphaToCoverageEnabled: WGPUBool;
  end;

  WGPUColorTargetState = record
    NextInChain: ^WGPUChainedStruct;
    Format: WGPUTextureFormat;
    Blend: Pointer;
    WriteMask: WGPUFlags;
  end;

  WGPUFragmentState = record
    NextInChain: ^WGPUChainedStruct;
    Module: WGPUShaderModule;
    EntryPoint: WGPUStringView;
    ConstantCount: NativeUInt;
    Constants: Pointer;
    TargetCount: NativeUInt;
    Targets: ^WGPUColorTargetState;
  end;

  // The master descriptor for creating a Render Pipeline
  WGPURenderPipelineDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
    Layout: WGPUPipelineLayout;
    Vertex: WGPUVertexState;
    Primitive: WGPUPrimitiveState;
    DepthStencil: ^WGPUDepthStencilState;
    Multisample: WGPUMultisampleState;
    Fragment: ^WGPUFragmentState;
  end;

// -----------------------------------------------------------------------------
// DYNAMICALLY IMPORTED WEBGPU FUNCTIONS
// These function pointers are loaded from wgpu_native.dll at runtime.
// -----------------------------------------------------------------------------
var
  wgpuCreateInstance: function(const Descriptor: WGPUInstanceDescriptor): WGPUInstance; cdecl;
  wgpuInstanceRequestAdapter: procedure(Instance: WGPUInstance; const Options: WGPURequestAdapterOptions; const CallbackInfo: WGPURequestAdapterCallbackInfo); cdecl;
  wgpuInstanceRelease: procedure(Instance: WGPUInstance); cdecl;
  wgpuInstanceProcessEvents: procedure(Instance: WGPUInstance); cdecl;
  wgpuInstanceCreateSurface: function(Instance: WGPUInstance; const Descriptor: WGPUSurfaceDescriptor): WGPUSurface; cdecl;

  wgpuAdapterRelease: procedure(Adapter: WGPUAdapter); cdecl;
  wgpuAdapterRequestDevice: procedure(Adapter: WGPUAdapter; const Descriptor: WGPUDeviceDescriptor; const CallbackInfo: WGPURequestDeviceCallbackInfo); cdecl;
  wgpuDeviceRelease: procedure(Device: WGPUDevice); cdecl;
  wgpuDeviceGetQueue: function(Device: WGPUDevice): WGPUQueue; cdecl;
  wgpuDeviceCreateCommandEncoder: function(Device: WGPUDevice; Descriptor: Pointer): WGPUCommandEncoder; cdecl;
  wgpuDeviceCreateBuffer: function(Device: WGPUDevice; const Descriptor: WGPUBufferDescriptor): WGPUBuffer; cdecl;
  wgpuDeviceCreateShaderModule: function(Device: WGPUDevice; const Descriptor: WGPUShaderModuleDescriptor): WGPUShaderModule; cdecl;

  wgpuDeviceCreateRenderPipeline: function(Device: WGPUDevice; const Descriptor: WGPURenderPipelineDescriptor): WGPURenderPipeline; cdecl;
  wgpuDeviceCreateTexture: function(Device: WGPUDevice; const Descriptor: WGPUTextureDescriptor): WGPUTexture; cdecl;

  wgpuQueueRelease: procedure(Queue: WGPUQueue); cdecl;
  wgpuQueueSubmit: procedure(Queue: WGPUQueue; CommandCount: NativeUInt; const Commands: WGPUCommandBuffer); cdecl;
  wgpuQueueWriteBuffer: procedure(Queue: WGPUQueue; Buffer: WGPUBuffer; BufferOffset: UInt64; Data: Pointer; Size: NativeUInt); cdecl;

  wgpuSurfaceRelease: procedure(Surface: WGPUSurface); cdecl;
  wgpuSurfaceConfigure: procedure(Surface: WGPUSurface; const Config: WGPUSurfaceConfiguration); cdecl;
  wgpuSurfaceUnconfigure: procedure(Surface: WGPUSurface); cdecl;
  wgpuSurfaceGetCurrentTexture: procedure(Surface: WGPUSurface; var SurfaceTexture: WGPUSurfaceTexture); cdecl;
  wgpuSurfacePresent: procedure(Surface: WGPUSurface); cdecl;

  wgpuTextureCreateView: function(Texture: WGPUTexture; Descriptor: Pointer): WGPUTextureView; cdecl;
  wgpuTextureRelease: procedure(Texture: WGPUTexture); cdecl;
  wgpuTextureViewRelease: procedure(TextureView: WGPUTextureView); cdecl;

  wgpuCommandEncoderBeginRenderPass: function(Encoder: WGPUCommandEncoder; Descriptor: Pointer): WGPURenderPassEncoder; cdecl;
  wgpuCommandEncoderFinish: function(Encoder: WGPUCommandEncoder; Descriptor: Pointer): WGPUCommandBuffer; cdecl;
  wgpuCommandEncoderRelease: procedure(Encoder: WGPUCommandEncoder); cdecl;
  wgpuCommandBufferRelease: procedure(CommandBuffer: WGPUCommandBuffer); cdecl;

  wgpuRenderPassEncoderEnd: procedure(RenderPassEncoder: WGPURenderPassEncoder); cdecl;
  wgpuRenderPassEncoderRelease: procedure(RenderPassEncoder: WGPURenderPassEncoder); cdecl;
  wgpuRenderPassEncoderSetPipeline: procedure(RenderPassEncoder: WGPURenderPassEncoder; Pipeline: WGPURenderPipeline); cdecl;
  wgpuRenderPassEncoderSetVertexBuffer: procedure(RenderPassEncoder: WGPURenderPassEncoder; Slot: UInt32; Buffer: WGPUBuffer; Offset: UInt64; Size: UInt64); cdecl;
  wgpuRenderPassEncoderSetIndexBuffer: procedure(RenderPassEncoder: WGPURenderPassEncoder; Buffer: WGPUBuffer; Format: WGPUIndexFormat; Offset: UInt64; Size: UInt64); cdecl;
  wgpuRenderPassEncoderDrawIndexed: procedure(RenderPassEncoder: WGPURenderPassEncoder; IndexCount: UInt32; InstanceCount: UInt32; FirstIndex: UInt32; BaseVertex: Int32; FirstInstance: UInt32); cdecl;

  wgpuBufferRelease: procedure(Buffer: WGPUBuffer); cdecl;
  wgpuShaderModuleRelease: procedure(ShaderModule: WGPUShaderModule); cdecl;
  wgpuRenderPipelineRelease: procedure(Pipeline: WGPURenderPipeline); cdecl;

// Public functions to load/unload the DLL
function InitWebGPU(const DllPath: string = 'wgpu_native.dll'): Boolean;
procedure ReleaseWebGPU;

implementation

uses
  Winapi.Windows;

var
  WebGPUHandle: THandle = 0;

// Helper function to dynamically load a function pointer from the DLL
function LoadProc(const Name: AnsiString): Pointer;
begin
  Result := GetProcAddress(WebGPUHandle, PAnsiChar(Name));
  if not Assigned(Result) then
    raise Exception.CreateFmt('WebGPU Funktion %s nicht in DLL gefunden!', [Name]);
end;

// Loads the wgpu_native.dll and binds all the imported functions
function InitWebGPU(const DllPath: string = 'wgpu_native.dll'): Boolean;
begin
  if WebGPUHandle <> 0 then Exit(True); // Already loaded
  WebGPUHandle := LoadLibrary(PChar(DllPath));
  Result := WebGPUHandle <> 0;
  if not Result then Exit;

  try
    // Instance
    @wgpuCreateInstance := LoadProc('wgpuCreateInstance');
    @wgpuInstanceRequestAdapter := LoadProc('wgpuInstanceRequestAdapter');
    @wgpuInstanceRelease := LoadProc('wgpuInstanceRelease');
    @wgpuInstanceProcessEvents := LoadProc('wgpuInstanceProcessEvents');
    @wgpuInstanceCreateSurface := LoadProc('wgpuInstanceCreateSurface');

    // Adapter
    @wgpuAdapterRelease := LoadProc('wgpuAdapterRelease');
    @wgpuAdapterRequestDevice := LoadProc('wgpuAdapterRequestDevice');

    // Device
    @wgpuDeviceRelease := LoadProc('wgpuDeviceRelease');
    @wgpuDeviceGetQueue := LoadProc('wgpuDeviceGetQueue');
    @wgpuDeviceCreateCommandEncoder := LoadProc('wgpuDeviceCreateCommandEncoder');
    @wgpuDeviceCreateBuffer := LoadProc('wgpuDeviceCreateBuffer');
    @wgpuDeviceCreateShaderModule := LoadProc('wgpuDeviceCreateShaderModule');
    @wgpuDeviceCreateRenderPipeline := LoadProc('wgpuDeviceCreateRenderPipeline');
    @wgpuDeviceCreateTexture := LoadProc('wgpuDeviceCreateTexture');

    // Queue
    @wgpuQueueRelease := LoadProc('wgpuQueueRelease');
    @wgpuQueueSubmit := LoadProc('wgpuQueueSubmit');
    @wgpuQueueWriteBuffer := LoadProc('wgpuQueueWriteBuffer');

    // Surface
    @wgpuSurfaceRelease := LoadProc('wgpuSurfaceRelease');
    @wgpuSurfaceConfigure := LoadProc('wgpuSurfaceConfigure');
    @wgpuSurfaceUnconfigure := LoadProc('wgpuSurfaceUnconfigure');
    @wgpuSurfaceGetCurrentTexture := LoadProc('wgpuSurfaceGetCurrentTexture');
    @wgpuSurfacePresent := LoadProc('wgpuSurfacePresent');

    // Texture
    @wgpuTextureCreateView := LoadProc('wgpuTextureCreateView');
    @wgpuTextureRelease := LoadProc('wgpuTextureRelease');
    @wgpuTextureViewRelease := LoadProc('wgpuTextureViewRelease');

    // Command Encoder
    @wgpuCommandEncoderBeginRenderPass := LoadProc('wgpuCommandEncoderBeginRenderPass');
    @wgpuCommandEncoderFinish := LoadProc('wgpuCommandEncoderFinish');
    @wgpuCommandEncoderRelease := LoadProc('wgpuCommandEncoderRelease');
    @wgpuCommandBufferRelease := LoadProc('wgpuCommandBufferRelease');

    // Render Pass Encoder
    @wgpuRenderPassEncoderEnd := LoadProc('wgpuRenderPassEncoderEnd');
    @wgpuRenderPassEncoderRelease := LoadProc('wgpuRenderPassEncoderRelease');
    @wgpuRenderPassEncoderSetPipeline := LoadProc('wgpuRenderPassEncoderSetPipeline');
    @wgpuRenderPassEncoderSetVertexBuffer := LoadProc('wgpuRenderPassEncoderSetVertexBuffer');
    @wgpuRenderPassEncoderSetIndexBuffer := LoadProc('wgpuRenderPassEncoderSetIndexBuffer');
    @wgpuRenderPassEncoderDrawIndexed := LoadProc('wgpuRenderPassEncoderDrawIndexed');

    // Resource Release
    @wgpuBufferRelease := LoadProc('wgpuBufferRelease');
    @wgpuShaderModuleRelease := LoadProc('wgpuShaderModuleRelease');
    @wgpuRenderPipelineRelease := LoadProc('wgpuRenderPipelineRelease');
  except
    on E: Exception do
    begin
      FreeLibrary(WebGPUHandle);
      WebGPUHandle := 0;
      raise;
    end;
  end;
end;

// Unloads the DLL
procedure ReleaseWebGPU;
begin
  if WebGPUHandle <> 0 then
  begin
    FreeLibrary(WebGPUHandle);
    WebGPUHandle := 0;
  end;
end;

end.
