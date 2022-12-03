import Lean.Data.Json

def getFuncName? (x : Lean.Json): Option String := 
  if let Lean.Json.obj obj := x then
    if obj.any (fun k v => (k == "tag") && (if let Except.ok str := v.getStr? then str == "function" else False)) then
      let prop? := obj.toArray.filter (fun x => x.fst == "name") |>.get? 0
      if let Option.some prop := prop? then
        prop.snd.getStr?.toOption
      else
        none
    else
      none
  else
    none

def main : IO Unit := do
  let jsonStr <- IO.FS.readFile "SDL2_c2ffi_output.json"
  let json? := Lean.Json.parse jsonStr
  
  match json? with
  | Except.error err => IO.println err
  | Except.ok json => do
    if let Lean.Json.arr arr := json then
      for x in (arr.map getFuncName? |>.filter (fun o => o.isSome) |>.map (fun o => o.get!)) do
        IO.println x