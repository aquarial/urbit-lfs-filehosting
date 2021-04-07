## File Hosting on Urbit (WIP)

## Overview

`./webserver/` is a HTTP REST fileserver

`./src/app/lfs-provider.hoon` manages access to the webserver through pokes and subscriptions

`./src/app/lfs-client.hoon` can subscribe to a provider and request an upload url


## TODO

- [x] client subscribes to providers
- [x] client `[%request-upload ~]` receives url response
- [x] webserver authenticates lfs-provider
- [ ] gall app stores uploaded-files and pending-requests
- [x] upload limits
- [x] eyre endpoint to confirm upload
- [x] upload permissions based on clients/groups/%kids of provider
- [ ] gall app restores webserver state on reboot
- [ ] poke to delete uploaded files
- [ ] client uses scrys+threads instead of pokes
- [ ] http upload interface
- [ ] demo html+js UI
- [ ] provider uses threads to connect IO
- [ ] backup provider map of file ownership
- [ ] behn fileserver status check
- [ ] transactions either succeed or can be safely retried

Considerations 

- [ ] how to ratelimit threads
- [ ] match client/provider versioning
- [ ] ensure provider is safe even if clients are modified 
- [ ] stats on fileserver
- [ ] deny comets. moon storage is based on parent
- [ ] handle deleting a group




## Useful commands

Some commands  I reference a lot. Also look at the makefile

```
cargo run -- --UNSAFE_DEBUG_AUTH

|mount %
|commit %home
|start %lfs-provider
|start %lfs-client
|fade %lfs-provider

:goad %force
:lfs-provider +dbug

:lfs-provider %bowl
:lfs-provider [%add-rule [justification=[%ship ships=~[~zod]] size=1.000]]
:lfs-provider [%add-rule [justification=[%group group=`@tas`'asdf'] size=30]]
:lfs-provider &lfs-provider-action [%connect-server address="localhost:8000" token="hunter2"]

:lfs-client %bowl
:lfs-client &lfs-client-action [threadid=~ %list-files ~]
:lfs-client &lfs-client-action [threadid=~ %add-provider ~zod]
:lfs-client &lfs-client-action [threadid=~ %remove-provider ~zod]
:lfs-client &lfs-client-action [threadid=~ %request-upload ~zod]]
:lfs-client &lfs-client-action [threadid=~ %request-delete ~zod 0vbeef]

rsync -a --ignore-times ./src/ ./dst/


=m (my [["a" 1] ["b" 2] ~])
(~(rut by m) |=([name=tape age=@ud] 1))
(~(get by m) "a")

(de-json:html '{"threadid": 123}')
(en-json:html [%n 42])
(en-json:html [%s 'asdf'])
(de-json:html (crip (en-json:html [%n '13'])))

((se:dejs:format %uv) [%s '0vabcd'])
((se:dejs:format %uv) [%s '0vabcd'])

=x (of:dejs:format ~[[%add-provider (su:dejs:format ;~(pfix sig fed:ag))] [%remove-provider (su:dejs:format ;~(pfix sig fed:ag))] [%request-upload (su:dejs:format ;~(pfix sig fed:ag))] [%list-files ul:dejs:format] [%request-delete (su:dejs:format ;~(pfix sig fed:ag)) (se:dejs:format %uv)]])

=srv -build-file %/lib/server/hoon
=group -build-file %/sur/group/hoon
.^((unit group:group) %gx /(scot %p our)/group-store/(scot %da now)/groups/ship/(scot %p our)/[%asdf]/noun)
.^((unit group:group) %gx /=group-store=/groups/ship/~zod/bbbbbbbbb/noun)
.^(* %gx /=group-store=/groups/ship/~zod/bbbbbbbbb/join/~zod/noun)

.^((unit group:group) %gx /=lfs-client=/groups/ship/~zod/bbbbbbbbb/noun)


curl -i localhost:8081/~/login -X POST -d "password=hunter2"

curl --header "Content-Type: application/json" \
     --cookie "COOKIE_FROM_PREVIOUS_COMMMAND" \
     --request PUT \
     --data '[{"id":1,"action":"poke","ship":"your-ship-name-here","app":"hood","mark":"helm-hi","json":"Opening airlock"}]' \
     http://localhost:8081/\~/channel/1601844290-ae45b

curl --header "Content-Type: application/json" \
     --cookie "COOKIE_FROM_PREVIOUS_COMMMAND" \
     --request PUT \
     --data @'hooncard.pdf' \
     http://localhost:8081/~upload


curl --header "Content-Type: application/json" \
     --cookie "$(curl -i localhost:8081/~/login -X POST -d "password=lidlut-tabwed-pillex-ridrup" | rg set-cookie | sed 's/set-cookie..//' | sed 's/;.*//')" \
     --request POST \
     --data '2' \
     http://localhost:8081/spider/noun/lfs-upload-url/json.json

curl --header "Content-Type: application/json" \
     --cookie "$(curl -i localhost:8081/~/login -X POST -d "password=lidlut-tabwed-pillex-ridrup" | rg set-cookie | sed 's/set-cookie..//' | sed 's/;.*//')" \
     --request GET \
     http://localhost:8081/~/scry/lfs-client/list-files.json
```

## Thoughts

how to ratelimit threads?
