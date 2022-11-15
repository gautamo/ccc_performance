#!/bin/bash

ENDPOINT_CONFIG="config/endpoints.json"

# take command line argument for --spike or -S, --linear or -L, --exponential or -E
if [ "$1" == "--spike" ] || [ "$1" == "-S" ]; then
    LOAD_CONFIG="config/load/spike.json"
elif [ "$1" == "--linear" ] || [ "$1" == "-L" ]; then
    LOAD_CONFIG="config/load/linear.json"
elif [ "$1" == "--exponential" ] || [ "$1" == "-E" ]; then
    LOAD_CONFIG="config/load/exponential.json"
else
    echo -e "\nPlease specify a test type: --spike (-S), --linear (-L), or --exponential (-E)\n"
    exit 1
fi

int(){ printf '%d' ${1:-} 2>/dev/null || :; }

set_load () {
    SCALE_FACTOR=$(jq -r '.SCALE_FACTOR' $LOAD_CONFIG)
    SCALE_FACTOR=$(int $SCALE_FACTOR)
    echo "SCALE_FACTOR: $SCALE_FACTOR"
    
    WINDOW_SIZE=$(jq -r '.WINDOW_SIZE' $LOAD_CONFIG)
    WINDOW_SIZE=$(int $WINDOW_SIZE)
    echo "WINDOW_SIZE: $WINDOW_SIZE"
    
    LOAD_PATTERN=()
    LOAD_PATTERN+=( $(jq -r '.LOAD_PATTERN[]' $LOAD_CONFIG) )
    # convert each element in array to integer
    for i in "${!LOAD_PATTERN[@]}"; do
        LOAD_PATTERN[$i]=$(int ${LOAD_PATTERN[$i]})
    done
    echo -e "LOAD_PATTERN: ${LOAD_PATTERN[@]}\n"
}

set_endpoint () {
    APP1_ENDPOINT=$(jq -r '.APP1' $LOAD_CONFIG)
    echo "APP1_ENDPOINT: $APP1_ENDPOINT"
    APP2_ENDPOINT=$(jq -r '.APP2' $LOAD_CONFIG)
    echo "APP2_ENDPOINT: $APP2_ENDPOINT"
    APP3_ENDPOINT=$(jq -r '.APP3' $LOAD_CONFIG)
    echo "APP3_ENDPOINT: $APP3_ENDPOINT"
    APP4_ENDPOINT=$(jq -r '.APP4' $LOAD_CONFIG)
    echo "APP4_ENDPOINT: $APP4_ENDPOINT"
    APP5_ENDPOINT=$(jq -r '.APP5' $LOAD_CONFIG)
    echo "APP5_ENDPOINT: $APP5_ENDPOINT"
}

setup () {
    echo -e "\nSETUP DETAILS for $LOAD_CONFIG\n"
    set_load
    set_endpoint
    echo ""
}

set_qps() {
    # QPS = ((load array index value) * scale factor)) / number of seconds in window)
    QPS=$(((${LOAD_PATTERN[$1]} * $SCALE_FACTOR) / $WINDOW_SIZE))
}

setup
read -r -p "Continue? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # run hey for each endpoint in the load pattern
    echo -e "\nCOMPLETED\n"
else
    exit 1
fi