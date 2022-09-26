#! /bin/bash

echo -e "\n~~~~~~ Welcome to the salon ~~~~~~\n"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
MAIN_MENU()
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How may I help you"
  #gathering available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
  #if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry there are no services available"
  else
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do 
      echo "$SERVICE_ID) $NAME"
    done     
  #getting customer info
  read SERVICE_ID_SELECTED
  #If wrong servie is chosen
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    #sending them back to the start
    MAIN_MENU "Sorry, please choose a number"
  else
    #get service availability
    AVAL_SERV=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    #if not available
    if [[ -z $AVAL_SERV ]]
    then
      #sending user back to start
      MAIN_MENU "Sorry that service is not avaialable"
    else
      #gathering there information
      echo "Please enter your phone number"
      read CUSTOMER_PHONE
      #checking if their name is in the database
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #if name is not in database
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "Please enter your name"
        read CUSTOMER_NAME
        CUSTOMER_NAME_INSERT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      fi
      echo "Please enter a time for your appointment"
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      read SERVICE_TIME
      SERVICE_TIME_INSERT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      if [[ $SERVICE_TIME ]]
      then
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
      fi
    fi
  fi
}
MAIN_MENU
