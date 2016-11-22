folder = "/home/brabemi/Documents/FIT/9.semestr/MI-SIB/sib/hw03/02"

mydata = read.table(paste(folder, "non-cached.txt", sep="/"))

mean = mean(mydata[,1])
var = var(mydata[,1])

print(mean)
print(var)
print(exp(1.848 + 1.371/2))
hist(mydata[,1], breaks=10, freq=FALSE, xlab = "Non-cached objects count", main = "Non-cached objects" )
xWidth = max(mydata[,1]) - min(mydata[,1])
xGrid = seq(min(mydata[,1])-0.1*xWidth, max(mydata[,1])+0.1*xWidth, length=length(mydata[,1]))
#lines(xGrid, dexp(xGrid, rate=L_t_m), col='green', lw=2, lty=1)
lines(xGrid, dlnorm(xGrid, meanlog = 1.848, sdlog = sqrt(1.371), log = FALSE), col='red', lw=2, lty=1)

mydata = read.table(paste(folder, "cached.txt", sep="/"))

mean = mean(mydata[,1])
var = var(mydata[,1])

print(mean)
print(var)
print((1/0.37)-1)
hist(mydata[,1], breaks=10, freq=FALSE, xlab = "Cached objects count", main = "Cached objects" )
xWidth = max(mydata[,1]) - min(mydata[,1])
xGrid = seq(min(mydata[,1])-0.1*xWidth, max(mydata[,1])+0.1*xWidth, length=length(mydata[,1]))
#lines(xGrid, dexp(xGrid, rate=L_t_m), col='green', lw=2, lty=1)
lines(seq(0,10), dgeom(seq(0,10), prob=0.37), col='red', lw=2, lty=1)


mydata = read.table(paste(folder, "inline.txt", sep="/"))

mean = mean(mydata[,1])
var = var(mydata[,1])

print(mean)
print(var)
print(0.237*23.416)
print(0.237*23.416^2)
hist(mydata[,1], breaks=10, freq=FALSE, xlab = "Inline objects count", main = "Inline objects" )
xWidth = max(mydata[,1]) - min(mydata[,1])
xGrid = seq(min(mydata[,1])-0.1*xWidth, max(mydata[,1])+0.1*xWidth, length=length(mydata[,1]))
#lines(xGrid, dexp(xGrid, rate=L_t_m), col='green', lw=2, lty=1)
lines(xGrid, dgamma(xGrid, 0.237, scale = 23.416), col='red', lw=2, lty=1)