#!/usr/bin/env bash
set -ex

cd ./build

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

cd ..

if [ $LOCAL = $REMOTE ]; then
	echo "Up-to-date"
elif [ $LOCAL = $BASE ]; then
	echo "Update available"
	./revert.sh
	./patch.sh
	./build.sh
	sudo systemctl restart invidious@worker.service	
	sudo systemctl restart invidious@web.service	
	sudo systemctl restart invidious@tor.service	
else
    echo "Diverged"
fi

