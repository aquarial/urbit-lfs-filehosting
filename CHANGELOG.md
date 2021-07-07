## 2020/06/09

### Add upload-time to file

**Affects**: provider and client

**Why**: provider needs to respond to a thread request

**What to do**

- update client.hoon
- provider needs insert an `"upload-time"` key into each file in the store.
  - retrieve an auth cookie: `COOKIE=$(curl -i localhost:8080/~/login -X POST -d "password=biltyv-navder" | grep set-cookie | sed 's/set-cookie..//' | sed 's/;.*//')`
  - backup the store `curl --cookie "$COOKIE" --request GET  http://localhost:8080/\~/scry/lfs-provider/store.json`
  - remove the provider`|fade lfs-provider`
  - edit the store to include a key like: `"upload-time": "~2021.7.7..06.21.03..f8aa"`
  - import the store `curl --cookie "$COOKIE" -d '["overwrite-store", [{"ship": "~zod", "storageinfo": {...}, {"ship": "~lapzod", "storageinfo": {...}}]]]' http://localhost:8080/spider/json/lfs-provider-command/json.json`
thneupdate provider.hoon

### Changed provider command type, added 

**Affects**: provider operations

**Why**: provider needs to respond to a thread request

**What to do**

- update provider.hoon
- update client.hoon

## 2020/05/19

#### Added a new type to actions a client can request

**Affects**: provider state

**Why**: clients can get out of sync if they miss subscription updates

**What to do**:

- update provider file


## 2020/05/17

#### Changed CORs handling

**Affects**: fileserver, NGINX config

**Why**: NGINX blocks reqeusts that are too big with a 413. But it doesn't add the `Allow-Access-Origin` header to fails (like 413) so CORS blocks the error message from getting to the client. New change

**What to do**:

- edit `/etc/nginx/sites-enabled/fileserver` to newer version on provider operating manual (separate `location /upload/file` in server)
- git pull & restart fileserver to use newest code
- on provider run `%connect-server` with the new password
