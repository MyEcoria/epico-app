#!/bin/bash

read -s -p "Password for the key: " KEY_PASS
echo

echo "FLUTTER_SIGNING_ENABLED=true" >> android/gradle.properties
cp epico_key.jks android/app/epico_key.jks
export KEY_PASSWORD="$KEY_PASS"
export STORE_PASSWORD="$KEY_PASS"
flutter build appbundle --release
sed -i '/FLUTTER_SIGNING_ENABLED=true/d' android/gradle.properties