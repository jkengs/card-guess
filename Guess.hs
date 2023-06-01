{-|
File     : Guess.hs

Automated guessing program for the game.
-}
module Guess (guess) where
import Data.List
import Card
import Game (feedback, initialGuess, nextGuess, GameState)
import System.Exit
import System.Environment

type Selection = [Card]
type Feedback = (Int, Int, Int, Int, Int)

-- | Individual Guess
guess :: String -> IO ()
guess answerString = do
    let answer = map read $ words answerString
    if validSelection answer then do
        let (guess,other) = initialGuess $ length answer
        loop answer guess other 1
    else do
      putStrLn "Invalid answer:  input must be a string of one or more"
      putStrLn "distinct cards separated by whitespace, where each card"
      putStrLn "is a single character rank 2-9, T, J, Q, K or A, followed"
      putStrLn "by a single character suit C, D, H, or S."
    
-- | The guessing loop.  Repeatedly call nextGuess until the correct answer 
--   is guessed.
loop :: Selection -> Selection -> GameState -> Int -> IO ()
loop answer guess other guesses = do
    putStrLn $ "Guess " ++ show guesses ++ ":  " ++ show guess
    if validSelection guess && length answer == length guess then do
        let result = feedback answer guess
        putStrLn $ "Feedback: " ++ show result
        if successful guess result then do
            putStrLn $ "You got it in " ++ show guesses ++ " guesses!"
          else do
            let (guess',other') = nextGuess (guess,other) result
            loop answer guess' other' (guesses + 1)
      else do
        putStrLn "Invalid guess"
        exitFailure

-- | Returns whether or not the feedback indicates the guess was correct.
successful :: Selection -> Feedback -> Bool
successful sel (right,_,_,_,_) = right == length sel

-- | Returns whether or not a guess or answer is valid, ie, has no repeats.
validSelection :: [Card] -> Bool
validSelection sel = sel == nub sel && not (null sel)