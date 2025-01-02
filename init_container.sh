#!/bin/bash

SUBJ="/C=BR/O=T.I/OU=Desenvolvimento"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ssl-cert.key -out ./ssl-cert.crt -subj "$SUBJ"

docker compose up -d