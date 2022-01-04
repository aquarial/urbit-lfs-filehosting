## Localhost debugging Operating Manual

The makefile can quickly reload hoon code. Also describes the flags you should set for the fileserver to work locally.

### How to install

Use the client instructions, start both provider and client on the same ship. I use the makefile to copy a fakezod ship, rsync gall-app onto the home, and start both apps.

### How to setup fileserver

```bash
cd ./urbit-lfs/fileserver/
ROCKET_PORT=8000 cargo run -- --authtoken_file "../data/unsafe_password" --add-cors-headers
```

### Doing stuff

The rest is the same as the [provider operating manual](./provider.md) for managing and testing the code.
