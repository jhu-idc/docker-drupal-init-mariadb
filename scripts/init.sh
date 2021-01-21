#!/bin/sh

MYSQL_HOST=${MYSQL_HOST:-mariadb}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

MYSQL_DATABASE=${MYSQL_DATABASE:-drupal_default}

function check_db_exists {
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} -e "use ${MYSQL_DATABASE};" > /dev/null 2>&1
}

function create_database {
    if $DEBUG; then
	echo "Creating Database"
    fi
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} -e "create database ${MYSQL_DATABASE}"
}

function create_db_if_not_exists {
    if ! check_db_exists; then
	create_database
    fi
}


function check_table_exists {
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${MYSQL_DATABASE} -e "select * from users limit 1;" > /dev/null 2>&1
}

function restore_database_from_file {
    if $DEBUG; then
	echo "Restoring from File"
    fi
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${MYSQL_DATABASE} < /var/lib/mysql-files/drupal_default.sql
}

function check_mysql_connection {
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${MYSQL_DATABASE}
}

until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done
	
create_db_if_not_exists

if ! check_table_exists; then
    if $DEBUG; then
	echo "Need to bootstrap database"
    fi
    restore_database_from_file
fi
