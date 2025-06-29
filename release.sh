#!/bin/bash

read -s -p "Password for the key: " KEY_PASS
echo

mv epico_key.jks android/app/epico_key.jks
export KEY_PASSWORD="$KEY_PASS"
export STORE_PASSWORD="$KEY_PASS"
flutter build appbundle --release