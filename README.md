# CCC Performance Testing

1. Run build_deploy_apps.sh to build and deploy new versions of app1-app5 to Docker Hub
   1. app1 char: ML Inference (Memory Size: 128 MB, Run Time: 6.5 sec, Init. Time: 4.5 sec)
   2. app2 char: Video Encoding (Memory Size: 128 MB, Run Time: 56 sec, Init. Time: 3 sec)
   3. app3 char: Matrix Multiply (Memory Size: 64 MB, Run Time: 2.5 sec, Init. Time: 2.2 sec)
   4. app4 char: Web Serving (Memory Size: 16 MB, Run Time: 2.4 sec, Init. Time: 2 sec)
   5. app5 char: Floating Point (Memory Size: 32 MB, Run Time: 2 sec, Init. Time: 1.7 sec)
2. Run run_perf_python.sh to run new perf test, pass in load pattern
   1. -L - linear load 
   2. -E - exponential load
   3. -S - spike load
3. Run deploy_framework.sh to deploy app1-app5 to Knative Serving, pass in framework version
   1. -fw1 - min.scale = 0
   2. -fw2 - min.scale = 1
   3. -fw3 - container freezer (pending implementation)
   4. -fw4 - custom implementation (pending implementation)

TODO:
1. update apps with unique properties (app size, init / run time using sleep calls) (DONE)
2. deploy_framework.sh deploying Knative Serving apps on Knative framework version - 1 and 2 (DONE)
3. Test run_perf_python.sh on live endpoints
4. Collect results into digestible format
5. Adapt to use arbitrary amount of apps
