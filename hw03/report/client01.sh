#!/bin/bash

seed=$(od -An -N4 -tu4 /dev/random)

t_lambda=0.02
size_lambda=576
trans_len=1000
tgParameters="on 5 tcp 10.10.1.3.4133
setup
arrival exponential $t_lambda length exponential $size_lambda
seed $seed packet $trans_len"
echo "$tgParameters"
echo "$tgParameters" | tg -f | dcat

