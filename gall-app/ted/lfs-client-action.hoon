/-  spider, lfs-provider, lfs-client
/+  strandio
=,  strand=strand:spider
|%
++  parse-action
  |=  [arg=* tid=(unit @ta)]
  ?+  arg  ~
  [* [~ [%a [%s %add-provider] [%s @ud] %.0]]]
     =/  target  `@p`(slav %p `@t`+>+>->:arg)
     (some [threadid=tid %add-provider target])
  ::
  [* [~ [%a [%s %remove-provider] [%s @ud] %.0]]]
     =/  target  `@p`(slav %p `@t`+>+>->:arg)
     (some [threadid=tid %remove-provider target])
  ::
  [* [~ [%a [%s %request-upload] [%s @ud] %.0]]]
     =/  target  `@p`(slav %p `@t`+>+>->:arg)
     (some [threadid=tid %request-upload target])
  ::
  [* [~ [%a [%s %request-delete] [%s @ud] [%s @ud] %.0]]]
      =/  target  `@p`(slav %p `@t`+>+>->:arg)
      =/  fileid  `@uv`(slav %uv `@t`+>+>+<+:arg)
     (some [threadid=tid %request-delete target fileid])
  ==
--
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  action  (parse-action arg (some tid.bowl))
?~  action  (pure:m !>([%o (my ~[['failure' [%b %.n]] ['reason' [%s (crip "unexpected input: {<arg>}")]]])]))
::
;<  ~             bind:m  (poke:strandio [our.bowl %lfs-client] %lfs-client-action !>(u.action))
;<  vmsg=vase     bind:m  (take-poke:strandio %client-action-response)
=/  resp  !<(client-action-response:lfs-client vmsg)
=/  msg
  ?-  -.resp
  %got-url
    (my ~[['success' [%b %.y]] ['url' [%s (crip url.resp)]]])
  %file-deleted
    (my ~[['success' [%b %.y]]])
  %updated-providers
    (my ~[['success' [%b %.y]]])
  %failure
    (my ~[['success' [%b %.n]] ['reason' [%s (crip reason.resp)]]])
  ==
(pure:m !>([%o msg]))
