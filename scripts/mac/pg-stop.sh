#!/bin/bash

cd $(dirname "$0")
echo "Le script s'execute dans : $(pwd)"

pg_ctl-17 stop -D ../../data -w -m fast