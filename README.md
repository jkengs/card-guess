# Card Guess
A card guessing game written in Haskell that stimulates two players facing each other, where one player tries to guess what the other player's cards (2-4) are. After every guess, a feedback of the guess will be given to the guesser and used to select an optimal next guess.

## Compile & Run
`ghc -O2 --make Main`
<br></br>
`./main`

## Feedback
Calculates the quality of a guess and returns these values in this order:
1. No. of correct cards
2. No. of lower ranked cards in the answer than the lowest rank in the guess
3. No. of correct ranks
4. No. of higher ranked cards in the answer than the highest rank in the guess
5. No. of correct suits

<br>

|Answer| Guess|Feedback|
|---|---|:-:|
| 3 ♣ 4 ♥ | 4 ♥ 3 ♣ | 2 0 2 0 2 |
| A ♣ 2 ♣ | 3 ♣ 4 ♥ | 0 1 0 1 1 |

## Example 

``` 
- Welcome to the Card Guessing Game!
- Enter the cards (answer) in the format "4C 3H"
- Type 'exit' if you wish to leave the game
-> 4C 3H 2D
Guess 1:  [TC,2D,6S]
Feedback: (1,0,1,0,2)
Guess 2:  [TC,5D,TD]
Feedback: (0,3,0,0,2)
Guess 3:  [4C,2D,2H]
Feedback: (2,0,2,0,3)
Guess 4:  [4C,2D,3H]
Feedback: (3,0,3,0,3)
You got it in 4 guesses!
-> exit
Exiting the game. Goodbye!
```
