#!/bin/bash

tgParameters="on 15
tcp 0.0.0.0.4133 server
at 1.1 wait"
echo "$tgParameters"
echo "$tgParameters" | tg -f | dcat

