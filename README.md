## File Hosting on Urbit (WIP)

## Overview

`./webserver/` is a HTTP REST fileserver

`./src/app/lfs-provider.hoon` manages access to the webserver through pokes and subscriptions

`./src/app/lfs-client.hoon` can subscribe to a provider and request an upload url

## How to run

#### Start fileserver

Run `make start-fileserver` which runs: `cd ./fileserver && ROCKET_PORT=8000 cargo run -- --UNSAFE_DEBUG_AUTH`

The provider controls the fileserver using a password printed when it starts up. With the debug flag it will
be be `hunter2`

If you get an error message while building that mentions nightly compiler, run `rustup override set nightly`

#### Setup provider

```
# startup ~zod and
|mount %
:: copy app onto ship
|commit %home
|start %lfs-provider
|start %lfs-client
:lfs-provider &lfs-provider-action [%connect-server loopback="localhost:8081" fileserver="localhost:8000" token="hunter2"]
:lfs-provider &lfs-provider-action [%connect-server loopback="urbit.vps.stephan.to" fileserver="fileserver.vps.stephan.to" token="M<k2?j0~RICyASZhR2@2*<?epHEwL(VDRm*?>RymGOdTP0&as(E5!$o(O65#"]

:: setup file storage permissions
:lfs-provider [%add-rule [justification=[%ship ships=~[~zod]] size=1.000.000]]
:lfs-provider [%add-rule [justification=[%group 'groupname'] size=3.000]]

:lfs-provider %list-rules
:lfs-provider [%remove-rule 0]
```

Replace the `loopback` parameter with the current address/port of ~zod.


#### Upload files

Go to `http://localhost:8081/~filemanager` for a simple html interface

![demo ui](./data/interface.png)

## TODO

- [x] client subscribes to providers
- [x] client `[%request-upload ~]` receives url response
- [x] webserver authenticates lfs-provider
- [x] gall app stores uploaded-files and pending-requests
- [x] upload limits
- [x] eyre endpoint to confirm upload
- [x] upload permissions based on clients/groups/%kids of provider
- [x] poke to delete uploaded files
- [x] client uses scrys+threads instead of pokes
- [x] http upload interface
- [x] demo html+js UI
- [ ] gall app restores webserver state on reboot
- [ ] provider confirms upload url is open before telling the client
- [ ] uses threads to connect IO
- [ ] provider can export & restore state
- [ ] behn fileserver status check
- [ ] transactions either succeed or can be safely retried

Considerations

- [ ] match client/provider versioning
- [ ] moons count to parent storage?
- [ ] ensure provider is safe even if clients are modified
- [ ] handle deleting a group
- [ ] what to do when client unsubscribes?




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
:lfs-provider [%add-rule [justification=[%group group='asdf'] size=30]]
:lfs-provider &lfs-provider-action [%connect-server loopback="localhost:8081" fileserver="localhost:8000" token="hunter2"]

:lfs-client %bowl
:lfs-client &lfs-client-action [threadid=~ %list-files ~]
:lfs-client &lfs-client-action [threadid=~ %add-provider ~zod]
:lfs-client &lfs-client-action [threadid=~ %remove-provider ~zod]
:lfs-client &lfs-client-action [threadid=~ %request-upload ~zod [~ "myfile.png"]]
:lfs-client &lfs-client-action [threadid=~ %request-delete ~zod "0vbeef""]

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
.^(* %gx /=lfs-client=/all-storage-info/json)

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
