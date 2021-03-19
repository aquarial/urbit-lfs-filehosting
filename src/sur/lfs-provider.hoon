|%
+$  action
  $%  [%connect-server loopback=tape fileserver=tape token=tape]
      [%request-upload id=@uv]
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
      [%file-uploaded ~] :: storage-update
      [%request-response id=@uv response=request-response]
  ==
+$  upload-rules  (list [=justification size=@ud])
+$  justification
  $%  [%group group=@tas]
      [%ship ships=(list ship)]
      [%kids ~]
  ==
+$  storageinfo  [storage=@ud used=@ud upload-url=(unit tape) files=(map @uv fileinfo)]
+$  fileinfo  [size=@ud]

+$  request-response
  $%  [%got-url url=tape]
      [%failure reason=tape]
  ==
--