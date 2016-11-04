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

Here is a quick demo on how to use the WSK CLI to configure your API GW

Lets create an API for a Bank name `Santana Bank` on basePath `/bank` to manage two type of resources `checks` and `accounts`
```
$ wsk api create -n "Santana Bank" /bank /checks get /whisk.system/utils/echo
ok: created api /checks GET for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
$ wsk api create -n "Santana Bank" /bank /checks post /whisk.system/utils/echo
ok: created api /checks POST for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
$ wsk api create -n "Santana Bank" /bank /checks put /whisk.system/utils/echo
ok: created api /checks PUT for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
$ wsk api create -n "Santana Bank" /bank /checks delete /whisk.system/utils/echo
ok: created api /checks DELETE for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
$ wsk api create -n "Santana Bank" /bank /accounts post /whisk.system/utils/echo
ok: created api /accounts POST for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
$ wsk api create -n "Santana Bank" /bank /accounts delete /whisk.system/utils/echo
ok: created api /accounts DELETE for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
$ wsk api create -n "Santana Bank" /bank /accounts get /whisk.system/utils/echo
ok: created api /accounts GET for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
$ wsk api create -n "Santana Bank" /bank /accounts put /whisk.system/utils/echo
ok: created api /accounts PUT for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
```
Let's list app APIs in our namespace

```
$ wsk api list
ok: apis
Action                           Verb             API Name  URL
whisk.system/utils/echo          post         Santana School  http://21ef035.api-gw.mybluemix.net/school/students
whisk.system/utils/echo           put         Santana School  http://21ef035.api-gw.mybluemix.net/school/students
whisk.system/utils/echo        delete         Santana School  http://21ef035.api-gw.mybluemix.net/school/students
whisk.system/utils/echo           get         Santana School  http://21ef035.api-gw.mybluemix.net/school/students

whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
```

Let's list only the ones for basePath `/bank`
```
$ wsk api list /bank
ok: apis
Action                           Verb             API Name  URL
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
```

We can also use API Name `Santana Bank` to list 
```
$ wsk api list "Santana Bank"
ok: apis
Action                           Verb             API Name  URL
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
```

Let's list only the ones for basePath `/bank` and API Path `/checks`
```
$ wsk api list /bank /checks
ok: apis
Action                           Verb             API Name  URL
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
```

Let's export API named `Santana Bank` into a swagger file that we can customize our APIs and store in Source Control to be use in continues integration and deployment (CI/CD) 
```
$ wsk api get "Santana Bank" > bank-swagger.json
$ vi bank-swagger.json
```
Let's test the swagger file by deleting the API name `Santana Bank`
```
$ wsk api delete "Santana Bank"
ok: deleted api Santana Bank
$ wsk api list
ok: apis
Action                           Verb             API Name  URL
```

Now let's restore the API named `Santana Bank` by using the file `bank-swagger.json`
```
$ wsk api create --config-file bank-swagger.json
ok: created api /accounts delete for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
ok: created api /accounts get for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
ok: created api /accounts post for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
ok: created api /accounts put for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/accounts
ok: created api /checks get for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
ok: created api /checks post for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
ok: created api /checks put for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
ok: created api /checks delete for action utils/echo
http://21ef035.api-gw.mybluemix.net/bank/checks
```

We can verify that the API is recreated
```
$ wsk api list
ok: apis
Action                           Verb             API Name  URL
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/accounts
whisk.system/utils/echo        delete         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo           get         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo          post         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
whisk.system/utils/echo           put         Santana Bank  http://21ef035.api-gw.mybluemix.net/bank/checks
```

Now just for fun lets deposit a check for `$1,000,000.99` with a HTTP `POST` using the API Gateway
```
$  curl -X POST -d '{"amount":"1000000.99", "account":"Carlos"}' http://21ef035.api-gw.mybluemix.net/bank/checks
{
  "amount": "11000000.99",
  "account": "Carlos"
}
```

Here is an example of the swagger output
```
$ wsk api get "Santana Bank"
{
    "swagger": "2.0",
    "basePath": "/bank",
    "info": {
        "title": "Santana Bank",
        "version": "1.0.0"
    },
    "paths": {
        "/accounts": {
            "delete": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            },
            "get": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            },
            "post": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            },
            "put": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            }
        },
        "/checks": {
            "delete": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            },
            "get": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            },
            "post": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            },
            "put": {
                "responses": {
                    "default": {
                        "description": "Default response"
                    }
                },
                "x-ibm-op-ext": {
                    "actionName": "utils/echo",
                    "actionNamespace": "whisk.system",
                    "backendMethod": "POST",
                    "backendUrl": "https://192.168.33.13/api/v1/namespaces/whisk.system/actions/utils/echo",
                    "policies": [
                        {
                            "type": "reqMapping",
                            "value": [
                                {
                                    "action": "transform",
                                    "from": {
                                        "location": "query",
                                        "name": "*"
                                    },
                                    "to": {
                                        "location": "body",
                                        "name": "*"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A="
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Authorization"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "application/json"
                                    },
                                    "to": {
                                        "location": "header",
                                        "name": "Content-Type"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "blocking"
                                    }
                                },
                                {
                                    "action": "insert",
                                    "from": {
                                        "value": "true"
                                    },
                                    "to": {
                                        "location": "query",
                                        "name": "result"
                                    }
                                }
                            ]
                        }
                    ]
                }
            }
        }
    }
}
```



