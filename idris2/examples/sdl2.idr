module SDL2

import System.FFI

export
SDL_INIT_VIDEO : Int
SDL_INIT_VIDEO = 0x00000020

export
SDL_RENDERER_ACCELERATED : Int
SDL_RENDERER_ACCELERATED = 0x00000002

SDL_Scancode : Type
SDL_Scancode = Int

SDL_JoystickPowerLevel : Type
SDL_JoystickPowerLevel = Int

SDL_CommonEvent : Type
SDL_CommonEvent = Struct "SDL_CommonEvent" [("type", Int), ("timestamp", Int)]

SDL_DisplayEvent : Type
SDL_DisplayEvent = Struct "SDL_DisplayEvent" [("type", Int), ("timestamp", Int), ("display", Int), ("event", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("data1", Bits16)]

SDL_WindowEvent : Type
SDL_WindowEvent = Struct "SDL_WindowEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("event", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("data1", Bits16), ("data2", Bits16)]

SDL_Keysym : Type
SDL_Keysym = Struct "SDL_Keysym" [("scancode", SDL_Scancode), ("sym", Bits16), ("mod", Bits16), ("unused", Int)]

SDL_KeyboardEvent : Type
SDL_KeyboardEvent = Struct "SDL_KeyboardEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("state", Bits8), ("repeat", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("keysym", SDL_Keysym)]

SDL_TextEditingEvent : Type
SDL_TextEditingEvent = Struct "SDL_TextEditingEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("text", Ptr Bits8), ("start", Bits16), ("length", Bits16)]

SDL_TextEditingExtEvent : Type
SDL_TextEditingExtEvent = Struct "SDL_TextEditingExtEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("text", String), ("start", Bits16), ("length", Bits16)]

SDL_TextInputEvent : Type
SDL_TextInputEvent = Struct "SDL_TextInputEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("text", Ptr Bits8)]

SDL_MouseMotionEvent : Type
SDL_MouseMotionEvent = Struct "SDL_MouseMotionEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("which", Int), ("state", Int), ("x", Bits16), ("y", Bits16), ("xrel", Bits16), ("yrel", Bits16)]

SDL_MouseButtonEvent : Type
SDL_MouseButtonEvent = Struct "SDL_MouseButtonEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("which", Int), ("button", Bits8), ("state", Bits8), ("clicks", Bits8), ("padding1", Bits8), ("x", Bits16), ("y", Bits16)]

SDL_MouseWheelEvent : Type
SDL_MouseWheelEvent = Struct "SDL_MouseWheelEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("which", Int), ("x", Bits16), ("y", Bits16), ("direction", Int), ("preciseX", Double), ("preciseY", Double), ("mouseX", Bits16), ("mouseY", Bits16)]

SDL_JoyAxisEvent : Type
SDL_JoyAxisEvent = Struct "SDL_JoyAxisEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("axis", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("value", Bits16), ("padding4", Bits16)]

SDL_JoyBallEvent : Type
SDL_JoyBallEvent = Struct "SDL_JoyBallEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("ball", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("xrel", Bits16), ("yrel", Bits16)]

SDL_JoyHatEvent : Type
SDL_JoyHatEvent = Struct "SDL_JoyHatEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("hat", Bits8), ("value", Bits8), ("padding1", Bits8), ("padding2", Bits8)]

SDL_JoyButtonEvent : Type
SDL_JoyButtonEvent = Struct "SDL_JoyButtonEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("button", Bits8), ("state", Bits8), ("padding1", Bits8), ("padding2", Bits8)]

SDL_JoyDeviceEvent : Type
SDL_JoyDeviceEvent = Struct "SDL_JoyDeviceEvent" [("type", Int), ("timestamp", Int), ("which", Bits16)]

SDL_JoyBatteryEvent : Type
SDL_JoyBatteryEvent = Struct "SDL_JoyBatteryEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("level", SDL_JoystickPowerLevel)]

SDL_ControllerAxisEvent : Type
SDL_ControllerAxisEvent = Struct "SDL_ControllerAxisEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("axis", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8), ("value", Bits16), ("padding4", Bits16)]

SDL_ControllerButtonEvent : Type
SDL_ControllerButtonEvent = Struct "SDL_ControllerButtonEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("button", Bits8), ("state", Bits8), ("padding1", Bits8), ("padding2", Bits8)]

SDL_ControllerDeviceEvent : Type
SDL_ControllerDeviceEvent = Struct "SDL_ControllerDeviceEvent" [("type", Int), ("timestamp", Int), ("which", Bits16)]

SDL_ControllerTouchpadEvent : Type
SDL_ControllerTouchpadEvent = Struct "SDL_ControllerTouchpadEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("touchpad", Bits16), ("finger", Bits16), ("x", Double), ("y", Double), ("pressure", Double)]

SDL_ControllerSensorEvent : Type
SDL_ControllerSensorEvent = Struct "SDL_ControllerSensorEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("sensor", Bits16), ("data", Ptr Double), ("timestamp_us", Bits64)]

SDL_AudioDeviceEvent : Type
SDL_AudioDeviceEvent = Struct "SDL_AudioDeviceEvent" [("type", Int), ("timestamp", Int), ("which", Int), ("iscapture", Bits8), ("padding1", Bits8), ("padding2", Bits8), ("padding3", Bits8)]

SDL_SensorEvent : Type
SDL_SensorEvent = Struct "SDL_SensorEvent" [("type", Int), ("timestamp", Int), ("which", Bits16), ("data", Ptr Double), ("timestamp_us", Bits64)]

SDL_QuitEvent : Type
SDL_QuitEvent = Struct "SDL_QuitEvent" [("type", Int), ("timestamp", Int)]

SDL_UserEvent : Type
SDL_UserEvent = Struct "SDL_UserEvent" [("type", Int), ("timestamp", Int), ("windowID", Int), ("code", Bits16), ("data1", AnyPtr), ("data2", AnyPtr)]

SDL_SysWMEvent : Type
SDL_SysWMEvent = Struct "SDL_SysWMEvent" [("type", Int), ("timestamp", Int), ("msg", AnyPtr)]

SDL_TouchFingerEvent : Type
SDL_TouchFingerEvent = Struct "SDL_TouchFingerEvent" [("type", Int), ("timestamp", Int), ("touchId", Bits64), ("fingerId", Bits64), ("x", Double), ("y", Double), ("dx", Double), ("dy", Double), ("pressure", Double), ("windowID", Int)]

SDL_MultiGestureEvent : Type
SDL_MultiGestureEvent = Struct "SDL_MultiGestureEvent" [("type", Int), ("timestamp", Int), ("touchId", Bits64), ("dTheta", Double), ("dDist", Double), ("x", Double), ("y", Double), ("numFingers", Bits16), ("padding", Bits16)]

SDL_DollarGestureEvent : Type
SDL_DollarGestureEvent = Struct "SDL_DollarGestureEvent" [("type", Int), ("timestamp", Int), ("touchId", Bits64), ("gestureId", Bits64), ("numFingers", Int), ("error", Double), ("x", Double), ("y", Double)]

SDL_DropEvent : Type
SDL_DropEvent = Struct "SDL_DropEvent" [("type", Int), ("timestamp", Int), ("file", String), ("windowID", Int)]

SDL_Event : Type
SDL_Event = GCAnyPtr

MkSDL_Event : SDL_Event
MkSDL_Event = unsafePerformIO (Mk_) where
  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc 56
    onCollectAny res free

SDL_Event_type : SDL_Event -> Int
SDL_Event_type u = u

SDL_Event_common : SDL_Event -> SDL_CommonEvent
SDL_Event_common u = u

SDL_Event_display : SDL_Event -> SDL_DisplayEvent
SDL_Event_display u = u

SDL_Event_window : SDL_Event -> SDL_WindowEvent
SDL_Event_window u = u

SDL_Event_key : SDL_Event -> SDL_KeyboardEvent
SDL_Event_key u = u

SDL_Event_edit : SDL_Event -> SDL_TextEditingEvent
SDL_Event_edit u = u

SDL_Event_editExt : SDL_Event -> SDL_TextEditingExtEvent
SDL_Event_editExt u = u

SDL_Event_text : SDL_Event -> SDL_TextInputEvent
SDL_Event_text u = u

SDL_Event_motion : SDL_Event -> SDL_MouseMotionEvent
SDL_Event_motion u = u

SDL_Event_button : SDL_Event -> SDL_MouseButtonEvent
SDL_Event_button u = u

SDL_Event_wheel : SDL_Event -> SDL_MouseWheelEvent
SDL_Event_wheel u = u

SDL_Event_jaxis : SDL_Event -> SDL_JoyAxisEvent
SDL_Event_jaxis u = u

SDL_Event_jball : SDL_Event -> SDL_JoyBallEvent
SDL_Event_jball u = u

SDL_Event_jhat : SDL_Event -> SDL_JoyHatEvent
SDL_Event_jhat u = u

SDL_Event_jbutton : SDL_Event -> SDL_JoyButtonEvent
SDL_Event_jbutton u = u

SDL_Event_jdevice : SDL_Event -> SDL_JoyDeviceEvent
SDL_Event_jdevice u = u

SDL_Event_jbattery : SDL_Event -> SDL_JoyBatteryEvent
SDL_Event_jbattery u = u

SDL_Event_caxis : SDL_Event -> SDL_ControllerAxisEvent
SDL_Event_caxis u = u

SDL_Event_cbutton : SDL_Event -> SDL_ControllerButtonEvent
SDL_Event_cbutton u = u

SDL_Event_cdevice : SDL_Event -> SDL_ControllerDeviceEvent
SDL_Event_cdevice u = u

SDL_Event_ctouchpad : SDL_Event -> SDL_ControllerTouchpadEvent
SDL_Event_ctouchpad u = u

SDL_Event_csensor : SDL_Event -> SDL_ControllerSensorEvent
SDL_Event_csensor u = u

SDL_Event_adevice : SDL_Event -> SDL_AudioDeviceEvent
SDL_Event_adevice u = u

SDL_Event_sensor : SDL_Event -> SDL_SensorEvent
SDL_Event_sensor u = u

SDL_Event_quit : SDL_Event -> SDL_QuitEvent
SDL_Event_quit u = u

SDL_Event_user : SDL_Event -> SDL_UserEvent
SDL_Event_user u = u

SDL_Event_syswm : SDL_Event -> SDL_SysWMEvent
SDL_Event_syswm u = u

SDL_Event_tfinger : SDL_Event -> SDL_TouchFingerEvent
SDL_Event_tfinger u = u

SDL_Event_mgesture : SDL_Event -> SDL_MultiGestureEvent
SDL_Event_mgesture u = u

SDL_Event_dgesture : SDL_Event -> SDL_DollarGestureEvent
SDL_Event_dgesture u = u

SDL_Event_drop : SDL_Event -> SDL_DropEvent
SDL_Event_drop u = u

SDL_Event_padding : SDL_Event -> Ptr Bits8
SDL_Event_padding u = u


%foreign "C:SDL_CreateWindow,SDL2"
export
SDL_CreateWindow : String -> Bits16 -> Bits16 -> Bits16 -> Bits16 -> Int -> PrimIO AnyPtr

%foreign "C:SDL_GetWindowSurface,SDL2"
export
SDL_GetWindowSurface : AnyPtr -> PrimIO AnyPtr

%foreign "C:SDL_UpdateWindowSurface,SDL2"
export
SDL_UpdateWindowSurface : AnyPtr -> PrimIO Bits16

%foreign "C:SDL_PollEvent,SDL2"
export
SDL_PollEvent : AnyPtr -> PrimIO Bits16

%foreign "C:SDL_CreateRenderer,SDL2"
export
SDL_CreateRenderer : AnyPtr -> Bits16 -> Int -> PrimIO AnyPtr

%foreign "C:SDL_RenderSetLogicalSize,SDL2"
export
SDL_RenderSetLogicalSize : AnyPtr -> Bits16 -> Bits16 -> PrimIO Bits16

%foreign "C:SDL_RenderClear,SDL2"
export
SDL_RenderClear : AnyPtr -> PrimIO Bits16

%foreign "C:SDL_RenderPresent,SDL2"
export
SDL_RenderPresent : AnyPtr -> PrimIO ()

%foreign "C:SDL_Delay,SDL2"
export
SDL_Delay : Int -> PrimIO ()

%foreign "C:SDL_Init,SDL2"
export
SDL_Init : Int -> PrimIO Bits16

