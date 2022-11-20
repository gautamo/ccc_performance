import os
import sys
import subprocess
import yaml # pip install pyyaml
import json

APP_INSTANCES = 1
# apps = ['app1', 'app2', 'app3', 'app4', 'app5']
apps = ['app1'] # since we only want to test with one app
# apps = ['autoscale-go']

endpoints_file = "config/endpoints.json"

# update metadata name in the file app1/service-fw1.yaml
def update_metadata_name(file, metadata_name):
    # load .yaml file as parsed dictionary
    with open(file, 'r') as stream:
        data = yaml.safe_load(stream)
    # update metadata name
    data['metadata']['name'] = metadata_name
    # write back to .yaml file
    with open(file, 'w') as stream:
        yaml.dump(data, stream)

def deploy():
    # create a json file to store the app names and their corresponding service names
    # get the framework numbers
    fw_num = sys.argv[1][3]
    app_service = {}

    # run the command kubectl apply -f app1/service-fw1.yaml
    count = 0
    for app in apps:
        init_metadata_name = app + f"-fw{fw_num}"
        for instance in range(1, APP_INSTANCES+1):
            metadata_name = init_metadata_name + f"-{instance}"
            deployment_file = app + "/service-fw" + fw_num + ".yaml"
            update_metadata_name(deployment_file, metadata_name)
            print(f"{count + 1}: Deploying {metadata_name} from {deployment_file}")
            subprocess.run(["kubectl", "apply", "-f", deployment_file])
            app_service[metadata_name] = f"http://{metadata_name}.default.127.0.0.1.nip.io"
            count += 1
        update_metadata_name(deployment_file, init_metadata_name)

    # save app_service dictionary to endpoints.json
    with open(endpoints_file, "w") as f:
        json.dump(app_service, f, indent=4)

def delete():
    # run the command kubectl delete -f app1/service-fw1.yaml
    # load the endpoints.json file
    with open(endpoints_file, "r") as f:
        app_service = json.load(f)

    for index, app in enumerate(app_service.keys()):
        if len(app.split("-")) == 3:
            app_name, app_framework, app_instance = app.split("-")
        elif len(app.split("-")) == 4:
            app_name_p1, app_name_p2, app_framework, app_instance = app.split("-")
            app_name = app_name_p1 + "-" + app_name_p2
        deployment_file = app_name + "/service-fw" + app_framework[2] + ".yaml"
        print(f"{index + 1}: Deleting {app} from {deployment_file}")
        update_metadata_name(deployment_file, app)
        subprocess.run(["kubectl", "delete", "-f", deployment_file])
        update_metadata_name(deployment_file, f"{app_name}-{app_framework}")
    
    # put empty dictionary to endpoints.json
    with open(endpoints_file, "w") as f:
        json.dump({}, f, indent=4)

# check if an argument is passed, -fw1, -fw2, -fw3, -fw4, or -d, and -i
if len(sys.argv) == 3 and sys.argv[2] in ["-i"]:
    APP_INSTANCES = max(1, int(input("Enter the number of instances per app: ")))
if len(sys.argv) >= 2 and sys.argv[1] in ["-fw1", "-fw2", "-fw3", "-fw4"]:
    deploy()
elif len(sys.argv) == 2 and sys.argv[1] == "-d":
    delete()
else:
    print("Usage: deploy_framework.sh -fw1/2/3/4 (Deploy framework #) + -i (prompt for instance count), or -d (Delete all services in endpoints.json)")
    sys.exit(1)
