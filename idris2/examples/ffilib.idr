module Ffilib

import System.FFI

%foreign "C:deref_as_int,ffilib"
export
deref_as_int : AnyPtr -> PrimIO Int
