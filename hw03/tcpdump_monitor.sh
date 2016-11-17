# sudo ./tcpdump_monitor.sh lo
# print delta between packets and packet site
tcpdump -nttt -i $1 "tcp[tcpflags] & tcp-push != 0 and dst port $2" | awk '{print $1,$21}'
