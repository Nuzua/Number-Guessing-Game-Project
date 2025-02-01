#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

function guessing_game () {

random_number=$(( (RANDOM % 1000) + 1 ))

echo "Guess the secret number between 1 and 1000:"

guess=0
while [ $random_number -ne $guess ] 
do
read guess
tries=$((tries + 1))
if [[ $guess =~ ^[0-9]+$ ]]
then
    if [ $random_number  -lt $guess ]
    then
        echo "It's lower than that, guess again:"
    elif [ $random_number -gt $guess ]
    then
        echo "It's higher than that, guess again:"
    else
        echo "You guessed it in $tries tries. The secret number was $random_number. Nice job!"
        #record the number of games played
            $PSQL "UPDATE number_guess SET games_played = games_played + 1 WHERE username = '$1';"
            # record the best game if it is <= number of tries or if 0 (first game)
                best_game=$($PSQL "SELECT best_game FROM number_guess WHERE username='$1';")
                if [[ $tries -lt $best_game || $best_game == 0 ]]
                then
                $PSQL "UPDATE number_guess SET best_game = $tries WHERE username = '$1';"
                fi
    fi
else
    echo "That is not an integer, guess again:"   
    guess=0
fi
done
}

echo "Enter your username:"
read username
username_check=$($PSQL "SELECT username FROM number_guess WHERE username='$username';")
#if username is not present in the database, add the new user and initiate the game
if [[ -z $username_check ]]
then
$PSQL "INSERT INTO number_guess(username, games_played, best_game) VALUES ('$username', 0, 0);"
echo "Welcome, $username! It looks like this is your first time here."
guessing_game $username
#if the user exists get games played and best game and then initiate the game
else
games_played=$($PSQL "SELECT games_played FROM number_guess WHERE username='$username';")
best_game=$($PSQL "SELECT best_game FROM number_guess WHERE username='$username';")
echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
guessing_game $username
fi
