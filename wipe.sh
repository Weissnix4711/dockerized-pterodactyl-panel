#!/bin/bash

# Down all containers
docker-compose down

# Remove and recreate app key file
sudo rm ./panel/data/appkey.env
touch ./panel/data/appkey.env

# Remove storage and cache
sudo rm -rf ./panel/data/storage/*
sudo rm -rf ./panel/data/bootstrap/cache/*

# Remove db
sudo rm -rf mysql/db/*
