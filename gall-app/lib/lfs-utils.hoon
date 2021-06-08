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
  |=  [fileid=tape download-url=tape size=@ud]
  [(crip fileid) [%o (my ~[['download-url' [%s (crip download-url)]] ['size' [%n (crip (format-number size))]]])]]
::
++  json-storage
  |=  =storageinfo:lfs-provider
  [%o (my ~[['storage' [%n (crip (format-number storage.storageinfo))]] ['used' [%n (crip (format-number used.storageinfo))]] ['files' [%o ((map @ta json) (transform-map files.storageinfo json-fileinfo))]]])]
::
++  json-storage-map
  |=  [=ship =storageinfo:lfs-provider]
  [(scot %p ship) (json-storage storageinfo)]
--
