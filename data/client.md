## Client Operating Manual

The client app includes an html interface to upload files to any configured providers.
### How to install


#### Create a moon

Since the project isn't stable yet, you should use a moon instead of your normal ship. In the dojo terminal run the following command:

```
~your-ship:dojo> |moon
>=
moon: ~some-long-your-ship
0v31a.6auka.k6f4c.dhr56.9uig5.pcktv.t98mv...
```

Now in a normal terminal start the moon by running:

```
user@computer:~$ echo "0v31a.6auka.k6f4c.dhr56.9uig5.pcktv..." > keyfile

# first boot
user@computer:~$ ./binaries/urbit -w some-long-your-ship -k keyfile

# later boots
user@computer:~$ rm keyfile
user@computer:~$ ./binaries/urbit ./some-long-your-ship
```

Wait until running `+trouble` shows the same base hash on the moon as your main ship. Give it a minute. Use the `|ames-verb %rcv` command to view ota progress.

#### Install the gall app

Back on the moon dojo
```
# moon dojo
~your-ship:dojo> |mount %

# terminal 
user@computer:~$ git clone --depth 10 https://github.com/aquarial/urbit-lfs-filehosting/
user@computer:~$ rsync --archive --ignore-times \
                    ./urbit-lfs-filehosting/gall-app/ ./some-long-your-ship/home/

# moon dojo
~your-ship:dojo> |commit %home
~your-ship:dojo> |start %lfs-client
```

#### How to use

At this point you can go to `http://localhost:8080/~filemanager` (use the http address of the moon instead of localhost) to see the following interface.

NOTE: streaming file upload doesn't work yet, so the ui can only upload files under a certain size. There is no limit when manually using curl, at the cost of inconvenience.

![demo ui](./interface.png)

For now, errors are only printed to the browser console. Open the console by right-clicking the page, "Inspect Element". Or Keyboard shortcut `Control-Shift-i`

Other messages are printed to the dojo terminal window.

### Commandline Controls (optional)

The client can be operated by poking the gall app with `action`s defined in `/app/lfs-client.hoon`.

```
~your-ship:dojo> :lfs-client &lfs-client-action [threadid=~ %add-provider ~zod]
~your-ship:dojo> :lfs-client &lfs-client-action [threadid=~ %request-upload ~zod ~]
>=
"client tells %local-poke to upload with : https://fileserver.vps.stephan.to/upload/file/0v1d.2d8lb.77rl9-file"

user@computer:~$ curl -X POST -T ./big-file.pdf https://fileserver.vps.stephan.to/upload/file/0v1d.2d8lb.77rl9-file
uploaded
```

The list of actions is found at [/app/sur/lfs-client.hoon`](https://github.com/aquarial/urbit-lfs-filehosting/blob/master/gall-app/sur/lfs-client.hoon)


You can view the current state of the client using the dbug:

```
~your-ship:dojo> :lfs-client +dbug
```

### HTTP Controls (optional)

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
                      http://localhost:8080/spider/noun/lfs-client-action/json.json
{
  "key": "0vp.g3kr8.hq2c2-filename.txt",
  "url": "http://localhost:8000/upload/file/0vp.g3kr8.hq2c2-filename.txt",
  "success": true
}
```
