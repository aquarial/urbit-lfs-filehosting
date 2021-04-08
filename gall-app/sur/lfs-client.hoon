|%
+$  action
  [threadid=(unit @ta) payload]
+$  payload
  $%  [%add-provider =ship]
      [%remove-provider =ship]
      [%request-upload =ship]
      [%list-files ~] :: (unit ship)
      [%request-delete =ship fileid=@uv]
  ==
+$  client-action-response
  $%  [%got-url url=tape key=@uv]
      [%file-deleted key=@uv]
      [%failure reason=tape]
      ::
      [%updated-providers ~]
  ==
--