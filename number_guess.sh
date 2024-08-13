#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USERNAME_ID=$($PSQL "select user_id from users where username='$USERNAME';")
if [[ -z $USERNAME_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "insert into users(username) values('$USERNAME');")
  USERNAME_ID=$($PSQL "select user_id from users where username='$USERNAME';")
else
  GAMES_PLAYED=$($PSQL "select count(*) from games where user_id=$USERNAME_ID;")
  BEST_GAME=$($PSQL "select min(number_of_guesses) from games where user_id=$USERNAME_ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESSED_NUMBER
i=1
while [ $GUESSED_NUMBER != $RANDOM_NUMBER ]
do

  if [[ ! $GUESSED_NUMBER =~ ^([1-9][0-9]{0,2}|1000)$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $RANDOM_NUMBER < $GUESSED_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESSED_NUMBER
  i=$(( $i + 1 ))

done

INSERT_GAME=$($PSQL "insert into games(user_id, number_of_guesses) values($USERNAME_ID, $i);")
echo "You guessed it in $i tries. The secret number was $RANDOM_NUMBER. Nice job!"