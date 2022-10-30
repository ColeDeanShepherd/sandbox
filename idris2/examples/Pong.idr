module Main

import SDL2

-- To-Do
-- - Game configuration
-- - Game state
-- - Init fn
-- - Update fn
-- - Render fn (or fn to map from game state to render state, then pass render state to SDL)

record GameConfig where
    constructor MkGameConfig
    windowWidth : Int
    windowHeight : Int

    -- background color

    windowTitle: String

    paddleWidth : Int
    paddleHeight : Int

    ballWidth : Int
    ballHeight : Int

    paddleHorizontalOffset : Int

    ballSpeed : Int

    pointsToWin : Int

record GameState where
    constructor MkGameState
    ballX : Int
    ballY : Int

    lPaddleY : Int
    rPaddleY : Int

    lScore : Int
    rScore : Int

main : IO ()
main = do
    x <- primIO (SDL_Init SDL_INIT_VIDEO)
    win <- primIO (SDL_CreateWindow "Test" 100 100 640 480 0)
    rend <- primIO (SDL_CreateRenderer win (-1) SDL_RENDERER_ACCELERATED)
    x <- primIO (SDL_RenderSetLogicalSize rend 640 480)

    surf <- primIO (SDL_GetWindowSurface win)
    y <- primIO (SDL_UpdateWindowSurface win)

    res <- primIO (SDL_RenderClear rend)
    primIO (SDL_RenderPresent rend)
    
    primIO  (SDL_Delay 5000)
    pure ()