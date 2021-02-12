## File Hosting on Urbit [initial proposal](https://grants.urbit.org/proposals/1760204192)

A gall app running on every ship

Optional LFS file server running on localhost

## Design

Gall app running on every ship that coordinates upload and download of files

Optional http server running on localhost, which stores files


```
|mount %
|commit %home
|start %lfs
|fade %lfs

:lfs +dbug

:lfs %a
:lfs &lfs-action [%connect-server port=9.987]
:lfs &lfs-action [%request-upload ~]


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
