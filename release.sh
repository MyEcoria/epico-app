#!/bin/bash

read -s -p "Entrez le mot de passe pour la clé : " KEY_PASS
echo

keytool -genkeypair -v \
    -keystore epico_key.jks \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias epico \
    -storepass "$KEY_PASS" \
    -keypass "$KEY_PASS" \
    -dname "CN=epico, OU=epico, O=epico, L=Paris, S=IDF, C=FR"

mv epico_key.jks android/app/epico_key.jks
export KEY_PASSWORD="$KEY_PASS"
export STORE_PASSWORD="$KEY_PASS"
flutter build appbundle --release