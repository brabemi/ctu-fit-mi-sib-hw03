#!/bin/bash


# main object size         (lognorm) : m = 8.346, s^2 = 1.866
# inline object size       (lognorm) : m = 6.166, s^2 = 5.581
# # of cached requests     (geom)    : p = 0.37
# # of non cached requests (lognorm) : n = 1.848, s^2 = 1.371
# parsing time             (gamma)   : a = 0.483, b = 0.269
# # of inline objects      (gamma)   : a = 0.237, b = 23.416
# inter-arrival time       (gamma)   : a = 0.16,  b = 5.375
# viewing time             (weibull) : a = 0.484, b = 18.534


TARGET_IP="10.10.1.3.4133"


random_gamma() {
    out=$(rg -I $next_init -D Gamma -a $1 -b $2)
    gamma_value=$(echo $out | awk -F' :' '{print $1}')
    next_init=$(echo $out | awk -F' :' '{print $2}')
}


random_lognormal() {
    out=$(rg -I $next_init -D Lognormal -m $1 -s $2)
    lognormal_value=$(echo $out | awk -F' :' '{print $1}')
    next_init=$(echo $out | awk -F' :' '{print $2}')
}


random_geometric() {
    out=$(rg -I $next_init -D Geometric -p $1)
    geometric_value=$(echo $out | awk -F' :' '{print $1}')
    next_init=$(echo $out | awk -F' :' '{print $2}')
}


random_weibull() {
    out=$(rg -I $next_init -D Weibull -a $1 -b $2)
    weibull_value=$(echo $out | awk -F' :' '{print $1}')
    next_init=$(echo $out | awk -F' :' '{print $2}')
}


# Float -> Int
round() {
    LC_ALL=C printf "%.0f" $1
}


# random 4B unsigned int
random_uint() {
    # head -c 4 /dev/random | od -N4 -tu4 | head -1 | awk -F' ' '{print $2}'
    od -An -N4 -t u4 /dev/random | awk '{print $1}'
}


generate_inline_object_count() {
    random_gamma 0.237 23.416
    inline_object_count=$(round $gamma_value)
}


# $1: data size
send_object() {
    # urandom due speed
    tg_seed=$(od -An -N4 -t u4 /dev/urandom | awk '{print $1}')
    echo "Sending $1 bytes of data"
#    tg_parameters=`cat <<-EOF
#	on 3
#	tcp $TARGET_IP
#	setup
#	arrival exponential 0.02 length exponential 576
#	seed $tg_seed data $1
#	EOF`
    tg_parameters=`cat <<-EOF
	on 3
	tcp $TARGET_IP
	setup
        arrival exponential 0.02 length $1
        seed $tg_seed packet 1
	EOF`
#    while (! echo "$tg_parameters" | tg -f > /dev/null ); do
#        echo "Restarting"
#    done
    echo "$tg_parameters" | tg -f > /dev/null 2>&1
    while [ $? -ne 0 ]; do
        echo "$tg_parameters" | tg -f > /dev/null 2>&1
    done
}


send_cached_request() {
    # send main object
    random_lognormal 8.346 1.866
    send_object $lognormal_value

    # wait parsing time
    random_gamma 0.483 0.269
    echo "Waiting $gamma_value time"
    microsleep $gamma_value

    # wait viewing time
    random_weibull 0.484 18.534
    echo "Viewing time: $weibull_value"
    microsleep $weibull_value
}


send_noncached_request() {
    # send main object
    random_lognormal 8.346 1.866
    send_object $lognormal_value

    # generate number of inline objects in the background
    generate_inline_object_count

    # wait parsing time
    random_gamma 0.483 0.269
    echo "Parsing time: $gamma_value"
    microsleep $gamma_value

    # send all inline objects
    echo "Sending $inline_object_count inline objects"
    for (( _IOC = 0; _IOC < inline_object_count; _IOC++ )); do
        # send inline object
        random_lognormal 6.166 5.581
        send_object $lognormal_value

        # sleep inter-arrival time
        random_gamma 0.16 5.375
        echo "Inter-arrival time: $gamma_value"
        microsleep $gamma_value
    done

    # wait viewing time
    random_weibull 0.484 18.534
    echo "Viewing time: $weibull_value"
    microsleep $weibull_value
}


generate_traffic() {
    # generate initial seed
    # init_seed=$(echo random_uint)
    init_seed=$(random_uint)
    next_init=$(rg -S $init_seed | awk -F' :' '{print $2}')

    # generate number of non-cached and cached requests
    random_lognormal 1.848 1.371
    NON_CACHED_OBJECTS=$(round $lognormal_value)
    random_geometric 0.37 # 0.44
    CACHED_OBJECTS=$(round $geometric_value)

    # send all non-cached objects
    echo "Sending $NON_CACHED_OBJECTS non-cached objects"
    for (( _NCO = 0; _NCO < $NON_CACHED_OBJECTS; _NCO++ )); do
        send_noncached_request
    done

    # send all cached objects
    echo "Sending $CACHED_OBJECTS cached objects"
    for (( _CO = 0; _CO < $CACHED_OBJECTS; _CO++ )); do
        send_cached_request
    done
}


generate_traffic
