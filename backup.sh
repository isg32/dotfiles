#!/bin/sh

read -p "Commit Message: " msg

date=$(date '+%Y-%m-%d')

rm -fr .config
cp -r ~/.config .config

git add .config backup.sh README.md

git commit -m "$date: $msg" -s
