## File Hosting on Urbit (WIP)

## Overview

`./webserver/` is a HTTP REST fileserver 

`./src/app/lfs-provider.hoon` manages access to the webserver through pokes and subscriptions

`./src/app/lfs-client.hoon` can subscribe to a provider and request an upload url


## Demo


Console 1 : startup http file server

```
shell$ cd ./webserver/
shell$ cargo run
....
Rocket has launched from http://localhost:8000
```

Console 2: run provider on fake-zod

```
shell$ # setup fake-zod with "|mount %"
shell$ rsync -a --info=progress2 --ignore-times ./src/ ./data/zod/home/
shell$ ./data/urbit ./data/zod
...
dojo> |commit %home
dojo> |start %lfs-provider
dojo> :lfs-provider &lfs-provider-action [%connect-server address="localhost:8000"]
```

Console 3: run client on fake-dopzod

```
shell$ # setup fake-dopzod with "|mount %"
shell$ rsync -a --info=progress2 --ignore-times ./src/ ./data/dopzod/home/
shell$ ./data/urbit ./data/dopzod
...
dojo> |commit %home
dojo> |start %lfs-client
dojo> :lfs-client &lfs-client-action [%add-provider ~zod]
dojo> :lfs-client &lfs-client-action [%request-upload ~zod]
```


## Useful commands

Some commands  I reference a lot. Also look at the makefile

```

|mount %
|commit %home
|start %lfs-provider
|start %lfs-client
|fade %lfs-provider

:goad %force
:lfs-provider +dbug

:lfs-provider %bowl
:lfs-provider &lfs-provider-action [%connect-server address="localhost:8000"]
:lfs-provider &lfs-provider-action [%request-upload ~]

:lfs-client %bowl
:lfs-client &lfs-client-action [%add-provider ~zod]
:lfs-client &lfs-client-action [%remove-provider ~zod]
:lfs-client &lfs-client-action [%request-upload ~zod]


curl -i localhost:8080/~/login -X POST -d "password=hunter2"

curl --header "Content-Type: application/json" \
     --cookie "COOKIE_FROM_PREVIOUS_COMMMAND" \
     --request PUT \
     --data '[{"id":1,"action":"poke","ship":"molnut-dopbex-panref-malsep--worhut-hadreg-tinpet-litzod","app":"hood","mark":"helm-hi","json":"Opening airlock"}]' \
     http://localhost:8080/\~/channel/1601844290-ae45b
     
curl --header "Content-Type: application/json" \
     --cookie "COOKIE_FROM_PREVIOUS_COMMMAND" \
     --request PUT \
     --data @'hooncard.pdf' \
     http://localhost:8080/~upload

```
