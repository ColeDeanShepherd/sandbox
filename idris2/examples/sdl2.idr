module SDL2

import Core
import System.FFI
import Ffilib

export
SDL_INIT_VIDEO : Int
SDL_INIT_VIDEO = 0x00000020

export
SDL_RENDERER_ACCELERATED : Int
SDL_RENDERER_ACCELERATED = 0x00000002

export
SDL_Scancode : Type
SDL_Scancode = Int

export
SDL_JoystickPowerLevel : Type
SDL_JoystickPowerLevel = Int

export
SDL_Rect : Type
SDL_Rect = Struct "SDL_Rect" [("x", Int), ("y", Int), ("w", Int), ("h", Int)]

export
MkSDL_Rect : SDL_Rect
MkSDL_Rect = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_CommonEvent : Type
SDL_CommonEvent = Struct "SDL_CommonEvent" [("type", Int), ("timestamp", Int)]

export
MkSDL_CommonEvent : SDL_CommonEvent
MkSDL_CommonEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 8
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_DisplayEvent : Type
SDL_DisplayEvent = Struct "SDL_DisplayEvent" [("type", Int), ("timestamp", Int), ("display", Int), ("event", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("data1", Int)]

export
MkSDL_DisplayEvent : SDL_DisplayEvent
MkSDL_DisplayEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 20
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_WindowEvent : Type
SDL_WindowEvent = Struct "SDL_WindowEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("event", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("data1", Int), ("data2", Int)]

export
MkSDL_WindowEvent : SDL_WindowEvent
MkSDL_WindowEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 24
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_Keysym : Type
SDL_Keysym = Struct "SDL_Keysym" [("scancode", SDL_Scancode), ("sym", Int), ("mod", Bits16), ("unused", Int)]

export
MkSDL_Keysym : SDL_Keysym
MkSDL_Keysym = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_KeyboardEvent : Type
SDL_KeyboardEvent = Struct "SDL_KeyboardEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("state", Bits8), ("repeat", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("keysym", SDL_Keysym)]

export
MkSDL_KeyboardEvent : SDL_KeyboardEvent
MkSDL_KeyboardEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 32
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_TextEditingEvent : Type
SDL_TextEditingEvent = Struct "SDL_TextEditingEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("text", Ptr Bits8), ("start", Int), ("length", Int)]

export
MkSDL_TextEditingEvent : SDL_TextEditingEvent
MkSDL_TextEditingEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 52
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_TextEditingExtEvent : Type
SDL_TextEditingExtEvent = Struct "SDL_TextEditingExtEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("text", String), ("start", Int), ("length", Int)]

export
MkSDL_TextEditingExtEvent : SDL_TextEditingExtEvent
MkSDL_TextEditingExtEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 32
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_TextInputEvent : Type
SDL_TextInputEvent = Struct "SDL_TextInputEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("text", Ptr Bits8)]

export
MkSDL_TextInputEvent : SDL_TextInputEvent
MkSDL_TextInputEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 44
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_MouseMotionEvent : Type
SDL_MouseMotionEvent = Struct "SDL_MouseMotionEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("which", Int), ("state", Int), ("x", Int), ("y", Int), ("xrel", Int), ("yrel", Int)]

export
MkSDL_MouseMotionEvent : SDL_MouseMotionEvent
MkSDL_MouseMotionEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 36
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_MouseButtonEvent : Type
SDL_MouseButtonEvent = Struct "SDL_MouseButtonEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("which", Int), ("button", Bits8), ("state", Bits8), ("clicks", Bits8), ("padding1", Bits8), ("x", Int), ("y", Int)]

export
MkSDL_MouseButtonEvent : SDL_MouseButtonEvent
MkSDL_MouseButtonEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 28
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_MouseWheelEvent : Type
SDL_MouseWheelEvent = Struct "SDL_MouseWheelEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("which", Int), ("x", Int), ("y", Int), ("direction", Int), ("preciseX", Double), ("preciseY", Double), ("mouseX", Int), ("mouseY", Int)]

export
MkSDL_MouseWheelEvent : SDL_MouseWheelEvent
MkSDL_MouseWheelEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 44
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_JoyAxisEvent : Type
SDL_JoyAxisEvent = Struct "SDL_JoyAxisEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("axis", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("value", Bits16), ("padding4", Bits16)]

export
MkSDL_JoyAxisEvent : SDL_JoyAxisEvent
MkSDL_JoyAxisEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 20
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_JoyBallEvent : Type
SDL_JoyBallEvent = Struct "SDL_JoyBallEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("ball", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("xrel", Bits16), ("yrel", Bits16)]

export
MkSDL_JoyBallEvent : SDL_JoyBallEvent
MkSDL_JoyBallEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 20
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_JoyHatEvent : Type
SDL_JoyHatEvent = Struct "SDL_JoyHatEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("hat", Bits8), ("value", Bits8), ("padding1", Bits8), ("padding2", Bits8)]

export
MkSDL_JoyHatEvent : SDL_JoyHatEvent
MkSDL_JoyHatEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_JoyButtonEvent : Type
SDL_JoyButtonEvent = Struct "SDL_JoyButtonEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("button", Bits8), ("state", Bits8), ("padding1", Bits8), ("padding2", Bits8)]

export
MkSDL_JoyButtonEvent : SDL_JoyButtonEvent
MkSDL_JoyButtonEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_JoyDeviceEvent : Type
SDL_JoyDeviceEvent = Struct "SDL_JoyDeviceEvent" [("type", Int), ("timestamp", Int), ("which", Int)]

export
MkSDL_JoyDeviceEvent : SDL_JoyDeviceEvent
MkSDL_JoyDeviceEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 12
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_JoyBatteryEvent : Type
SDL_JoyBatteryEvent = Struct "SDL_JoyBatteryEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("level", SDL_JoystickPowerLevel)]

export
MkSDL_JoyBatteryEvent : SDL_JoyBatteryEvent
MkSDL_JoyBatteryEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_ControllerAxisEvent : Type
SDL_ControllerAxisEvent = Struct "SDL_ControllerAxisEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("axis", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("value", Bits16), ("padding4", Bits16)]

export
MkSDL_ControllerAxisEvent : SDL_ControllerAxisEvent
MkSDL_ControllerAxisEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 20
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_ControllerButtonEvent : Type
SDL_ControllerButtonEvent = Struct "SDL_ControllerButtonEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("button", Bits8), ("state", Bits8), ("padding1", Bits8), ("padding2", Bits8)]

export
MkSDL_ControllerButtonEvent : SDL_ControllerButtonEvent
MkSDL_ControllerButtonEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_ControllerDeviceEvent : Type
SDL_ControllerDeviceEvent = Struct "SDL_ControllerDeviceEvent" [("type", Int), ("timestamp", Int), ("which", Int)]

export
MkSDL_ControllerDeviceEvent : SDL_ControllerDeviceEvent
MkSDL_ControllerDeviceEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 12
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_ControllerTouchpadEvent : Type
SDL_ControllerTouchpadEvent = Struct "SDL_ControllerTouchpadEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("touchpad", Int), ("finger", Int), ("x", Double), ("y", Double), ("pressure", Double)]

export
MkSDL_ControllerTouchpadEvent : SDL_ControllerTouchpadEvent
MkSDL_ControllerTouchpadEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 32
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_ControllerSensorEvent : Type
SDL_ControllerSensorEvent = Struct "SDL_ControllerSensorEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("sensor", Int), ("data", Ptr Double), ("timestamp_us", Bits64)]

export
MkSDL_ControllerSensorEvent : SDL_ControllerSensorEvent
MkSDL_ControllerSensorEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 40
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_AudioDeviceEvent : Type
SDL_AudioDeviceEvent = Struct "SDL_AudioDeviceEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("iscapture", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8)]

export
MkSDL_AudioDeviceEvent : SDL_AudioDeviceEvent
MkSDL_AudioDeviceEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_SensorEvent : Type
SDL_SensorEvent = Struct "SDL_SensorEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("data", Ptr Double), ("timestamp_us", Bits64)]

export
MkSDL_SensorEvent : SDL_SensorEvent
MkSDL_SensorEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 48
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_QuitEvent : Type
SDL_QuitEvent = Struct "SDL_QuitEvent" [("type", Int), ("timestamp", Int)]

export
MkSDL_QuitEvent : SDL_QuitEvent
MkSDL_QuitEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 8
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_UserEvent : Type
SDL_UserEvent = Struct "SDL_UserEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("code", Int), ("data1", AnyPtr), ("data2", AnyPtr)]

export
MkSDL_UserEvent : SDL_UserEvent
MkSDL_UserEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 32
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_SysWMEvent : Type
SDL_SysWMEvent = Struct "SDL_SysWMEvent" [("type", Int), ("timestamp", Int), ("msg", AnyPtr)]

export
MkSDL_SysWMEvent : SDL_SysWMEvent
MkSDL_SysWMEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 16
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_TouchFingerEvent : Type
SDL_TouchFingerEvent = Struct "SDL_TouchFingerEvent" [("type", Int), ("timestamp", Int), ("touchId", Bits64), ("fingerId", Bits64), ("x", Double), ("y", Double), ("dx", Double), ("dy", Double), ("pressure", Double), ("windowID", Int)]

export
MkSDL_TouchFingerEvent : SDL_TouchFingerEvent
MkSDL_TouchFingerEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 48
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_MultiGestureEvent : Type
SDL_MultiGestureEvent = Struct "SDL_MultiGestureEvent" [("type", Int), ("timestamp", Int), ("touchId", Bits64), ("dTheta", Double), ("dDist", Double), ("x", Double), ("y", Double), ("numFingers", Bits16), ("padding", Bits16)]

export
MkSDL_MultiGestureEvent : SDL_MultiGestureEvent
MkSDL_MultiGestureEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 40
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_DollarGestureEvent : Type
SDL_DollarGestureEvent = Struct "SDL_DollarGestureEvent" [("type", Int), ("timestamp", Int), ("touchId", Bits64), ("gestureId", Bits64), ("numFingers", Int), ("error", Double), ("x", Double), ("y", Double)]

export
MkSDL_DollarGestureEvent : SDL_DollarGestureEvent
MkSDL_DollarGestureEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 40
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_DropEvent : Type
SDL_DropEvent = Struct "SDL_DropEvent" [("type", Int), ("timestamp", Int), ("file", String), ("windowID", Int)]

export
MkSDL_DropEvent : SDL_DropEvent
MkSDL_DropEvent = unsafeCast (unsafePerformIO (Mk_)) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 24
    io_pure (unsafeCast res)
    -- onCollectAny res free


export
SDL_Event : Type
SDL_Event = GCAnyPtr

export
MkSDL_Event : SDL_Event
MkSDL_Event = unsafePerformIO (Mk_) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 56
    io_pure (unsafeCast res)
    -- onCollectAny res free

export
SDL_Event_type : SDL_Event -> Int
SDL_Event_type u = unsafePerformIO (primIO (deref_as_int (unsafeCast u)))

export
SDL_Event_common : SDL_Event -> SDL_CommonEvent
SDL_Event_common = believe_me

export
SDL_Event_display : SDL_Event -> SDL_DisplayEvent
SDL_Event_display = believe_me

export
SDL_Event_window : SDL_Event -> SDL_WindowEvent
SDL_Event_window = believe_me

export
SDL_Event_key : SDL_Event -> SDL_KeyboardEvent
SDL_Event_key = believe_me

export
SDL_Event_edit : SDL_Event -> SDL_TextEditingEvent
SDL_Event_edit = believe_me

export
SDL_Event_editExt : SDL_Event -> SDL_TextEditingExtEvent
SDL_Event_editExt = believe_me

export
SDL_Event_text : SDL_Event -> SDL_TextInputEvent
SDL_Event_text = believe_me

export
SDL_Event_motion : SDL_Event -> SDL_MouseMotionEvent
SDL_Event_motion = believe_me

export
SDL_Event_button : SDL_Event -> SDL_MouseButtonEvent
SDL_Event_button = believe_me

export
SDL_Event_wheel : SDL_Event -> SDL_MouseWheelEvent
SDL_Event_wheel = believe_me

export
SDL_Event_jaxis : SDL_Event -> SDL_JoyAxisEvent
SDL_Event_jaxis = believe_me

export
SDL_Event_jball : SDL_Event -> SDL_JoyBallEvent
SDL_Event_jball = believe_me

export
SDL_Event_jhat : SDL_Event -> SDL_JoyHatEvent
SDL_Event_jhat = believe_me

export
SDL_Event_jbutton : SDL_Event -> SDL_JoyButtonEvent
SDL_Event_jbutton = believe_me

export
SDL_Event_jdevice : SDL_Event -> SDL_JoyDeviceEvent
SDL_Event_jdevice = believe_me

export
SDL_Event_jbattery : SDL_Event -> SDL_JoyBatteryEvent
SDL_Event_jbattery = believe_me

export
SDL_Event_caxis : SDL_Event -> SDL_ControllerAxisEvent
SDL_Event_caxis = believe_me

export
SDL_Event_cbutton : SDL_Event -> SDL_ControllerButtonEvent
SDL_Event_cbutton = believe_me

export
SDL_Event_cdevice : SDL_Event -> SDL_ControllerDeviceEvent
SDL_Event_cdevice = believe_me

export
SDL_Event_ctouchpad : SDL_Event -> SDL_ControllerTouchpadEvent
SDL_Event_ctouchpad = believe_me

export
SDL_Event_csensor : SDL_Event -> SDL_ControllerSensorEvent
SDL_Event_csensor = believe_me

export
SDL_Event_adevice : SDL_Event -> SDL_AudioDeviceEvent
SDL_Event_adevice = believe_me

export
SDL_Event_sensor : SDL_Event -> SDL_SensorEvent
SDL_Event_sensor = believe_me

export
SDL_Event_quit : SDL_Event -> SDL_QuitEvent
SDL_Event_quit = believe_me

export
SDL_Event_user : SDL_Event -> SDL_UserEvent
SDL_Event_user = believe_me

export
SDL_Event_syswm : SDL_Event -> SDL_SysWMEvent
SDL_Event_syswm = believe_me

export
SDL_Event_tfinger : SDL_Event -> SDL_TouchFingerEvent
SDL_Event_tfinger = believe_me

export
SDL_Event_mgesture : SDL_Event -> SDL_MultiGestureEvent
SDL_Event_mgesture = believe_me

export
SDL_Event_dgesture : SDL_Event -> SDL_DollarGestureEvent
SDL_Event_dgesture = believe_me

export
SDL_Event_drop : SDL_Event -> SDL_DropEvent
SDL_Event_drop = believe_me

export
SDL_Event_padding : SDL_Event -> Ptr Bits8
SDL_Event_padding = believe_me


%foreign "C:SDL_CreateWindow,SDL2"
export
SDL_CreateWindow : String -> Int -> Int -> Int -> Int -> Int -> PrimIO AnyPtr

%foreign "C:SDL_GetWindowSurface,SDL2"
export
SDL_GetWindowSurface : AnyPtr -> PrimIO AnyPtr

%foreign "C:SDL_UpdateWindowSurface,SDL2"
export
SDL_UpdateWindowSurface : AnyPtr -> PrimIO Int

%foreign "C:SDL_PollEvent,SDL2"
export
SDL_PollEvent : AnyPtr -> PrimIO Int

%foreign "C:SDL_CreateRenderer,SDL2"
export
SDL_CreateRenderer : AnyPtr -> Int -> Int -> PrimIO AnyPtr

%foreign "C:SDL_RenderSetLogicalSize,SDL2"
export
SDL_RenderSetLogicalSize : AnyPtr -> Int -> Int -> PrimIO Int

%foreign "C:SDL_RenderClear,SDL2"
export
SDL_RenderClear : AnyPtr -> PrimIO Int

%foreign "C:SDL_RenderDrawRect,SDL2"
export
SDL_RenderDrawRect : AnyPtr -> AnyPtr -> PrimIO Int

%foreign "C:SDL_RenderPresent,SDL2"
export
SDL_RenderPresent : AnyPtr -> PrimIO ()

%foreign "C:SDL_Delay,SDL2"
export
SDL_Delay : Int -> PrimIO ()

%foreign "C:SDL_Init,SDL2"
export
SDL_Init : Int -> PrimIO Int

