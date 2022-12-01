-- Problems --
-- \r\n doesn't work
-- VS Code extension doesn't work on windows
-- Compiler output in PowerShell doesn't work properly
-- Using Struct doesn't work as intended
-- Passing a GCAnyPtr seems to fail
-- "case" doesn't work on constants

module Main

import System.FFI
import Core
import Vector2
import SDL2

record GameConfig where
    constructor MkGameConfig
    windowPos : Vector2 Int

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

record GameState where
    constructor MkGameState
    lPaddleY : Double
    rPaddleY : Double

    lPaddleDirection : Int
    rPaddleDirection : Int

    ballPos : Vector2 Double

    lScore : Int
    rScore : Int

    quitting: Bool

gameConfig : GameConfig
gameConfig = MkGameConfig
    {
    windowPos = MkVector2 {t = Int} 100 100,

    windowWidth = 640,
    windowHeight = 480,

    backgroundColorR = 0,
    backgroundColorG = 0,
    backgroundColorB = 0,

    windowTitle = "Pong in Idris2",

    paddleWidth = 20,
    paddleHeight = 80,

    ballWidth = 20,
    ballHeight = 20,

    paddleHorizontalOffset = 300,

    ballSpeed = 100,
    
    pointsToWin = 10
    }

lPaddleX : Double
lPaddleX = ((cast gameConfig.windowWidth) / 2) - (cast gameConfig.paddleHorizontalOffset)

lPaddlePos : GameState -> Vector2 Double
lPaddlePos state = MkVector2 {t = Double} lPaddleX state.lPaddleY

rPaddleX : Double
rPaddleX = ((cast gameConfig.windowWidth) / 2) + (cast gameConfig.paddleHorizontalOffset)

rPaddlePos : GameState -> Vector2 Double
rPaddlePos state = MkVector2 {t = Double} rPaddleX state.rPaddleY

renderWhiteRect : AnyPtr -> Vector2 Double -> Double -> Double -> IO ()
renderWhiteRect rend pos w h = do
    r <- pure (MkSDL_Rect)
    primIO (SDL_Rect_set_x r (cast (pos.x - (w / 2))))
    primIO (SDL_Rect_set_y r (cast (pos.y - (h / 2))))
    primIO (SDL_Rect_set_w r (cast w))
    primIO (SDL_Rect_set_h r (cast h))

    xx <- primIO (SDL_SetRenderDrawColor rend 255 255 255 255)
    x <- primIO (SDL_RenderFillRect rend (unsafeCast r))

    pure ()

renderPaddle : AnyPtr -> Vector2 Double -> IO ()
renderPaddle rend pos = renderWhiteRect rend pos (cast gameConfig.paddleWidth) (cast gameConfig.paddleHeight)

renderBall : AnyPtr -> Vector2 Double -> IO ()
renderBall rend pos = renderWhiteRect rend pos (cast gameConfig.ballWidth) (cast gameConfig.ballHeight)

renderFrame : AnyPtr -> GameState -> IO ()
renderFrame rend state = do
    xx <- primIO (SDL_SetRenderDrawColor rend gameConfig.backgroundColorR gameConfig.backgroundColorG gameConfig.backgroundColorB 255)
    res <- primIO (SDL_RenderClear rend)
    
    renderPaddle rend (lPaddlePos state)
    renderPaddle rend (rPaddlePos state) 

    renderBall rend state.ballPos

    primIO (SDL_RenderPresent rend)

handleEvent : SDL_Event -> GameState -> GameState
handleEvent evt state =
    let eventType = SDL_Event_type evt in
        if eventType == SDL_KEYDOWN then { lPaddleDirection := 1 } state else
        if eventType == SDL_KEYUP then { lPaddleDirection := 0 } state else
        if eventType == SDL_QUIT then { quitting := True } state else
        state
        --if (eventType == SDL_KEYDOWN) then putStrLn (show (getField (getField (unsafeCast {to=SDL_KeyboardEvent} evt) "keysym") "scancode")) else io_pure ()

doFrame : SDL_Event -> AnyPtr -> GameState -> IO ()
doFrame evt rend state = do
    -- TODO: poll multiple events per frame
    asdf <- primIO (SDL_PollEvent (unsafeCast evt))
    
    let state = handleEvent evt state

    let state = {
            ballPos := (MkVector2 {t = Double} (0.01 + state.ballPos.x) (state.ballPos.y)),
            lPaddleY $= (+ if state.lPaddleDirection == 1 then -0.01 else if state.lPaddleDirection == -1 then 0.01 else 0),
            rPaddleY $= (+ 0.01)
        } state

    renderFrame rend state

    if state.quitting == False then doFrame evt rend state else io_pure ()

main : IO ()
main = do
    x <- primIO (SDL_Init SDL_INIT_VIDEO)
    win <- primIO (SDL_CreateWindow gameConfig.windowTitle gameConfig.windowPos.x gameConfig.windowPos.y gameConfig.windowWidth gameConfig.windowHeight 0)
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
            ballPos = MkVector2 {t = Double} ((cast gameConfig.windowWidth) / 2)  ((cast gameConfig.windowHeight) / 2),
            lScore = 0,
            rScore = 0,
            quitting = False
        })

    doFrame evt rend state

    pure ()