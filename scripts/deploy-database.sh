#!/bin/sh

#
# Parameters
#

interactive=true

if [ "$1" = "--no-interactive" ]; then
	interactive=false
fi

#
# Enable and start Postgres
#

sudo systemctl start postgresql.service
sudo systemctl enable postgresql.service

#
# Create databse and user
#

if [ "$interactive" = "true" ]; then
	sudo -u postgres -- createuser -P invidious
	sudo -u postgres -- createdb -O invidious invidious
else
	# Generate a DB password
	if [ -z "$POSTGRES_PASS" ]; then
		echo "Generating database password"
		POSTGRES_PASS=$(tr -dc 'A-Za-z0-9.;!?{[()]}\\/' < /dev/urandom | head -c16)
	fi

	# hostname:port:database:username:password
	echo "Writing .pgpass"
	echo "127.0.0.1:*:invidious:invidious:${POSTGRES_PASS}" > "$HOME/.pgpass"

	sudo -u postgres -- psql -c "CREATE USER invidious WITH PASSWORD '$POSTGRES_PASS';"
	sudo -u postgres -- psql -c "CREATE DATABASE invidious WITH OWNER invidious;"
	sudo -u postgres -- psql -c "GRANT ALL ON DATABASE invidious TO invidious;"
fi


#
# Instructions for modification of pg_hba.conf
#

if [ "$interactive" = "true" ]; then
	echo
	echo "-------------"
	echo "   NOTICE    "
	echo "-------------"
	echo
	echo "Make sure that your postgreSQL's pg_hba.conf file contains the follwong"
	echo "lines before previous 'host' configurations:"
	echo
	echo "host  invidious  invidious  127.0.0.1/32  md5"
	echo "host  invidious  invidious  ::1/128       md5"
	echo
fi
