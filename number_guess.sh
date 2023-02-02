#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"


echo -e "\n~~~ Welcome To Liam's Number Guessing Game ~~~\n"

NUMBER_GAME() {

  #Creates a variable with a random number between 1-1000
  NUMBER_TO_GUESS=$(( $RANDOM % 1000 + 1 ))
  #Creates a variable that will count the number of guesses
  GUESSES=0

  PLAY_GAME() {
    if [[ ! $1 ]] 
      then
        echo "Guess the secret number between 1 and 1000:"
      else
        echo "$1"
    fi
    read GUESS
    GUESSES=$(($GUESSES+1))
    CHECK_RESULTS $GUESS $GUESSES
  }

  EXIT(){
    echo "You guessed it in $2 tries. The secret number was $1. Nice job!"
  }

  CHECK_RESULTS(){

        if [[ ! $1 =~ ^[0-9]+$ ]]
          then
            PLAY_GAME "That is not an integer, guess again:"          
          elif [[ $1 < $NUMBER_TO_GUESS ]]
            then
              PLAY_GAME "It's higher than that, guess again:"
          elif [[ $1 > $NUMBER_TO_GUESS ]]
            then
              PLAY_GAME "It's lower than that, guess again:"
          elif [[ $1 = $NUMBER_TO_GUESS ]]
            then
              SAVE_RESULT=$($PSQL "INSERT INTO games(user_id,guesses) VALUES ($USERNAME_RESULT_CHECK, $2)")
              GAME_RECORD=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USERNAME_RESULT_CHECK AND guesses = $2")
              EXIT $1 $2
        fi
  }

  echo -e "Enter your username:"
  read USERNAME

  USERNAME_RESULT_CHECK=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME';")

  if [[ -z $USERNAME_RESULT_CHECK ]]
    then
      #Show the welcome message and add the user to the db
      echo -e "Welcome, $USERNAME! It looks like this is your first time here."
      ADD_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME');")
      #Save the user's id in the variable USERNAME_RESULT_CHECK
      USERNAME_RESULT_CHECK=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME';")
      PLAY_GAME
    else
      #Retrieve the user's history
      USER_HISTORY=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE user_id = $USERNAME_RESULT_CHECK;")
      echo $USER_HISTORY | while read GAME_COUNT BAR BEST_GAME 
        do
          echo "Welcome back, $USERNAME! You have played $GAME_COUNT games, and your best game took $BEST_GAME guesses."
        done
      PLAY_GAME
  fi

}

NUMBER_GAME