{-|
File        : Game.hs
Author      : jkengs
Description : An implementation of a Card Guessing Game

The game stimulates two players facing each other, where one player is the answerer and the other is
the guesser. The answerer selects a number of cards (2-4) without showing the guesser and the 
objective of the game is for the guesser to guess these cards. After every guess, a feedback of the
guess will be given to the guesser and used to select a better guess next.

There are 3 main components of this program:
1. Feedback         - Calculates the quality of a guess, including the 
                      number of correct cards, correct ranks, correct suits and lower/higher ranked 
                      cards as compared to the answer.

2. Initial Guess    - Creates the initial game state, which is the unique combinations of n-cards,
                      and picks the first guess.

3. Next Guess       - Generates an optimal next guess and also updates the game state where the 
                      choices of possible guesses in the game state is significantly reduced via 
                      filtering off guesses that have inconsistent feedbacks.
-}
module Game (feedback, initialGuess, nextGuess, GameState) where
import Card
import Data.List
import Data.Ord (comparing)

-- | GameState is a list of list of Cards, that holds the state of the game (possible guesses left),
--   Feedback is a tuple of five integers that holds the feedback from the answerer after each     
--   guess.
type GameState = [[Card]]
type Feedback = (Int,Int,Int,Int,Int)

-- | Feedback takes a target and a guess, each represented as a list of cards, and returns the five
--   feedback numbers.
feedback :: [Card] -> [Card] -> Feedback
feedback answer guess = (correctCards, lowerRanks, correctRanks, higherRanks, correctSuits)
    where
        -- Cards in both answer and guess
        correctCards = length $ intersect answer guess

        -- Cards in answer that is lower than the lowest ranked card in guess
        lowerRanks = 
            let lowestRank = head . sortBy (comparing rank) $ [x | x <- guess] 
            in length [x | x <- answer, rank x < rank lowestRank]

        -- Cards of the same rank in both answer and guess
        correctRanks = length $ intersect' (map rank answer) (map rank guess)

        -- Cards in answer that is higher than the highest ranked card in guess
        higherRanks = 
            let highestRank = last . sortBy (comparing rank) $ [x | x <- guess] 
            in  length [x | x <- answer, rank x > rank highestRank]
        
        -- Cards of the same suit in both answer and guess
        correctSuits = length $ intersect' (map suit answer) (map suit guess)

-- | A helper function used to find the common suits and ranks when calculating the feedback.
--   It ensures that a card in the guess is only counted once. For example, if the answer has 
--   two clubs and the guess has one club, or vice versa, the correct suits number would be 1,
--   not 2.
intersect' :: Eq a => [a] -> [a] -> [a]
intersect' xs ys = xs \\ diff
    where diff = xs \\ ys

-- | Returns a pair of initial guess of n-cards and the initial game state (contains the possible 
--   guesses).
initialGuess :: Int -> ([Card], GameState)
initialGuess n = (guess, state)
    where 
        allCards = [Card suit rank | suit <- [Club .. Spade], rank <- [R2 .. Ace]]
        allCardCombinations = getCardCombinations n allCards
        guess = getInitialGuess n
        state = delete guess allCardCombinations

-- | A helper function to return unique combinations of n-cards where the order of elements do not
--   matter (i.e. [Card1,Card2] is the same as [Card2,Card1] and thus will not be repeated).
getCardCombinations :: Int -> [Card] -> [[Card]]
getCardCombinations 0 _ = [[]]
getCardCombinations _ [] = []
getCardCombinations n (x:xs) = [x:rest | rest <- getCardCombinations (n-1) xs] 
                               ++ getCardCombinations n xs

-- | Returns an initial guess of n-cards, selected for performing well during testing, where the 
--   cards are of different suits and about 13/(n+1) ranks apart, in order to get the best first 
--   guess.
getInitialGuess :: Int -> [Card]
getInitialGuess n
    | n == 2 = [Card Diamond R2, Card Spade R6]
    | n == 3 = [Card Club R10, Card Diamond R2, Card Spade R6]
    | n == 4 = [Card Club R2, Card Diamond R5, Card Heart R7, Card Spade R10]
    | otherwise = error ("The game can only guess 2-4 cards for now!")

-- | Takes the current guess and game state, and returns a pair of the next guess and the new game state. 
--   The old game state is first processed to filter out guesses that are inconsistent with the 
--   previous feedback. For every possible guess from the state, we treat it as the "answer" thus it
--   should also give the same feedback as the previous feedback. Any possible guesses that do not
--   meet this requirement is regarded as inconsistent and removed.
--   The next guess is then generated and removed from the game state.
nextGuess :: ([Card], GameState) -> Feedback -> ([Card], GameState)
nextGuess (prevGuess, state) prevFeedback = (newGuess, newState)
    where 
        filteredState = delete prevGuess [guess | guess <- state, feedback guess prevGuess == prevFeedback]
        newGuess = getNextGuess filteredState
        newState = delete newGuess filteredState

-- | Takes the current game state and returns the next optimal guess.
--   We will use the following method for games that are guessing a hand of 2 cards:
--   The game state, which contains all the possible guesses is used to create a list of tuple 
--   pairs, where the tuple contains a guess and its corresponding expected number of remaining 
--   possible answers for that guess.
--   We then pick the pair that has the smallest expected number and return the corresponding guess.
--   Otherwise, for games that are guessing a hand of 3/4 cards we will do the following:
--   We will take from the middle of the game state since it performs better on average.
getNextGuess :: GameState -> [Card]
getNextGuess state 
    | handSize == 2 = guess
    | otherwise = state !! mid
        where
            handSize = length $ head state
            mid = length state `div` 2
            ansGuessPairs = [(getPossibleAnsNo guess state, guess) | guess <- state]
            guess = snd $ minimum ansGuessPairs

-- | A helper function that calculates the expected number of remaining possible answers for a chosen
--   guess E(G), based on this formula: 
--   E(G) = (Sum of Squares of Group Sizes) / (Sum of Group Sizes)
--   The game state is first sorted based on their feedback value (with the chosen guess), and then
--   grouped according to their feedback value (i.e. possible answers with same value are grouped 
--   together).
--   We then find the size of every group, and use them to get the values required for the above
--   formula.
getPossibleAnsNo :: [Card] -> GameState -> Double
getPossibleAnsNo guess state = fromIntegral sumSquare / fromIntegral sumSize
    where
        sortedState = sortOn (flip feedback guess) state
        groupedState = groupBy (\a b -> feedback a guess == feedback b guess) state
        groupSize = map length groupedState
        sumSquare = sum $ map (^2) groupSize
        sumSize = sum groupSize