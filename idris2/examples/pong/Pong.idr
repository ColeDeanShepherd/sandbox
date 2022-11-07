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

    backgroundColorR: Bits8
    backgroundColorG: Bits8
    backgroundColorB: Bits8

    windowTitle: String

    paddleWidth : Int
    paddleHeight : Int

    ballWidth : Int
    ballHeight : Int

    paddleHorizontalOffset : Int

    ballSpeed : Int

    pointsToWin : Int

gameConfig : GameConfig
gameConfig = MkGameConfig
    640
    480

    0
    0
    0

    "Pong in Idris2"

    20
    80

    20
    20

    200

    100
    
    10

record GameState where
    constructor MkGameState
    ballX : Int
    ballY : Int

    lPaddleY : Int
    rPaddleY : Int

    lScore : Int
    rScore : Int

renderPaddle : AnyPtr -> Int -> Int -> IO ()
renderPaddle rend x y = do
    r <- pure (MkSDL_Rect)
    primIO (SDL_Rect_set_x r x)
    primIO (SDL_Rect_set_y r y)
    primIO (SDL_Rect_set_w r gameConfig.paddleWidth)
    primIO (SDL_Rect_set_h r gameConfig.paddleHeight)

    xx <- primIO (SDL_SetRenderDrawColor rend 255 255 255 255)
    x <- primIO (SDL_RenderFillRect rend (unsafeCast r))

    pure ()

renderBall : AnyPtr -> Int -> Int -> IO ()
renderBall rend x y = do
    r <- pure (MkSDL_Rect)
    primIO (SDL_Rect_set_x r x)
    primIO (SDL_Rect_set_y r y)
    primIO (SDL_Rect_set_w r gameConfig.ballWidth)
    primIO (SDL_Rect_set_h r gameConfig.ballHeight)

    xx <- primIO (SDL_SetRenderDrawColor rend 255 255 255 255)
    x <- primIO (SDL_RenderFillRect rend (unsafeCast r))

    pure ()

renderFrame : AnyPtr -> IO ()
renderFrame rend = do
    xx <- primIO (SDL_SetRenderDrawColor rend gameConfig.backgroundColorR gameConfig.backgroundColorG gameConfig.backgroundColorB 255)
    res <- primIO (SDL_RenderClear rend)
    
    renderPaddle rend 10 10
    renderPaddle rend 400 10

    renderBall rend 200 200

    primIO (SDL_RenderPresent rend)

doFrame : SDL_Event -> AnyPtr -> IO ()
doFrame evt rend = do
    asdf <- primIO (SDL_PollEvent (unsafeCast evt))
    eventType <- io_pure (SDL_Event_type evt)

    renderFrame rend

    if eventType /= SDL_QUIT then doFrame evt rend else io_pure ()

main : IO ()
main = do
    x <- primIO (SDL_Init SDL_INIT_VIDEO)
    win <- primIO (SDL_CreateWindow gameConfig.windowTitle 100 100 gameConfig.windowWidth gameConfig.windowHeight 0)
    rend <- primIO (SDL_CreateRenderer win (-1) SDL_RENDERER_ACCELERATED)
    x <- primIO (SDL_RenderSetLogicalSize rend gameConfig.windowWidth gameConfig.windowHeight)

    surf <- primIO (SDL_GetWindowSurface win)
    y <- primIO (SDL_UpdateWindowSurface win)

    fdsa <- pure (MkSDL_Event)

    doFrame fdsa rend

    pure ()