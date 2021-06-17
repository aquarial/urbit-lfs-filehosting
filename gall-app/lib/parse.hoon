|%
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
