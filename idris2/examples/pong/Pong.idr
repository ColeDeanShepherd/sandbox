module Main

import System.FFI
import Core
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

doFrame : SDL_Event -> AnyPtr -> SDL_Rect -> IO ()
doFrame evt rend r = do
    asdf <- primIO (SDL_PollEvent (unsafeCast evt))

    eventType <- io_pure (SDL_Event_type evt)
    putStrLn (show eventType)

    xx <- primIO (SDL_SetRenderDrawColor rend 0 0 0 255)
    res <- primIO (SDL_RenderClear rend)
    
    xx <- primIO (SDL_SetRenderDrawColor rend 255 255 255 255)
    x <- primIO (SDL_RenderFillRect rend (unsafeCast r))

    primIO (SDL_RenderPresent rend)

    if eventType /= 0x100 then doFrame evt rend r else io_pure ()

main : IO ()
main = do
    x <- primIO (SDL_Init SDL_INIT_VIDEO)
    win <- primIO (SDL_CreateWindow "Test" 100 100 640 480 0)
    rend <- primIO (SDL_CreateRenderer win (-1) SDL_RENDERER_ACCELERATED)
    x <- primIO (SDL_RenderSetLogicalSize rend 640 480)

    surf <- primIO (SDL_GetWindowSurface win)
    y <- primIO (SDL_UpdateWindowSurface win)

    r <- pure (MkSDL_Rect)
    primIO (SDL_Rect_set_x r 80)
    primIO (SDL_Rect_set_y r 20)
    primIO (SDL_Rect_set_w r 100)
    primIO (SDL_Rect_set_h r 40)

    fdsa <- pure (MkSDL_Event)

    doFrame fdsa rend r

    pure ()