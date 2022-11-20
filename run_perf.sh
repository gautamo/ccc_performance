#!/usr/bin/python3

import json
import os
import sys
import subprocess
import time

def process_arguments():
    LOAD_CONFIG = ""
    # take command line argument for --spike or -S, --poisson or -P, --exponential or -E
    if len(sys.argv) == 2:
        if sys.argv[1] == "--spike" or sys.argv[1] == "-S":
            LOAD_CONFIG = "config/load/spike.json"
        elif sys.argv[1] == "--linear" or sys.argv[1] == "-P":
            LOAD_CONFIG = "config/load/poisson.json"
        elif sys.argv[1] == "--exponential" or sys.argv[1] == "-E":
            LOAD_CONFIG = "config/load/exponential.json"
    
    if not os.path.isfile(LOAD_CONFIG):
        print("\nPlease specify a valid test type: --spike (-S), --poisson (-P), or --exponential (-E)\n")
        exit(1)
    
    return LOAD_CONFIG

def get_load(LOAD_CONFIG):
    with open(LOAD_CONFIG) as f:
        data = json.load(f)
        return int(data["SCALE_FACTOR"]), int(data["WINDOW_SIZE"]), [int(v) for v in data["LOAD_PATTERN"]]

def get_endpoints():
    ENDPOINT_CONFIG = "config/endpoints.json"
    with open(ENDPOINT_CONFIG) as f:
        return json.load(f)

def setup():
    LOAD_CONFIG = process_arguments()
    SCALE_FACTOR, WINDOW_SIZE, LOAD_PATTERN = get_load(LOAD_CONFIG)
    # create a dictionary of endpoints
    config = {
        "LOAD_TYPE": LOAD_CONFIG.split("/")[2].split(".")[0],
        "SCALE_FACTOR": SCALE_FACTOR,
        "WINDOW_SIZE": WINDOW_SIZE,
        "LOAD_PATTERN": LOAD_PATTERN,
        "ENDPOINTS": get_endpoints()
    }

    # prettify the json to be printed
    config_json = json.dumps(config, indent=4)
    print(config_json)

    return config

def get_qps(config, index):
    return int((config["LOAD_PATTERN"][index] * config["SCALE_FACTOR"]) / config["WINDOW_SIZE"])

def proceed():
    response = input("\nContinue? [y/N] ")
    if response.lower() == "y" or response.lower() == "yes":
        return
    else:
        exit(1)

def getTrueEndpoint(endpoint_name):
    if endpoint_name.split("-")[0] == "autoscale" and endpoint_name.split("-")[1] == "go":
        # get instance number 
        instance = int(endpoint_name.split("-")[3])
        sleep = 10 * instance
        bloat = 5 * instance
        # prime = 10000 * instance
        return f"http://localhost:8080?sleep={sleep}&bloat={bloat}"

    return "http://localhost:8080"


def run_perf(config):
    # run hey load generator for all apps in parallel with 5 processes
    print(f"\nRUNNING HEY LOAD GENERATOR FOR ALL {len(config['ENDPOINTS'].items())} APPS IN PARALLEL\n")
    promise_list = []
    for load_index in range(len(config["LOAD_PATTERN"])):
        qps = get_qps(config, load_index)
        request_count = config["LOAD_PATTERN"][load_index] * config["SCALE_FACTOR"]
        print(f"Running hey load generator for {config['WINDOW_SIZE']}s window {load_index+1} of {len(config['LOAD_PATTERN'])} with {qps} WORKERS/QPS")

        for endpoint_name, endpoint in config["ENDPOINTS"].items():
            true_endpoint = getTrueEndpoint(endpoint_name)
            host = f"{endpoint.split('//')[1]}"
            # send output to file
            with open(f"result/{endpoint_name}_{config['LOAD_TYPE']}.txt","a") as out:
                # hey -n 10 -c 1 -m 'GET' -host "app1-fw1-1.default.127.0.0.1.nip.io"  "http://localhost:8080"
                # call = f"hey -n {request_count} -c 1 -q {qps} -t 20 -m 'GET' -host '{host}' '{true_endpoint}'"
                # call = f"hey -z {config['WINDOW_SIZE']}s -c 1 -t 20 -q {qps} -m 'GET' -host '{host}' '{true_endpoint}'"
                call = f"hey -z {config['WINDOW_SIZE']}s -c {qps} -t 20 -m 'GET' -host '{host}' '{true_endpoint}'"
                print(f"Request: {call}")
                promise = subprocess.Popen(call, shell=True, stdout=out)  
                promise_list.append(promise)
        time.sleep(config["WINDOW_SIZE"])
    for promise_item in promise_list:
        promise.wait()

if __name__ == "__main__":
    config = setup()
    proceed()
    # print start time
    print(f"\nSTART TIME: {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())}")
    # run the load test
    run_perf(config)
    # print end time
    print(f"\nEND TIME: {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())}")
    print("COMPLETE")




