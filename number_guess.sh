#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET=$(($RANDOM % 1000 + 1))
echo "Enter your username:"
read USERNAME
if [[ ${#USERNAME} -gt 22 ]]
then
  echo "22 symbols MAX"
else
  #check if username exists
  USER_INFO=$($PSQL "SELECT * FROM usernames WHERE username='$USERNAME';")
  if [[ -z $USER_INFO ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    IFS="|" read USERNAME_ID USER GAMES_PLAYED BEST_SCORE <<< $USER_INFO
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
  fi
  #guess game starts - request an input
  #continue to ask the guess until they got it
  FOUND=false
  COUNT=1
  echo "Guess the secret number between 1 and 1000:"
  while [[ $FOUND == false ]]
  do
  read GUESS
  #if this is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    #compare GUESS with secret number
    #if sercret is lower/bigger or equal...
    if [[ $GUESS -gt $SECRET ]]
    then
      echo "It's lower than that, guess again:"
      COUNT=$(( $COUNT + 1 ))
    elif [[ $GUESS -lt $SECRET ]]
    then
      echo "It's higher than that, guess again:"
      COUNT=$(( $COUNT + 1 ))
    else
      echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"
      FOUND=true
    fi
  fi
  done
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  #if found user - change it data. If not - create one
  if [[ -z $USER_INFO ]]
  then
    ADD_USER=$($PSQL "INSERT INTO usernames(username, best_score) VALUES('$USERNAME', $COUNT);")
  else 
    if [[ $COUNT -lt $BEST_SCORE ]]
    then
    CHANGE_USER=$($PSQL "UPDATE usernames SET games_played=$GAMES_PLAYED, best_score=$COUNT WHERE username_id=$USERNAME_ID;")
    else
    CHANGE_USER=$($PSQL "UPDATE usernames SET games_played=$GAMES_PLAYED WHERE username_id=$USERNAME_ID;")
    fi
  fi
fi