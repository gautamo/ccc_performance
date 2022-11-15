#!/bin/bash

build () {
    # build each app
    echo -e "\nBUILD APP1\n"
    docker build -t gautamo/app1 app1
    echo -e "\nBUILD APP2\n"
    docker build -t gautamo/app2 app2
    echo -e "\nBUILD APP3\n"
    docker build -t gautamo/app3 app3
    echo -e "\nBUILD APP4\n"
    docker build -t gautamo/app4 app4
    echo -e "\nBUILD APP5\n"
    docker build -t gautamo/app5 app5
}

deploy () {
    # deploy each app to dockerhub
    echo -e "\nDEPLOY APP1\n"
    docker push gautamo/app1
    echo -e "\nDEPLOY APP2\n"
    docker push gautamo/app2
    echo -e "\nDEPLOY APP3\n"
    docker push gautamo/app3
    echo -e "\nDEPLOY APP4\n"
    docker push gautamo/app4
    echo -e "\nDEPLOY APP5\n"
    docker push gautamo/app5
}

echo -e "\nREMEMBER TO RUN 'docker login' BEFORE EXECUTING. ENSURE YOU HAVE PERMISSIONS.\n"
read -r -p "Continue? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    build
    deploy
    echo -e "\nCOMPLETED\n"
else
    exit 1
fi