(*
  Copyright 2020 Akira13641
  License: http://www.opensource.org/licenses/BSD-2-Clause

  This unit contains a translation of the BGFX C99 API headers to Free Pascal / Delphi,
  and was partially automatically generated with Chet:
  https://github.com/neslib/Chet
*)

unit BGFX_Delphi;

{$MINENUMSIZE 4}
{$ALIGN 8} // Wichtig für C/C++ Kompatibilität bei Records auf 64-Bit

interface

const
  {$IF Defined(MSWINDOWS)}
    BGFX_LIB_NAME = 'bgfx-shared-libRelease.dll';
  {$ELSEIF Defined(LINUX)}
    BGFX_LIB_NAME = 'libbgfx-shared-libRelease.so';
  {$ELSEIF Defined(MACOS) or Defined(DARWIN)}
    BGFX_LIB_NAME = 'libbgfx-shared-libRelease.dylib';
  {$IFEND}

const
  BGFX_API_VERSION = UInt32(115);
  (*
   * Color RGB/alpha/depth write. When it's not specified write will be disabled.
   *)
  // Enable R write.
  BGFX_STATE_WRITE_R = $0000000000000001;
  // Enable G write.
  BGFX_STATE_WRITE_G = $0000000000000002;
  // Enable B write.
  BGFX_STATE_WRITE_B = $0000000000000004;
  // Enable alpha write.
  BGFX_STATE_WRITE_A = $0000000000000008;
  // Enable depth write.
  BGFX_STATE_WRITE_Z = $0000004000000000;
  // Enable RGB write.
  BGFX_STATE_WRITE_RGB = (0 or BGFX_STATE_WRITE_R or BGFX_STATE_WRITE_G or BGFX_STATE_WRITE_B);
  // Write all channels mask.
  BGFX_STATE_WRITE_MASK = (0 or BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_A or BGFX_STATE_WRITE_Z);
  (*
   * Depth test state. When `BGFX_STATE_DEPTH_` is not specified depth test will
   * be disabled.
   *)
  // Enable depth test, less.
  BGFX_STATE_DEPTH_TEST_LESS = $0000000000000010;
  // Enable depth test, less or equal.
  BGFX_STATE_DEPTH_TEST_LEQUAL = $0000000000000020;
  // Enable depth test, equal.
  BGFX_STATE_DEPTH_TEST_EQUAL = $0000000000000030;
  // Enable depth test, greater or equal.
  BGFX_STATE_DEPTH_TEST_GEQUAL = $0000000000000040;
  // Enable depth test, greater.
  BGFX_STATE_DEPTH_TEST_GREATER = $0000000000000050;
  // Enable depth test, not equal.
  BGFX_STATE_DEPTH_TEST_NOTEQUAL = $0000000000000060;
  // Enable depth test, never.
  BGFX_STATE_DEPTH_TEST_NEVER = $0000000000000070;
  // Enable depth test, always.
  BGFX_STATE_DEPTH_TEST_ALWAYS = $0000000000000080;
  // Depth test state bit shift
  BGFX_STATE_DEPTH_TEST_SHIFT = 4;
  // Depth test state bit mask
  BGFX_STATE_DEPTH_TEST_MASK = $00000000000000f0;
  // 0, 0, 0, 0
  BGFX_STATE_BLEND_ZERO = $0000000000001000;
  // 1, 1, 1, 1
  BGFX_STATE_BLEND_ONE = $0000000000002000;
  // Rs, Gs, Bs, As
  BGFX_STATE_BLEND_SRC_COLOR = $0000000000003000;
  // 1-Rs, 1-Gs, 1-Bs, 1-As
  BGFX_STATE_BLEND_INV_SRC_COLOR = $0000000000004000;
  // As, As, As, As
  BGFX_STATE_BLEND_SRC_ALPHA = $0000000000005000;
  // 1-As, 1-As, 1-As, 1-As
  BGFX_STATE_BLEND_INV_SRC_ALPHA = $0000000000006000;
  // Ad, Ad, Ad, Ad
  BGFX_STATE_BLEND_DST_ALPHA = $0000000000007000;
  // 1-Ad, 1-Ad, 1-Ad ,1-Ad
  BGFX_STATE_BLEND_INV_DST_ALPHA = $0000000000008000;
  // Rd, Gd, Bd, Ad
  BGFX_STATE_BLEND_DST_COLOR = $0000000000009000;
  // 1-Rd, 1-Gd, 1-Bd, 1-Ad
  BGFX_STATE_BLEND_INV_DST_COLOR = $000000000000a000;
  // f, f, f, 1; f = min(As, 1-Ad)
  BGFX_STATE_BLEND_SRC_ALPHA_SAT = $000000000000b000;
  // Blend factor
  BGFX_STATE_BLEND_FACTOR = $000000000000c000;
  // 1-Blend factor
  BGFX_STATE_BLEND_INV_FACTOR = $000000000000d000;
  // Blend state bit shift
  BGFX_STATE_BLEND_SHIFT = 12;
  // Blend state bit mask
  BGFX_STATE_BLEND_MASK = $000000000ffff000;
  // Blend add: src + dst.
  BGFX_STATE_BLEND_EQUATION_ADD = $0000000000000000;
  // Blend subtract: src - dst.
  BGFX_STATE_BLEND_EQUATION_SUB = $0000000010000000;
  // Blend reverse subtract: dst - src.
  BGFX_STATE_BLEND_EQUATION_REVSUB = $0000000020000000;
  // Blend min: min(src, dst).
  BGFX_STATE_BLEND_EQUATION_MIN = $0000000030000000;
  // Blend max: max(src, dst).
  BGFX_STATE_BLEND_EQUATION_MAX = $0000000040000000;
  // Blend equation bit shift
  BGFX_STATE_BLEND_EQUATION_SHIFT = 28;
  // Blend equation bit mask
  BGFX_STATE_BLEND_EQUATION_MASK = $00000003f0000000;
  (*
   * Cull state. When `BGFX_STATE_CULL_*` is not specified culling will be
   * disabled.
   *)
  // Cull clockwise triangles.
  BGFX_STATE_CULL_CW = $0000001000000000;
  // Cull counter-clockwise triangles.
  BGFX_STATE_CULL_CCW = $0000002000000000;
  // Culling mode bit shift
  BGFX_STATE_CULL_SHIFT = 36;
  // Culling mode bit mask
  BGFX_STATE_CULL_MASK = $0000003000000000;
  (*
   * Alpha reference value.
   *)
  // Alpha reference bit shift
  BGFX_STATE_ALPHA_REF_SHIFT = 40;
  // Alpha reference bit mask
  BGFX_STATE_ALPHA_REF_MASK = $0000ff0000000000;
  // Tristrip.
  BGFX_STATE_PT_TRISTRIP = $0001000000000000;
  // Lines.
  BGFX_STATE_PT_LINES = $0002000000000000;
  // Line strip.
  BGFX_STATE_PT_LINESTRIP = $0003000000000000;
  // Points.
  BGFX_STATE_PT_POINTS = $0004000000000000;
  // Primitive type bit shift
  BGFX_STATE_PT_SHIFT = 48;
  // Primitive type bit mask
  BGFX_STATE_PT_MASK = $0007000000000000;
  (*
   * Point size value.
   *)
  // Point size bit shift
  BGFX_STATE_POINT_SIZE_SHIFT = 52;
  // Point size bit mask
  BGFX_STATE_POINT_SIZE_MASK = $00f0000000000000;
  (*
   * Enable MSAA write when writing into MSAA frame buffer.
   * This flag is ignored when not writing into MSAA frame buffer.
   *)
  // Enable MSAA rasterization.
  BGFX_STATE_MSAA = $0100000000000000;
  // Enable line AA rasterization.
  BGFX_STATE_LINEAA = $0200000000000000;
  // Enable conservative rasterization.
  BGFX_STATE_CONSERVATIVE_RASTER = $0400000000000000;
  // No state.
  BGFX_STATE_NONE = $0000000000000000;
  // Front counter-clockwise (default is clockwise).
  BGFX_STATE_FRONT_CCW = $0000008000000000;
  // Enable blend independent.
  BGFX_STATE_BLEND_INDEPENDENT = $0000000400000000;
  // Enable alpha to coverage.
  BGFX_STATE_BLEND_ALPHA_TO_COVERAGE = $0000000800000000;
  // Default state is write to RGB, alpha, and depth with depth test less enabled,
  // with clockwise culling and MSAA (when writing into MSAA frame buffer,
  // otherwise this flag is ignored).
  BGFX_STATE_DEFAULT = (0 or BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_A or
    BGFX_STATE_WRITE_Z or BGFX_STATE_DEPTH_TEST_LESS or BGFX_STATE_CULL_CW or BGFX_STATE_MSAA);
  // State bit mask
  BGFX_STATE_MASK = $ffffffffffffffff;
  (*
   * Do not use!
   *)
  BGFX_STATE_RESERVED_SHIFT = 61;
  BGFX_STATE_RESERVED_MASK = $e000000000000000;
  (*
   * Set stencil ref value.
   *)
  BGFX_STENCIL_FUNC_REF_SHIFT = 0;
  BGFX_STENCIL_FUNC_REF_MASK = $000000ff;
  (*
   * Set stencil rmask value.
   *)
  BGFX_STENCIL_FUNC_RMASK_SHIFT = 8;
  BGFX_STENCIL_FUNC_RMASK_MASK = $0000ff00;
  BGFX_STENCIL_NONE = $00000000;
  BGFX_STENCIL_MASK = $ffffffff;
  BGFX_STENCIL_DEFAULT = $00000000;
  // Enable stencil test, less.
  BGFX_STENCIL_TEST_LESS = $00010000;
  // Enable stencil test, less or equal.
  BGFX_STENCIL_TEST_LEQUAL = $00020000;
  // Enable stencil test, equal.
  BGFX_STENCIL_TEST_EQUAL = $00030000;
  // Enable stencil test, greater or equal.
  BGFX_STENCIL_TEST_GEQUAL = $00040000;
  // Enable stencil test, greater.
  BGFX_STENCIL_TEST_GREATER = $00050000;
  // Enable stencil test, not equal.
  BGFX_STENCIL_TEST_NOTEQUAL = $00060000;
  // Enable stencil test, never.
  BGFX_STENCIL_TEST_NEVER = $00070000;
  // Enable stencil test, always.
  BGFX_STENCIL_TEST_ALWAYS = $00080000;
  // Stencil test bit shift
  BGFX_STENCIL_TEST_SHIFT = 16;
  // Stencil test bit mask
  BGFX_STENCIL_TEST_MASK = $000f0000;
  // Zero.
  BGFX_STENCIL_OP_FAIL_S_ZERO = $00000000;
  // Keep.
  BGFX_STENCIL_OP_FAIL_S_KEEP = $00100000;
  // Replace.
  BGFX_STENCIL_OP_FAIL_S_REPLACE = $00200000;
  // Increment and wrap.
  BGFX_STENCIL_OP_FAIL_S_INCR = $00300000;
  // Increment and clamp.
  BGFX_STENCIL_OP_FAIL_S_INCRSAT = $00400000;
  // Decrement and wrap.
  BGFX_STENCIL_OP_FAIL_S_DECR = $00500000;
  // Decrement and clamp.
  BGFX_STENCIL_OP_FAIL_S_DECRSAT = $00600000;
  // Invert.
  BGFX_STENCIL_OP_FAIL_S_INVERT = $00700000;
  // Stencil operation fail bit shift
  BGFX_STENCIL_OP_FAIL_S_SHIFT = 20;
  // Stencil operation fail bit mask
  BGFX_STENCIL_OP_FAIL_S_MASK = $00f00000;
  // Zero.
  BGFX_STENCIL_OP_FAIL_Z_ZERO = $00000000;
  // Keep.
  BGFX_STENCIL_OP_FAIL_Z_KEEP = $01000000;
  // Replace.
  BGFX_STENCIL_OP_FAIL_Z_REPLACE = $02000000;
  // Increment and wrap.
  BGFX_STENCIL_OP_FAIL_Z_INCR = $03000000;
  // Increment and clamp.
  BGFX_STENCIL_OP_FAIL_Z_INCRSAT = $04000000;
  // Decrement and wrap.
  BGFX_STENCIL_OP_FAIL_Z_DECR = $05000000;
  // Decrement and clamp.
  BGFX_STENCIL_OP_FAIL_Z_DECRSAT = $06000000;
  // Invert.
  BGFX_STENCIL_OP_FAIL_Z_INVERT = $07000000;
  // Stencil operation depth fail bit shift
  BGFX_STENCIL_OP_FAIL_Z_SHIFT = 24;
  // Stencil operation depth fail bit mask
  BGFX_STENCIL_OP_FAIL_Z_MASK = $0f000000;
  // Zero.
  BGFX_STENCIL_OP_PASS_Z_ZERO = $00000000;
  // Keep.
  BGFX_STENCIL_OP_PASS_Z_KEEP = $10000000;
  // Replace.
  BGFX_STENCIL_OP_PASS_Z_REPLACE = $20000000;
  // Increment and wrap.
  BGFX_STENCIL_OP_PASS_Z_INCR = $30000000;
  // Increment and clamp.
  BGFX_STENCIL_OP_PASS_Z_INCRSAT = $40000000;
  // Decrement and wrap.
  BGFX_STENCIL_OP_PASS_Z_DECR = $50000000;
  // Decrement and clamp.
  BGFX_STENCIL_OP_PASS_Z_DECRSAT = $60000000;
  // Invert.
  BGFX_STENCIL_OP_PASS_Z_INVERT = $70000000;
  // Stencil operation depth pass bit shift
  BGFX_STENCIL_OP_PASS_Z_SHIFT = 28;
  // Stencil operation depth pass bit mask
  BGFX_STENCIL_OP_PASS_Z_MASK = $f0000000;
  // No clear flags.
  BGFX_CLEAR_NONE = $0000;
  // Clear color.
  BGFX_CLEAR_COLOR = $0001;
  // Clear depth.
  BGFX_CLEAR_DEPTH = $0002;
  // Clear stencil.
  BGFX_CLEAR_STENCIL = $0004;
  // Discard frame buffer attachment 0.
  BGFX_CLEAR_DISCARD_COLOR_0 = $0008;
  // Discard frame buffer attachment 1.
  BGFX_CLEAR_DISCARD_COLOR_1 = $0010;
  // Discard frame buffer attachment 2.
  BGFX_CLEAR_DISCARD_COLOR_2 = $0020;
  // Discard frame buffer attachment 3.
  BGFX_CLEAR_DISCARD_COLOR_3 = $0040;
  // Discard frame buffer attachment 4.
  BGFX_CLEAR_DISCARD_COLOR_4 = $0080;
  // Discard frame buffer attachment 5.
  BGFX_CLEAR_DISCARD_COLOR_5 = $0100;
  // Discard frame buffer attachment 6.
  BGFX_CLEAR_DISCARD_COLOR_6 = $0200;
  // Discard frame buffer attachment 7.
  BGFX_CLEAR_DISCARD_COLOR_7 = $0400;
  // Discard frame buffer depth attachment.
  BGFX_CLEAR_DISCARD_DEPTH = $0800;
  // Discard frame buffer stencil attachment.
  BGFX_CLEAR_DISCARD_STENCIL = $1000;
  BGFX_CLEAR_DISCARD_COLOR_MASK =
    (0 or BGFX_CLEAR_DISCARD_COLOR_0 or BGFX_CLEAR_DISCARD_COLOR_1 or
    BGFX_CLEAR_DISCARD_COLOR_2 or BGFX_CLEAR_DISCARD_COLOR_3 or
    BGFX_CLEAR_DISCARD_COLOR_4 or BGFX_CLEAR_DISCARD_COLOR_5 or
    BGFX_CLEAR_DISCARD_COLOR_6 or BGFX_CLEAR_DISCARD_COLOR_7);
  BGFX_CLEAR_DISCARD_MASK = (0 or BGFX_CLEAR_DISCARD_COLOR_MASK or
    BGFX_CLEAR_DISCARD_DEPTH or BGFX_CLEAR_DISCARD_STENCIL);
  (*
   * Rendering state discard. When state is preserved in submit, rendering states
   * can be discarded on a finer grain.
   *)
  // Discard only Index Buffer
  BGFX_DISCARD_INDEX_BUFFER = $01;
  // Discard only Vertex Streams
  BGFX_DISCARD_VERTEX_STREAMS = $02;
  // Discard only texture samplers
  BGFX_DISCARD_TEXTURE_SAMPLERS = $04;
  // Discard only Compute shader related state
  BGFX_DISCARD_COMPUTE = $08;
  // Discard only state
  BGFX_DISCARD_STATE = $10;
  // Discard every rendering states
  BGFX_DICARD_ALL = (0 or BGFX_DISCARD_INDEX_BUFFER or BGFX_DISCARD_VERTEX_STREAMS or
    BGFX_DISCARD_TEXTURE_SAMPLERS or BGFX_DISCARD_COMPUTE or BGFX_DISCARD_STATE);
  // No debug.
  BGFX_DEBUG_NONE = $00000000;
  // Enable wireframe for all primitives.
  BGFX_DEBUG_WIREFRAME = $00000001;
  // Enable infinitely fast hardware test. No draw calls will be submitted to
  // driver. It's useful when profiling to quickly assess bottleneck between CPU
  // and GPU.
  BGFX_DEBUG_IFH = $00000002;
  // Enable statistics display.
  BGFX_DEBUG_STATS = $00000004;
  // Enable debug text display.
  BGFX_DEBUG_TEXT = $00000008;
  // Enable profiler.
  BGFX_DEBUG_PROFILER = $00000010;
  // 1 8-bit value
  BGFX_BUFFER_COMPUTE_FORMAT_8X1 = $0001;
  // 2 8-bit values
  BGFX_BUFFER_COMPUTE_FORMAT_8X2 = $0002;
  // 4 8-bit values
  BGFX_BUFFER_COMPUTE_FORMAT_8X4 = $0003;
  // 1 16-bit value
  BGFX_BUFFER_COMPUTE_FORMAT_16X1 = $0004;
  // 2 16-bit values
  BGFX_BUFFER_COMPUTE_FORMAT_16X2 = $0005;
  // 4 16-bit values
  BGFX_BUFFER_COMPUTE_FORMAT_16X4 = $0006;
  // 1 32-bit value
  BGFX_BUFFER_COMPUTE_FORMAT_32X1 = $0007;
  // 2 32-bit values
  BGFX_BUFFER_COMPUTE_FORMAT_32X2 = $0008;
  // 4 32-bit values
  BGFX_BUFFER_COMPUTE_FORMAT_32X4 = $0009;
  BGFX_BUFFER_COMPUTE_FORMAT_SHIFT = 0;
  BGFX_BUFFER_COMPUTE_FORMAT_MASK = $000f;
  // Type `int`.
  BGFX_BUFFER_COMPUTE_TYPE_INT = $0010;
  // Type `uint`.
  BGFX_BUFFER_COMPUTE_TYPE_UINT = $0020;
  // Type `float`.
  BGFX_BUFFER_COMPUTE_TYPE_FLOAT = $0030;
  BGFX_BUFFER_COMPUTE_TYPE_SHIFT = 4;
  BGFX_BUFFER_COMPUTE_TYPE_MASK = $0030;
  BGFX_BUFFER_NONE = $0000;
  // Buffer will be read by shader.
  BGFX_BUFFER_COMPUTE_READ = $0100;
  // Buffer will be used for writing.
  BGFX_BUFFER_COMPUTE_WRITE = $0200;
  // Buffer will be used for storing draw indirect commands.
  BGFX_BUFFER_DRAW_INDIRECT = $0400;
  // Allow dynamic index/vertex buffer resize during update.
  BGFX_BUFFER_ALLOW_RESIZE = $0800;
  // Index buffer contains 32-bit indices.
  BGFX_BUFFER_INDEX32 = $1000;
  BGFX_BUFFER_COMPUTE_READ_WRITE = (0 or BGFX_BUFFER_COMPUTE_READ or BGFX_BUFFER_COMPUTE_WRITE);
  BGFX_TEXTURE_NONE = $0000000000000000;
  // Texture will be used for MSAA sampling.
  BGFX_TEXTURE_MSAA_SAMPLE = $0000000800000000;
  // Render target no MSAA.
  BGFX_TEXTURE_RT = $0000001000000000;
  // Texture will be used for compute write.
  BGFX_TEXTURE_COMPUTE_WRITE = $0000100000000000;
  // Sample texture as sRGB.
  BGFX_TEXTURE_SRGB = $0000200000000000;
  // Texture will be used as blit destination.
  BGFX_TEXTURE_BLIT_DST = $0000400000000000;
  // Texture will be used for read back from GPU.
  BGFX_TEXTURE_READ_BACK = $0000800000000000;
  // Render target MSAAx2 mode.
  BGFX_TEXTURE_RT_MSAA_X2 = $0000002000000000;
  // Render target MSAAx4 mode.
  BGFX_TEXTURE_RT_MSAA_X4 = $0000003000000000;
  // Render target MSAAx8 mode.
  BGFX_TEXTURE_RT_MSAA_X8 = $0000004000000000;
  // Render target MSAAx16 mode.
  BGFX_TEXTURE_RT_MSAA_X16 = $0000005000000000;
  BGFX_TEXTURE_RT_MSAA_SHIFT = 36;
  BGFX_TEXTURE_RT_MSAA_MASK = $0000007000000000;
  // Render target will be used for writing
  BGFX_TEXTURE_RT_WRITE_ONLY = $0000008000000000;
  BGFX_TEXTURE_RT_SHIFT = 36;
  BGFX_TEXTURE_RT_MASK = $000000f000000000;
  (*
   * Sampler flags.
   *)
  // Wrap U mode: Mirror
  BGFX_SAMPLER_U_MIRROR = $00000001;
  // Wrap U mode: Clamp
  BGFX_SAMPLER_U_CLAMP = $00000002;
  // Wrap U mode: Border
  BGFX_SAMPLER_U_BORDER = $00000003;
  BGFX_SAMPLER_U_SHIFT = 0;
  BGFX_SAMPLER_U_MASK = $00000003;
  // Wrap V mode: Mirror
  BGFX_SAMPLER_V_MIRROR = $00000004;
  // Wrap V mode: Clamp
  BGFX_SAMPLER_V_CLAMP = $00000008;
  // Wrap V mode: Border
  BGFX_SAMPLER_V_BORDER = $0000000c;
  BGFX_SAMPLER_V_SHIFT = 2;
  BGFX_SAMPLER_V_MASK = $0000000c;
  // Wrap W mode: Mirror
  BGFX_SAMPLER_W_MIRROR = $00000010;
  // Wrap W mode: Clamp
  BGFX_SAMPLER_W_CLAMP = $00000020;
  // Wrap W mode: Border
  BGFX_SAMPLER_W_BORDER = $00000030;
  BGFX_SAMPLER_W_SHIFT = 4;
  BGFX_SAMPLER_W_MASK = $00000030;
  // Min sampling mode: Point
  BGFX_SAMPLER_MIN_POINT = $00000040;
  // Min sampling mode: Anisotropic
  BGFX_SAMPLER_MIN_ANISOTROPIC = $00000080;
  BGFX_SAMPLER_MIN_SHIFT = 6;
  BGFX_SAMPLER_MIN_MASK = $000000c0;
  // Mag sampling mode: Point
  BGFX_SAMPLER_MAG_POINT = $00000100;
  // Mag sampling mode: Anisotropic
  BGFX_SAMPLER_MAG_ANISOTROPIC = $00000200;
  BGFX_SAMPLER_MAG_SHIFT = 8;
  BGFX_SAMPLER_MAG_MASK = $00000300;
  // Mip sampling mode: Point
  BGFX_SAMPLER_MIP_POINT = $00000400;
  BGFX_SAMPLER_MIP_SHIFT = 10;
  BGFX_SAMPLER_MIP_MASK = $00000400;
  // Compare when sampling depth texture: less.
  BGFX_SAMPLER_COMPARE_LESS = $00010000;
  // Compare when sampling depth texture: less or equal.
  BGFX_SAMPLER_COMPARE_LEQUAL = $00020000;
  // Compare when sampling depth texture: equal.
  BGFX_SAMPLER_COMPARE_EQUAL = $00030000;
  // Compare when sampling depth texture: greater or equal.
  BGFX_SAMPLER_COMPARE_GEQUAL = $00040000;
  // Compare when sampling depth texture: greater.
  BGFX_SAMPLER_COMPARE_GREATER = $00050000;
  // Compare when sampling depth texture: not equal.
  BGFX_SAMPLER_COMPARE_NOTEQUAL = $00060000;
  // Compare when sampling depth texture: never.
  BGFX_SAMPLER_COMPARE_NEVER = $00070000;
  // Compare when sampling depth texture: always.
  BGFX_SAMPLER_COMPARE_ALWAYS = $00080000;
  BGFX_SAMPLER_COMPARE_SHIFT = 16;
  BGFX_SAMPLER_COMPARE_MASK = $000f0000;
  BGFX_SAMPLER_BORDER_COLOR_SHIFT = 24;
  BGFX_SAMPLER_BORDER_COLOR_MASK = $0f000000;
  BGFX_SAMPLER_RESERVED_SHIFT = 28;
  BGFX_SAMPLER_RESERVED_MASK = $f0000000;
  BGFX_SAMPLER_NONE = $00000000;
  // Sample stencil instead of depth.
  BGFX_SAMPLER_SAMPLE_STENCIL = $00100000;
  BGFX_SAMPLER_POINT = (0 or BGFX_SAMPLER_MIN_POINT or BGFX_SAMPLER_MAG_POINT or
    BGFX_SAMPLER_MIP_POINT);
  BGFX_SAMPLER_UVW_MIRROR = (0 or BGFX_SAMPLER_U_MIRROR or BGFX_SAMPLER_V_MIRROR or
    BGFX_SAMPLER_W_MIRROR);
  BGFX_SAMPLER_UVW_CLAMP = (0 or BGFX_SAMPLER_U_CLAMP or BGFX_SAMPLER_V_CLAMP or
    BGFX_SAMPLER_W_CLAMP);
  BGFX_SAMPLER_UVW_BORDER = (0 or BGFX_SAMPLER_U_BORDER or BGFX_SAMPLER_V_BORDER or
    BGFX_SAMPLER_W_BORDER);
  BGFX_SAMPLER_BITS_MASK = (0 or BGFX_SAMPLER_U_MASK or BGFX_SAMPLER_V_MASK or
    BGFX_SAMPLER_W_MASK or BGFX_SAMPLER_MIN_MASK or BGFX_SAMPLER_MAG_MASK or
    BGFX_SAMPLER_MIP_MASK or BGFX_SAMPLER_COMPARE_MASK);
  // Enable 2x MSAA.
  BGFX_RESET_MSAA_X2 = $00000010;
  // Enable 4x MSAA.
  BGFX_RESET_MSAA_X4 = $00000020;
  // Enable 8x MSAA.
  BGFX_RESET_MSAA_X8 = $00000030;
  // Enable 16x MSAA.
  BGFX_RESET_MSAA_X16 = $00000040;
  BGFX_RESET_MSAA_SHIFT = 4;
  BGFX_RESET_MSAA_MASK = $00000070;
  // No reset flags.
  BGFX_RESET_NONE = $00000000;
  // Not supported yet.
  BGFX_RESET_FULLSCREEN = $00000001;
  // Enable V-Sync.
  BGFX_RESET_VSYNC = $00000080;
  // Turn on/off max anisotropy.
  BGFX_RESET_MAXANISOTROPY = $00000100;
  // Begin screen capture.
  BGFX_RESET_CAPTURE = $00000200;
  // Flush rendering after submitting to GPU.
  BGFX_RESET_FLUSH_AFTER_RENDER = $00002000;
  // This flag specifies where flip occurs. Default behavior is that flip occurs
  // before rendering new frame. This flag only has effect when
  // `BGFX_CONFIG_MULTITHREADED=0`.
  BGFX_RESET_FLIP_AFTER_RENDER = $00004000;
  // Enable sRGB backbuffer.
  BGFX_RESET_SRGB_BACKBUFFER = $00008000;
  // Enable HDR10 rendering.
  BGFX_RESET_HDR10 = $00010000;
  // Enable HiDPI rendering.
  BGFX_RESET_HIDPI = $00020000;
  // Enable depth clamp.
  BGFX_RESET_DEPTH_CLAMP = $00040000;
  // Suspend rendering.
  BGFX_RESET_SUSPEND = $00080000;
  BGFX_RESET_FULLSCREEN_SHIFT = 0;
  BGFX_RESET_FULLSCREEN_MASK = $00000001;
  // Internal bit shift
  BGFX_RESET_RESERVED_SHIFT = 31;
  // Internal bit mask
  BGFX_RESET_RESERVED_MASK = $80000000;
  // Alpha to coverage is supported.
  BGFX_CAPS_ALPHA_TO_COVERAGE = $0000000000000001;
  // Blend independent is supported.
  BGFX_CAPS_BLEND_INDEPENDENT = $0000000000000002;
  // Compute shaders are supported.
  BGFX_CAPS_COMPUTE = $0000000000000004;
  // Conservative rasterization is supported.
  BGFX_CAPS_CONSERVATIVE_RASTER = $0000000000000008;
  // Draw indirect is supported.
  BGFX_CAPS_DRAW_INDIRECT = $0000000000000010;
  // Fragment depth is accessible in fragment shader.
  BGFX_CAPS_FRAGMENT_DEPTH = $0000000000000020;
  // Fragment ordering is available in fragment shader.
  BGFX_CAPS_FRAGMENT_ORDERING = $0000000000000040;
  // Read/Write frame buffer attachments are supported.
  BGFX_CAPS_FRAMEBUFFER_RW = $0000000000000080;
  // Graphics debugger is present.
  BGFX_CAPS_GRAPHICS_DEBUGGER = $0000000000000100;
  BGFX_CAPS_RESERVED = $0000000000000200;
  // HDR10 rendering is supported.
  BGFX_CAPS_HDR10 = $0000000000000400;
  // HiDPI rendering is supported.
  BGFX_CAPS_HIDPI = $0000000000000800;
  // 32-bit indices are supported.
  BGFX_CAPS_INDEX32 = $0000000000001000;
  // Instancing is supported.
  BGFX_CAPS_INSTANCING = $0000000000002000;
  // Occlusion query is supported.
  BGFX_CAPS_OCCLUSION_QUERY = $0000000000004000;
  // Renderer is on separate thread.
  BGFX_CAPS_RENDERER_MULTITHREADED = $0000000000008000;
  // Multiple windows are supported.
  BGFX_CAPS_SWAP_CHAIN = $0000000000010000;
  // 2D texture array is supported.
  BGFX_CAPS_TEXTURE_2D_ARRAY = $0000000000020000;
  // 3D textures are supported.
  BGFX_CAPS_TEXTURE_3D = $0000000000040000;
  // Texture blit is supported.
  BGFX_CAPS_TEXTURE_BLIT = $0000000000080000;
  // All texture compare modes are supported.
  BGFX_CAPS_TEXTURE_COMPARE_RESERVED = $0000000000100000;
  // Texture compare less equal mode is supported.
  BGFX_CAPS_TEXTURE_COMPARE_LEQUAL = $0000000000200000;
  // Cubemap texture array is supported.
  BGFX_CAPS_TEXTURE_CUBE_ARRAY = $0000000000400000;
  // CPU direct access to GPU texture memory.
  BGFX_CAPS_TEXTURE_DIRECT_ACCESS = $0000000000800000;
  // Read-back texture is supported.
  BGFX_CAPS_TEXTURE_READ_BACK = $0000000001000000;
  // Vertex attribute half-float is supported.
  BGFX_CAPS_VERTEX_ATTRIB_HALF = $0000000002000000;
  // Vertex attribute 10_10_10_2 is supported.
  BGFX_CAPS_VERTEX_ATTRIB_UINT10 = $0000000004000000;
  // Rendering with VertexID only is supported.
  BGFX_CAPS_VERTEX_ID = $0000000008000000;
  // All texture compare modes are supported.
  BGFX_CAPS_TEXTURE_COMPARE_ALL =
    (0 or BGFX_CAPS_TEXTURE_COMPARE_RESERVED or BGFX_CAPS_TEXTURE_COMPARE_LEQUAL);
  // Texture format is not supported.
  BGFX_CAPS_FORMAT_TEXTURE_NONE = $0000;
  // Texture format is supported.
  BGFX_CAPS_FORMAT_TEXTURE_2D = $0001;
  // Texture as sRGB format is supported.
  BGFX_CAPS_FORMAT_TEXTURE_2D_SRGB = $0002;
  // Texture format is emulated.
  BGFX_CAPS_FORMAT_TEXTURE_2D_EMULATED = $0004;
  // Texture format is supported.
  BGFX_CAPS_FORMAT_TEXTURE_3D = $0008;
  // Texture as sRGB format is supported.
  BGFX_CAPS_FORMAT_TEXTURE_3D_SRGB = $0010;
  // Texture format is emulated.
  BGFX_CAPS_FORMAT_TEXTURE_3D_EMULATED = $0020;
  // Texture format is supported.
  BGFX_CAPS_FORMAT_TEXTURE_CUBE = $0040;
  // Texture as sRGB format is supported.
  BGFX_CAPS_FORMAT_TEXTURE_CUBE_SRGB = $0080;
  // Texture format is emulated.
  BGFX_CAPS_FORMAT_TEXTURE_CUBE_EMULATED = $0100;
  // Texture format can be used from vertex shader.
  BGFX_CAPS_FORMAT_TEXTURE_VERTEX = $0200;
  // Texture format can be used as image from compute shader.
  BGFX_CAPS_FORMAT_TEXTURE_IMAGE = $0400;
  // Texture format can be used as frame buffer.
  BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER = $0800;
  // Texture format can be used as MSAA frame buffer.
  BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA = $1000;
  // Texture can be sampled as MSAA.
  BGFX_CAPS_FORMAT_TEXTURE_MSAA = $2000;
  // Texture format supports auto-generated mips.
  BGFX_CAPS_FORMAT_TEXTURE_MIP_AUTOGEN = $4000;
  // No resolve flags.
  BGFX_RESOLVE_NONE = $00;
  // Auto-generate mip maps on resolve.
  BGFX_RESOLVE_AUTO_GEN_MIPS = $01;
  // Autoselect adapter.
  BGFX_PCI_ID_NONE = $0000;
  // Software rasterizer.
  BGFX_PCI_ID_SOFTWARE_RASTERIZER = $0001;
  // AMD adapter.
  BGFX_PCI_ID_AMD = $1002;
  // Intel adapter.
  BGFX_PCI_ID_INTEL = $8086;
  // nVidia adapter.
  BGFX_PCI_ID_NVIDIA = $10de;
  // Cubemap +x.
  BGFX_CUBE_MAP_POSITIVE_X = $00;
  // Cubemap -x.
  BGFX_CUBE_MAP_NEGATIVE_X = $01;
  // Cubemap +y.
  BGFX_CUBE_MAP_POSITIVE_Y = $02;
  // Cubemap -y.
  BGFX_CUBE_MAP_NEGATIVE_Y = $03;
  // Cubemap +z.
  BGFX_CUBE_MAP_POSITIVE_Z = $04;
  // Cubemap -z.
  BGFX_CUBE_MAP_NEGATIVE_Z = $05;

type
  // Forward declarations
  Pbgfx_encoder_s = Pointer;
  PPbgfx_encoder_s = ^Pbgfx_encoder_s;
  Pbgfx_allocator_interface_s = ^bgfx_allocator_interface_s;
  Pbgfx_allocator_vtbl_s = ^bgfx_allocator_vtbl_s;
  Pbgfx_callback_interface_s = ^bgfx_callback_interface_s;
  Pbgfx_callback_vtbl_s = ^bgfx_callback_vtbl_s;
  Pbgfx_dynamic_index_buffer_handle_s = ^bgfx_dynamic_index_buffer_handle_s;
  Pbgfx_dynamic_vertex_buffer_handle_s = ^bgfx_dynamic_vertex_buffer_handle_s;
  Pbgfx_frame_buffer_handle_s = ^bgfx_frame_buffer_handle_s;
  Pbgfx_index_buffer_handle_s = ^bgfx_index_buffer_handle_s;
  Pbgfx_indirect_buffer_handle_s = ^bgfx_indirect_buffer_handle_s;
  Pbgfx_occlusion_query_handle_s = ^bgfx_occlusion_query_handle_s;
  Pbgfx_program_handle_s = ^bgfx_program_handle_s;
  Pbgfx_shader_handle_s = ^bgfx_shader_handle_s;
  Pbgfx_texture_handle_s = ^bgfx_texture_handle_s;
  Pbgfx_uniform_handle_s = ^bgfx_uniform_handle_s;
  Pbgfx_vertex_buffer_handle_s = ^bgfx_vertex_buffer_handle_s;
  Pbgfx_vertex_layout_handle_s = ^bgfx_vertex_layout_handle_s;
  Pbgfx_caps_gpu_s = ^bgfx_caps_gpu_s;
  Pbgfx_caps_limits_s = ^bgfx_caps_limits_s;
  Pbgfx_caps_s = ^bgfx_caps_s;
  Pbgfx_internal_data_s = ^bgfx_internal_data_s;
  Pbgfx_platform_data_s = ^bgfx_platform_data_s;
  Pbgfx_resolution_s = ^bgfx_resolution_s;
  Pbgfx_init_limits_s = ^bgfx_init_limits_s;
  Pbgfx_init_s = ^bgfx_init_s;
  Pbgfx_memory_s = ^bgfx_memory_s;
  Pbgfx_transient_index_buffer_s = ^bgfx_transient_index_buffer_s;
  Pbgfx_transient_vertex_buffer_s = ^bgfx_transient_vertex_buffer_s;
  Pbgfx_instance_data_buffer_s = ^bgfx_instance_data_buffer_s;
  Pbgfx_texture_info_s = ^bgfx_texture_info_s;
  Pbgfx_uniform_info_s = ^bgfx_uniform_info_s;
  Pbgfx_attachment_s = ^bgfx_attachment_s;
  Pbgfx_transform_s = ^bgfx_transform_s;
  Pbgfx_view_stats_s = ^bgfx_view_stats_s;
  Pbgfx_encoder_stats_s = ^bgfx_encoder_stats_s;
  Pbgfx_stats_s = ^bgfx_stats_s;
  Pbgfx_vertex_layout_s = ^bgfx_vertex_layout_s;
  Pbgfx_interface_vtbl = ^bgfx_interface_vtbl;
  Pbgfx_interface_vtbl_t = ^bgfx_interface_vtbl;

  (* Fatal error enum. *)
  bgfx_fatal = (
    (* ( 0) *)
    BGFX_FATAL_DEBUG_CHECK = 0,
    (* ( 1) *)
    BGFX_FATAL_INVALID_SHADER = 1,
    (* ( 2) *)
    BGFX_FATAL_UNABLE_TO_INITIALIZE = 2,
    (* ( 3) *)
    BGFX_FATAL_UNABLE_TO_CREATE_TEXTURE = 3,
    (* ( 4) *)
    BGFX_FATAL_DEVICE_LOST = 4,
    (* ( 4) *)
    BGFX_FATAL_COUNT = 5);
  Pbgfx_fatal = ^bgfx_fatal;
  (* Fatal error enum. *)
  bgfx_fatal_t = bgfx_fatal;

  (* Renderer backend type enum. *)
  bgfx_renderer_type = (
    (* ( 0) No rendering. *)
    BGFX_RENDERER_TYPE_NOOP = 0,
    (* ( 1) AGC *)
    BGFX_RENDERER_TYPE_AGC = 1,
    (* ( 2) Direct3D 9.0 *)
    BGFX_RENDERER_TYPE_DIRECT3D9 = 2,
    (* ( 3) Direct3D 11.0 *)
    BGFX_RENDERER_TYPE_DIRECT3D11 = 3,
    (* ( 4) Direct3D 12.0 *)
    BGFX_RENDERER_TYPE_DIRECT3D12 = 4,
    (* ( 5) GNM *)
    BGFX_RENDERER_TYPE_GNM = 5,
    (* ( 6) Metal *)
    BGFX_RENDERER_TYPE_METAL = 6,
    (* ( 7) NVN *)
    BGFX_RENDERER_TYPE_NVN = 7,
    (* ( 8) OpenGL ES 2.0+ *)
    BGFX_RENDERER_TYPE_OPENGLES = 8,
    (* ( 9) OpenGL 2.1+ *)
    BGFX_RENDERER_TYPE_OPENGL = 9,
    (* (10) Vulkan *)
    BGFX_RENDERER_TYPE_VULKAN = 10,
    (* (11) WebGPU *)
    BGFX_RENDERER_TYPE_WEBGPU = 11,
    (* (11) WebGPU *)
    BGFX_RENDERER_TYPE_COUNT = 12);
  Pbgfx_renderer_type = ^bgfx_renderer_type;
  (* Renderer backend type enum. *)
  bgfx_renderer_type_t = bgfx_renderer_type;
  Pbgfx_renderer_type_t = ^bgfx_renderer_type_t;

  (* Access mode enum. *)
  bgfx_access = (
    (* ( 0) Read. *)
    BGFX_ACCESS_READ = 0,
    (* ( 1) Write. *)
    BGFX_ACCESS_WRITE = 1,
    (* ( 2) Read and write. *)
    BGFX_ACCESS_READWRITE = 2,
    (* ( 2) Read and write. *)
    BGFX_ACCESS_COUNT = 3);
  Pbgfx_access = ^bgfx_access;
  (* Access mode enum. *)
  bgfx_access_t = bgfx_access;

  (* Vertex attribute enum. *)
  bgfx_attrib = (
    (* ( 0) a_position *)
    BGFX_ATTRIB_POSITION = 0,
    (* ( 1) a_normal *)
    BGFX_ATTRIB_NORMAL = 1,
    (* ( 2) a_tangent *)
    BGFX_ATTRIB_TANGENT = 2,
    (* ( 3) a_bitangent *)
    BGFX_ATTRIB_BITANGENT = 3,
    (* ( 4) a_color0 *)
    BGFX_ATTRIB_COLOR0 = 4,
    (* ( 5) a_color1 *)
    BGFX_ATTRIB_COLOR1 = 5,
    (* ( 6) a_color2 *)
    BGFX_ATTRIB_COLOR2 = 6,
    (* ( 7) a_color3 *)
    BGFX_ATTRIB_COLOR3 = 7,
    (* ( 8) a_indices *)
    BGFX_ATTRIB_INDICES = 8,
    (* ( 9) a_weight *)
    BGFX_ATTRIB_WEIGHT = 9,
    (* (10) a_texcoord0 *)
    BGFX_ATTRIB_TEXCOORD0 = 10,
    (* (11) a_texcoord1 *)
    BGFX_ATTRIB_TEXCOORD1 = 11,
    (* (12) a_texcoord2 *)
    BGFX_ATTRIB_TEXCOORD2 = 12,
    (* (13) a_texcoord3 *)
    BGFX_ATTRIB_TEXCOORD3 = 13,
    (* (14) a_texcoord4 *)
    BGFX_ATTRIB_TEXCOORD4 = 14,
    (* (15) a_texcoord5 *)
    BGFX_ATTRIB_TEXCOORD5 = 15,
    (* (16) a_texcoord6 *)
    BGFX_ATTRIB_TEXCOORD6 = 16,
    (* (17) a_texcoord7 *)
    BGFX_ATTRIB_TEXCOORD7 = 17,
    (* (17) a_texcoord7 *)
    BGFX_ATTRIB_COUNT = 18);
  Pbgfx_attrib = ^bgfx_attrib;
  (* Vertex attribute enum. *)
  bgfx_attrib_t = bgfx_attrib;

  (* Vertex attribute type enum. *)
  bgfx_attrib_type = (
    (* ( 0) Uint8 *)
    BGFX_ATTRIB_TYPE_UINT8 = 0,
    (* ( 1) Uint10, availability depends on: `BGFX_CAPS_VERTEX_ATTRIB_UINT10`. *)
    BGFX_ATTRIB_TYPE_UINT10 = 1,
    (* ( 2) Int16 *)
    BGFX_ATTRIB_TYPE_INT16 = 2,
    (* ( 3) Half, availability depends on: `BGFX_CAPS_VERTEX_ATTRIB_HALF`. *)
    BGFX_ATTRIB_TYPE_HALF = 3,
    (* ( 4) Float *)
    BGFX_ATTRIB_TYPE_FLOAT = 4,
    (* ( 4) Float *)
    BGFX_ATTRIB_TYPE_COUNT = 5);
  Pbgfx_attrib_type = ^bgfx_attrib_type;
  (* Vertex attribute type enum. *)
  bgfx_attrib_type_t = bgfx_attrib_type;
  Pbgfx_attrib_type_t = ^bgfx_attrib_type_t;

  (* Texture format enum. *)
  bgfx_texture_format = (
    (* ( 0) DXT1 R5G6B5A1 *)
    BGFX_TEXTURE_FORMAT_BC1 = 0,
    (* ( 1) DXT3 R5G6B5A4 *)
    BGFX_TEXTURE_FORMAT_BC2 = 1,
    (* ( 2) DXT5 R5G6B5A8 *)
    BGFX_TEXTURE_FORMAT_BC3 = 2,
    (* ( 3) LATC1/ATI1 R8 *)
    BGFX_TEXTURE_FORMAT_BC4 = 3,
    (* ( 4) LATC2/ATI2 RG8 *)
    BGFX_TEXTURE_FORMAT_BC5 = 4,
    (* ( 5) BC6H RGB16F *)
    BGFX_TEXTURE_FORMAT_BC6H = 5,
    (* ( 6) BC7 RGB 4-7 bits per color channel, 0-8 bits alpha *)
    BGFX_TEXTURE_FORMAT_BC7 = 6,
    (* ( 7) ETC1 RGB8 *)
    BGFX_TEXTURE_FORMAT_ETC1 = 7,
    (* ( 8) ETC2 RGB8 *)
    BGFX_TEXTURE_FORMAT_ETC2 = 8,
    (* ( 9) ETC2 RGBA8 *)
    BGFX_TEXTURE_FORMAT_ETC2A = 9,
    (* (10) ETC2 RGB8A1 *)
    BGFX_TEXTURE_FORMAT_ETC2A1 = 10,
    (* (11) PVRTC1 RGB 2BPP *)
    BGFX_TEXTURE_FORMAT_PTC12 = 11,
    (* (12) PVRTC1 RGB 4BPP *)
    BGFX_TEXTURE_FORMAT_PTC14 = 12,
    (* (13) PVRTC1 RGBA 2BPP *)
    BGFX_TEXTURE_FORMAT_PTC12A = 13,
    (* (14) PVRTC1 RGBA 4BPP *)
    BGFX_TEXTURE_FORMAT_PTC14A = 14,
    (* (15) PVRTC2 RGBA 2BPP *)
    BGFX_TEXTURE_FORMAT_PTC22 = 15,
    (* (16) PVRTC2 RGBA 4BPP *)
    BGFX_TEXTURE_FORMAT_PTC24 = 16,
    (* (17) ATC RGB 4BPP *)
    BGFX_TEXTURE_FORMAT_ATC = 17,
    (* (18) ATCE RGBA 8 BPP explicit alpha *)
    BGFX_TEXTURE_FORMAT_ATCE = 18,
    (* (19) ATCI RGBA 8 BPP interpolated alpha *)
    BGFX_TEXTURE_FORMAT_ATCI = 19,
    (* (20) ASTC 4x4 8.0 BPP *)
    BGFX_TEXTURE_FORMAT_ASTC4X4 = 20,
    (* (21) ASTC 5x5 5.12 BPP *)
    BGFX_TEXTURE_FORMAT_ASTC5X5 = 21,
    (* (22) ASTC 6x6 3.56 BPP *)
    BGFX_TEXTURE_FORMAT_ASTC6X6 = 22,
    (* (23) ASTC 8x5 3.20 BPP *)
    BGFX_TEXTURE_FORMAT_ASTC8X5 = 23,
    (* (24) ASTC 8x6 2.67 BPP *)
    BGFX_TEXTURE_FORMAT_ASTC8X6 = 24,
    (* (25) ASTC 10x5 2.56 BPP *)
    BGFX_TEXTURE_FORMAT_ASTC10X5 = 25,
    (* (26) Compressed formats above. *)
    BGFX_TEXTURE_FORMAT_UNKNOWN = 26,
    (* (27) *)
    BGFX_TEXTURE_FORMAT_R1 = 27,
    (* (28) *)
    BGFX_TEXTURE_FORMAT_A8 = 28,
    (* (29) *)
    BGFX_TEXTURE_FORMAT_R8 = 29,
    (* (30) *)
    BGFX_TEXTURE_FORMAT_R8I = 30,
    (* (31) *)
    BGFX_TEXTURE_FORMAT_R8U = 31,
    (* (32) *)
    BGFX_TEXTURE_FORMAT_R8S = 32,
    (* (33) *)
    BGFX_TEXTURE_FORMAT_R16 = 33,
    (* (34) *)
    BGFX_TEXTURE_FORMAT_R16I = 34,
    (* (35) *)
    BGFX_TEXTURE_FORMAT_R16U = 35,
    (* (36) *)
    BGFX_TEXTURE_FORMAT_R16F = 36,
    (* (37) *)
    BGFX_TEXTURE_FORMAT_R16S = 37,
    (* (38) *)
    BGFX_TEXTURE_FORMAT_R32I = 38,
    (* (39) *)
    BGFX_TEXTURE_FORMAT_R32U = 39,
    (* (40) *)
    BGFX_TEXTURE_FORMAT_R32F = 40,
    (* (41) *)
    BGFX_TEXTURE_FORMAT_RG8 = 41,
    (* (42) *)
    BGFX_TEXTURE_FORMAT_RG8I = 42,
    (* (43) *)
    BGFX_TEXTURE_FORMAT_RG8U = 43,
    (* (44) *)
    BGFX_TEXTURE_FORMAT_RG8S = 44,
    (* (45) *)
    BGFX_TEXTURE_FORMAT_RG16 = 45,
    (* (46) *)
    BGFX_TEXTURE_FORMAT_RG16I = 46,
    (* (47) *)
    BGFX_TEXTURE_FORMAT_RG16U = 47,
    (* (48) *)
    BGFX_TEXTURE_FORMAT_RG16F = 48,
    (* (49) *)
    BGFX_TEXTURE_FORMAT_RG16S = 49,
    (* (50) *)
    BGFX_TEXTURE_FORMAT_RG32I = 50,
    (* (51) *)
    BGFX_TEXTURE_FORMAT_RG32U = 51,
    (* (52) *)
    BGFX_TEXTURE_FORMAT_RG32F = 52,
    (* (53) *)
    BGFX_TEXTURE_FORMAT_RGB8 = 53,
    (* (54) *)
    BGFX_TEXTURE_FORMAT_RGB8I = 54,
    (* (55) *)
    BGFX_TEXTURE_FORMAT_RGB8U = 55,
    (* (56) *)
    BGFX_TEXTURE_FORMAT_RGB8S = 56,
    (* (57) *)
    BGFX_TEXTURE_FORMAT_RGB9E5F = 57,
    (* (58) *)
    BGFX_TEXTURE_FORMAT_BGRA8 = 58,
    (* (59) *)
    BGFX_TEXTURE_FORMAT_RGBA8 = 59,
    (* (60) *)
    BGFX_TEXTURE_FORMAT_RGBA8I = 60,
    (* (61) *)
    BGFX_TEXTURE_FORMAT_RGBA8U = 61,
    (* (62) *)
    BGFX_TEXTURE_FORMAT_RGBA8S = 62,
    (* (63) *)
    BGFX_TEXTURE_FORMAT_RGBA16 = 63,
    (* (64) *)
    BGFX_TEXTURE_FORMAT_RGBA16I = 64,
    (* (65) *)
    BGFX_TEXTURE_FORMAT_RGBA16U = 65,
    (* (66) *)
    BGFX_TEXTURE_FORMAT_RGBA16F = 66,
    (* (67) *)
    BGFX_TEXTURE_FORMAT_RGBA16S = 67,
    (* (68) *)
    BGFX_TEXTURE_FORMAT_RGBA32I = 68,
    (* (69) *)
    BGFX_TEXTURE_FORMAT_RGBA32U = 69,
    (* (70) *)
    BGFX_TEXTURE_FORMAT_RGBA32F = 70,
    (* (71) *)
    BGFX_TEXTURE_FORMAT_R5G6B5 = 71,
    (* (72) *)
    BGFX_TEXTURE_FORMAT_RGBA4 = 72,
    (* (73) *)
    BGFX_TEXTURE_FORMAT_RGB5A1 = 73,
    (* (74) *)
    BGFX_TEXTURE_FORMAT_RGB10A2 = 74,
    (* (75) *)
    BGFX_TEXTURE_FORMAT_RG11B10F = 75,
    (* (76) Depth formats below. *)
    BGFX_TEXTURE_FORMAT_UNKNOWNDEPTH = 76,
    (* (77) *)
    BGFX_TEXTURE_FORMAT_D16 = 77,
    (* (78) *)
    BGFX_TEXTURE_FORMAT_D24 = 78,
    (* (79) *)
    BGFX_TEXTURE_FORMAT_D24S8 = 79,
    (* (80) *)
    BGFX_TEXTURE_FORMAT_D32 = 80,
    (* (81) *)
    BGFX_TEXTURE_FORMAT_D16F = 81,
    (* (82) *)
    BGFX_TEXTURE_FORMAT_D24F = 82,
    (* (83) *)
    BGFX_TEXTURE_FORMAT_D32F = 83,
    (* (84) *)
    BGFX_TEXTURE_FORMAT_D0S8 = 84,
    (* (84) *)
    BGFX_TEXTURE_FORMAT_COUNT = 85);
  Pbgfx_texture_format = ^bgfx_texture_format;
  (* Texture format enum. *)
  bgfx_texture_format_t = bgfx_texture_format;

  (* Uniform type enum. *)
  bgfx_uniform_type = (
    (* ( 0) Sampler. *)
    BGFX_UNIFORM_TYPE_SAMPLER = 0,
    (* ( 1) Reserved, do not use. *)
    BGFX_UNIFORM_TYPE_END = 1,
    (* ( 2) 4 floats vector. *)
    BGFX_UNIFORM_TYPE_VEC4 = 2,
    (* ( 3) 3x3 matrix. *)
    BGFX_UNIFORM_TYPE_MAT3 = 3,
    (* ( 4) 4x4 matrix. *)
    BGFX_UNIFORM_TYPE_MAT4 = 4,
    (* ( 4) 4x4 matrix. *)
    BGFX_UNIFORM_TYPE_COUNT = 5);
  Pbgfx_uniform_type = ^bgfx_uniform_type;
  (* Uniform type enum. *)
  bgfx_uniform_type_t = bgfx_uniform_type;

  (* Backbuffer ratio enum. *)
  bgfx_backbuffer_ratio = (
    (* ( 0) Equal to backbuffer. *)
    BGFX_BACKBUFFER_RATIO_EQUAL = 0,
    (* ( 1) One half size of backbuffer. *)
    BGFX_BACKBUFFER_RATIO_HALF = 1,
    (* ( 2) One quarter size of backbuffer. *)
    BGFX_BACKBUFFER_RATIO_QUARTER = 2,
    (* ( 3) One eighth size of backbuffer. *)
    BGFX_BACKBUFFER_RATIO_EIGHTH = 3,
    (* ( 4) One sixteenth size of backbuffer. *)
    BGFX_BACKBUFFER_RATIO_SIXTEENTH = 4,
    (* ( 5) Double size of backbuffer. *)
    BGFX_BACKBUFFER_RATIO_DOUBLE = 5,
    (* ( 5) Double size of backbuffer. *)
    BGFX_BACKBUFFER_RATIO_COUNT = 6);
  Pbgfx_backbuffer_ratio = ^bgfx_backbuffer_ratio;
  (* Backbuffer ratio enum. *)
  bgfx_backbuffer_ratio_t = bgfx_backbuffer_ratio;

  (* Occlusion query result. *)
  bgfx_occlusion_query_result = (
    (* ( 0) Query failed test. *)
    BGFX_OCCLUSION_QUERY_RESULT_INVISIBLE = 0,
    (* ( 1) Query passed test. *)
    BGFX_OCCLUSION_QUERY_RESULT_VISIBLE = 1,
    (* ( 2) Query result is not available yet. *)
    BGFX_OCCLUSION_QUERY_RESULT_NORESULT = 2,
    (* ( 2) Query result is not available yet. *)
    BGFX_OCCLUSION_QUERY_RESULT_COUNT = 3);
  Pbgfx_occlusion_query_result = ^bgfx_occlusion_query_result;
  (* Occlusion query result. *)
  bgfx_occlusion_query_result_t = bgfx_occlusion_query_result;

  (* Primitive topology. *)
  bgfx_topology = (
    (* ( 0) Triangle list. *)
    BGFX_TOPOLOGY_TRI_LIST = 0,
    (* ( 1) Triangle strip. *)
    BGFX_TOPOLOGY_TRI_STRIP = 1,
    (* ( 2) Line list. *)
    BGFX_TOPOLOGY_LINE_LIST = 2,
    (* ( 3) Line strip. *)
    BGFX_TOPOLOGY_LINE_STRIP = 3,
    (* ( 4) Point list. *)
    BGFX_TOPOLOGY_POINT_LIST = 4,
    (* ( 4) Point list. *)
    BGFX_TOPOLOGY_COUNT = 5);
  Pbgfx_topology = ^bgfx_topology;
  (* Primitive topology. *)
  bgfx_topology_t = bgfx_topology;

  (* Topology conversion function. *)
  bgfx_topology_convert_t = (
    (* ( 0) Flip winding order of triangle list. *)
    BGFX_TOPOLOGY_CONVERT_TRI_LIST_FLIP_WINDING = 0,
    (* ( 1) Flip winding order of triangle strip. *)
    BGFX_TOPOLOGY_CONVERT_TRI_STRIP_FLIP_WINDING = 1,
    (* ( 2) Convert triangle list to line list. *)
    BGFX_TOPOLOGY_CONVERT_TRI_LIST_TO_LINE_LIST = 2,
    (* ( 3) Convert triangle strip to triangle list. *)
    BGFX_TOPOLOGY_CONVERT_TRI_STRIP_TO_TRI_LIST = 3,
    (* ( 4) Convert line strip to line list. *)
    BGFX_TOPOLOGY_CONVERT_LINE_STRIP_TO_LINE_LIST = 4,
    (* ( 4) Convert line strip to line list. *)
    BGFX_TOPOLOGY_CONVERT_COUNT = 5);
  Pbgfx_topology_convert = ^bgfx_topology_convert_t;

  (* Topology sort order. *)
  bgfx_topology_sort = (
    (* ( 0) *)
    BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MIN = 0,
    (* ( 1) *)
    BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_AVG = 1,
    (* ( 2) *)
    BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MAX = 2,
    (* ( 3) *)
    BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MIN = 3,
    (* ( 4) *)
    BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_AVG = 4,
    (* ( 5) *)
    BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MAX = 5,
    (* ( 6) *)
    BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MIN = 6,
    (* ( 7) *)
    BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_AVG = 7,
    (* ( 8) *)
    BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MAX = 8,
    (* ( 9) *)
    BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MIN = 9,
    (* (10) *)
    BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_AVG = 10,
    (* (11) *)
    BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MAX = 11,
    (* (11) *)
    BGFX_TOPOLOGY_SORT_COUNT = 12);
  Pbgfx_topology_sort = ^bgfx_topology_sort;
  (* Topology sort order. *)
  bgfx_topology_sort_t = bgfx_topology_sort;

  (* View mode sets draw call sort order. *)
  bgfx_view_mode = (
    (* ( 0) Default sort order. *)
    BGFX_VIEW_MODE_DEFAULT = 0,
    (* ( 1) Sort in the same order in which submit calls were called. *)
    BGFX_VIEW_MODE_SEQUENTIAL = 1,
    (* ( 2) Sort draw call depth in ascending order. *)
    BGFX_VIEW_MODE_DEPTH_ASCENDING = 2,
    (* ( 3) Sort draw call depth in descending order. *)
    BGFX_VIEW_MODE_DEPTH_DESCENDING = 3,
    (* ( 3) Sort draw call depth in descending order. *)
    BGFX_VIEW_MODE_COUNT = 4);
  Pbgfx_view_mode = ^bgfx_view_mode;
  (* View mode sets draw call sort order. *)
  bgfx_view_mode_t = bgfx_view_mode;

  (* Render frame enum. *)
  bgfx_render_frame_t = (
    (* ( 0) Renderer context is not created yet. *)
    BGFX_RENDER_FRAME_NO_CONTEXT = 0,
    (* ( 1) Renderer context is created and rendering. *)
    BGFX_RENDER_FRAME_RENDER = 1,
    (* ( 2) Renderer context wait for main thread signal timed out without rendering. *)
    BGFX_RENDER_FRAME_TIMEOUT = 2,
    (* ( 3) Renderer context is getting destroyed. *)
    BGFX_RENDER_FRAME_EXITING = 3,
    (* ( 3) Renderer context is getting destroyed. *)
    BGFX_RENDER_FRAME_COUNT = 4);
  Pbgfx_render_frame = ^bgfx_render_frame_t;

  bgfx_view_id_t = UInt16;
  Pbgfx_view_id_t = ^bgfx_view_id_t;

  bgfx_allocator_interface_s = record
    vtbl: Pbgfx_allocator_vtbl_s;
  end;

  bgfx_allocator_interface_t = bgfx_allocator_interface_s;
  Pbgfx_allocator_interface_t = ^bgfx_allocator_interface_t;

  bgfx_allocator_vtbl_s = record
    realloc: function(_this: Pbgfx_allocator_interface_t; _ptr: Pointer; _size: NativeUInt; _align: NativeUInt; const _file: PUTF8Char; _line: UInt32): Pointer; cdecl;
  end;

  bgfx_allocator_vtbl_t = bgfx_allocator_vtbl_s;

  bgfx_callback_interface_s = record
    vtbl: Pbgfx_callback_vtbl_s;
  end;

  bgfx_callback_interface_t = bgfx_callback_interface_s;
  Pbgfx_callback_interface_t = ^bgfx_callback_interface_t;

  bgfx_callback_vtbl_s = record
    fatal: procedure(_this: Pbgfx_callback_interface_t; const _filePath: PUTF8Char; _line: UInt16; _code: bgfx_fatal_t; const _str: PUTF8Char); cdecl;
    trace_vargs: procedure(_this: Pbgfx_callback_interface_t; const _filePath: PUTF8Char; _line: UInt16; const _format: PUTF8Char; _argList: Pointer); cdecl;
    profiler_begin: procedure(_this: Pbgfx_callback_interface_t; const _name: PUTF8Char; _abgr: UInt32; const _filePath: PUTF8Char; _line: UInt16); cdecl;
    profiler_begin_literal: procedure(_this: Pbgfx_callback_interface_t; const _name: PUTF8Char; _abgr: UInt32; const _filePath: PUTF8Char; _line: UInt16); cdecl;
    profiler_end: procedure(_this: Pbgfx_callback_interface_t); cdecl;
    cache_read_size: function(_this: Pbgfx_callback_interface_t; _id: UInt64): UInt32; cdecl;
    cache_read: function(_this: Pbgfx_callback_interface_t; _id: UInt64; _data: Pointer; _size: UInt32): Boolean; cdecl;
    cache_write: procedure(_this: Pbgfx_callback_interface_t; _id: UInt64; const _data: Pointer; _size: UInt32); cdecl;
    screen_shot: procedure(_this: Pbgfx_callback_interface_t; const _filePath: PUTF8Char; _width: UInt32; _height: UInt32; _pitch: UInt32; const _data: Pointer; _size: UInt32; _yflip: Boolean); cdecl;
    capture_begin: procedure(_this: Pbgfx_callback_interface_t; _width: UInt32; _height: UInt32; _pitch: UInt32; _format: bgfx_texture_format_t; _yflip: Boolean); cdecl;
    capture_end: procedure(_this: Pbgfx_callback_interface_t); cdecl;
    capture_frame: procedure(_this: Pbgfx_callback_interface_t; const _data: Pointer; _size: UInt32); cdecl;
  end;

  bgfx_callback_vtbl_t = bgfx_callback_vtbl_s;

  bgfx_dynamic_index_buffer_handle_s = record
    idx: UInt16;
  end;

  bgfx_dynamic_index_buffer_handle_t = bgfx_dynamic_index_buffer_handle_s;

  bgfx_dynamic_vertex_buffer_handle_s = record
    idx: UInt16;
  end;

  bgfx_dynamic_vertex_buffer_handle_t = bgfx_dynamic_vertex_buffer_handle_s;

  bgfx_frame_buffer_handle_s = record
    idx: UInt16;
  end;

  bgfx_frame_buffer_handle_t = bgfx_frame_buffer_handle_s;

  bgfx_index_buffer_handle_s = record
    idx: UInt16;
  end;

  bgfx_index_buffer_handle_t = bgfx_index_buffer_handle_s;

  bgfx_indirect_buffer_handle_s = record
    idx: UInt16;
  end;

  bgfx_indirect_buffer_handle_t = bgfx_indirect_buffer_handle_s;

  bgfx_occlusion_query_handle_s = record
    idx: UInt16;
  end;

  bgfx_occlusion_query_handle_t = bgfx_occlusion_query_handle_s;

  bgfx_program_handle_s = record
    idx: UInt16;
  end;

  bgfx_program_handle_t = bgfx_program_handle_s;

  bgfx_shader_handle_s = record
    idx: UInt16;
  end;

  bgfx_shader_handle_t = bgfx_shader_handle_s;

  bgfx_texture_handle_s = record
    idx: UInt16;
  end;

  bgfx_texture_handle_t = bgfx_texture_handle_s;
  Pbgfx_texture_handle_t = ^bgfx_texture_handle_t;

  bgfx_uniform_handle_s = record
    idx: UInt16;
  end;

  bgfx_uniform_handle_t = bgfx_uniform_handle_s;
  Pbgfx_uniform_handle_t = ^bgfx_uniform_handle_t;

  bgfx_vertex_buffer_handle_s = record
    idx: UInt16;
  end;

  bgfx_vertex_buffer_handle_t = bgfx_vertex_buffer_handle_s;

  bgfx_vertex_layout_handle_s = record
    idx: UInt16;
  end;

  bgfx_vertex_layout_handle_t = bgfx_vertex_layout_handle_s;

  (* Memory release callback.
     @param(_ptr [in] Pointer to allocated data.)
     @param(_userData [in] User defined data if needed.) *)
  bgfx_release_fn_t = procedure(_ptr: Pointer; _userData: Pointer); cdecl;

  (* GPU info. *)
  bgfx_caps_gpu_s = record
    (* Vendor PCI id. See `BGFX_PCI_ID_*`. *)
    vendorId: UInt16;
    (* Device id. *)
    deviceId: UInt16;
  end;

  (* GPU info. *)
  bgfx_caps_gpu_t = bgfx_caps_gpu_s;

  (* Renderer runtime limits. *)
  bgfx_caps_limits_s = record
    (* Maximum number of draw calls. *)
    maxDrawCalls: UInt32;
    (* Maximum number of blit calls. *)
    maxBlits: UInt32;
    (* Maximum texture size. *)
    maxTextureSize: UInt32;
    (* Maximum texture layers. *)
    maxTextureLayers: UInt32;
    (* Maximum number of views. *)
    maxViews: UInt32;
    (* Maximum number of frame buffer handles. *)
    maxFrameBuffers: UInt32;
    (* Maximum number of frame buffer attachments. *)
    maxFBAttachments: UInt32;
    (* Maximum number of program handles. *)
    maxPrograms: UInt32;
    (* Maximum number of shader handles. *)
    maxShaders: UInt32;
    (* Maximum number of texture handles. *)
    maxTextures: UInt32;
    (* Maximum number of texture samplers. *)
    maxTextureSamplers: UInt32;
    (* Maximum number of compute bindings. *)
    maxComputeBindings: UInt32;
    (* Maximum number of vertex format layouts. *)
    maxVertexLayouts: UInt32;
    (* Maximum number of vertex streams. *)
    maxVertexStreams: UInt32;
    (* Maximum number of index buffer handles. *)
    maxIndexBuffers: UInt32;
    (* Maximum number of vertex buffer handles. *)
    maxVertexBuffers: UInt32;
    (* Maximum number of dynamic index buffer handles. *)
    maxDynamicIndexBuffers: UInt32;
    (* Maximum number of dynamic vertex buffer handles. *)
    maxDynamicVertexBuffers: UInt32;
    (* Maximum number of uniform handles. *)
    maxUniforms: UInt32;
    (* Maximum number of occlusion query handles. *)
    maxOcclusionQueries: UInt32;
    (* Maximum number of encoder threads. *)
    maxEncoders: UInt32;
    (* Minimum resource command buffer size. *)
    minResourceCbSize: UInt32;
    (* Maximum transient vertex buffer size. *)
    transientVbSize: UInt32;
    (* Maximum transient index buffer size. *)
    transientIbSize: UInt32;
  end;

  (* Renderer runtime limits. *)
  bgfx_caps_limits_t = bgfx_caps_limits_s;

  (* Renderer capabilities. *)
  bgfx_caps_s = record
    (* Renderer backend type. See: `bgfx::RendererType` *)
    rendererType: bgfx_renderer_type_t;
    (* Supported functionality.

       See `BGFX_CAPS_*` flags at https://bkaradzic.github.io/bgfx/bgfx.html#available-caps *)
    supported: UInt64;
    (* Selected GPU vendor PCI id. *)
    vendorId: UInt16;
    (* Selected GPU device id. *)
    deviceId: UInt16;
    (* True when NDC depth is in [-1, 1] range, otherwise its [0, 1]. *)
    homogeneousDepth: Boolean;
    (* True when NDC origin is at bottom left. *)
    originBottomLeft: Boolean;
    (* Number of enumerated GPUs. *)
    numGPUs: UInt8;
    (* Enumerated GPUs. *)
    gpu: array [0..3] of bgfx_caps_gpu_t;
    (* Renderer runtime limits. *)
    limits: bgfx_caps_limits_t;
    (* Supported texture format capabilities flags. *)
    formats: array [0..84] of UInt16;
  end;

  (* Renderer capabilities. *)
  bgfx_caps_t = bgfx_caps_s;
  Pbgfx_caps_t = ^bgfx_caps_t;

  (* Internal data. *)
  bgfx_internal_data_s = record
    (* Renderer capabilities. *)
    caps: Pbgfx_caps_t;
    (* GL context, or D3D device. *)
    context: Pointer;
  end;

  (* Internal data. *)
  bgfx_internal_data_t = bgfx_internal_data_s;
  Pbgfx_internal_data_t = ^bgfx_internal_data_t;

  (* Platform data. *)
  bgfx_platform_data_s = record
    (* Native display type (Unix specific). *)
    ndt: Pointer;
    (* Native window handle. If `NULL` bgfx will create headless
       context/device if renderer API supports it. *)
    nwh: Pointer;
    (* GL context, or D3D device. If `NULL`, bgfx will create context/device. *)
    context: Pointer;
    (* GL back-buffer, or D3D render target view. If `NULL` bgfx will
       create back-buffer color surface. *)
    backBuffer: Pointer;
    (* Backbuffer depth/stencil. If `NULL` bgfx will create back-buffer
       depth/stencil surface. *)
    backBufferDS: Pointer;
  end;

  (* Platform data. *)
  bgfx_platform_data_t = bgfx_platform_data_s;
  Pbgfx_platform_data_t = ^bgfx_platform_data_t;

  (* Backbuffer resolution and reset parameters. *)
  bgfx_resolution_s = record
    (* Backbuffer format. *)
    format: bgfx_texture_format_t;
    (* Backbuffer width. *)
    width: UInt32;
    (* Backbuffer height. *)
    height: UInt32;
    (* Reset parameters. *)
    reset: UInt32;
    (* Number of back buffers. *)
    numBackBuffers: UInt8;
    (* Maximum frame latency. *)
    maxFrameLatency: UInt8;
  end;

  (* Backbuffer resolution and reset parameters. *)
  bgfx_resolution_t = bgfx_resolution_s;

  (* Configurable runtime limits parameters. *)
  bgfx_init_limits_s = record
    (* Maximum number of encoder threads. *)
    maxEncoders: UInt16;
    (* Minimum resource command buffer size. *)
    minResourceCbSize: UInt32;
    (* Maximum transient vertex buffer size. *)
    transientVbSize: UInt32;
    (* Maximum transient index buffer size. *)
    transientIbSize: UInt32;
  end;

  (* Configurable runtime limits parameters. *)
  bgfx_init_limits_t = bgfx_init_limits_s;

  (* Initialization parameters used by `bgfx::init`. *)
  bgfx_init_s = record
    (* Select rendering backend. *)
    _type: bgfx_renderer_type_t;
    (* Vendor PCI id. *)
    vendorId: UInt16;
    (* Device id. *)
    deviceId: UInt16;
    (* Capabilities initialization mask (default: UINT64_MAX). *)
    capabilities: UInt64;
    (* Enable device for debuging. *)
    debug: Boolean;
    (* Enable device for profiling. *)
    profile: Boolean;
    (* Platform data. *)
    platformData: bgfx_platform_data_t;
    (* Backbuffer resolution and reset parameters. See: `bgfx::Resolution`. *)
    resolution: bgfx_resolution_t;
    (* Configurable runtime limits parameters. *)
    limits: bgfx_init_limits_t;
    (* Provide application specific callback interface. *)
    callback: Pbgfx_callback_interface_t;
    (* Custom allocator. *)
    allocator: Pbgfx_allocator_interface_t;
  end;

  (* Initialization parameters used by `bgfx::init`. *)
  bgfx_init_t = bgfx_init_s;
  Pbgfx_init_t = ^bgfx_init_t;

  (* Memory. *)
  bgfx_memory_s = record
    (* Pointer to data. *)
    data: PUInt8;
    (* Data size. *)
    size: UInt32;
  end;

  (* Memory. *)
  bgfx_memory_t = bgfx_memory_s;
  Pbgfx_memory_t = ^bgfx_memory_t;

  (* Transient index buffer. *)
  bgfx_transient_index_buffer_s = record
    (* Pointer to data. *)
    data: PUInt8;
    (* Data size. *)
    size: UInt32;
    (* First index. *)
    startIndex: UInt32;
    (* Index buffer handle. *)
    handle: bgfx_index_buffer_handle_t;
    (* Index buffer format is 16-bits if true, otherwise it is 32-bit. *)
    isIndex16: Boolean;
  end;

  (* Transient index buffer. *)
  bgfx_transient_index_buffer_t = bgfx_transient_index_buffer_s;
  Pbgfx_transient_index_buffer_t = ^bgfx_transient_index_buffer_t;

  (* Transient vertex buffer. *)
  bgfx_transient_vertex_buffer_s = record
    (* Pointer to data. *)
    data: PUInt8;
    (* Data size. *)
    size: UInt32;
    (* First vertex. *)
    startVertex: UInt32;
    (* Vertex stride. *)
    stride: UInt16;
    (* Vertex buffer handle. *)
    handle: bgfx_vertex_buffer_handle_t;
    (* Vertex layout handle. *)
    layoutHandle: bgfx_vertex_layout_handle_t;
  end;

  (* Transient vertex buffer. *)
  bgfx_transient_vertex_buffer_t = bgfx_transient_vertex_buffer_s;
  Pbgfx_transient_vertex_buffer_t = ^bgfx_transient_vertex_buffer_t;

  (* Instance data buffer info. *)
  bgfx_instance_data_buffer_s = record
    (* Pointer to data. *)
    data: PUInt8;
    (* Data size. *)
    size: UInt32;
    (* Offset in vertex buffer. *)
    offset: UInt32;
    (* Number of instances. *)
    num: UInt32;
    (* Vertex buffer stride. *)
    stride: UInt16;
    (* Vertex buffer object handle. *)
    handle: bgfx_vertex_buffer_handle_t;
  end;

  (* Instance data buffer info. *)
  bgfx_instance_data_buffer_t = bgfx_instance_data_buffer_s;
  Pbgfx_instance_data_buffer_t = ^bgfx_instance_data_buffer_t;

  (* Texture info. *)
  bgfx_texture_info_s = record
    (* Texture format. *)
    format: bgfx_texture_format_t;
    (* Total amount of bytes required to store texture. *)
    storageSize: UInt32;
    (* Texture width. *)
    width: UInt16;
    (* Texture height. *)
    height: UInt16;
    (* Texture depth. *)
    depth: UInt16;
    (* Number of layers in texture array. *)
    numLayers: UInt16;
    (* Number of MIP maps. *)
    numMips: UInt8;
    (* Format bits per pixel. *)
    bitsPerPixel: UInt8;
    (* Texture is cubemap. *)
    cubeMap: Boolean;
  end;

  (* Texture info. *)
  bgfx_texture_info_t = bgfx_texture_info_s;
  Pbgfx_texture_info_t = ^bgfx_texture_info_t;

  (* Uniform info. *)
  bgfx_uniform_info_s = record
    (* Uniform name. *)
    name: array [0..255] of UTF8Char;
    (* Uniform type. *)
    _type: bgfx_uniform_type_t;
    (* Number of elements in array. *)
    num: UInt16;
  end;

  (* Uniform info. *)
  bgfx_uniform_info_t = bgfx_uniform_info_s;
  Pbgfx_uniform_info_t = ^bgfx_uniform_info_t;

  (* Frame buffer texture attachment info. *)
  bgfx_attachment_s = record
    (* Attachment access. See `Access::Enum`. *)
    access: bgfx_access_t;
    (* Render target texture handle. *)
    handle: bgfx_texture_handle_t;
    (* Mip level. *)
    mip: UInt16;
    (* Cubemap side or depth layer/slice to use. *)
    layer: UInt16;
    (* Number of texture layer/slice(s) in array to use. *)
    numLayers: UInt16;
    (* Resolve flags. See: `BGFX_RESOLVE_*` *)
    resolve: UInt8;
  end;

  (* Frame buffer texture attachment info. *)
  bgfx_attachment_t = bgfx_attachment_s;
  Pbgfx_attachment_t = ^bgfx_attachment_t;

  (* Transform data. *)
  bgfx_transform_s = record
    (* Pointer to first 4x4 matrix. *)
    data: PSingle;
    (* Number of matrices. *)
    num: UInt16;
  end;

  (* Transform data. *)
  bgfx_transform_t = bgfx_transform_s;
  Pbgfx_transform_t = ^bgfx_transform_t;

  (* View stats. *)
  bgfx_view_stats_s = record
    (* View name. *)
    name: array [0..255] of UTF8Char;
    (* View id. *)
    view: bgfx_view_id_t;
    (* CPU (submit) begin time. *)
    cpuTimeBegin: Int64;
    (* CPU (submit) end time. *)
    cpuTimeEnd: Int64;
    (* GPU begin time. *)
    gpuTimeBegin: Int64;
    (* GPU end time. *)
    gpuTimeEnd: Int64;
  end;

  (* View stats. *)
  bgfx_view_stats_t = bgfx_view_stats_s;
  Pbgfx_view_stats_t = ^bgfx_view_stats_t;

  (* Encoder stats. *)
  bgfx_encoder_stats_s = record
    (* Encoder thread CPU submit begin time. *)
    cpuTimeBegin: Int64;
    (* Encoder thread CPU submit end time. *)
    cpuTimeEnd: Int64;
  end;

  (* Encoder stats. *)
  bgfx_encoder_stats_t = bgfx_encoder_stats_s;
  Pbgfx_encoder_stats_t = ^bgfx_encoder_stats_t;

  (* Renderer statistics data. *)
  bgfx_stats_s = record
    (* CPU time between two `bgfx::frame` calls. *)
    cpuTimeFrame: Int64;
    (* Render thread CPU submit begin time. *)
    cpuTimeBegin: Int64;
    (* Render thread CPU submit end time. *)
    cpuTimeEnd: Int64;
    (* CPU timer frequency. Timestamps-per-second *)
    cpuTimerFreq: Int64;
    (* GPU frame begin time. *)
    gpuTimeBegin: Int64;
    (* GPU frame end time. *)
    gpuTimeEnd: Int64;
    (* GPU timer frequency. *)
    gpuTimerFreq: Int64;
    (* Time spent waiting for render backend thread. *)
    waitRender: Int64;
    (* Time spent waiting for submit thread. *)
    waitSubmit: Int64;
    (* Number of draw calls submitted. *)
    numDraw: UInt32;
    (* Number of compute calls submitted. *)
    numCompute: UInt32;
    (* Number of blit calls submitted. *)
    numBlit: UInt32;
    (* GPU driver latency. *)
    maxGpuLatency: UInt32;
    (* Number of used dynamic index buffers. *)
    numDynamicIndexBuffers: UInt16;
    (* Number of used dynamic vertex buffers. *)
    numDynamicVertexBuffers: UInt16;
    (* Number of used frame buffers. *)
    numFrameBuffers: UInt16;
    (* Number of used index buffers. *)
    numIndexBuffers: UInt16;
    (* Number of used occlusion queries. *)
    numOcclusionQueries: UInt16;
    (* Number of used programs. *)
    numPrograms: UInt16;
    (* Number of used shaders. *)
    numShaders: UInt16;
    (* Number of used textures. *)
    numTextures: UInt16;
    (* Number of used uniforms. *)
    numUniforms: UInt16;
    (* Number of used vertex buffers. *)
    numVertexBuffers: UInt16;
    (* Number of used vertex layouts. *)
    numVertexLayouts: UInt16;
    (* Estimate of texture memory used. *)
    textureMemoryUsed: Int64;
    (* Estimate of render target memory used. *)
    rtMemoryUsed: Int64;
    (* Amount of transient vertex buffer used. *)
    transientVbUsed: Int32;
    (* Amount of transient index buffer used. *)
    transientIbUsed: Int32;
    (* Number of primitives rendered. *)
    numPrims: array [0..4] of UInt32;
    (* Maximum available GPU memory for application. *)
    gpuMemoryMax: Int64;
    (* Amount of GPU memory used by the application. *)
    gpuMemoryUsed: Int64;
    (* Backbuffer width in pixels. *)
    width: UInt16;
    (* Backbuffer height in pixels. *)
    height: UInt16;
    (* Debug text width in characters. *)
    textWidth: UInt16;
    (* Debug text height in characters. *)
    textHeight: UInt16;
    (* Number of view stats. *)
    numViews: UInt16;
    (* Array of View stats. *)
    viewStats: Pbgfx_view_stats_t;
    (* Number of encoders used during frame. *)
    numEncoders: UInt8;
    (* Array of encoder stats. *)
    encoderStats: Pbgfx_encoder_stats_t;
  end;

  (* Renderer statistics data. *)
  bgfx_stats_t = bgfx_stats_s;
  Pbgfx_stats_t = ^bgfx_stats_t;

  (* Vertex layout. *)
  bgfx_vertex_layout_s = record
    (* Hash. *)
    hash: UInt32;
    (* Stride. *)
    stride: UInt16;
    (* Attribute offsets. *)
    offset: array [0..17] of UInt16;
    (* Used attributes. *)
    attributes: array [0..17] of UInt16;
  end;

  (* Vertex layout. *)
  bgfx_vertex_layout_t = bgfx_vertex_layout_s;
  Pbgfx_vertex_layout_t = ^bgfx_vertex_layout_t;
  Pbgfx_encoder_t = Pointer;
  PPbgfx_encoder_t = ^Pbgfx_encoder_t;

  bgfx_function_id = (
    BGFX_FUNCTION_ID_ATTACHMENT_INIT = 0,
    BGFX_FUNCTION_ID_VERTEX_LAYOUT_BEGIN = 1,
    BGFX_FUNCTION_ID_VERTEX_LAYOUT_ADD = 2,
    BGFX_FUNCTION_ID_VERTEX_LAYOUT_DECODE = 3,
    BGFX_FUNCTION_ID_VERTEX_LAYOUT_HAS = 4,
    BGFX_FUNCTION_ID_VERTEX_LAYOUT_SKIP = 5,
    BGFX_FUNCTION_ID_VERTEX_LAYOUT_END = 6,
    BGFX_FUNCTION_ID_VERTEX_PACK = 7,
    BGFX_FUNCTION_ID_VERTEX_UNPACK = 8,
    BGFX_FUNCTION_ID_VERTEX_CONVERT = 9,
    BGFX_FUNCTION_ID_WELD_VERTICES = 10,
    BGFX_FUNCTION_ID_TOPOLOGY_CONVERT = 11,
    BGFX_FUNCTION_ID_TOPOLOGY_SORT_TRI_LIST = 12,
    BGFX_FUNCTION_ID_GET_SUPPORTED_RENDERERS = 13,
    BGFX_FUNCTION_ID_GET_RENDERER_NAME = 14,
    BGFX_FUNCTION_ID_INIT_CTOR = 15,
    BGFX_FUNCTION_ID_INIT = 16,
    BGFX_FUNCTION_ID_SHUTDOWN = 17,
    BGFX_FUNCTION_ID_RESET = 18,
    BGFX_FUNCTION_ID_FRAME = 19,
    BGFX_FUNCTION_ID_GET_RENDERER_TYPE = 20,
    BGFX_FUNCTION_ID_GET_CAPS = 21,
    BGFX_FUNCTION_ID_GET_STATS = 22,
    BGFX_FUNCTION_ID_ALLOC = 23,
    BGFX_FUNCTION_ID_COPY = 24,
    BGFX_FUNCTION_ID_MAKE_REF = 25,
    BGFX_FUNCTION_ID_MAKE_REF_RELEASE = 26,
    BGFX_FUNCTION_ID_SET_DEBUG = 27,
    BGFX_FUNCTION_ID_DBG_TEXT_CLEAR = 28,
    BGFX_FUNCTION_ID_DBG_TEXT_PRINTF = 29,
    BGFX_FUNCTION_ID_DBG_TEXT_VPRINTF = 30,
    BGFX_FUNCTION_ID_DBG_TEXT_IMAGE = 31,
    BGFX_FUNCTION_ID_CREATE_INDEX_BUFFER = 32,
    BGFX_FUNCTION_ID_SET_INDEX_BUFFER_NAME = 33,
    BGFX_FUNCTION_ID_DESTROY_INDEX_BUFFER = 34,
    BGFX_FUNCTION_ID_CREATE_VERTEX_LAYOUT = 35,
    BGFX_FUNCTION_ID_DESTROY_VERTEX_LAYOUT = 36,
    BGFX_FUNCTION_ID_CREATE_VERTEX_BUFFER = 37,
    BGFX_FUNCTION_ID_SET_VERTEX_BUFFER_NAME = 38,
    BGFX_FUNCTION_ID_DESTROY_VERTEX_BUFFER = 39,
    BGFX_FUNCTION_ID_CREATE_DYNAMIC_INDEX_BUFFER = 40,
    BGFX_FUNCTION_ID_CREATE_DYNAMIC_INDEX_BUFFER_MEM = 41,
    BGFX_FUNCTION_ID_UPDATE_DYNAMIC_INDEX_BUFFER = 42,
    BGFX_FUNCTION_ID_DESTROY_DYNAMIC_INDEX_BUFFER = 43,
    BGFX_FUNCTION_ID_CREATE_DYNAMIC_VERTEX_BUFFER = 44,
    BGFX_FUNCTION_ID_CREATE_DYNAMIC_VERTEX_BUFFER_MEM = 45,
    BGFX_FUNCTION_ID_UPDATE_DYNAMIC_VERTEX_BUFFER = 46,
    BGFX_FUNCTION_ID_DESTROY_DYNAMIC_VERTEX_BUFFER = 47,
    BGFX_FUNCTION_ID_GET_AVAIL_TRANSIENT_INDEX_BUFFER = 48,
    BGFX_FUNCTION_ID_GET_AVAIL_TRANSIENT_VERTEX_BUFFER = 49,
    BGFX_FUNCTION_ID_GET_AVAIL_INSTANCE_DATA_BUFFER = 50,
    BGFX_FUNCTION_ID_ALLOC_TRANSIENT_INDEX_BUFFER = 51,
    BGFX_FUNCTION_ID_ALLOC_TRANSIENT_VERTEX_BUFFER = 52,
    BGFX_FUNCTION_ID_ALLOC_TRANSIENT_BUFFERS = 53,
    BGFX_FUNCTION_ID_ALLOC_INSTANCE_DATA_BUFFER = 54,
    BGFX_FUNCTION_ID_CREATE_INDIRECT_BUFFER = 55,
    BGFX_FUNCTION_ID_DESTROY_INDIRECT_BUFFER = 56,
    BGFX_FUNCTION_ID_CREATE_SHADER = 57,
    BGFX_FUNCTION_ID_GET_SHADER_UNIFORMS = 58,
    BGFX_FUNCTION_ID_SET_SHADER_NAME = 59,
    BGFX_FUNCTION_ID_DESTROY_SHADER = 60,
    BGFX_FUNCTION_ID_CREATE_PROGRAM = 61,
    BGFX_FUNCTION_ID_CREATE_COMPUTE_PROGRAM = 62,
    BGFX_FUNCTION_ID_DESTROY_PROGRAM = 63,
    BGFX_FUNCTION_ID_IS_TEXTURE_VALID = 64,
    BGFX_FUNCTION_ID_IS_FRAME_BUFFER_VALID = 65,
    BGFX_FUNCTION_ID_CALC_TEXTURE_SIZE = 66,
    BGFX_FUNCTION_ID_CREATE_TEXTURE = 67,
    BGFX_FUNCTION_ID_CREATE_TEXTURE_2D = 68,
    BGFX_FUNCTION_ID_CREATE_TEXTURE_2D_SCALED = 69,
    BGFX_FUNCTION_ID_CREATE_TEXTURE_3D = 70,
    BGFX_FUNCTION_ID_CREATE_TEXTURE_CUBE = 71,
    BGFX_FUNCTION_ID_UPDATE_TEXTURE_2D = 72,
    BGFX_FUNCTION_ID_UPDATE_TEXTURE_3D = 73,
    BGFX_FUNCTION_ID_UPDATE_TEXTURE_CUBE = 74,
    BGFX_FUNCTION_ID_READ_TEXTURE = 75,
    BGFX_FUNCTION_ID_SET_TEXTURE_NAME = 76,
    BGFX_FUNCTION_ID_GET_DIRECT_ACCESS_PTR = 77,
    BGFX_FUNCTION_ID_DESTROY_TEXTURE = 78,
    BGFX_FUNCTION_ID_CREATE_FRAME_BUFFER = 79,
    BGFX_FUNCTION_ID_CREATE_FRAME_BUFFER_SCALED = 80,
    BGFX_FUNCTION_ID_CREATE_FRAME_BUFFER_FROM_HANDLES = 81,
    BGFX_FUNCTION_ID_CREATE_FRAME_BUFFER_FROM_ATTACHMENT = 82,
    BGFX_FUNCTION_ID_CREATE_FRAME_BUFFER_FROM_NWH = 83,
    BGFX_FUNCTION_ID_SET_FRAME_BUFFER_NAME = 84,
    BGFX_FUNCTION_ID_GET_TEXTURE = 85,
    BGFX_FUNCTION_ID_DESTROY_FRAME_BUFFER = 86,
    BGFX_FUNCTION_ID_CREATE_UNIFORM = 87,
    BGFX_FUNCTION_ID_GET_UNIFORM_INFO = 88,
    BGFX_FUNCTION_ID_DESTROY_UNIFORM = 89,
    BGFX_FUNCTION_ID_CREATE_OCCLUSION_QUERY = 90,
    BGFX_FUNCTION_ID_GET_RESULT = 91,
    BGFX_FUNCTION_ID_DESTROY_OCCLUSION_QUERY = 92,
    BGFX_FUNCTION_ID_SET_PALETTE_COLOR = 93,
    BGFX_FUNCTION_ID_SET_PALETTE_COLOR_RGBA8 = 94,
    BGFX_FUNCTION_ID_SET_VIEW_NAME = 95,
    BGFX_FUNCTION_ID_SET_VIEW_RECT = 96,
    BGFX_FUNCTION_ID_SET_VIEW_RECT_RATIO = 97,
    BGFX_FUNCTION_ID_SET_VIEW_SCISSOR = 98,
    BGFX_FUNCTION_ID_SET_VIEW_CLEAR = 99,
    BGFX_FUNCTION_ID_SET_VIEW_CLEAR_MRT = 100,
    BGFX_FUNCTION_ID_SET_VIEW_MODE = 101,
    BGFX_FUNCTION_ID_SET_VIEW_FRAME_BUFFER = 102,
    BGFX_FUNCTION_ID_SET_VIEW_TRANSFORM = 103,
    BGFX_FUNCTION_ID_SET_VIEW_ORDER = 104,
    BGFX_FUNCTION_ID_RESET_VIEW = 105,
    BGFX_FUNCTION_ID_ENCODER_BEGIN = 106,
    BGFX_FUNCTION_ID_ENCODER_END = 107,
    BGFX_FUNCTION_ID_ENCODER_SET_MARKER = 108,
    BGFX_FUNCTION_ID_ENCODER_SET_STATE = 109,
    BGFX_FUNCTION_ID_ENCODER_SET_CONDITION = 110,
    BGFX_FUNCTION_ID_ENCODER_SET_STENCIL = 111,
    BGFX_FUNCTION_ID_ENCODER_SET_SCISSOR = 112,
    BGFX_FUNCTION_ID_ENCODER_SET_SCISSOR_CACHED = 113,
    BGFX_FUNCTION_ID_ENCODER_SET_TRANSFORM = 114,
    BGFX_FUNCTION_ID_ENCODER_SET_TRANSFORM_CACHED = 115,
    BGFX_FUNCTION_ID_ENCODER_ALLOC_TRANSFORM = 116,
    BGFX_FUNCTION_ID_ENCODER_SET_UNIFORM = 117,
    BGFX_FUNCTION_ID_ENCODER_SET_INDEX_BUFFER = 118,
    BGFX_FUNCTION_ID_ENCODER_SET_DYNAMIC_INDEX_BUFFER = 119,
    BGFX_FUNCTION_ID_ENCODER_SET_TRANSIENT_INDEX_BUFFER = 120,
    BGFX_FUNCTION_ID_ENCODER_SET_VERTEX_BUFFER = 121,
    BGFX_FUNCTION_ID_ENCODER_SET_VERTEX_BUFFER_WITH_LAYOUT = 122,
    BGFX_FUNCTION_ID_ENCODER_SET_DYNAMIC_VERTEX_BUFFER = 123,
    BGFX_FUNCTION_ID_ENCODER_SET_DYNAMIC_VERTEX_BUFFER_WITH_LAYOUT = 124,
    BGFX_FUNCTION_ID_ENCODER_SET_TRANSIENT_VERTEX_BUFFER = 125,
    BGFX_FUNCTION_ID_ENCODER_SET_TRANSIENT_VERTEX_BUFFER_WITH_LAYOUT = 126,
    BGFX_FUNCTION_ID_ENCODER_SET_VERTEX_COUNT = 127,
    BGFX_FUNCTION_ID_ENCODER_SET_INSTANCE_DATA_BUFFER = 128,
    BGFX_FUNCTION_ID_ENCODER_SET_INSTANCE_DATA_FROM_VERTEX_BUFFER = 129,
    BGFX_FUNCTION_ID_ENCODER_SET_INSTANCE_DATA_FROM_DYNAMIC_VERTEX_BUFFER = 130,
    BGFX_FUNCTION_ID_ENCODER_SET_INSTANCE_COUNT = 131,
    BGFX_FUNCTION_ID_ENCODER_SET_TEXTURE = 132,
    BGFX_FUNCTION_ID_ENCODER_TOUCH = 133,
    BGFX_FUNCTION_ID_ENCODER_SUBMIT = 134,
    BGFX_FUNCTION_ID_ENCODER_SUBMIT_OCCLUSION_QUERY = 135,
    BGFX_FUNCTION_ID_ENCODER_SUBMIT_INDIRECT = 136,
    BGFX_FUNCTION_ID_ENCODER_SET_COMPUTE_INDEX_BUFFER = 137,
    BGFX_FUNCTION_ID_ENCODER_SET_COMPUTE_VERTEX_BUFFER = 138,
    BGFX_FUNCTION_ID_ENCODER_SET_COMPUTE_DYNAMIC_INDEX_BUFFER = 139,
    BGFX_FUNCTION_ID_ENCODER_SET_COMPUTE_DYNAMIC_VERTEX_BUFFER = 140,
    BGFX_FUNCTION_ID_ENCODER_SET_COMPUTE_INDIRECT_BUFFER = 141,
    BGFX_FUNCTION_ID_ENCODER_SET_IMAGE = 142,
    BGFX_FUNCTION_ID_ENCODER_DISPATCH = 143,
    BGFX_FUNCTION_ID_ENCODER_DISPATCH_INDIRECT = 144,
    BGFX_FUNCTION_ID_ENCODER_DISCARD = 145,
    BGFX_FUNCTION_ID_ENCODER_BLIT = 146,
    BGFX_FUNCTION_ID_REQUEST_SCREEN_SHOT = 147,
    BGFX_FUNCTION_ID_RENDER_FRAME = 148,
    BGFX_FUNCTION_ID_SET_PLATFORM_DATA = 149,
    BGFX_FUNCTION_ID_GET_INTERNAL_DATA = 150,
    BGFX_FUNCTION_ID_OVERRIDE_INTERNAL_TEXTURE_PTR = 151,
    BGFX_FUNCTION_ID_OVERRIDE_INTERNAL_TEXTURE = 152,
    BGFX_FUNCTION_ID_SET_MARKER = 153,
    BGFX_FUNCTION_ID_SET_STATE = 154,
    BGFX_FUNCTION_ID_SET_CONDITION = 155,
    BGFX_FUNCTION_ID_SET_STENCIL = 156,
    BGFX_FUNCTION_ID_SET_SCISSOR = 157,
    BGFX_FUNCTION_ID_SET_SCISSOR_CACHED = 158,
    BGFX_FUNCTION_ID_SET_TRANSFORM = 159,
    BGFX_FUNCTION_ID_SET_TRANSFORM_CACHED = 160,
    BGFX_FUNCTION_ID_ALLOC_TRANSFORM = 161,
    BGFX_FUNCTION_ID_SET_UNIFORM = 162,
    BGFX_FUNCTION_ID_SET_INDEX_BUFFER = 163,
    BGFX_FUNCTION_ID_SET_DYNAMIC_INDEX_BUFFER = 164,
    BGFX_FUNCTION_ID_SET_TRANSIENT_INDEX_BUFFER = 165,
    BGFX_FUNCTION_ID_SET_VERTEX_BUFFER = 166,
    BGFX_FUNCTION_ID_SET_VERTEX_BUFFER_WITH_LAYOUT = 167,
    BGFX_FUNCTION_ID_SET_DYNAMIC_VERTEX_BUFFER = 168,
    BGFX_FUNCTION_ID_SET_DYNAMIC_VERTEX_BUFFER_WITH_LAYOUT = 169,
    BGFX_FUNCTION_ID_SET_TRANSIENT_VERTEX_BUFFER = 170,
    BGFX_FUNCTION_ID_SET_TRANSIENT_VERTEX_BUFFER_WITH_LAYOUT = 171,
    BGFX_FUNCTION_ID_SET_VERTEX_COUNT = 172,
    BGFX_FUNCTION_ID_SET_INSTANCE_DATA_BUFFER = 173,
    BGFX_FUNCTION_ID_SET_INSTANCE_DATA_FROM_VERTEX_BUFFER = 174,
    BGFX_FUNCTION_ID_SET_INSTANCE_DATA_FROM_DYNAMIC_VERTEX_BUFFER = 175,
    BGFX_FUNCTION_ID_SET_INSTANCE_COUNT = 176,
    BGFX_FUNCTION_ID_SET_TEXTURE = 177,
    BGFX_FUNCTION_ID_TOUCH = 178,
    BGFX_FUNCTION_ID_SUBMIT = 179,
    BGFX_FUNCTION_ID_SUBMIT_OCCLUSION_QUERY = 180,
    BGFX_FUNCTION_ID_SUBMIT_INDIRECT = 181,
    BGFX_FUNCTION_ID_SET_COMPUTE_INDEX_BUFFER = 182,
    BGFX_FUNCTION_ID_SET_COMPUTE_VERTEX_BUFFER = 183,
    BGFX_FUNCTION_ID_SET_COMPUTE_DYNAMIC_INDEX_BUFFER = 184,
    BGFX_FUNCTION_ID_SET_COMPUTE_DYNAMIC_VERTEX_BUFFER = 185,
    BGFX_FUNCTION_ID_SET_COMPUTE_INDIRECT_BUFFER = 186,
    BGFX_FUNCTION_ID_SET_IMAGE = 187,
    BGFX_FUNCTION_ID_DISPATCH = 188,
    BGFX_FUNCTION_ID_DISPATCH_INDIRECT = 189,
    BGFX_FUNCTION_ID_DISCARD = 190,
    BGFX_FUNCTION_ID_BLIT = 191,
    BGFX_FUNCTION_ID_COUNT = 192);
  Pbgfx_function_id = ^bgfx_function_id;
  bgfx_function_id_t = bgfx_function_id;

  bgfx_interface_vtbl = record
    attachment_init: procedure(_this: Pbgfx_attachment_t; _handle: bgfx_texture_handle_t; _access: bgfx_access_t; _layer: UInt16; _numLayers: UInt16; _mip: UInt16; _resolve: UInt8); cdecl;
    vertex_layout_begin: function(_this: Pbgfx_vertex_layout_t; _rendererType: bgfx_renderer_type_t): Pbgfx_vertex_layout_t; cdecl;
    vertex_layout_add: function(_this: Pbgfx_vertex_layout_t; _attrib: bgfx_attrib_t; _num: UInt8; _type: bgfx_attrib_type_t; _normalized: Boolean; _asInt: Boolean): Pbgfx_vertex_layout_t; cdecl;
    vertex_layout_decode: procedure(const _this: Pbgfx_vertex_layout_t; _attrib: bgfx_attrib_t; _num: PUInt8; _type: Pbgfx_attrib_type_t; _normalized: PBoolean; _asInt: PBoolean); cdecl;
    vertex_layout_has: function(const _this: Pbgfx_vertex_layout_t; _attrib: bgfx_attrib_t): Boolean; cdecl;
    vertex_layout_skip: function(_this: Pbgfx_vertex_layout_t; _num: UInt8): Pbgfx_vertex_layout_t; cdecl;
    vertex_layout_end: procedure(_this: Pbgfx_vertex_layout_t); cdecl;
    vertex_pack: procedure(_input: PSingle; _inputNormalized: Boolean; _attr: bgfx_attrib_t; const _layout: Pbgfx_vertex_layout_t; _data: Pointer; _index: UInt32); cdecl;
    vertex_unpack: procedure(_output: PSingle; _attr: bgfx_attrib_t; const _layout: Pbgfx_vertex_layout_t; const _data: Pointer; _index: UInt32); cdecl;
    vertex_convert: procedure(const _dstLayout: Pbgfx_vertex_layout_t; _dstData: Pointer; const _srcLayout: Pbgfx_vertex_layout_t; const _srcData: Pointer; _num: UInt32); cdecl;
    weld_vertices: function(_output: Pointer; const _layout: Pbgfx_vertex_layout_t; const _data: Pointer; _num: UInt32; _index32: Boolean; _epsilon: Single): UInt32; cdecl;
    topology_convert: function(_conversion: bgfx_topology_convert_t; _dst: Pointer; _dstSize: UInt32; const _indices: Pointer; _numIndices: UInt32; _index32: Boolean): UInt32; cdecl;
    topology_sort_tri_list: procedure(_sort: bgfx_topology_sort_t; _dst: Pointer; _dstSize: UInt32; _dir: PSingle; _pos: PSingle; const _vertices: Pointer; _stride: UInt32; const _indices: Pointer; _numIndices: UInt32; _index32: Boolean); cdecl;
    get_supported_renderers: function(_max: UInt8; _enum: Pbgfx_renderer_type_t): UInt8; cdecl;
    get_renderer_name: function(_type: bgfx_renderer_type_t): PUTF8Char; cdecl;
    init_ctor: procedure(_init: Pbgfx_init_t); cdecl;
    init: function(const _init: Pbgfx_init_t): Boolean; cdecl;
    shutdown: procedure(); cdecl;
    reset: procedure(_width: UInt32; _height: UInt32; _flags: UInt32; _format: bgfx_texture_format_t); cdecl;
    frame: function(_capture: Boolean): UInt32; cdecl;
    get_renderer_type: function(): bgfx_renderer_type_t; cdecl;
    get_caps: function(): Pbgfx_caps_t; cdecl;
    get_stats: function(): Pbgfx_stats_t; cdecl;
    alloc: function(_size: UInt32): Pbgfx_memory_t; cdecl;
    copy: function(const _data: Pointer; _size: UInt32): Pbgfx_memory_t; cdecl;
    make_ref: function(const _data: Pointer; _size: UInt32): Pbgfx_memory_t; cdecl;
    make_ref_release: function(const _data: Pointer; _size: UInt32; _releaseFn: bgfx_release_fn_t; _userData: Pointer): Pbgfx_memory_t; cdecl;
    set_debug: procedure(_debug: UInt32); cdecl;
    dbg_text_clear: procedure(_attr: UInt8; _small: Boolean); cdecl;
    dbg_text_printf: procedure(_x: UInt16; _y: UInt16; _attr: UInt8; const _format: PUTF8Char) varargs; cdecl;
    dbg_text_vprintf: procedure(_x: UInt16; _y: UInt16; _attr: UInt8; const _format: PUTF8Char; _argList: Pointer); cdecl;
    dbg_text_image: procedure(_x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16; const _data: Pointer; _pitch: UInt16); cdecl;
    create_index_buffer: function(const _mem: Pbgfx_memory_t; _flags: UInt16): bgfx_index_buffer_handle_t; cdecl;
    set_index_buffer_name: procedure(_handle: bgfx_index_buffer_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
    destroy_index_buffer: procedure(_handle: bgfx_index_buffer_handle_t); cdecl;
    create_vertex_layout: function(const _layout: Pbgfx_vertex_layout_t): bgfx_vertex_layout_handle_t; cdecl;
    destroy_vertex_layout: procedure(_layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
    create_vertex_buffer: function(const _mem: Pbgfx_memory_t; const _layout: Pbgfx_vertex_layout_t; _flags: UInt16): bgfx_vertex_buffer_handle_t; cdecl;
    set_vertex_buffer_name: procedure(_handle: bgfx_vertex_buffer_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
    destroy_vertex_buffer: procedure(_handle: bgfx_vertex_buffer_handle_t); cdecl;
    create_dynamic_index_buffer: function(_num: UInt32; _flags: UInt16): bgfx_dynamic_index_buffer_handle_t; cdecl;
    create_dynamic_index_buffer_mem: function(const _mem: Pbgfx_memory_t; _flags: UInt16): bgfx_dynamic_index_buffer_handle_t; cdecl;
    update_dynamic_index_buffer: procedure(_handle: bgfx_dynamic_index_buffer_handle_t; _startIndex: UInt32; const _mem: Pbgfx_memory_t); cdecl;
    destroy_dynamic_index_buffer: procedure(_handle: bgfx_dynamic_index_buffer_handle_t); cdecl;
    create_dynamic_vertex_buffer: function(_num: UInt32; const _layout: Pbgfx_vertex_layout_t; _flags: UInt16): bgfx_dynamic_vertex_buffer_handle_t; cdecl;
    create_dynamic_vertex_buffer_mem: function(const _mem: Pbgfx_memory_t; const _layout: Pbgfx_vertex_layout_t; _flags: UInt16): bgfx_dynamic_vertex_buffer_handle_t; cdecl;
    update_dynamic_vertex_buffer: procedure(_handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; const _mem: Pbgfx_memory_t); cdecl;
    destroy_dynamic_vertex_buffer: procedure(_handle: bgfx_dynamic_vertex_buffer_handle_t); cdecl;
    get_avail_transient_index_buffer: function(_num: UInt32; _index32: Boolean): UInt32; cdecl;
    get_avail_transient_vertex_buffer: function(_num: UInt32; const _layout: Pbgfx_vertex_layout_t): UInt32; cdecl;
    get_avail_instance_data_buffer: function(_num: UInt32; _stride: UInt16): UInt32; cdecl;
    alloc_transient_index_buffer: procedure(_tib: Pbgfx_transient_index_buffer_t; _num: UInt32; _index32: Boolean); cdecl;
    alloc_transient_vertex_buffer: procedure(_tvb: Pbgfx_transient_vertex_buffer_t; _num: UInt32; const _layout: Pbgfx_vertex_layout_t); cdecl;
    alloc_transient_buffers: function(_tvb: Pbgfx_transient_vertex_buffer_t; const _layout: Pbgfx_vertex_layout_t; _numVertices: UInt32; _tib: Pbgfx_transient_index_buffer_t; _numIndices: UInt32; _index32: Boolean): Boolean; cdecl;
    alloc_instance_data_buffer: procedure(_idb: Pbgfx_instance_data_buffer_t; _num: UInt32; _stride: UInt16); cdecl;
    create_indirect_buffer: function(_num: UInt32): bgfx_indirect_buffer_handle_t; cdecl;
    destroy_indirect_buffer: procedure(_handle: bgfx_indirect_buffer_handle_t); cdecl;
    create_shader: function(const _mem: Pbgfx_memory_t): bgfx_shader_handle_t; cdecl;
    get_shader_uniforms: function(_handle: bgfx_shader_handle_t; _uniforms: Pbgfx_uniform_handle_t; _max: UInt16): UInt16; cdecl;
    set_shader_name: procedure(_handle: bgfx_shader_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
    destroy_shader: procedure(_handle: bgfx_shader_handle_t); cdecl;
    create_program: function(_vsh: bgfx_shader_handle_t; _fsh: bgfx_shader_handle_t; _destroyShaders: Boolean): bgfx_program_handle_t; cdecl;
    create_compute_program: function(_csh: bgfx_shader_handle_t; _destroyShaders: Boolean): bgfx_program_handle_t; cdecl;
    destroy_program: procedure(_handle: bgfx_program_handle_t); cdecl;
    is_texture_valid: function(_depth: UInt16; _cubeMap: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64): Boolean; cdecl;
    is_frame_buffer_valid: function(_num: UInt8; const _attachment: Pbgfx_attachment_t): Boolean; cdecl;
    calc_texture_size: procedure(_info: Pbgfx_texture_info_t; _width: UInt16; _height: UInt16; _depth: UInt16; _cubeMap: Boolean; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t); cdecl;
    create_texture: function(const _mem: Pbgfx_memory_t; _flags: UInt64; _skip: UInt8; _info: Pbgfx_texture_info_t): bgfx_texture_handle_t; cdecl;
    create_texture_2d: function(_width: UInt16; _height: UInt16; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64; const _mem: Pbgfx_memory_t): bgfx_texture_handle_t; cdecl;
    create_texture_2d_scaled: function(_ratio: bgfx_backbuffer_ratio_t; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64): bgfx_texture_handle_t; cdecl;
    create_texture_3d: function(_width: UInt16; _height: UInt16; _depth: UInt16; _hasMips: Boolean; _format: bgfx_texture_format_t; _flags: UInt64; const _mem: Pbgfx_memory_t): bgfx_texture_handle_t; cdecl;
    create_texture_cube: function(_size: UInt16; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64; const _mem: Pbgfx_memory_t): bgfx_texture_handle_t; cdecl;
    update_texture_2d: procedure(_handle: bgfx_texture_handle_t; _layer: UInt16; _mip: UInt8; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16; const _mem: Pbgfx_memory_t; _pitch: UInt16); cdecl;
    update_texture_3d: procedure(_handle: bgfx_texture_handle_t; _mip: UInt8; _x: UInt16; _y: UInt16; _z: UInt16; _width: UInt16; _height: UInt16; _depth: UInt16; const _mem: Pbgfx_memory_t); cdecl;
    update_texture_cube: procedure(_handle: bgfx_texture_handle_t; _layer: UInt16; _side: UInt8; _mip: UInt8; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16; const _mem: Pbgfx_memory_t; _pitch: UInt16); cdecl;
    read_texture: function(_handle: bgfx_texture_handle_t; _data: Pointer; _mip: UInt8): UInt32; cdecl;
    set_texture_name: procedure(_handle: bgfx_texture_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
    get_direct_access_ptr: function(_handle: bgfx_texture_handle_t): Pointer; cdecl;
    destroy_texture: procedure(_handle: bgfx_texture_handle_t); cdecl;
    create_frame_buffer: function(_width: UInt16; _height: UInt16; _format: bgfx_texture_format_t; _textureFlags: UInt64): bgfx_frame_buffer_handle_t; cdecl;
    create_frame_buffer_scaled: function(_ratio: bgfx_backbuffer_ratio_t; _format: bgfx_texture_format_t; _textureFlags: UInt64): bgfx_frame_buffer_handle_t; cdecl;
    create_frame_buffer_from_handles: function(_num: UInt8; const _handles: Pbgfx_texture_handle_t; _destroyTexture: Boolean): bgfx_frame_buffer_handle_t; cdecl;
    create_frame_buffer_from_attachment: function(_num: UInt8; const _attachment: Pbgfx_attachment_t; _destroyTexture: Boolean): bgfx_frame_buffer_handle_t; cdecl;
    create_frame_buffer_from_nwh: function(_nwh: Pointer; _width: UInt16; _height: UInt16; _format: bgfx_texture_format_t; _depthFormat: bgfx_texture_format_t): bgfx_frame_buffer_handle_t; cdecl;
    set_frame_buffer_name: procedure(_handle: bgfx_frame_buffer_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
    get_texture: function(_handle: bgfx_frame_buffer_handle_t; _attachment: UInt8): bgfx_texture_handle_t; cdecl;
    destroy_frame_buffer: procedure(_handle: bgfx_frame_buffer_handle_t); cdecl;
    create_uniform: function(const _name: PUTF8Char; _type: bgfx_uniform_type_t; _num: UInt16): bgfx_uniform_handle_t; cdecl;
    get_uniform_info: procedure(_handle: bgfx_uniform_handle_t; _info: Pbgfx_uniform_info_t); cdecl;
    destroy_uniform: procedure(_handle: bgfx_uniform_handle_t); cdecl;
    create_occlusion_query: function(): bgfx_occlusion_query_handle_t; cdecl;
    get_result: function(_handle: bgfx_occlusion_query_handle_t; _result: PInt32): bgfx_occlusion_query_result_t; cdecl;
    destroy_occlusion_query: procedure(_handle: bgfx_occlusion_query_handle_t); cdecl;
    set_palette_color: procedure(_index: UInt8; _rgba: PSingle); cdecl;
    set_palette_color_rgba8: procedure(_index: UInt8; _rgba: UInt32); cdecl;
    set_view_name: procedure(_id: bgfx_view_id_t; const _name: PUTF8Char); cdecl;
    set_view_rect: procedure(_id: bgfx_view_id_t; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16); cdecl;
    set_view_rect_ratio: procedure(_id: bgfx_view_id_t; _x: UInt16; _y: UInt16; _ratio: bgfx_backbuffer_ratio_t); cdecl;
    set_view_scissor: procedure(_id: bgfx_view_id_t; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16); cdecl;
    set_view_clear: procedure(_id: bgfx_view_id_t; _flags: UInt16; _rgba: UInt32; _depth: Single; _stencil: UInt8); cdecl;
    set_view_clear_mrt: procedure(_id: bgfx_view_id_t; _flags: UInt16; _depth: Single; _stencil: UInt8; _c0: UInt8; _c1: UInt8; _c2: UInt8; _c3: UInt8; _c4: UInt8; _c5: UInt8; _c6: UInt8; _c7: UInt8); cdecl;
    set_view_mode: procedure(_id: bgfx_view_id_t; _mode: bgfx_view_mode_t); cdecl;
    set_view_frame_buffer: procedure(_id: bgfx_view_id_t; _handle: bgfx_frame_buffer_handle_t); cdecl;
    set_view_transform: procedure(_id: bgfx_view_id_t; const _view: Pointer; const _proj: Pointer); cdecl;
    set_view_order: procedure(_id: bgfx_view_id_t; _num: UInt16; const _order: Pbgfx_view_id_t); cdecl;
    reset_view: procedure(_id: bgfx_view_id_t); cdecl;
    encoder_begin: function(_forThread: Boolean): Pbgfx_encoder_t; cdecl;
    encoder_end: procedure(_encoder: Pbgfx_encoder_t); cdecl;
    encoder_set_marker: procedure(_this: Pbgfx_encoder_t; const _marker: PUTF8Char); cdecl;
    encoder_set_state: procedure(_this: Pbgfx_encoder_t; _state: UInt64; _rgba: UInt32); cdecl;
    encoder_set_condition: procedure(_this: Pbgfx_encoder_t; _handle: bgfx_occlusion_query_handle_t; _visible: Boolean); cdecl;
    encoder_set_stencil: procedure(_this: Pbgfx_encoder_t; _fstencil: UInt32; _bstencil: UInt32); cdecl;
    encoder_set_scissor: function(_this: Pbgfx_encoder_t; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16): UInt16; cdecl;
    encoder_set_scissor_cached: procedure(_this: Pbgfx_encoder_t; _cache: UInt16); cdecl;
    encoder_set_transform: function(_this: Pbgfx_encoder_t; const _mtx: Pointer; _num: UInt16): UInt32; cdecl;
    encoder_set_transform_cached: procedure(_this: Pbgfx_encoder_t; _cache: UInt32; _num: UInt16); cdecl;
    encoder_alloc_transform: function(_this: Pbgfx_encoder_t; _transform: Pbgfx_transform_t; _num: UInt16): UInt32; cdecl;
    encoder_set_uniform: procedure(_this: Pbgfx_encoder_t; _handle: bgfx_uniform_handle_t; const _value: Pointer; _num: UInt16); cdecl;
    encoder_set_index_buffer: procedure(_this: Pbgfx_encoder_t; _handle: bgfx_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
    encoder_set_dynamic_index_buffer: procedure(_this: Pbgfx_encoder_t; _handle: bgfx_dynamic_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
    encoder_set_transient_index_buffer: procedure(_this: Pbgfx_encoder_t; const _tib: Pbgfx_transient_index_buffer_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
    encoder_set_vertex_buffer: procedure(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
    encoder_set_vertex_buffer_with_layout: procedure(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
    encoder_set_dynamic_vertex_buffer: procedure(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
    encoder_set_dynamic_vertex_buffer_with_layout: procedure(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
    encoder_set_transient_vertex_buffer: procedure(_this: Pbgfx_encoder_t; _stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
    encoder_set_transient_vertex_buffer_with_layout: procedure(_this: Pbgfx_encoder_t; _stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
    encoder_set_vertex_count: procedure(_this: Pbgfx_encoder_t; _numVertices: UInt32); cdecl;
    encoder_set_instance_data_buffer: procedure(_this: Pbgfx_encoder_t; const _idb: Pbgfx_instance_data_buffer_t; _start: UInt32; _num: UInt32); cdecl;
    encoder_set_instance_data_from_vertex_buffer: procedure(_this: Pbgfx_encoder_t; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
    encoder_set_instance_data_from_dynamic_vertex_buffer: procedure(_this: Pbgfx_encoder_t; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
    encoder_set_instance_count: procedure(_this: Pbgfx_encoder_t; _numInstances: UInt32); cdecl;
    encoder_set_texture: procedure(_this: Pbgfx_encoder_t; _stage: UInt8; _sampler: bgfx_uniform_handle_t; _handle: bgfx_texture_handle_t; _flags: UInt32); cdecl;
    encoder_touch: procedure(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t); cdecl;
    encoder_submit: procedure(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
    encoder_submit_occlusion_query: procedure(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _occlusionQuery: bgfx_occlusion_query_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
    encoder_submit_indirect: procedure(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _depth: UInt32; _flags: UInt8); cdecl;
    encoder_set_compute_index_buffer: procedure(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
    encoder_set_compute_vertex_buffer: procedure(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
    encoder_set_compute_dynamic_index_buffer: procedure(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_dynamic_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
    encoder_set_compute_dynamic_vertex_buffer: procedure(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
    encoder_set_compute_indirect_buffer: procedure(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_indirect_buffer_handle_t; _access: bgfx_access_t); cdecl;
    encoder_set_image: procedure(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_texture_handle_t; _mip: UInt8; _access: bgfx_access_t; _format: bgfx_texture_format_t); cdecl;
    encoder_dispatch: procedure(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _numX: UInt32; _numY: UInt32; _numZ: UInt32; _flags: UInt8); cdecl;
    encoder_dispatch_indirect: procedure(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _flags: UInt8); cdecl;
    encoder_discard: procedure(_this: Pbgfx_encoder_t; _flags: UInt8); cdecl;
    encoder_blit: procedure(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _dst: bgfx_texture_handle_t; _dstMip: UInt8; _dstX: UInt16; _dstY: UInt16; _dstZ: UInt16; _src: bgfx_texture_handle_t; _srcMip: UInt8; _srcX: UInt16; _srcY: UInt16; _srcZ: UInt16; _width: UInt16; _height: UInt16; _depth: UInt16); cdecl;
    request_screen_shot: procedure(_handle: bgfx_frame_buffer_handle_t; const _filePath: PUTF8Char); cdecl;
    render_frame: function(_msecs: Int32): bgfx_render_frame_t; cdecl;
    set_platform_data: procedure(const _data: Pbgfx_platform_data_t); cdecl;
    get_internal_data: function(): Pbgfx_internal_data_t; cdecl;
    override_internal_texture_ptr: function(_handle: bgfx_texture_handle_t; _ptr: UIntPtr): UIntPtr; cdecl;
    override_internal_texture: function(_handle: bgfx_texture_handle_t; _width: UInt16; _height: UInt16; _numMips: UInt8; _format: bgfx_texture_format_t; _flags: UInt64): UIntPtr; cdecl;
    set_marker: procedure(const _marker: PUTF8Char); cdecl;
    set_state: procedure(_state: UInt64; _rgba: UInt32); cdecl;
    set_condition: procedure(_handle: bgfx_occlusion_query_handle_t; _visible: Boolean); cdecl;
    set_stencil: procedure(_fstencil: UInt32; _bstencil: UInt32); cdecl;
    set_scissor: function(_x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16): UInt16; cdecl;
    set_scissor_cached: procedure(_cache: UInt16); cdecl;
    set_transform: function(const _mtx: Pointer; _num: UInt16): UInt32; cdecl;
    set_transform_cached: procedure(_cache: UInt32; _num: UInt16); cdecl;
    alloc_transform: function(_transform: Pbgfx_transform_t; _num: UInt16): UInt32; cdecl;
    set_uniform: procedure(_handle: bgfx_uniform_handle_t; const _value: Pointer; _num: UInt16); cdecl;
    set_index_buffer: procedure(_handle: bgfx_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
    set_dynamic_index_buffer: procedure(_handle: bgfx_dynamic_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
    set_transient_index_buffer: procedure(const _tib: Pbgfx_transient_index_buffer_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
    set_vertex_buffer: procedure(_stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
    set_vertex_buffer_with_layout: procedure(_stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
    set_dynamic_vertex_buffer: procedure(_stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
    set_dynamic_vertex_buffer_with_layout: procedure(_stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
    set_transient_vertex_buffer: procedure(_stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
    set_transient_vertex_buffer_with_layout: procedure(_stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
    set_vertex_count: procedure(_numVertices: UInt32); cdecl;
    set_instance_data_buffer: procedure(const _idb: Pbgfx_instance_data_buffer_t; _start: UInt32; _num: UInt32); cdecl;
    set_instance_data_from_vertex_buffer: procedure(_handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
    set_instance_data_from_dynamic_vertex_buffer: procedure(_handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
    set_instance_count: procedure(_numInstances: UInt32); cdecl;
    set_texture: procedure(_stage: UInt8; _sampler: bgfx_uniform_handle_t; _handle: bgfx_texture_handle_t; _flags: UInt32); cdecl;
    touch: procedure(_id: bgfx_view_id_t); cdecl;
    submit: procedure(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
    submit_occlusion_query: procedure(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _occlusionQuery: bgfx_occlusion_query_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
    submit_indirect: procedure(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _depth: UInt32; _flags: UInt8); cdecl;
    set_compute_index_buffer: procedure(_stage: UInt8; _handle: bgfx_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
    set_compute_vertex_buffer: procedure(_stage: UInt8; _handle: bgfx_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
    set_compute_dynamic_index_buffer: procedure(_stage: UInt8; _handle: bgfx_dynamic_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
    set_compute_dynamic_vertex_buffer: procedure(_stage: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
    set_compute_indirect_buffer: procedure(_stage: UInt8; _handle: bgfx_indirect_buffer_handle_t; _access: bgfx_access_t); cdecl;
    set_image: procedure(_stage: UInt8; _handle: bgfx_texture_handle_t; _mip: UInt8; _access: bgfx_access_t; _format: bgfx_texture_format_t); cdecl;
    dispatch: procedure(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _numX: UInt32; _numY: UInt32; _numZ: UInt32; _flags: UInt8); cdecl;
    dispatch_indirect: procedure(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _flags: UInt8); cdecl;
    discard: procedure(_flags: UInt8); cdecl;
    blit: procedure(_id: bgfx_view_id_t; _dst: bgfx_texture_handle_t; _dstMip: UInt8; _dstX: UInt16; _dstY: UInt16; _dstZ: UInt16; _src: bgfx_texture_handle_t; _srcMip: UInt8; _srcX: UInt16; _srcY: UInt16; _srcZ: UInt16; _width: UInt16; _height: UInt16; _depth: UInt16); cdecl;
  end;

  PFN_BGFX_GET_INTERFACE = function(_version: UInt32): Pbgfx_interface_vtbl_t; cdecl;

(* External Function Declarations *)

procedure bgfx_attachment_init(_this: Pbgfx_attachment_t; _handle: bgfx_texture_handle_t; _access: bgfx_access_t; _layer: UInt16; _numLayers: UInt16; _mip: UInt16; _resolve: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_attachment_init';

function bgfx_vertex_layout_begin(_this: Pbgfx_vertex_layout_t; _rendererType: bgfx_renderer_type_t): Pbgfx_vertex_layout_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_layout_begin';

function bgfx_vertex_layout_add(_this: Pbgfx_vertex_layout_t; _attrib: bgfx_attrib_t; _num: UInt8; _type: bgfx_attrib_type_t; _normalized: Boolean; _asInt: Boolean): Pbgfx_vertex_layout_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_layout_add';

procedure bgfx_vertex_layout_decode(const _this: Pbgfx_vertex_layout_t; _attrib: bgfx_attrib_t; _num: PUInt8; _type: Pbgfx_attrib_type_t; _normalized: PBoolean; _asInt: PBoolean); cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_layout_decode';

function bgfx_vertex_layout_has(const _this: Pbgfx_vertex_layout_t; _attrib: bgfx_attrib_t): Boolean; cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_layout_has';

function bgfx_vertex_layout_skip(_this: Pbgfx_vertex_layout_t; _num: UInt8): Pbgfx_vertex_layout_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_layout_skip';

procedure bgfx_vertex_layout_end(_this: Pbgfx_vertex_layout_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_layout_end';

procedure bgfx_vertex_pack(_input: PSingle; _inputNormalized: Boolean; _attr: bgfx_attrib_t; const _layout: Pbgfx_vertex_layout_t; _data: Pointer; _index: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_pack';

procedure bgfx_vertex_unpack(_output: PSingle; _attr: bgfx_attrib_t; const _layout: Pbgfx_vertex_layout_t; const _data: Pointer; _index: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_unpack';

procedure bgfx_vertex_convert(const _dstLayout: Pbgfx_vertex_layout_t; _dstData: Pointer; const _srcLayout: Pbgfx_vertex_layout_t; const _srcData: Pointer; _num: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_vertex_convert';

function bgfx_weld_vertices(_output: Pointer; const _layout: Pbgfx_vertex_layout_t; const _data: Pointer; _num: UInt32; _index32: Boolean; _epsilon: Single): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_weld_vertices';

function bgfx_topology_convert(_conversion: bgfx_topology_convert_t; _dst: Pointer; _dstSize: UInt32; const _indices: Pointer; _numIndices: UInt32; _index32: Boolean): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_topology_convert';

procedure bgfx_topology_sort_tri_list(_sort: bgfx_topology_sort_t; _dst: Pointer; _dstSize: UInt32; _dir: PSingle; _pos: PSingle; const _vertices: Pointer; _stride: UInt32; const _indices: Pointer; _numIndices: UInt32; _index32: Boolean); cdecl;
  external BGFX_LIB_NAME name 'bgfx_topology_sort_tri_list';

function bgfx_get_supported_renderers(_max: UInt8; _enum: Pbgfx_renderer_type_t): UInt8; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_supported_renderers';

function bgfx_get_renderer_name(_type: bgfx_renderer_type_t): PUTF8Char; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_renderer_name';

procedure bgfx_init_ctor(_init: Pbgfx_init_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_init_ctor';

function bgfx_init(const _init: Pbgfx_init_t): Boolean; cdecl;
  external BGFX_LIB_NAME name 'bgfx_init';

procedure bgfx_shutdown(); cdecl;
  external BGFX_LIB_NAME name 'bgfx_shutdown';

procedure bgfx_reset(_width: UInt32; _height: UInt32; _flags: UInt32; _format: bgfx_texture_format_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_reset';

function bgfx_frame(_capture: Boolean): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_frame';

function bgfx_get_renderer_type(): bgfx_renderer_type_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_renderer_type';

function bgfx_get_caps(): Pbgfx_caps_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_caps';

function bgfx_get_stats(): Pbgfx_stats_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_stats';

function bgfx_alloc(_size: UInt32): Pbgfx_memory_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_alloc';

function bgfx_copy(const _data: Pointer; _size: UInt32): Pbgfx_memory_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_copy';

function bgfx_make_ref(const _data: Pointer; _size: UInt32): Pbgfx_memory_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_make_ref';

function bgfx_make_ref_release(const _data: Pointer; _size: UInt32; _releaseFn: bgfx_release_fn_t; _userData: Pointer): Pbgfx_memory_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_make_ref_release';

procedure bgfx_set_debug(_debug: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_debug';

procedure bgfx_dbg_text_clear(_attr: UInt8; _small: Boolean); cdecl;
  external BGFX_LIB_NAME name 'bgfx_dbg_text_clear';

procedure bgfx_dbg_text_printf(_x: UInt16; _y: UInt16; _attr: UInt8; const _format: PUTF8Char) varargs; cdecl;
  external BGFX_LIB_NAME name 'bgfx_dbg_text_printf';

procedure bgfx_dbg_text_vprintf(_x: UInt16; _y: UInt16; _attr: UInt8; const _format: PUTF8Char; _argList: Pointer); cdecl;
  external BGFX_LIB_NAME name 'bgfx_dbg_text_vprintf';

procedure bgfx_dbg_text_image(_x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16; const _data: Pointer; _pitch: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_dbg_text_image';

function bgfx_create_index_buffer(const _mem: Pbgfx_memory_t; _flags: UInt16): bgfx_index_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_index_buffer';

procedure bgfx_set_index_buffer_name(_handle: bgfx_index_buffer_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_index_buffer_name';

procedure bgfx_destroy_index_buffer(_handle: bgfx_index_buffer_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_index_buffer';

function bgfx_create_vertex_layout(const _layout: Pbgfx_vertex_layout_t): bgfx_vertex_layout_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_vertex_layout';

procedure bgfx_destroy_vertex_layout(_layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_vertex_layout';

function bgfx_create_vertex_buffer(const _mem: Pbgfx_memory_t; const _layout: Pbgfx_vertex_layout_t; _flags: UInt16): bgfx_vertex_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_vertex_buffer';

procedure bgfx_set_vertex_buffer_name(_handle: bgfx_vertex_buffer_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_vertex_buffer_name';

procedure bgfx_destroy_vertex_buffer(_handle: bgfx_vertex_buffer_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_vertex_buffer';

function bgfx_create_dynamic_index_buffer(_num: UInt32; _flags: UInt16): bgfx_dynamic_index_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_dynamic_index_buffer';

function bgfx_create_dynamic_index_buffer_mem(const _mem: Pbgfx_memory_t; _flags: UInt16): bgfx_dynamic_index_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_dynamic_index_buffer_mem';

procedure bgfx_update_dynamic_index_buffer(_handle: bgfx_dynamic_index_buffer_handle_t; _startIndex: UInt32; const _mem: Pbgfx_memory_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_update_dynamic_index_buffer';

procedure bgfx_destroy_dynamic_index_buffer(_handle: bgfx_dynamic_index_buffer_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_dynamic_index_buffer';

function bgfx_create_dynamic_vertex_buffer(_num: UInt32; const _layout: Pbgfx_vertex_layout_t; _flags: UInt16): bgfx_dynamic_vertex_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_dynamic_vertex_buffer';

function bgfx_create_dynamic_vertex_buffer_mem(const _mem: Pbgfx_memory_t; const _layout: Pbgfx_vertex_layout_t; _flags: UInt16): bgfx_dynamic_vertex_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_dynamic_vertex_buffer_mem';

procedure bgfx_update_dynamic_vertex_buffer(_handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; const _mem: Pbgfx_memory_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_update_dynamic_vertex_buffer';

procedure bgfx_destroy_dynamic_vertex_buffer(_handle: bgfx_dynamic_vertex_buffer_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_dynamic_vertex_buffer';

function bgfx_get_avail_transient_index_buffer(_num: UInt32; _index32: Boolean): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_avail_transient_index_buffer';

function bgfx_get_avail_transient_vertex_buffer(_num: UInt32; const _layout: Pbgfx_vertex_layout_t): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_avail_transient_vertex_buffer';

function bgfx_get_avail_instance_data_buffer(_num: UInt32; _stride: UInt16): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_avail_instance_data_buffer';

procedure bgfx_alloc_transient_index_buffer(_tib: Pbgfx_transient_index_buffer_t; _num: UInt32; _index32: Boolean); cdecl;
  external BGFX_LIB_NAME name 'bgfx_alloc_transient_index_buffer';

procedure bgfx_alloc_transient_vertex_buffer(_tvb: Pbgfx_transient_vertex_buffer_t; _num: UInt32; const _layout: Pbgfx_vertex_layout_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_alloc_transient_vertex_buffer';

function bgfx_alloc_transient_buffers(_tvb: Pbgfx_transient_vertex_buffer_t; const _layout: Pbgfx_vertex_layout_t; _numVertices: UInt32; _tib: Pbgfx_transient_index_buffer_t; _numIndices: UInt32; _index32: Boolean): Boolean; cdecl;
  external BGFX_LIB_NAME name 'bgfx_alloc_transient_buffers';

procedure bgfx_alloc_instance_data_buffer(_idb: Pbgfx_instance_data_buffer_t; _num: UInt32; _stride: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_alloc_instance_data_buffer';

function bgfx_create_indirect_buffer(_num: UInt32): bgfx_indirect_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_indirect_buffer';

procedure bgfx_destroy_indirect_buffer(_handle: bgfx_indirect_buffer_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_indirect_buffer';

function bgfx_create_shader(const _mem: Pbgfx_memory_t): bgfx_shader_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_shader';

function bgfx_get_shader_uniforms(_handle: bgfx_shader_handle_t; _uniforms: Pbgfx_uniform_handle_t; _max: UInt16): UInt16; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_shader_uniforms';

procedure bgfx_set_shader_name(_handle: bgfx_shader_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_shader_name';

procedure bgfx_destroy_shader(_handle: bgfx_shader_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_shader';

function bgfx_create_program(_vsh: bgfx_shader_handle_t; _fsh: bgfx_shader_handle_t; _destroyShaders: Boolean): bgfx_program_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_program';

function bgfx_create_compute_program(_csh: bgfx_shader_handle_t; _destroyShaders: Boolean): bgfx_program_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_compute_program';

procedure bgfx_destroy_program(_handle: bgfx_program_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_program';

function bgfx_is_texture_valid(_depth: UInt16; _cubeMap: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64): Boolean; cdecl;
  external BGFX_LIB_NAME name 'bgfx_is_texture_valid';

function bgfx_is_frame_buffer_valid(_num: UInt8; const _attachment: Pbgfx_attachment_t): Boolean; cdecl;
  external BGFX_LIB_NAME name 'bgfx_is_frame_buffer_valid';

procedure bgfx_calc_texture_size(_info: Pbgfx_texture_info_t; _width: UInt16; _height: UInt16; _depth: UInt16; _cubeMap: Boolean; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_calc_texture_size';

function bgfx_create_texture(const _mem: Pbgfx_memory_t; _flags: UInt64; _skip: UInt8; _info: Pbgfx_texture_info_t): bgfx_texture_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_texture';

function bgfx_create_texture_2d(_width: UInt16; _height: UInt16; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64; const _mem: Pbgfx_memory_t): bgfx_texture_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_texture_2d';

function bgfx_create_texture_2d_scaled(_ratio: bgfx_backbuffer_ratio_t; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64): bgfx_texture_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_texture_2d_scaled';

function bgfx_create_texture_3d(_width: UInt16; _height: UInt16; _depth: UInt16; _hasMips: Boolean; _format: bgfx_texture_format_t; _flags: UInt64; const _mem: Pbgfx_memory_t): bgfx_texture_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_texture_3d';

function bgfx_create_texture_cube(_size: UInt16; _hasMips: Boolean; _numLayers: UInt16; _format: bgfx_texture_format_t; _flags: UInt64; const _mem: Pbgfx_memory_t): bgfx_texture_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_texture_cube';

procedure bgfx_update_texture_2d(_handle: bgfx_texture_handle_t; _layer: UInt16; _mip: UInt8; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16; const _mem: Pbgfx_memory_t; _pitch: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_update_texture_2d';

procedure bgfx_update_texture_3d(_handle: bgfx_texture_handle_t; _mip: UInt8; _x: UInt16; _y: UInt16; _z: UInt16; _width: UInt16; _height: UInt16; _depth: UInt16; const _mem: Pbgfx_memory_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_update_texture_3d';

procedure bgfx_update_texture_cube(_handle: bgfx_texture_handle_t; _layer: UInt16; _side: UInt8; _mip: UInt8; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16; const _mem: Pbgfx_memory_t; _pitch: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_update_texture_cube';

function bgfx_read_texture(_handle: bgfx_texture_handle_t; _data: Pointer; _mip: UInt8): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_read_texture';

procedure bgfx_set_texture_name(_handle: bgfx_texture_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_texture_name';

function bgfx_get_direct_access_ptr(_handle: bgfx_texture_handle_t): Pointer; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_direct_access_ptr';

procedure bgfx_destroy_texture(_handle: bgfx_texture_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_texture';

function bgfx_create_frame_buffer(_width: UInt16; _height: UInt16; _format: bgfx_texture_format_t; _textureFlags: UInt64): bgfx_frame_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_frame_buffer';

function bgfx_create_frame_buffer_scaled(_ratio: bgfx_backbuffer_ratio_t; _format: bgfx_texture_format_t; _textureFlags: UInt64): bgfx_frame_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_frame_buffer_scaled';

function bgfx_create_frame_buffer_from_handles(_num: UInt8; const _handles: Pbgfx_texture_handle_t; _destroyTexture: Boolean): bgfx_frame_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_frame_buffer_from_handles';

function bgfx_create_frame_buffer_from_attachment(_num: UInt8; const _attachment: Pbgfx_attachment_t; _destroyTexture: Boolean): bgfx_frame_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_frame_buffer_from_attachment';

function bgfx_create_frame_buffer_from_nwh(_nwh: Pointer; _width: UInt16; _height: UInt16; _format: bgfx_texture_format_t; _depthFormat: bgfx_texture_format_t): bgfx_frame_buffer_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_frame_buffer_from_nwh';

procedure bgfx_set_frame_buffer_name(_handle: bgfx_frame_buffer_handle_t; const _name: PUTF8Char; _len: Int32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_frame_buffer_name';

function bgfx_get_texture(_handle: bgfx_frame_buffer_handle_t; _attachment: UInt8): bgfx_texture_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_texture';

procedure bgfx_destroy_frame_buffer(_handle: bgfx_frame_buffer_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_frame_buffer';

function bgfx_create_uniform(const _name: PUTF8Char; _type: bgfx_uniform_type_t; _num: UInt16): bgfx_uniform_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_uniform';

procedure bgfx_get_uniform_info(_handle: bgfx_uniform_handle_t; _info: Pbgfx_uniform_info_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_uniform_info';

procedure bgfx_destroy_uniform(_handle: bgfx_uniform_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_uniform';

function bgfx_create_occlusion_query(): bgfx_occlusion_query_handle_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_create_occlusion_query';

function bgfx_get_result(_handle: bgfx_occlusion_query_handle_t; _result: PInt32): bgfx_occlusion_query_result_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_result';

procedure bgfx_destroy_occlusion_query(_handle: bgfx_occlusion_query_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_destroy_occlusion_query';

procedure bgfx_set_palette_color(_index: UInt8; _rgba: PSingle); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_palette_color';

procedure bgfx_set_palette_color_rgba8(_index: UInt8; _rgba: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_palette_color_rgba8';

procedure bgfx_set_view_name(_id: bgfx_view_id_t; const _name: PUTF8Char); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_name';

procedure bgfx_set_view_rect(_id: bgfx_view_id_t; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_rect';

procedure bgfx_set_view_rect_ratio(_id: bgfx_view_id_t; _x: UInt16; _y: UInt16; _ratio: bgfx_backbuffer_ratio_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_rect_ratio';

procedure bgfx_set_view_scissor(_id: bgfx_view_id_t; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_scissor';

procedure bgfx_set_view_clear(_id: bgfx_view_id_t; _flags: UInt16; _rgba: UInt32; _depth: Single; _stencil: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_clear';

procedure bgfx_set_view_clear_mrt(_id: bgfx_view_id_t; _flags: UInt16; _depth: Single; _stencil: UInt8; _c0: UInt8; _c1: UInt8; _c2: UInt8; _c3: UInt8; _c4: UInt8; _c5: UInt8; _c6: UInt8; _c7: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_clear_mrt';

procedure bgfx_set_view_mode(_id: bgfx_view_id_t; _mode: bgfx_view_mode_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_mode';

procedure bgfx_set_view_frame_buffer(_id: bgfx_view_id_t; _handle: bgfx_frame_buffer_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_frame_buffer';

procedure bgfx_set_view_transform(_id: bgfx_view_id_t; const _view: Pointer; const _proj: Pointer); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_transform';

procedure bgfx_set_view_order(_id: bgfx_view_id_t; _num: UInt16; const _order: Pbgfx_view_id_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_view_order';

procedure bgfx_reset_view(_id: bgfx_view_id_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_reset_view';

function bgfx_encoder_begin(_forThread: Boolean): Pbgfx_encoder_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_begin';

procedure bgfx_encoder_end(_encoder: Pbgfx_encoder_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_end';

procedure bgfx_encoder_set_marker(_this: Pbgfx_encoder_t; const _marker: PUTF8Char); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_marker';

procedure bgfx_encoder_set_state(_this: Pbgfx_encoder_t; _state: UInt64; _rgba: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_state';

procedure bgfx_encoder_set_condition(_this: Pbgfx_encoder_t; _handle: bgfx_occlusion_query_handle_t; _visible: Boolean); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_condition';

procedure bgfx_encoder_set_stencil(_this: Pbgfx_encoder_t; _fstencil: UInt32; _bstencil: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_stencil';

function bgfx_encoder_set_scissor(_this: Pbgfx_encoder_t; _x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16): UInt16; cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_scissor';

procedure bgfx_encoder_set_scissor_cached(_this: Pbgfx_encoder_t; _cache: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_scissor_cached';

function bgfx_encoder_set_transform(_this: Pbgfx_encoder_t; const _mtx: Pointer; _num: UInt16): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_transform';

procedure bgfx_encoder_set_transform_cached(_this: Pbgfx_encoder_t; _cache: UInt32; _num: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_transform_cached';

function bgfx_encoder_alloc_transform(_this: Pbgfx_encoder_t; _transform: Pbgfx_transform_t; _num: UInt16): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_alloc_transform';

procedure bgfx_encoder_set_uniform(_this: Pbgfx_encoder_t; _handle: bgfx_uniform_handle_t; const _value: Pointer; _num: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_uniform';

procedure bgfx_encoder_set_index_buffer(_this: Pbgfx_encoder_t; _handle: bgfx_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_index_buffer';

procedure bgfx_encoder_set_dynamic_index_buffer(_this: Pbgfx_encoder_t; _handle: bgfx_dynamic_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_dynamic_index_buffer';

procedure bgfx_encoder_set_transient_index_buffer(_this: Pbgfx_encoder_t; const _tib: Pbgfx_transient_index_buffer_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_transient_index_buffer';

procedure bgfx_encoder_set_vertex_buffer(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_vertex_buffer';

procedure bgfx_encoder_set_vertex_buffer_with_layout(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_vertex_buffer_with_layout';

procedure bgfx_encoder_set_dynamic_vertex_buffer(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_dynamic_vertex_buffer';

procedure bgfx_encoder_set_dynamic_vertex_buffer_with_layout(_this: Pbgfx_encoder_t; _stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_dynamic_vertex_buffer_with_layout';

procedure bgfx_encoder_set_transient_vertex_buffer(_this: Pbgfx_encoder_t; _stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_transient_vertex_buffer';

procedure bgfx_encoder_set_transient_vertex_buffer_with_layout(_this: Pbgfx_encoder_t; _stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_transient_vertex_buffer_with_layout';

procedure bgfx_encoder_set_vertex_count(_this: Pbgfx_encoder_t; _numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_vertex_count';

procedure bgfx_encoder_set_instance_data_buffer(_this: Pbgfx_encoder_t; const _idb: Pbgfx_instance_data_buffer_t; _start: UInt32; _num: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_instance_data_buffer';

procedure bgfx_encoder_set_instance_data_from_vertex_buffer(_this: Pbgfx_encoder_t; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_instance_data_from_vertex_buffer';

procedure bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer(_this: Pbgfx_encoder_t; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer';

procedure bgfx_encoder_set_instance_count(_this: Pbgfx_encoder_t; _numInstances: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_instance_count';

procedure bgfx_encoder_set_texture(_this: Pbgfx_encoder_t; _stage: UInt8; _sampler: bgfx_uniform_handle_t; _handle: bgfx_texture_handle_t; _flags: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_texture';

procedure bgfx_encoder_touch(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_touch';

procedure bgfx_encoder_submit(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_submit';

procedure bgfx_encoder_submit_occlusion_query(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _occlusionQuery: bgfx_occlusion_query_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_submit_occlusion_query';

procedure bgfx_encoder_submit_indirect(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _depth: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_submit_indirect';

procedure bgfx_encoder_set_compute_index_buffer(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_compute_index_buffer';

procedure bgfx_encoder_set_compute_vertex_buffer(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_compute_vertex_buffer';

procedure bgfx_encoder_set_compute_dynamic_index_buffer(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_dynamic_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_compute_dynamic_index_buffer';

procedure bgfx_encoder_set_compute_dynamic_vertex_buffer(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_compute_dynamic_vertex_buffer';

procedure bgfx_encoder_set_compute_indirect_buffer(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_indirect_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_compute_indirect_buffer';

procedure bgfx_encoder_set_image(_this: Pbgfx_encoder_t; _stage: UInt8; _handle: bgfx_texture_handle_t; _mip: UInt8; _access: bgfx_access_t; _format: bgfx_texture_format_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_set_image';

procedure bgfx_encoder_dispatch(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _numX: UInt32; _numY: UInt32; _numZ: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_dispatch';

procedure bgfx_encoder_dispatch_indirect(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_dispatch_indirect';

procedure bgfx_encoder_discard(_this: Pbgfx_encoder_t; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_discard';

procedure bgfx_encoder_blit(_this: Pbgfx_encoder_t; _id: bgfx_view_id_t; _dst: bgfx_texture_handle_t; _dstMip: UInt8; _dstX: UInt16; _dstY: UInt16; _dstZ: UInt16; _src: bgfx_texture_handle_t; _srcMip: UInt8; _srcX: UInt16; _srcY: UInt16; _srcZ: UInt16; _width: UInt16; _height: UInt16; _depth: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_encoder_blit';

procedure bgfx_request_screen_shot(_handle: bgfx_frame_buffer_handle_t; const _filePath: PUTF8Char); cdecl;
  external BGFX_LIB_NAME name 'bgfx_request_screen_shot';

function bgfx_render_frame(_msecs: Int32): bgfx_render_frame_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_render_frame';

procedure bgfx_set_platform_data(const _data: Pbgfx_platform_data_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_platform_data';

function bgfx_get_internal_data(): Pbgfx_internal_data_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_internal_data';

function bgfx_override_internal_texture_ptr(_handle: bgfx_texture_handle_t; _ptr: UIntPtr): UIntPtr; cdecl;
  external BGFX_LIB_NAME name 'bgfx_override_internal_texture_ptr';

function bgfx_override_internal_texture(_handle: bgfx_texture_handle_t; _width: UInt16; _height: UInt16; _numMips: UInt8; _format: bgfx_texture_format_t; _flags: UInt64): UIntPtr; cdecl;
  external BGFX_LIB_NAME name 'bgfx_override_internal_texture';

procedure bgfx_set_marker(const _marker: PUTF8Char); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_marker';

procedure bgfx_set_state(_state: UInt64; _rgba: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_state';

procedure bgfx_set_condition(_handle: bgfx_occlusion_query_handle_t; _visible: Boolean); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_condition';

procedure bgfx_set_stencil(_fstencil: UInt32; _bstencil: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_stencil';

function bgfx_set_scissor(_x: UInt16; _y: UInt16; _width: UInt16; _height: UInt16): UInt16; cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_scissor';

procedure bgfx_set_scissor_cached(_cache: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_scissor_cached';

function bgfx_set_transform(const _mtx: Pointer; _num: UInt16): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_transform';

procedure bgfx_set_transform_cached(_cache: UInt32; _num: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_transform_cached';

function bgfx_alloc_transform(_transform: Pbgfx_transform_t; _num: UInt16): UInt32; cdecl;
  external BGFX_LIB_NAME name 'bgfx_alloc_transform';

procedure bgfx_set_uniform(_handle: bgfx_uniform_handle_t; const _value: Pointer; _num: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_uniform';

procedure bgfx_set_index_buffer(_handle: bgfx_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_index_buffer';

procedure bgfx_set_dynamic_index_buffer(_handle: bgfx_dynamic_index_buffer_handle_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_dynamic_index_buffer';

procedure bgfx_set_transient_index_buffer(const _tib: Pbgfx_transient_index_buffer_t; _firstIndex: UInt32; _numIndices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_transient_index_buffer';

procedure bgfx_set_vertex_buffer(_stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_vertex_buffer';

procedure bgfx_set_vertex_buffer_with_layout(_stream: UInt8; _handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_vertex_buffer_with_layout';

procedure bgfx_set_dynamic_vertex_buffer(_stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_dynamic_vertex_buffer';

procedure bgfx_set_dynamic_vertex_buffer_with_layout(_stream: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_dynamic_vertex_buffer_with_layout';

procedure bgfx_set_transient_vertex_buffer(_stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_transient_vertex_buffer';

procedure bgfx_set_transient_vertex_buffer_with_layout(_stream: UInt8; const _tvb: Pbgfx_transient_vertex_buffer_t; _startVertex: UInt32; _numVertices: UInt32; _layoutHandle: bgfx_vertex_layout_handle_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_transient_vertex_buffer_with_layout';

procedure bgfx_set_vertex_count(_numVertices: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_vertex_count';

procedure bgfx_set_instance_data_buffer(const _idb: Pbgfx_instance_data_buffer_t; _start: UInt32; _num: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_instance_data_buffer';

procedure bgfx_set_instance_data_from_vertex_buffer(_handle: bgfx_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_instance_data_from_vertex_buffer';

procedure bgfx_set_instance_data_from_dynamic_vertex_buffer(_handle: bgfx_dynamic_vertex_buffer_handle_t; _startVertex: UInt32; _num: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_instance_data_from_dynamic_vertex_buffer';

procedure bgfx_set_instance_count(_numInstances: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_instance_count';

procedure bgfx_set_texture(_stage: UInt8; _sampler: bgfx_uniform_handle_t; _handle: bgfx_texture_handle_t; _flags: UInt32); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_texture';

procedure bgfx_touch(_id: bgfx_view_id_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_touch';

procedure bgfx_submit(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_submit';

procedure bgfx_submit_occlusion_query(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _occlusionQuery: bgfx_occlusion_query_handle_t; _depth: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_submit_occlusion_query';

procedure bgfx_submit_indirect(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _depth: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_submit_indirect';

procedure bgfx_set_compute_index_buffer(_stage: UInt8; _handle: bgfx_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_compute_index_buffer';

procedure bgfx_set_compute_vertex_buffer(_stage: UInt8; _handle: bgfx_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_compute_vertex_buffer';

procedure bgfx_set_compute_dynamic_index_buffer(_stage: UInt8; _handle: bgfx_dynamic_index_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_compute_dynamic_index_buffer';

procedure bgfx_set_compute_dynamic_vertex_buffer(_stage: UInt8; _handle: bgfx_dynamic_vertex_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_compute_dynamic_vertex_buffer';

procedure bgfx_set_compute_indirect_buffer(_stage: UInt8; _handle: bgfx_indirect_buffer_handle_t; _access: bgfx_access_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_compute_indirect_buffer';

procedure bgfx_set_image(_stage: UInt8; _handle: bgfx_texture_handle_t; _mip: UInt8; _access: bgfx_access_t; _format: bgfx_texture_format_t); cdecl;
  external BGFX_LIB_NAME name 'bgfx_set_image';

procedure bgfx_dispatch(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _numX: UInt32; _numY: UInt32; _numZ: UInt32; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_dispatch';

procedure bgfx_dispatch_indirect(_id: bgfx_view_id_t; _program: bgfx_program_handle_t; _indirectHandle: bgfx_indirect_buffer_handle_t; _start: UInt16; _num: UInt16; _flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_dispatch_indirect';

procedure bgfx_discard(_flags: UInt8); cdecl;
  external BGFX_LIB_NAME name 'bgfx_discard';

procedure bgfx_blit(_id: bgfx_view_id_t; _dst: bgfx_texture_handle_t; _dstMip: UInt8; _dstX: UInt16; _dstY: UInt16; _dstZ: UInt16; _src: bgfx_texture_handle_t; _srcMip: UInt8; _srcX: UInt16; _srcY: UInt16; _srcZ: UInt16; _width: UInt16; _height: UInt16; _depth: UInt16); cdecl;
  external BGFX_LIB_NAME name 'bgfx_blit';

function bgfx_get_interface(_version: UInt32): Pbgfx_interface_vtbl_t; cdecl;
  external BGFX_LIB_NAME name 'bgfx_get_interface';

implementation

end.
