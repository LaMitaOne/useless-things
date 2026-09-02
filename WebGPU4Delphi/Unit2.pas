unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, WebGPU4Delphi, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FInstance: WGPUInstance;
    FAdapter: WGPUAdapter;
    FDevice: WGPUDevice;
    FQueue: WGPUQueue;
    FSurface: WGPUSurface;
    procedure InitWebGPUContext;
    procedure ReleaseWebGPUContext;
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

  // Wir laden die Render-Funktionen lokal, damit es stabil bleibt
  wgpuDeviceCreateCommandEncoder: function(Device: WGPUDevice; const Descriptor: Pointer): WGPUCommandEncoder; cdecl;
  wgpuCommandEncoderBeginRenderPass: function(Encoder: WGPUCommandEncoder; const Descriptor: Pointer): WGPURenderPassEncoder; cdecl;
  wgpuRenderPassEncoderEnd: procedure(RenderPassEncoder: WGPURenderPassEncoder); cdecl;
  wgpuRenderPassEncoderRelease: procedure(RenderPassEncoder: WGPURenderPassEncoder); cdecl;
  wgpuCommandEncoderFinish: function(Encoder: WGPUCommandEncoder; const Descriptor: Pointer): WGPUCommandBuffer; cdecl;
  wgpuCommandEncoderRelease: procedure(Encoder: WGPUCommandEncoder); cdecl;
  wgpuQueueSubmit: procedure(Queue: WGPUQueue; CommandCount: NativeUInt; const Commands: WGPUCommandBuffer); cdecl;
  wgpuCommandBufferRelease: procedure(CommandBuffer: WGPUCommandBuffer); cdecl;
  wgpuTextureRelease: procedure(Texture: WGPUTexture); cdecl;
  wgpuTextureCreateView: function(Texture: WGPUTexture; const Descriptor: Pointer): WGPUTextureView; cdecl;
  wgpuTextureViewRelease: procedure(TextureView: WGPUTextureView); cdecl;

implementation

{$R *.dfm}

var
  FCallbackAdapter: WGPUAdapter = nil;
  FCallbackDevice: WGPUDevice = nil;

procedure AdapterRequestCallback(Status: WGPURequestAdapterStatus;
  Adapter: WGPUAdapter; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;
begin
  if Status = WGPURequestAdapterStatus_Success then
    FCallbackAdapter := Adapter;
end;

procedure DeviceRequestCallback(Status: WGPURequestDeviceStatus;
  Device: WGPUDevice; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;
begin
  if Status = WGPURequestDeviceStatus_Success then
    FCallbackDevice := Device;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  hLib: THandle;
begin
  // Render-Funktionen lokal laden
  hLib := GetModuleHandle('wgpu_native.dll');
  if hLib <> 0 then
  begin
    @wgpuDeviceCreateCommandEncoder := GetProcAddress(hLib, 'wgpuDeviceCreateCommandEncoder');
    @wgpuCommandEncoderBeginRenderPass := GetProcAddress(hLib, 'wgpuCommandEncoderBeginRenderPass');
    @wgpuRenderPassEncoderEnd := GetProcAddress(hLib, 'wgpuRenderPassEncoderEnd');
    @wgpuRenderPassEncoderRelease := GetProcAddress(hLib, 'wgpuRenderPassEncoderRelease');
    @wgpuCommandEncoderFinish := GetProcAddress(hLib, 'wgpuCommandEncoderFinish');
    @wgpuCommandEncoderRelease := GetProcAddress(hLib, 'wgpuCommandEncoderRelease');
    @wgpuQueueSubmit := GetProcAddress(hLib, 'wgpuQueueSubmit');
    @wgpuCommandBufferRelease := GetProcAddress(hLib, 'wgpuCommandBufferRelease');
    @wgpuTextureRelease := GetProcAddress(hLib, 'wgpuTextureRelease');
    @wgpuTextureCreateView := GetProcAddress(hLib, 'wgpuTextureCreateView');
    @wgpuTextureViewRelease := GetProcAddress(hLib, 'wgpuTextureViewRelease');
  end;

  InitWebGPUContext;
end;

procedure TForm2.InitWebGPUContext;
var
  InstanceDesc: WGPUInstanceDescriptor;
  InstanceExtras: WGPUInstanceExtras;
  AdapterOptions: WGPURequestAdapterOptions;
  DeviceDesc: WGPUDeviceDescriptor;
  AdapterCBInfo: WGPURequestAdapterCallbackInfo;
  DeviceCBInfo: WGPURequestDeviceCallbackInfo;

  SurfaceDesc: WGPUSurfaceDescriptor;
  SurfaceSource: WGPUSurfaceSourceWindowsHWND;
  SurfaceConfig: WGPUSurfaceConfiguration;
begin
  if not InitWebGPU then
  begin
    ShowMessage('WebGPU DLL konnte nicht geladen werden!');
    Exit;
  end;

  // 1. Instance
  FillChar(InstanceExtras, SizeOf(InstanceExtras), 0);
  InstanceExtras.Chain.SType := WGPUSType_InstanceExtras;
  InstanceExtras.Backends := WGPUInstanceBackend_Primary;

  FillChar(InstanceDesc, SizeOf(InstanceDesc), 0);
  InstanceDesc.NextInChain := @InstanceExtras;

  FInstance := wgpuCreateInstance(InstanceDesc);

  // 2. Adapter
  FillChar(AdapterOptions, SizeOf(AdapterOptions), 0);
  AdapterOptions.FeatureLevel := WGPUFeatureLevel_Core;
  AdapterOptions.PowerPreference := WGPUPowerPreference_HighPerformance;

  FillChar(AdapterCBInfo, SizeOf(AdapterCBInfo), 0);
  AdapterCBInfo.Mode := WGPUCallbackMode_AllowProcessEvents;
  AdapterCBInfo.Callback := AdapterRequestCallback;

  FCallbackAdapter := nil;
  wgpuInstanceRequestAdapter(FInstance, AdapterOptions, AdapterCBInfo);
  Application.ProcessMessages; Sleep(100); Application.ProcessMessages;
  FAdapter := FCallbackAdapter;

  // 3. Device
  FillChar(DeviceDesc, SizeOf(DeviceDesc), 0);
  FillChar(DeviceCBInfo, SizeOf(DeviceCBInfo), 0);
  DeviceCBInfo.Mode := WGPUCallbackMode_AllowProcessEvents;
  DeviceCBInfo.Callback := DeviceRequestCallback;

  FCallbackDevice := nil;
  wgpuAdapterRequestDevice(FAdapter, DeviceDesc, DeviceCBInfo);
  Application.ProcessMessages; Sleep(100); Application.ProcessMessages;
  FDevice := FCallbackDevice;
  FQueue := wgpuDeviceGetQueue(FDevice);

  // 4. Surface
  FillChar(SurfaceSource, SizeOf(SurfaceSource), 0);
  SurfaceSource.Chain.SType := WGPUSType_SurfaceSourceWindowsHWND;
  SurfaceSource.Hinstance := Pointer(hInstance);
  SurfaceSource.Hwnd := Pointer(Self.Handle);

  FillChar(SurfaceDesc, SizeOf(SurfaceDesc), 0);
  SurfaceDesc.NextInChain := @SurfaceSource;
  FSurface := wgpuInstanceCreateSurface(FInstance, SurfaceDesc);

  // 5. Surface Konfigurieren
  FillChar(SurfaceConfig, SizeOf(SurfaceConfig), 0);
  SurfaceConfig.Device := FDevice;
  SurfaceConfig.Format := WGPUTextureFormat_BGRA8Unorm;
  SurfaceConfig.Usage := $0000000000000010;
  SurfaceConfig.Width := ClientWidth;
  SurfaceConfig.Height := ClientHeight;
  SurfaceConfig.PresentMode := WGPUPresentMode_Fifo;

  wgpuSurfaceConfigure(FSurface, SurfaceConfig);

  ShowMessage('WebGPU ist bereit! Klicke Button2 zum Rendern.');
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  SurfaceTexture: WGPUSurfaceTexture;
begin
  if FSurface = nil then Exit;

  // 1. Texture von der Surface holen
  wgpuSurfaceGetCurrentTexture(FSurface, SurfaceTexture);

  if SurfaceTexture.Texture = nil then
  begin
    ShowMessage('Konnte keine Textur von der Surface holen!');
    Exit;
  end;

  // 2. Present (Textur auf den Bildschirm werfen)
  // Wir präsentieren die leere Textur. Das Fenster wird schwarz.
  wgpuSurfacePresent(FSurface);

  // WICHTIG: Kein wgpuTextureRelease hier!
  // Die Surface gibt die Textur im nächsten Frame automatisch frei.
  // Wenn wir sie freigeben, crasht es beim nächsten Present.
end;

procedure TForm2.ReleaseWebGPUContext;
begin
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
  ReleaseWebGPU;
end;

end.
