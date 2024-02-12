#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Specify your CSV file
CSV_FILE="games.csv"
$($PSQL "DROP TABLE teams CASCADE;")
$($PSQL "DROP TABLE games;")
$($PSQL "DROP TABLE teams,games;")
$($PSQL "CREATE TABLE teams
  (team_id serial not null primary key,
  name varchar(255) not null unique);")
$($PSQL "CREATE TABLE games
  (game_id serial not null primary key,
  year int not null,
  round varchar(255) not null,
  winner_id int not null, 
  opponent_id int not null,
  winner_goals int not null,
  opponent_goals int not null);")
$($PSQL "ALTER TABLE games
ADD FOREIGN KEY (winner_id) REFERENCES teams(team_id);")
$($PSQL "ALTER TABLE games
ADD FOREIGN KEY (opponent_id) REFERENCES teams(team_id);")
count=1
# Loop through each line in the CSV file
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  if [ $count = 1 ];then
    count=2
    continue
  fi
  # Add teams to teams table
  checkwinner=$($PSQL "SELECT COUNT(*) FROM teams WHERE name = ('$winner');")
  checkopponent=$($PSQL "SELECT COUNT(*) FROM teams WHERE name = ('$opponent');")
  if [ $checkwinner -eq 0 ]; then
    # Use the values from the CSV in your psql commands
    $PSQL "INSERT INTO teams (name) VALUES ('$winner');"
  fi
  if [ $checkopponent -eq 0 ]; then
    # Use the values from the CSV in your psql commands
    $PSQL "INSERT INTO teams (name) VALUES ('$opponent');"
  fi
  # grab the winner and opponent ids
  findwinnerid=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
  # Check if the result is not empty (meaning the name was found)
  if [ -n "$findwinnerid" ]; then
    # Assign the result to a variable
    winnerid=$(echo "$findwinnerid" | tr -d '[:space:]')
  fi
  findopponentid=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
  # Check if the result is not empty (meaning the name was found)
  if [ -n "$findopponentid" ]; then
    # Assign the result to a variable
    opponentid=$(echo "$findopponentid" | tr -d '[:space:]')
  fi
  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$year', '$round', '$winnerid','$opponentid','$winner_goals','$opponent_goals');"
  #echo $year $round $winner $opponent $winner_goals $opponent_goals
  # Add more psql commands as needed

done < "$CSV_FILE"