/-  lfs-provider
|%
++  to-store
  |=  ship-metas=(list ship-meta)
  ^-  (map ship storageinfo:lfs-provider)
  (~(gas by *(map ship storageinfo:lfs-provider)) (turn ship-metas to-store-key))
++  to-store-key
  |=  =ship-meta
  ^-  [=ship =storageinfo:lfs-provider]
  [ship:ship-meta (to-store-storageinfo storageinfo:ship-meta)]
++  to-store-storageinfo
  |=  =storageinfo
  ^-  storageinfo:lfs-provider
  [storage=storage:storageinfo used=used:storageinfo files=(~(gas by *(map tape fileinfo:lfs-provider)) (turn files:storageinfo to-store-files))]
++  to-store-files
  |=  =file
  ^-  [id=tape fileinfo:lfs-provider]
  [(trip id:file) (trip url:file) size:file]
+$  file
  [id=@t url=@t size=@ud]
+$  storageinfo
  [storage=@ud used=@ud files=(list file)]
+$  ship-meta
  [=ship =storageinfo]
++  dejs
  =,  dejs:format
  |%
  ++  ship-metas
    ^-  $-(json (list ^ship-meta))
    (ar ship-meta)
  ++  ship-meta
    ^-  $-(json ^ship-meta)
    %-  ot
    :~  [%ship (su ;~(pfix sig fed:ag))]
        [%storageinfo storageinfo]
    ==
  ++  storageinfo
    ^-  $-(json ^storageinfo)
    %-  ot
    :~  [%storage ni]
        [%used ni]
        [%files (ar file)]
    ==
  ++  file
    ^-  $-(json ^file)
    %-  ot
    :~  [%fileid so]
        [%download-url so]
        [%size ni]
    ==
  --
--
