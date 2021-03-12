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
      [%request-response id=@uv response=request-response]
  ==
+$  storageinfo  [storage=@ud used=@ud upload-url=(unit tape) files=(map @uv fileinfo)]
+$  fileinfo  [size=@ud]

+$  request-response
  $%  [%got-url url=tape]
      [%failure reason=tape]
  ==
--