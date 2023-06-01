module Main(main) where
import Game
import Guess

main :: IO ()
main = do
    putStrLn "- Welcome to the Card Guessing Game!"
    putStrLn "- Enter the cards (answer) in the format \"4C 3H\""
    putStrLn "- Type 'exit' if you wish to leave the game"
    gameLoop

gameLoop :: IO ()
gameLoop = do
    putStr "- "
    answer <- getLine
    if answer == "exit" then
        putStrLn "Exiting the game. Goodbye!"
    else do
        guess answer
        gameLoop