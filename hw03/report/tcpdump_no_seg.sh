# sudo ./tcpdump_monitor.sh any 4133
# print delta between packets and packet site
tcpdump -lnttt -i $1 "tcp[tcpflags] & tcp-push != 0 and dst port $2" | awk '{print $1,$21}'
