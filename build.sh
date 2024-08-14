#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: build [development|release]"
    exit 1
fi

mode=$1


if [ "$mode" == "release" ]; then
        docker compose --profile base build --build-arg release=1
fi

if [ "$mode" == "development" ]; then
        docker compose --profile base build --build-arg release=0
fi

yes | docker system prune
