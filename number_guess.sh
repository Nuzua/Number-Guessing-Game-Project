#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

random_number=$(( (RANDOM % 1000) + 1 ))

function guessing_game () {
tries=0
while [ "$guess" -ne "$random_number" ]; do
    read -p "Guess the secret number between 1 and 1000:" guess
    tries=$((tries + 1))

    if [ "$guess" -lt "$random_number" ]; then
        echo "It's lower than that, guess again:"
    elif [ "$guess" -gt "$random_number" ]; then
        echo "It's higher than that, guess again:"
    else
        echo "You guessed it in $tries tries. The secret number was $random_number. Nice job!"
    fi
done

}

echo "Enter your username:"

read username

check_for_username=$($PSQL("SELECT username FROM number_guess WHERE username=$username;"))

if [[ $check_for_username -z ]] 
then
insert_username=$($PSQL("INSERT INTO number_guess(username, games_played, best_game) VALUES ('$username', 0, 0);"))
inserted_username=$($PSQL("SELECT username FROM number_guess WHERE username=$username;"))
echo "Welcome, $inserted_username! It looks like this is your first time here."
echo "Guess the secret number between 1 and 1000:"

else
inserted_username=$($PSQL("SELECT username FROM number_guess WHERE username='$username';"))
games_played=$($PSQL("SELECT games_played FROM number_guess WHERE username='$inserted_username';"))
best_game=$($PSQL("SELECT best_game FROM number_guess WHERE username='$inserted_username';"))
echo "Welcome back, $inserted_username! You have played $games_played games, and your best game took $best_game guesses."

