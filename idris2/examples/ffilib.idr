module Ffilib

import System.FFI

%foreign "C:deref_as_int,ffilib"
export
deref_as_int : AnyPtr -> Int

%foreign "C:ptr_set_as_int,ffilib"
export
ptr_set_as_int : AnyPtr -> Int -> PrimIO ()

%foreign "C:ptr_add_byte_offset,ffilib"
export
ptr_add_byte_offset : AnyPtr -> Int -> AnyPtr
