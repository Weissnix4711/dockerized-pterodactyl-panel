#!/bin/bash

docker-compose down

sudo rm ./panel/data/appkey.env
touch ./panel/data/appkey.env

sudo rm -rf mysql/db/*
