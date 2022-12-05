import Lean.Data.Json

def allowedFuncNames := [
  "SDL_Init"
]

def readFile? (filePath: System.FilePath): IO (Except IO.Error String) := do
  try
    let contents <- IO.FS.readFile filePath
    return Except.ok contents
  catch e => return Except.error e

def getJsonObjPropVal? (x: Lean.Json) (propName: String) :=
  if let Lean.Json.obj obj := x then
    let prop? := obj.toArray.find? (fun x => x.fst == propName)
    if let .some prop := prop? then
      some prop.snd
    else none
  else none

def getJsonObjPropValStr? (x: Lean.Json) (propName: String): Option String :=
  (getJsonObjPropVal? x propName) >>= (fun x => x.getStr?.toOption)

def getJsonObjPropValArr? (x: Lean.Json) (propName: String): Option (Array Lean.Json) :=
  (getJsonObjPropVal? x propName) >>= (fun x => x.getArr?.toOption)

def getFuncName? (x : Lean.Json): Option String := 
  let tagPropVal? := getJsonObjPropValStr? x "tag"
  if tagPropVal? == "function" then
    getJsonObjPropValStr? x "name"
  else none

def getFuncReturnType? (x : Lean.Json): Option String := 
  let tagPropVal? := getJsonObjPropValStr? x "tag"
  if tagPropVal? == "function" then
    getJsonObjPropValStr? x "name"
  else none

def shouldGenFfiCode (x : Lean.Json): Bool :=
  let funcName? := getFuncName? x
  if let .some funcName := funcName? then
    allowedFuncNames.contains funcName
  else
    False

def genFfiType (x: Lean.Json): String :=
  let tag := (getJsonObjPropValStr? x "tag").get!
  match tag with
  | ":int" => "Int32"
  | "Uint32" => "UInt32"
  | _ => panic! ""

def genParam (x: Lean.Json): String :=
  let name := (getJsonObjPropValStr? x "name").get!
  let type := (getJsonObjPropVal? x "type").get!
  let genType := genFfiType type

  s!"({name}: {genType})"

-- TODO: Use string builder?
def genFfiCode? (x : Lean.Json): Option String :=
  let tagPropVal? := getJsonObjPropValStr? x "tag"
  if tagPropVal? != "function" then none
  else
    let namePropVal := (getJsonObjPropValStr? x "name").get!
    let paramsStr := (getJsonObjPropValArr? x "parameters").get!.toList
      |>.map genParam
      |> String.intercalate (s := ", ")
    let returnTypeName := (getJsonObjPropVal? x "return-type").get! |> genFfiType

    s!"@[extern \"{namePropVal}\"]
constant {namePropVal} : {paramsStr} -> {returnTypeName}"

def main : IO Unit := do
  -- TODO: print errors from "Either"s.
  let .ok jsonStr <- readFile? "SDL2_c2ffi_output.json"
    | IO.println "Failed to load JSON file."

  let .ok json := Lean.Json.parse jsonStr
    | IO.println "Failed to parse JSON."

  let .arr jsonArr := json
    | IO.println "JSON isn't an array."
  
  let genCodeParts := jsonArr.filter shouldGenFfiCode
    |>.map genFfiCode?
    |>.filter Option.isSome
    |>.map Option.get!

  for x in genCodeParts do
    IO.println x