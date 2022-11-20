# CCC Performance Testing

1. Run build_apps.sh to build and deploy new versions of app1-app5 to Docker Hub
   1. app1 char: ML Inference (Memory Size: 16 MB, Run Time: 2 sec, Init. Time: 4.5 sec)
   2. app2 char: Video Encoding (Memory Size: 32 MB, Run Time: 1 sec, Init. Time: 3 sec)
   3. app3 char: Matrix Multiply (Memory Size: 64 MB, Run Time: 2 sec, Init. Time: 2.2 sec)
   4. app4 char: Web Serving (Memory Size: 16 MB, Run Time: 1 sec, Init. Time: 2 sec)
   5. app5 char: Floating Point (Memory Size: 32 MB, Run Time: 0 sec, Init. Time: 1.7 sec)

2. Run deploy_fw.sh to deploy app1-app5 to Knative Serving, pass in framework version (have Knative running, check pods with kubectl get all)
   1. -fw1 - min.scale = 0
   2. -fw2 - min.scale = 1
   3. -fw3 - container freezer (pending implementation)
   4. -fw4 - custom implementation (pending implementation)
   5. -d - deletes previous deployment from knative
   6. -i - allows you to specify how many instances of an application type you want deployed
   
3. Run run_perf.sh to run new perf test, pass in load pattern
   1. -P - poisson load
   2. -E - exponential load
   3. -S - spike load
   4. -N -O1 does new_poission distribution with 250 rps shared by 10 workers

- hey load generator feedback will appear in the results folder during run of run_perf.sh
- if you want to update the load pattern, you can update the appropriate json in the load/ folder
- the .json in the load/ folder has three values:
  - LOAD_PATTERN[index] * SCALE_FACTOR is the number of workers sending requests during WINDOW_SIZE seconds.


How to Use Repo:

1. python3 deploy_fw.py -fw1 # launches framework1 of application (requires pip3 install pyyaml)
2. ./run_perf.sh -E # launches perf test of exponential load for 5 minutes
3. If you make a change to an app (other than service file), you can run ./build_apps to build and deploy app builds to docker hub
4. Once you are done with a test, run python3 deploy_fw.py -d to remove last framework deployment
5. NOTE: only app1 will be deployed. if you want other apps to be deployed, uncomment them at the top of deploy_fw.py
6. NOTE: knative_setup.sh is an setup guide to get your local system setup with knative, prometheus, and graphana.


