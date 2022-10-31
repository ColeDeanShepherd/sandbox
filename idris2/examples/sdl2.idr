module SDL2

export
SDL_INIT_VIDEO : Int
SDL_INIT_VIDEO = 0x00000020
export
SDL_RENDERER_ACCELERATED : Int
SDL_RENDERER_ACCELERATED = 0x00000002
%foreign "C:SDL_CreateWindow,SDL2"
export
SDL_CreateWindow : String -> Int -> Int -> Int -> Int -> Int -> PrimIO AnyPtr

%foreign "C:SDL_GetWindowSurface,SDL2"
export
SDL_GetWindowSurface : AnyPtr -> PrimIO AnyPtr

%foreign "C:SDL_UpdateWindowSurface,SDL2"
export
SDL_UpdateWindowSurface : AnyPtr -> PrimIO Int

%foreign "C:SDL_CreateRenderer,SDL2"
export
SDL_CreateRenderer : AnyPtr -> Int -> Int -> PrimIO AnyPtr

%foreign "C:SDL_RenderSetLogicalSize,SDL2"
export
SDL_RenderSetLogicalSize : AnyPtr -> Int -> Int -> PrimIO Int

%foreign "C:SDL_RenderClear,SDL2"
export
SDL_RenderClear : AnyPtr -> PrimIO Int

%foreign "C:SDL_RenderPresent,SDL2"
export
SDL_RenderPresent : AnyPtr -> PrimIO ()

%foreign "C:SDL_Delay,SDL2"
export
SDL_Delay : Int -> PrimIO ()

%foreign "C:SDL_Init,SDL2"
export
SDL_Init : Int -> PrimIO Int

