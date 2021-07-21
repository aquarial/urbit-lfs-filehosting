|%
+$  command
  [threadid=(unit @ta) command-payload]
+$  command-payload
  $%  [%connect-server loopback=tape fileserver=tape token=tape]
      [%disconnect-server ~]
      [%list-rules ~]
      [%remove-rule index=@ud]
      [%add-rule =justification size=@ud]
      [%overwrite-store newstore=(map ship storageinfo)]
  ==
+$  provider-command-response
  $%  [%success ~]
      [%failure reason=tape]
      [%rules =upload-rules]
  ==
+$  action
  $%  [%request-upload filename=(unit tape) id=@uv]
      [%request-delete fileid=tape id=@uv]
      [%request-cache-update ~]
  ==
+$  fileserver-status
  $%  %online
      %offline
  ==
+$  server-update
  $%  [%heartbeat current-state=@ud fileserver-status]
      [%file-uploaded fileid=tape filesize=@ud download-url=tape upload-time=@da]
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
+$  storageinfo  [current-state=@ud storage=@ud used=@ud files=(map tape fileinfo)]
+$  fileinfo  [download-url=tape size=@ud upload-time=@da]

+$  request-response
  $%  [%got-url url=tape key=tape] :: url includes key, key tracks fileid
      [%file-deleted key=tape]
      [%failure reason=tape]
  ==
--