|%
+$  server-status
  $%  [%no-server ~]
      [%not-connected port=@ud]
      [%connected port=@ud]
  ==
+$  fileid  [=ship time=@da]
+$  uploaded  (map fileid content-status)
+$  content-status
  $%  [%uploading ~]
      [%sha256 @]
  ==
--