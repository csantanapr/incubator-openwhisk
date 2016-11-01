### OpenWhisk API Gateway POC

Video Tutorial: https://youtu.be/kqaYhr7_rI8


Take into account that the apigateway repos are not public yet

Clone routemgmt branch and change directory
```
git clone --depth=1 https://github.com/csantanapr/openwhisk.git --branch routemgmt
cd openwhisk
```


Clone apigw repos
```
./clone_apigw.sh
```

Verify apigw repos are present
```
ls core/apigw/
apigateway                            gateway-service-gw-controller         gateway-service-redis
gateway-director-management-interface gateway-service-manager
```

### Using Vagrant

Change directory to vagrant and start VM
```
cd openwhisk/tools/vagrant
./hello
```

Check that API GW is running via explorer url http://192.168.33.13:3100/explorer

Login into Vagrant VM
```
vagrant ssh
```

Create your first API to expose a whisk action
```
wsk api create -b /api/test/v1 /echo get /whisk.system/utils/echo
ok: created api /echo GET for action /whisk.systems/utils/echo
http://192.168.33.13:8090/api/45baceb8-d106-4879-929a-ad2649bb1df1/api/test/v1/echo
```
In this case the api is using basePath `/api/test/v1`, path `/echo` and http verb `get` to invoke the action `/whisk.systems/utils/echo`

Test your API using `curl` by invoking your action using the API gateway, using the managed URL return in the previous command
```
curl -X GET http://192.168.33.13:8090/api/45baceb8-d106-4879-929a-ad2649bb1df1/api/test/v1/echo?bark=woof
{
 "bark":"woof"
}
```


## Using native Mac
Edit the file `ansible/roles/routemgmt/scripts/installRouteMgmt.sh` to set the IP added to docker-engine ip 192.168.99.100
```
-p gwUrl "http://192.168.99.100:3100/v1"
```

Deploy the routemgmt package after whisk is running locally
```
cd ansible
ansible-playbook -i environments/local routemgmt.yml
```

Set environment variable DC_HOST to the docker-engine ip from docker-machine
```
export DC_HOST=192.168.99.100
```

Build and run the gateway
```
cd core/apigw/gateway-service-gw-controller
docker-compose build
docker-compose up
```


