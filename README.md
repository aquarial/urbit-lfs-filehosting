## File Hosting on Urbit [initial proposal](https://grants.urbit.org/proposals/1760204192)

A gall app running on every ship

Optional LFS file server running on localhost

## Design

Gall app running on every ship that coordinates upload and download of files

Optional http server running on localhost, which stores files


```
|mount %
|commit %home
|start %lfs
|fade %lfs

:lfs +dbug

:lfs %a
:lfs &lfs-action [%connect-server port=9.987]
:lfs &lfs-action [%request-upload ~]
```
