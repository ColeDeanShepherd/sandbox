def minAns := 1
def maxAns := 100

mutual

partial def main : IO Unit := do
  IO.println "Number Guessing Game in Lean 4"
  IO.println "==============================¬"
  
  let ans <- IO.rand minAns maxAns
  let mut numGuesses := 0

  repeat do
    IO.println s!"Guess a number from {minAns} to {maxAns}."
    let guess <- readGuess
    IO.println ""
    
    numGuesses := numGuesses + 1

    if guess == ans then
      IO.println s!"Congratulations, you're correct! You guessed {numGuesses} times.\n"
      break
    else if guess < ans then
      IO.println "Your guess is too low.\n"
    else
      IO.println "Your guess is too high.\n"

partial def readGuess : IO Nat := do
  let stdin <- IO.getStdin

  let guess? :=
       (<- stdin.getLine)
    |> String.dropRightWhile (p := Char.isWhitespace)
    |> String.toNat?
  
  if let some guess := guess? then
    if guess >= minAns && guess <= maxAns then
      return guess
  
  IO.println "Your guess is invalid.\n"
  readGuess

end