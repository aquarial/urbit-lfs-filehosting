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
