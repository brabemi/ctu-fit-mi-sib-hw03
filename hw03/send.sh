#!/bin/bash


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


round() {
    LC_ALL=C printf "%.0f" $1
}


generate_inline_object_count() {
    random_gamma 0.237 23.416
    inline_object_count=$(round $gamma_value)
}


send_object() {
    echo "Sending $1 bytes of data"
}


generate_traffic() {
    # generate initial seed
    next_init=$(head -c 4 /dev/urandom | od -N4 -tu4 | \
                head -1 | awk -F' ' '{print $2}')

    # generate number of non-cached and cached objects
    random_lognormal 1.848 1.371
    NON_CACHED_OBJECTS=$(round $lognormal_value)

    random_geometric 0.37 # 0.44
    CACHED_OBJECTS=$(round $geometric_value)

    # send all non-cached objects
    echo "Sending $NON_CACHED_OBJECTS non-cached objects"
    for (( i = 0; i < $NON_CACHED_OBJECTS; i++ )); do
        send_noncached_request
    done

    # send all cached objects
    echo "Sending $CACHED_OBJECTS cached objects"
    for (( i = 0; i < $CACHED_OBJECTS; i++ )); do
        send_cached_request
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
    for (( i = 0; i < inline_object_count; i++ )); do
        random_lognormal 6.166 5.581
        send_object $lognormal_value

        random_gamma 0.16 5.375
        echo "Inter-arrival time: $gamma_value"
        microsleep $gamma_value
    done

    # wait viewing time
    random_weibull 0.484 18.534
    echo "Viewing time: $weibull_value"
    microsleep $weibull_value
}


generate_traffic
