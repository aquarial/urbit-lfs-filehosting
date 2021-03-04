## File Hosting on Urbit (WIP)

## Design

Gall app running on every ship that coordinates upload and download of files

Optional http server running to store and serve files. 
One provider running the http server handles the files for many
clients.

How to 'respond' to a poke? Give response to file-upload-request

```
[wex={[p=[wire=/counter/~timluc ship=~timluc term=%poketime] q=[acked=%.y path=/counter]]} sup={}]
```

```
|mount %
|commit %home
|start %lfs-provider
|fade %lfs-provider

:goad %force
:lfs-provider +dbug

:lfs-provider %bowl
:lfs-provider &lfs-provider-action [%connect-server address="localhost:8000"]
:lfs-provider &lfs-provider-action [%request-upload ~]

:lfs-client %bowl
:lfs-client &lfs-client-action [%add-provider ~dopzod]
:lfs-client &lfs-client-action [%remove-provider ~dopzod]
:lfs-client &lfs-client-action [%request-upload ~dopzod]

rsync -a --info=progress2 --ignore-times ./src/ ./data/molnut/home/
rm -rf data/molnut; cp -r ./data/old.molnut ./data/molnut; ./data/urbit -L ./data/molnut


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
