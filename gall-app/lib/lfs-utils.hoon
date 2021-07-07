/-  lfs-provider, lfs-client
|%
++  transform-map
  |*  [m=(map * *) f=gate]
  (~(gas by *(map * *)) (turn ~(tap by m) f))
++  format-number
  |=  n=@ud
  :: 1.234 -> "1234"
  (tape (skim ((list @tD) "{<n>}") |=(c=@tD ?!(=(c '.')))))
++  sanitize-char
  |=  c=@t
  ?:  ?|  =(c '_')  =(c '-')  =(c '.')
          &((gte c 'a') (lte c 'z'))
          &((gte c 'A') (lte c 'Z'))
          &((gte c '0') (lte c '9'))
      ==
    c
  '-'
:: TODO allow any filename by url-encoding it? allow more than 40 chars?
++  sanitize-filename
  |=  in=tape
  ^-  tape
  (swag [0 40] (turn in sanitize-char))
::
:: JSON
::
++  json-justification
    |=  =justification:lfs-provider
    ?-  -.justification
    %group  [%o (my ~[['type' [%s 'group']] ['host' [%s (scot %p host.justification)]] ['name' [%s name.justification]]])]
    %ship  [%o (my ~[['type' [%s 'ship']] ['ships' [%a (turn ships.justification |=(=ship [%s (scot %p ship)]))]]])]
    %kids  [%o (my ~[['type' [%s 'kids']]])]
    ==
::
++  json-rule
  |=  [=justification:lfs-provider size=@ud]
  [%o (my ~[['justification' (json-justification justification)] ['size' [%n (crip (format-number size))]]])]
::
++  json-fileinfo
  |=  [fileid=tape download-url=tape size=@ud upload-time=@da]
  [%o (my ~[['fileid' [%s (crip fileid)]] ['download-url' [%s (crip download-url)]] ['size' [%n (crip (format-number size))]] ['upload-time' [%s (crip "{<upload-time>}")]]])]
::
++  json-storage
  |=  =storageinfo:lfs-provider
  [%o (my ~[['storage' [%n (crip (format-number storage.storageinfo))]] ['used' [%n (crip (format-number used.storageinfo))]] ['files' [%a (turn ~(tap by files.storageinfo) json-fileinfo)]]])]
::
++  json-storage-map
  |=  [=ship =storageinfo:lfs-provider]
  [%o (my ~[['ship' [%s (scot %p ship)]] ['storageinfo' (json-storage storageinfo)]])]
::
:: JSON PARSING
::
++  from-json
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
    [(trip id:file) (trip url:file) size:file `@da`upload-time:file]
  +$  file
    [id=@t url=@t size=@ud upload-time=@da]
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
          [%upload-date du:dejs:format]
      ==
    --
  --
--
