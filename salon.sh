#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

# $PSQL "DROP TABLE IF EXISTS appointments;"
# $PSQL "DROP TABLE IF EXISTS services;"
# $PSQL "DROP TABLE IF EXISTS customers;"

# $PSQL "
# CREATE TABLE customers (
#     customer_id SERIAL PRIMARY KEY NOT NULL,
#     phone VARCHAR(255) UNIQUE NOT NULL,
#     name VARCHAR(255) NOT NULL
# );"

# $PSQL "
# CREATE TABLE appointments (
#     appointment_id SERIAL PRIMARY KEY NOT NULL,
#     time VARCHAR(255) NOT NULL
# );"

# $PSQL "
# CREATE TABLE services (
#     service_id SERIAL PRIMARY KEY NOT NULL,
#     name VARCHAR(255) UNIQUE NOT NULL
# );"

# $PSQL "
# ALTER TABLE appointments
# ADD COLUMN customer_id INT REFERENCES customers(customer_id) NOT NULL,
# ADD COLUMN service_id INT REFERENCES services(service_id) NOT NULL;
# "

# $PSQL "
#   INSERT INTO services (name) VALUES('cut');
#   INSERT INTO services (name) VALUES('color');
#   INSERT INTO services (name) VALUES('perm');
# "

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES_AVAILABLE" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  #check if service input is valid
  SERVICE_ID_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

  if [[ $SERVICE_ID_SELECTED != $SERVICE_ID_AVAILABLE ]]
  then
    #if not, display the service menu  
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    #get customer phone
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    #check customer phone in db
    PHONE_CUSTOMER_RECORDED=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $PHONE_CUSTOMER_RECORDED ]]
    then
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      #record customer name and phone
      INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
      SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_AVAILABLE'")
      CUSTOMER_NAME_RECORDED=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      CUSTOMER_ID_RECORDED=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      echo "What time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME_RECORDED?"
      read SERVICE_TIME
      echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME_RECORDED."
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID_RECORDED, $SERVICE_ID_AVAILABLE)")

  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?"
