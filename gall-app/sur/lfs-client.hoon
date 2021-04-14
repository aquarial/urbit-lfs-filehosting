|%
+$  action
  [threadid=(unit @ta) payload]
+$  payload
  $%  [%add-provider =ship]
      [%remove-provider =ship]
      [%request-upload =ship filename=(unit tape)]
      [%list-files ~] :: (unit ship)
      [%request-delete =ship fileid=tape]
  ==
+$  client-action-response
  $%  [%got-url url=tape key=tape]
      [%file-deleted key=tape]
      [%failure reason=tape]
      ::
      [%updated-providers ~]
  ==
--