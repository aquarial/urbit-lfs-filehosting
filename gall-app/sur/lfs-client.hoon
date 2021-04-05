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
--