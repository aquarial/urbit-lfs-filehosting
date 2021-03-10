|%
+$  action
  $%  [%connect-server address=tape loopback=tape token=tape]
      [%client-request id=@uv client-request]
  ==
+$  client-request
  $%  [%upload]
  ==
+$  server
+$  fileserver-status
  $%  %online
      %offline
  ==
+$  server-update
  $%  [%heartbeat fileserver-status]
      [%request-response id=@uv request-response]
  ==
+$  storageinfo  [storage=@ud used=@ud upload-url=(unit tape) files=(map @uv fileinfo)]
+$  fileinfo  [size=@ud]

+$  request-response
  $%  [%got-url url=tape]
      [%failure reason=tape]
  ==
--