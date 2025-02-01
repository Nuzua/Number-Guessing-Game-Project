#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

random_number=$(( (RANDOM % 1000) + 1 ))

function guessing_game () {
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
        record_games_played=$($PSQL "UPDATE number_guess SET games_played = games_played + 1 WHERE username = '$1';")
        record_best_game=$($PSQL "UPDATE number_guess SET best_game = $tries WHERE username = '$1' AND best_game;")    
    fi
else
    echo "That is not an integer, guess again:"
fi
done
}

echo "Enter your username:"
read username
username_check=$($PSQL "SELECT username FROM number_guess WHERE username='$username';")

if [[ -z $username_check ]]
then
insert_username=$($PSQL "INSERT INTO number_guess(username, games_played, best_game) VALUES ('$username', 0, 0);")
echo "Welcome, $username! It looks like this is your first time here."
guessing_game $username

else
get_games_played=$($PSQL "SELECT games_played FROM number_guess WHERE username='$username';")
get_best_game=$($PSQL "SELECT best_game FROM number_guess WHERE username='$username';")
echo "Welcome back, $username! You have played $get_games_played games, and your best game took $get_best_game guesses."
guessing_game $username
fi
