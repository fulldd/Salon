#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"




MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1 How can I help you?"
  else
      echo -e "Welcome to My Salon, how can I help you?\n"
  fi


  # get services
  SERVICES=$($PSQL "select * from services order by service_id")

  echo "$SERVICES" | while read SERV_ID BAR SERV_NAME
  do
    echo "$SERV_ID) $SERV_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
    else
      echo -e "\nWhat is your telephone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'") 
      echo $CUSTOMER_NAME
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CUST_INSERT=$($PSQL "INSERT INTO customers(name,phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      fi
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'") 
      APP_INSERT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME' )") 
      SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED") 
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
} 

MAIN_MENU