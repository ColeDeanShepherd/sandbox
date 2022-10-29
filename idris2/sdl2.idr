%foreign "C:SDL_CreateWindow,libsdl"
SDL_CreateWindow : Ptr String -> Int -> Int -> Int -> Int -> Int -> IO SDL_Window

%foreign "C:SDL_GetWindowSurface,libsdl"
SDL_GetWindowSurface : SDL_Window * -> IO SDL_Surface

%foreign "C:SDL_UpdateWindowSurface,libsdl"
SDL_UpdateWindowSurface : SDL_Window * -> IO int

%foreign "C:SDL_Delay,libsdl"
SDL_Delay : Int -> IO void

%foreign "C:SDL_Init,libsdl"
SDL_Init : Int -> IO int

