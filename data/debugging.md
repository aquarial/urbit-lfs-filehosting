## Localhost debugging Operating Manual

I've got ncie system using the makefile to quickly reload hoon code. Also describes the flags you should set for the fileserver to work locally.

### How to install

Use the client instructions, start both provider and client on the same ship. I use the makefile to copy a fakezod ship, rsync gall-app onto the home, and start both apps.

### How to setup fileserver

```bash
cd ./urbit-lfs/fileserver/
rustup override set nightly  # http fileserver requires newest versions
ROCKET_PORT=8000 cargo run -- --UNSAFE_DEBUG_AUTH --add-cors-headers
```

Debug auth sets the authorized header to `hunter2` every time, so I can hardcode it in the makefile. Need to add CORS headers so the client UI can curl to upload the file. On a real setup the NGINX/proxy will add the headers.


### Doing stuff

The rest is the same as the [provider operating manual](./provider.md) for managing and testing the code.
