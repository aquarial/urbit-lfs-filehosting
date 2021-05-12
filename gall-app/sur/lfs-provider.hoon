|%
+$  command
  $%  [%connect-server loopback=tape fileserver=tape token=tape]
      [%disconnect-server ~]
      [%list-rules ~]
      [%remove-rule index=@ud]
      [%add-rule =justification size=@ud]
  ==
+$  action
  $%  [%request-upload filename=(unit tape) id=@uv]
      [%request-delete fileid=tape id=@uv]
  ==
+$  fileserver-status
  $%  %online
      %offline
  ==
+$  server-update
  $%  [%heartbeat fileserver-status]
      [%file-uploaded fileid=tape filesize=@ud download-url=tape]
      [%request-response id=@uv response=request-response]
      [%storageinfo =storageinfo]
      [%storage-rules-changed newsize=@ud]
  ==
+$  upload-rules  (list [=justification size=@ud])
+$  justification
  $%  [%group host=ship name=@tas]
      [%ship ships=(list ship)]
      [%kids ~]
  ==
+$  storageinfo  [storage=@ud used=@ud files=(map tape fileinfo)]
+$  fileinfo  [download-url=tape size=@ud]

+$  request-response
  $%  [%got-url url=tape key=tape] :: url includes key, key tracks fileid
      [%file-deleted key=tape]
      [%failure reason=tape]
  ==
--