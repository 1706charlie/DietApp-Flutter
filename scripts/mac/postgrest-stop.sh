#!/bin/bash

cd $(dirname "$0")
echo "Le script s'execute dans : $(pwd)"

source $(dirname "$0")/env.sh

killall postgrest

source pg-stop.sh