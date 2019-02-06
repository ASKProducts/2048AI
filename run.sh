#!/bin/sh

#  run.sh
#  2048AI
#
#  Created by Aaron Kaufer on 2/5/19.
#  

if ["$1" == ""]; then
    swift run
else
    cat Sources/2048AI/main.swift > $1
    unbuffer swift run > $1 &
fi
