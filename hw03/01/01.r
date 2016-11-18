folder = "/home/brabemi/Documents/FIT/9.semestr/MI-SIB/sib/hw03/01"

#TG params
# on 5 tcp 10.10.1.3.4133
# setup
# arrival exponential 0.02 length exponential 576
# seed3467571962 packet 1000

mydata = read.table(paste(folder, "seed_3467571962.txt", sep="/"))

L_t = 1/0.02
L_s = 1/576
print(L_s)

test = 0.35
print(test)

seed = 2974291915
times = mydata[2:1000,1]
sizes = mydata[1:1000,2]

mean_t = mean(times)
L_t_m = 1/mean_t
print(mean_t) # 0.01968717
hist(times, breaks=10, freq=FALSE, main="Histogram času mezi packety a hustota exp. rozdeleni")
xWidth = max(times) - min(times)
xGrid = seq(min(times)-0.1*xWidth, max(times)+0.1*xWidth, length=length(times))
lines(xGrid, dexp(xGrid, rate=L_t_m), col='green', lw=2, lty=1)
lines(xGrid, dexp(xGrid, rate=L_t), col='red', lw=2, lty=2)

mean_s = mean(sizes)
L_s_m = 1/mean_s
print(mean_s) # 450.751
hist(sizes, breaks=10, freq=FALSE, main="Histogram velikosti packetů a hustota exp. rozdeleni")
xWidth = max(sizes) - min(sizes)
xGrid = seq(min(sizes)-0.1*xWidth, max(sizes)+0.1*xWidth, length=length(sizes))
lines(xGrid, dexp(xGrid, rate=L_s_m), col='green', lw=2, lty=1)
lines(xGrid, dexp(xGrid, rate=L_s), col='red', lw=2, lty=2)
