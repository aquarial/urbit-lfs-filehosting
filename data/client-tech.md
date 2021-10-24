### Commandline Controls

The client can be operated by poking the gall app with `action`s defined in `/app/lfs-client.hoon`.

```
~your-ship:dojo> :lfs-client &lfs-client-action [threadid=~ %add-provider ~zod]
~your-ship:dojo> :lfs-client &lfs-client-action [threadid=~ %request-upload ~zod ~]
>=
"client tells %local-poke to upload with : https://fileserver.vps.domain./upload/file/0v1d.2d8lb.77rl9-file"

user@computer:~$ curl -X POST -T ./big-file.pdf https://fileserver.vps.domain.tld/upload/file/0v1d.2d8lb.77rl9-file
uploaded
```

The list of actions is found at [/app/sur/lfs-client.hoon`](https://github.com/aquarial/urbit-lfs-filehosting/blob/master/gall-app/sur/lfs-client.hoon)


You can view the current state of the client using the dbug:

```
~your-ship:dojo> :lfs-client +dbug
```

### HTTP Controls

The html interface uses scrys and threads to communicate with the gall app.

```
# get auth cookie
user@computer:~$ curl -i localhost:8080/~/login -X POST -d "password=~tirdyt-simsyr-lidmut-bolbec"
HTTP/1.1 204 ok
Connection: keep-alive
Server: urbit/vere-1.3
set-cookie: urbauth-~zod=0v28s.023pe.24lcn.q0fnu; Path=/; Max-Age=604800
#           ^                                  ^
#            \___  send this as a cookie  ____/

# use cookie to get client state
user@computer:~$ curl --header "Content-Type: application/json" \
                      --cookie "urbauth-~zod=0v28s.023pe.24lcn.q0fnu" \
                      --request GET \
                      http://localhost:8080/~/scry/lfs-client/all-storage-info.json
{
  "~zod": {
    "storage": 1000000,
    "used": 395,
    "files": {
      "0v27v.jec67.3mc5o.d74us-filename.txt": {
        "download-url": "http://localhost:8000/download/file/0v27v.jec67.3mc5o.d74us-filename.txt",
        "size": 395
      }
    }
  }
}


# use cookie to run client action
user@computer:~$ curl --header "Content-Type: application/json" \
                      --cookie "urbauth-~zod=0v28s.023pe.24lcn.q0fnu" \
                      --request POST \
                      -d '["request-upload", "~zod", "filename.txt"]' \
                      http://localhost:8080/spider/lfs-client/noun/lfs-client-action/json.json
{
  "key": "0vp.g3kr8.hq2c2-filename.txt",
  "url": "http://localhost:8000/upload/file/0vp.g3kr8.hq2c2-filename.txt",
  "success": true
}
```
