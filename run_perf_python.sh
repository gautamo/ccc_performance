#!/usr/bin/python3

import json
import os
import sys
import subprocess

def process_arguments():
    LOAD_CONFIG = ""
    # take command line argument for --spike or -S, --linear or -L, --exponential or -E
    if len(sys.argv) == 2:
        if sys.argv[1] == "--spike" or sys.argv[1] == "-S":
            LOAD_CONFIG = "config/load/spike.json"
        elif sys.argv[1] == "--linear" or sys.argv[1] == "-L":
            LOAD_CONFIG = "config/load/linear.json"
        elif sys.argv[1] == "--exponential" or sys.argv[1] == "-E":
            LOAD_CONFIG = "config/load/exponential.json"
    
    if not os.path.isfile(LOAD_CONFIG):
        print("\nPlease specify a valid test type: --spike (-S), --linear (-L), or --exponential (-E)\n")
        exit(1)
    
    return LOAD_CONFIG

def get_load(LOAD_CONFIG):
    with open(LOAD_CONFIG) as f:
        data = json.load(f)
        return int(data["SCALE_FACTOR"]), int(data["WINDOW_SIZE"]), [int(v) for v in data["LOAD_PATTERN"]]

def get_endpoints():
    ENDPOINT_CONFIG = "config/endpoints.json"
    with open(ENDPOINT_CONFIG) as f:
        data = json.load(f)
        return data["APP1"], data["APP2"], data["APP3"], data["APP4"], data["APP5"]

def setup():
    LOAD_CONFIG = process_arguments()
    SCALE_FACTOR, WINDOW_SIZE, LOAD_PATTERN = get_load(LOAD_CONFIG)
    APP1_ENDPOINT, APP2_ENDPOINT, APP3_ENDPOINT, APP4_ENDPOINT, APP5_ENDPOINT = get_endpoints()
    # create a dictionary of endpoints
    config = {
        "SCALE_FACTOR": SCALE_FACTOR,
        "WINDOW_SIZE": WINDOW_SIZE,
        "LOAD_PATTERN": LOAD_PATTERN,
        "APP1": APP1_ENDPOINT,
        "APP2": APP2_ENDPOINT,
        "APP3": APP3_ENDPOINT,
        "APP4": APP4_ENDPOINT,
        "APP5": APP5_ENDPOINT
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

def run_perf(config):

    # run hey load generator for all 5 apps in parallel with 5 processes
    print("\nRUNNING HEY LOAD GENERATOR FOR ALL 5 APPS IN PARALLEL\n")
    for i in range(len(config["LOAD_PATTERN"])):
        print("Running hey load generator for window " + str(i+1) + " of " + str(len(config["LOAD_PATTERN"])))
        qps = get_qps(config, i)
        # send output to file
        with open("result/p1_stdout.txt","a") as out1, open("result/p1_stderr.txt","a") as err1:
            p1 = subprocess.Popen(["hey", "-z", str(config["WINDOW_SIZE"])+"s", "-c", str(1), "-q", str(qps), config["APP1"]], stdout=out1, stderr=err1)
        with open("result/p2_stdout.txt","a") as out2, open("result/p2_stderr.txt","a") as err2:
            p2 = subprocess.Popen(["hey", "-z", str(config["WINDOW_SIZE"])+"s", "-c", str(1), "-q", str(qps), config["APP2"]], stdout=out2, stderr=err2)
        with open("result/p3_stdout.txt","a") as out3, open("result/p3_stderr.txt","a") as err3:
            p3 = subprocess.Popen(["hey", "-z", str(config["WINDOW_SIZE"])+"s", "-c", str(1), "-q", str(qps), config["APP3"]], stdout=out3, stderr=err3)
        with open("result/p4_stdout.txt","a") as out4, open("result/p4_stderr.txt","a") as err4:
            p4 = subprocess.Popen(["hey", "-z", str(config["WINDOW_SIZE"])+"s", "-c", str(1), "-q", str(qps), config["APP4"]], stdout=out4, stderr=err4)
        with open("result/p5_stdout.txt","a") as out5, open("result/p5_stderr.txt","a") as err5:
            p5 = subprocess.Popen(["hey", "-z", str(config["WINDOW_SIZE"])+"s", "-c", str(1), "-q", str(qps), config["APP5"]], stdout=out5, stderr=err5)
        p1.wait()
        p2.wait()
        p3.wait()
        p4.wait()
        p5.wait()

if __name__ == "__main__":
    config = setup()
    proceed()
    # run the load test
    run_perf(config)
    print("COMPLETE")

