|%
+$  action
  $%  [%connect-server address=tape]
      [%request-upload ~]
      [%request-access fileid=tape]
  ==
+$  server-status
  $%  [%no-server ~]
      [%not-connected address=tape]
      [%connected address=tape]
  ==
::  +$  fileid  [=ship time=@da]
::  +$  uploaded  (map fileid content-status)
::  +$  content-status
::    $%  [%uploading ~]
::        [%sha256 @]
::    ==
--