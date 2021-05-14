## Provider Operating Manual

The provider is complicated to setup and manage. You will need a domain and server to run the fileserver & provider ship on.

### How to install

Similar to the client instructions, but run `|start %lfs-provider` at the end.

### How to setup fileserver

First need to setup the rust HTTP fileserver. You will need to install [rustup](https://rustup.rs/) rust manager. A dockerfile is in the works.

The steps to run it look like

```bash
cd ./urbit-lfs/fileserver/
rustup override set nightly  # http fileserver requires newest versions
ROCKET_PORT=8000 cargo run --release
```

Every time the fileserver starts up, it generates a new secret key to communicate with the provider. This key makes sure only the provider ship can authorize actions on the fileserver.

```
Authorized Header is aosdivj)(*jOIgs0gjipaox-v*)
```


### How to setup NGINX (based off https://subject.network/posts/urbit-nginx-letsencrypt/)

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


user@computer:~$ cat /etc/nginx/sites-enabled/fileserver
server {
        server_name fileserver.domain.tld;           # YOUR DOMAIN

        location / {
                proxy_pass http://127.0.0.1:8000;    # ACTUAL PORT OF FILESERVER
        }
}


user@computer:~$ service nginx restart


user@computer:~$ cerbot    # apt install nginx certbot python3-certbot-nginx
```



### Connect Provider to fileserver

In the provider dojo connect using:

```
~your-ship:dojo> :lfs-provider &lfs-provider-command [%connect-server loopback="https://your-ship.domain.tld" fileserver="https://fileserver.domain.tdl" token="aosdivj)(*jOIgs0gjipaox-v*)"]
>=
"provider on-arvo /setup"
"provider on-arvo setup response code 200"
"provider connected to https://fileserver.domain.tld"
```

To allow users to upload you add 'justifications' for storage space. If multiple rules apply the highest value is used. A moon is always treated like it's parent, and comets are banned unless explicitly listed in ships.

The three types of rules:

```
~your-ship:dojo> :lfs-provider &lfs-provider-command [%add-rule justification=[%ship ships=~[~zod ~dopzod]] size=1.000.000]

~your-ship:dojo> :lfs-provider &lfs-provider-command [%add-rule justification=[%group host=~middev name=%the-forge] size=500.000]

~your-ship:dojo> :lfs-provider &lfs-provider-command [%add-rule justification=[%kids ~] size=200]
```


Other things to do with rules are list them, and remove them:

```

~your-ship:dojo> :lfs-provider &lfs-provider-command [%list-rules ~]]
>=
"rules are: ~[[justification=[%ship ships=~[~zod ~dopzod]] size=1.000.000] [justification=[%group host=~middev name=%the-forge] size=1.000.000]]"

~your-ship:dojo> :lfs-provider &lfs-provider-command [%remove-rule 0]
```
