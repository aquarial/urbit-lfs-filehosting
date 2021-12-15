## Client Operating Manual

The client app includes an html interface to upload files to any configured providers.

### How to install

#### Create a moon (not strictly necessary)

You can install/uninstall the app with software distribution, so it's less necessary to use a moon nowadays.

However if you choose to, here are some notes:

```
~your-ship:dojo> |moon
>=
moon: ~some-long-your-ship
0v31a.6auka.k6f4c.dhr56.9uig5.pcktv.t98mv...
```

in a normal terminal start the moon by running:

```
user@computer:~$ echo "0v31a.6auka.k6f4c.dhr56.9uig5.pcktv..." > keyfile

# first boot
user@computer:~$ ./binaries/urbit -w some-long-your-ship -k keyfile

# later boots
user@computer:~$ rm keyfile
user@computer:~$ ./binaries/urbit ./some-long-your-ship
```

Wait until running `+vats` shows the same base hashs on the moon as your main ship. Give it a minute. Use the `|ames-verb %rcv`` command to view ota progress.

If `+vats` only shows `%base`, you will need to `|install` the other apps:

```
~your-moon-ship:dojo> |install (sein:title our now our) %garden
~your-moon-ship:dojo> |install (sein:title our now our) %landscape
~your-moon-ship:dojo> |install (sein:title our now our) %base
```


#### Install the gall app

Software distribution is HERE! Search for apps hosted by `~nilsud-walwyd-tabnus-fondeg` in the omnisearch bar. 

You can uninstall with the app tile menu (click in the top right hamburger menu)

#### How to use

At this point you can go to `http://localhost:8080/app/lfs-client/` (use the http address of the moon instead of localhost) to see the interface.

NOTE: streaming file upload doesn't work yet, so the ui can only upload files under a certain size. A 413 error means it was too big.

For more technical details, see [client-tech.md](./client-tech.md)
