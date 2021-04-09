|%
+$  action
  $%  [%connect-server loopback=tape fileserver=tape token=tape]
      [%request-upload id=@uv]
      [%request-delete fileid=@uv id=@uv]
   :: [%test-loopback loopback=tape]
  ==
+$  client-request
  $%  [%upload]
  ==
+$  fileserver-status
  $%  %online
      %offline
  ==
+$  server-update
  $%  [%heartbeat fileserver-status]
      [%file-uploaded fileid=@uv filesize=@ud download-url=tape]
      [%request-response id=@uv response=request-response]
      [%storageinfo =storageinfo]
  ==
+$  upload-rules  (list [=justification size=@ud])
+$  justification
  $%  [%group group=@tas]
      [%ship ships=(list ship)]
      [%kids ~]
  ==
+$  storageinfo  [storage=@ud used=@ud upload-key=(unit @uv) files=(map @uv fileinfo)]
+$  fileinfo  [download-url=tape size=@ud]

+$  request-response
  $%  [%got-url url=tape key=@uv] :: url includes key, key tracks fileid
      [%file-deleted key=@uv]
      [%failure reason=tape]
  ==
--