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
    windowX : Int
    windowY : Int

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
    {windowX=100,
    windowY=100,

    windowWidth=640,
    windowHeight=480,

    backgroundColorR=0,
    backgroundColorG=0,
    backgroundColorB=0,

    windowTitle="Pong in Idris2",

    paddleWidth=20,
    paddleHeight=80,

    ballWidth=20,
    ballHeight=20,

    paddleHorizontalOffset=300,

    ballSpeed=100,
    
    pointsToWin=10}

lPaddleX : Double
lPaddleX = ((cast gameConfig.windowWidth) / 2) - (cast gameConfig.paddleHorizontalOffset)

rPaddleX : Double
rPaddleX = ((cast gameConfig.windowWidth) / 2) + (cast gameConfig.paddleHorizontalOffset)

record GameState where
    constructor MkGameState
    lPaddleY : Double
    rPaddleY : Double

    lPaddleDirection : Int
    rPaddleDirection : Int

    ballX : Double
    ballY : Double

    lScore : Int
    rScore : Int

renderWhiteRect : AnyPtr -> Double -> Double -> Double -> Double -> IO ()
renderWhiteRect rend x y w h = do
    r <- pure (MkSDL_Rect)
    primIO (SDL_Rect_set_x r (cast (x - (w / 2))))
    primIO (SDL_Rect_set_y r (cast (y - (h / 2))))
    primIO (SDL_Rect_set_w r (cast w))
    primIO (SDL_Rect_set_h r (cast h))

    xx <- primIO (SDL_SetRenderDrawColor rend 255 255 255 255)
    x <- primIO (SDL_RenderFillRect rend (unsafeCast r))

    pure ()

renderPaddle : AnyPtr -> Double -> Double -> IO ()
renderPaddle rend x y = renderWhiteRect rend x y (cast gameConfig.paddleWidth) (cast gameConfig.paddleHeight)

renderBall : AnyPtr -> Double -> Double -> IO ()
renderBall rend x y = renderWhiteRect rend x y (cast gameConfig.ballWidth) (cast gameConfig.ballHeight)

renderFrame : AnyPtr -> GameState -> IO ()
renderFrame rend state = do
    xx <- primIO (SDL_SetRenderDrawColor rend gameConfig.backgroundColorR gameConfig.backgroundColorG gameConfig.backgroundColorB 255)
    res <- primIO (SDL_RenderClear rend)
    
    renderPaddle rend lPaddleX state.lPaddleY
    renderPaddle rend rPaddleX state.rPaddleY

    renderBall rend state.ballX state.ballY

    primIO (SDL_RenderPresent rend)

doFrame : SDL_Event -> AnyPtr -> GameState -> IO ()
doFrame evt rend state = do
    -- TODO: poll multiple events per frame
    asdf <- primIO (SDL_PollEvent (unsafeCast evt))
    eventType <- io_pure (SDL_Event_type evt)

    let state = if (eventType == SDL_KEYDOWN) then { lPaddleDirection := 1 } state else if (eventType == SDL_KEYUP) then { lPaddleDirection := 0 } state else state

    let state = {
            ballX $= (+ 0.01),
            lPaddleY $= (+ if state.lPaddleDirection == 1 then -0.01 else if state.lPaddleDirection == -1 then 0.01 else 0),
            rPaddleY $= (+ 0.01)
        } state

    renderFrame rend state

    if eventType /= SDL_QUIT then doFrame evt rend state else io_pure ()

main : IO ()
main = do
    x <- primIO (SDL_Init SDL_INIT_VIDEO)
    win <- primIO (SDL_CreateWindow gameConfig.windowTitle gameConfig.windowX gameConfig.windowY gameConfig.windowWidth gameConfig.windowHeight 0)
    rend <- primIO (SDL_CreateRenderer win (-1) SDL_RENDERER_ACCELERATED)
    x <- primIO (SDL_RenderSetLogicalSize rend gameConfig.windowWidth gameConfig.windowHeight)

    surf <- primIO (SDL_GetWindowSurface win)
    y <- primIO (SDL_UpdateWindowSurface win)

    evt <- pure (MkSDL_Event)

    state <- pure (
        MkGameState {
            lPaddleY = ((cast gameConfig.windowHeight) / 2),
            rPaddleY = ((cast gameConfig.windowHeight) / 2),
            lPaddleDirection = 0,
            rPaddleDirection = 0,
            ballX = ((cast gameConfig.windowWidth) / 2),
            ballY = ((cast gameConfig.windowHeight) / 2),
            lScore = 0,
            rScore = 0
        })

    doFrame evt rend state

    pure ()