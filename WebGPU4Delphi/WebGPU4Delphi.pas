unit WebGPU4Delphi;

{$ALIGN 8}
{$MINENUMSIZE 4}

interface

uses
  System.SysUtils;

type
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

  WGPUStringView = record
    Data: PAnsiChar;
    Length: NativeUInt;
  end;

  WGPUSType = (
    WGPUSType_SurfaceSourceWindowsHWND = $00000005,
    WGPUSType_InstanceExtras = $00030006
  );

  WGPUCallbackMode = (
    WGPUCallbackMode_AllowProcessEvents = $00000002
  );

  WGPUBackendType = (
    WGPUBackendType_Undefined = $00000000
  );

  WGPUFeatureLevel = (
    WGPUFeatureLevel_Core = $00000002
  );

  WGPUPowerPreference = (
    WGPUPowerPreference_HighPerformance = $00000002
  );

  WGPURequestAdapterStatus = (
    WGPURequestAdapterStatus_Success = $00000001
  );

  WGPURequestDeviceStatus = (
    WGPURequestDeviceStatus_Success = $00000001
  );

  WGPUInstanceBackend = type WGPUFlags;

const
  WGPUInstanceBackend_Primary = $00000025;

type
  WGPUTextureFormat = (
    WGPUTextureFormat_BGRA8Unorm = $00000017
  );

  WGPUPresentMode = (
    WGPUPresentMode_Fifo = $00000001
  );

  WGPUChainedStruct = record
    Next: ^WGPUChainedStruct;
    SType: WGPUSType;
  end;

  WGPUInstanceExtras = record
    Chain: WGPUChainedStruct;
    Backends: WGPUInstanceBackend;
    Flags: WGPUFlags;
    Dx12ShaderCompiler: UInt32;
    Gles3MinorVersion: UInt32;
    DxilPath: WGPUStringView;
    DxcPath: WGPUStringView;
  end;

  WGPUInstanceDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Features: record
      NextInChain: ^WGPUChainedStruct;
      TimedWaitAnyEnable: WGPUBool;
      TimedWaitAnyMaxCount: NativeUInt;
    end;
  end;

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
    Lbl: WGPUStringView;
  end;

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

  WGPURequestAdapterCallback = procedure(Status: WGPURequestAdapterStatus;
    Adapter: WGPUAdapter; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;

  WGPURequestDeviceCallback = procedure(Status: WGPURequestDeviceStatus;
    Device: WGPUDevice; Msg: WGPUStringView; UserData1, UserData2: Pointer); cdecl;

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

  WGPUSurfaceSourceWindowsHWND = record
    Chain: WGPUChainedStruct;
    Hinstance: Pointer;
    Hwnd: Pointer;
  end;

  WGPUSurfaceDescriptor = record
    NextInChain: ^WGPUChainedStruct;
    Lbl: WGPUStringView;
  end;

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

  WGPUSurfaceTexture = record
    NextInChain: Pointer;
    Texture: WGPUTexture;
    Status: UInt32;
  end;

var
  wgpuCreateInstance: function(const Descriptor: WGPUInstanceDescriptor): WGPUInstance; cdecl;
  wgpuInstanceRequestAdapter: procedure(Instance: WGPUInstance;
    const Options: WGPURequestAdapterOptions;
    const CallbackInfo: WGPURequestAdapterCallbackInfo); cdecl;
  wgpuInstanceRelease: procedure(Instance: WGPUInstance); cdecl;
  wgpuAdapterRelease: procedure(Adapter: WGPUAdapter); cdecl;
  wgpuAdapterRequestDevice: procedure(Adapter: WGPUAdapter;
    const Descriptor: WGPUDeviceDescriptor;
    const CallbackInfo: WGPURequestDeviceCallbackInfo); cdecl;
  wgpuDeviceRelease: procedure(Device: WGPUDevice); cdecl;
  wgpuDeviceGetQueue: function(Device: WGPUDevice): WGPUQueue; cdecl;
  wgpuQueueRelease: procedure(Queue: WGPUQueue); cdecl;

  wgpuInstanceCreateSurface: function(Instance: WGPUInstance;
    const Descriptor: WGPUSurfaceDescriptor): WGPUSurface; cdecl;
  wgpuSurfaceRelease: procedure(Surface: WGPUSurface); cdecl;
  wgpuSurfaceConfigure: procedure(Surface: WGPUSurface;
    const Config: WGPUSurfaceConfiguration); cdecl;
  wgpuSurfaceUnconfigure: procedure(Surface: WGPUSurface); cdecl;
  wgpuSurfaceGetCurrentTexture: procedure(Surface: WGPUSurface;
    out SurfaceTexture: WGPUSurfaceTexture); cdecl;
  wgpuSurfacePresent: procedure(Surface: WGPUSurface); cdecl;

function ToWGPUStringView(const S: string): WGPUStringView;
function InitWebGPU(const DllPath: string = 'wgpu_native.dll'): Boolean;
procedure ReleaseWebGPU;

implementation

uses
  Winapi.Windows;

var
  WebGPUHandle: THandle = 0;

function LoadProc(const Name: AnsiString): Pointer;
begin
  Result := GetProcAddress(WebGPUHandle, PAnsiChar(Name));
  if not Assigned(Result) then
    raise Exception.CreateFmt('WebGPU Funktion %s nicht in DLL gefunden!', [Name]);
end;

function ToWGPUStringView(const S: string): WGPUStringView;
var
  AnsiStr: AnsiString;
begin
  if S = '' then
  begin
    Result.Data := nil;
    Result.Length := 0;
  end
  else
  begin
    AnsiStr := AnsiString(S);
    Result.Data := PAnsiChar(AnsiStr);
    Result.Length := Length(AnsiStr);
  end;
end;

function InitWebGPU(const DllPath: string = 'wgpu_native.dll'): Boolean;
begin
  if WebGPUHandle <> 0 then Exit(True);

  WebGPUHandle := LoadLibrary(PChar(DllPath));
  Result := WebGPUHandle <> 0;
  if not Result then Exit;

  try
    @wgpuCreateInstance := LoadProc('wgpuCreateInstance');
    @wgpuInstanceRequestAdapter := LoadProc('wgpuInstanceRequestAdapter');
    @wgpuInstanceRelease := LoadProc('wgpuInstanceRelease');
    @wgpuAdapterRelease := LoadProc('wgpuAdapterRelease');
    @wgpuAdapterRequestDevice := LoadProc('wgpuAdapterRequestDevice');
    @wgpuDeviceRelease := LoadProc('wgpuDeviceRelease');
    @wgpuDeviceGetQueue := LoadProc('wgpuDeviceGetQueue');
    @wgpuQueueRelease := LoadProc('wgpuQueueRelease');

    @wgpuInstanceCreateSurface := LoadProc('wgpuInstanceCreateSurface');
    @wgpuSurfaceRelease := LoadProc('wgpuSurfaceRelease');
    @wgpuSurfaceConfigure := LoadProc('wgpuSurfaceConfigure');
    @wgpuSurfaceUnconfigure := LoadProc('wgpuSurfaceUnconfigure');
    @wgpuSurfaceGetCurrentTexture := LoadProc('wgpuSurfaceGetCurrentTexture');
    @wgpuSurfacePresent := LoadProc('wgpuSurfacePresent');
  except
    on E: Exception do
    begin
      FreeLibrary(WebGPUHandle);
      WebGPUHandle := 0;
      raise;
    end;
  end;
end;

procedure ReleaseWebGPU;
begin
  if WebGPUHandle <> 0 then
  begin
    FreeLibrary(WebGPUHandle);
    WebGPUHandle := 0;
  end;
end;

end.
