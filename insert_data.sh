#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#trucating old data
echo $($PSQL "TRUNCATE TABLE games,teams")
#reading in the data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNERS=$($PSQL "SELECT name FROM teams WHERE name='$WINNNER'")
  if [[ $WINNER != "winner" ]]
  then
    #if winner is not found
    if [[ -z $WINNERS ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      #confirming it worked
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo inserted into teams, $WINNER
      fi
    fi
  fi
  #same but for opponents
  OPPONENTS=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
  if [[ $OPPONENT != "opponent" ]]
  then
    #if winner is not ofund
    if [[ -z $OPPONENTS ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      #confirming it worked
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo inserted into teams, $OPPONENT
      fi
    fi
  fi
  #fixing the duplicate key
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  LOSER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
  if [[ -n $WINNER_ID || -n $LOSER_ID ]]
  then
    if [[ $YEAR != "year" ]]
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_goals,opponent_goals,winner_id,opponent_id) VALUES($YEAR,'$ROUND',$WINNER_GOALS,$OPPONENT_GOALS,$WINNER_ID,$LOSER_ID)")
    fi
  fi

done
