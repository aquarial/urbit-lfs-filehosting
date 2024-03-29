## Provider Operating Manual

The provider is complicated to setup and manage. You will need a domain and https for both the provider ship and an http fileserver.

### How to install

Use software distribution to install `%lfs-client` app. If you want to build from source, [leave a comment to let me know](https://github.com/aquarial/urbit-lfs-filehosting/issues/1). Otherwise follow the instructions below

### How to setup fileserver

First need to setup the rust HTTP fileserver. You will need to install [rustup](https://rustup.rs/) rust manager. There is no dockerfile yet. You can generate the token however you want, here I use openssl. You will need this token later to setup the hoon provider.

```bash
cd ./urbit-lfs/fileserver/
echo "$(openssl rand -base64 40) > ./AUTHTOKEN_FILE"
ROCKET_PORT=8000 cargo run --release  --  --authtoken_file ./AUTHTOKEN_FILE
```

### How to setup NGINX for ship (based off https://subject.network/posts/urbit-nginx-letsencrypt/)

Once the provider ship is running and the fileserver is running, you will need to make them world-accessable through https. Both the ship and the fileserver must be public.

Start with:

```
user@computer:~$ cat /etc/nginx/sites-enabled/ship.urbit
server {
        server_name your-ship.domain.tdl;            # CHANGE TO YOUR DOMAIN

        location / {
                proxy_set_header Host $host;
                proxy_set_header Connection '';
                proxy_http_version 1.1;
                proxy_pass http://127.0.0.1:8080;    # LOCAL ADDRESS HERE
                chunked_transfer_encoding off;
                proxy_buffering off;
                proxy_cache off;
                proxy_redirect default;
                proxy_set_header Forwarded for=$remote_addr;
        }
}

```

Now add an entry for the fileserver

```

user@computer:~$ cat /etc/nginx/sites-enabled/fileserver
server {
        server_name fileserver.domain.tld;           # YOUR DOMAIN

        location /upload/file/ {
                proxy_pass http://127.0.0.1:8000;    # ACTUAL PORT OF FILESERVER
                add_header Access-Control-Allow-Origin * always;
                add_header Access-Control-Allow-Methods OPTIONS,POST always;
                add_header Access-Control-Allow-Headers * always;
                add_header Access-Control-Allow-Credentials true always;

        }
        location / {
                proxy_pass http://127.0.0.1:8000;    # ACTUAL PORT OF FILESERVER
        }
}


user@computer:~$ service nginx restart


user@computer:~$ cerbot    # apt install nginx certbot python3-certbot-nginx
```


#### NGINX will block requests around a Megabyte in size

The client UI uploads directly because I can't figure out how to stream javascript uploads. (Uploading with curl works fine)

Edit `/etc/nginx/nginx.conf` and add `client_max_body_size 5M;` to raise the limit to whatever you prefer. Similar advice for apache.

### Start Provider and connect to fileserver

In the provider dojo connect using:

```
~your-ship:dojo> |rein %lfs-client [& %lfs-provider]

~your-ship:dojo> :lfs-provider &lfs-provider-command [threadid=~ %connect-server loopback="https://your-ship.domain.tld" fileserver="https://fileserver.domain.tdl" token="THE_TOKEN_FROM_EARLIER"]
>=
"provider on-arvo /setup"
"provider on-arvo setup response code 200"
"provider connected to https://fileserver.domain.tld"
```

To allow users to upload you add 'justifications' for storage space. If multiple rules apply the highest value is used. A moon is always treated like it's parent, and comets are banned unless explicitly listed in ships.

The three types of rules:

```
~your-ship:dojo> :lfs-provider &lfs-provider-command [threadid=~ %add-rule justification=[%ship ships=~[~zod ~dopzod]] size=1.000.000]

~your-ship:dojo> :lfs-provider &lfs-provider-command [threadid=~ %add-rule justification=[%group host=~middev name=%the-forge] size=500.000]

~your-ship:dojo> :lfs-provider &lfs-provider-command [threadid=~ %add-rule justification=[%kids ~] size=200]
```


Other things to do with rules are list them, and remove them:

```

~your-ship:dojo> :lfs-provider &lfs-provider-command [threadid=~ %list-rules ~]]
>=
"rules are: ~[[justification=[%ship ships=~[~zod ~dopzod]] size=1.000.000] [justification=[%group host=~middev name=%the-forge] size=1.000.000]]"

~your-ship:dojo> :lfs-provider &lfs-provider-command [threadid=~ %remove-rule 0]
```

### Debugging

```
~your-ship:dojo> :lfs-provider +dbug
```

State stores the following:

```
storage
    store=(map ship storageinfo)
    storageinfo=[storage=@ud used=@ud files=(map id=tape fileinfo)]
    fileinfo=[download-url=tape size=@ud]

current uploads available, by subscriber
    active-urls=(map ship tape)

one request at a time. usually empty
    pending=(list [src=ship action=action:lfs-provider])

storage space rules
    =upload-rules

networking
    =fileserver-status
    loopback=tape
    fileserver=tape
    fileserverauth=tape
```

Save/Load cycling (restarting the ship) will clear the active-urls on the provider and the fileserver. Should reconnect to fileserver as well.

If you need to poke into the guts to fix something, add a `%noun` poke to `/app/lfs-provider.hoon` to modify the state using any code you want.
