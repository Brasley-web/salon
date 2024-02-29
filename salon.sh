#!/bin/bash
echo -e "\n~~ MY SALON ~~\n"

PSQL="psql --username=freecodecamp --dbname=salon -t -c "


function MAIN(){

  SHOW_SERVICES "Welcome to My Salon, how can I help you?"
  
}


function SHOW_SERVICES(){
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  QUERY_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$QUERY_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done

  echo -e "\nSelect the service that you want:"
  read SERVICE_ID_SELECTED

  QUERY_SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $QUERY_SERVICES ]]
  then
    SHOW_SERVICES "I could not find that service. What would you like today?"
  else
    MAKE_APPOINTMENT
  fi
}

function MAKE_APPOINTMENT(){

  echo "Enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nEnter your name:"
    read CUSTOMER_NAME
    REGISTER_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  echo -e "\nEnter the time:"
  read SERVICE_TIME

  QUERY_APPOINTMENTS=$($PSQL "SELECT services.name, customers.name FROM appointments INNER JOIN customers USING (customer_id) INNER JOIN services USING (service_id) WHERE customer_id = $CUSTOMER_ID AND service_id = $QUERY_SERVICES AND time = '$SERVICE_TIME'")

  if [[ -z $QUERY_APPOINTMENTS ]]
  then
    MAKE_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $QUERY_SERVICES, '$SERVICE_TIME')")
    QUERY_APPOINTMENT
  else
    QUERY_APPOINTMENT
  fi


}


function QUERY_APPOINTMENT(){

  QUERY_APPOINTMENTS=$($PSQL "SELECT services.name, customers.name FROM appointments INNER JOIN customers USING (customer_id) INNER JOIN services USING (service_id) WHERE customer_id = $CUSTOMER_ID AND service_id = $QUERY_SERVICES AND time = '$SERVICE_TIME'")
  echo "$QUERY_APPOINTMENTS"  | while IFS="|" read SERVICE NAME
  do
    echo "I have put you down for a $(echo $SERVICE | sed -E 's/^ +| +$//g') at $SERVICE_TIME, $(echo $NAME | sed -E 's/^ +| +$//g')."
  done
}

MAIN