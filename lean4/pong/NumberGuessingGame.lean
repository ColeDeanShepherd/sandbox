mutual

partial def main : IO Unit := do
  IO.println "Number Guessing Game in Lean 4"
  IO.println "=============================="
  
  let ans <- IO.rand 1 100

  doGameLoop ans

partial def doGameLoop (ans: Nat) : IO Unit := do
  let stdin <- IO.getStdin

  IO.println "Guess a number from 1 to 100."
  
  let guess? :=
       (<- stdin.getLine)
    |> String.dropRightWhile (p := Char.isWhitespace)
    |> String.toNat?
  
  IO.println ""

  match guess? with
  | some guess => do
    if guess < ans then
      IO.println "Your guess is too low."
      IO.println ""
      doGameLoop ans
    else if guess > ans then
      IO.println "Your guess is too high."
      IO.println ""
      doGameLoop ans
    else
      IO.println "Congratulations, you're correct!"
  | none => do
    IO.println "Your guess is invalid."
    IO.println ""
    doGameLoop ans
  
end