/-  spider, lfs-provider, lfs-client
/+  strandio
=,  strand=strand:spider
|%
++  parse-action
  |=  arg=*
  ?+  arg  ~
  [* [~ [%a [%s %add-provider] [%s @ud] %.0]]]
     =/  target  (slaw %p `@t`+>+>->:arg)
     ?:  ?=(~ target)  ~
     (some [%add-provider u.target])
  ::
  [* [~ [%a [%s %remove-provider] [%s @ud] %.0]]]
     =/  target  (slaw %p `@t`+>+>->:arg)
     ?:  ?=(~ target)  ~
     (some [%remove-provider u.target])
  ::
  [* [~ [%a [%s %request-upload] [%s @ud] [%s @ud] %.0]]]
     =/  target  (slaw %p `@t`+>+>->:arg)
     ?:  ?=(~ target)  ~
     =/  filename  (trip `@t`+>+>+<+:arg)
     (some [%request-upload u.target (some filename)])
  ::
  [* [~ [%a [%s %request-delete] [%s @ud] [%s @ud] %.0]]]
      =/  target  (slaw %p `@t`+>+>->:arg)
     ?:  ?=(~ target)  ~
      =/  fileid  (trip `@t`+>+>+<+:arg)
     (some [%request-delete ship=u.target fileid=fileid])
  ==
--
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  action  (parse-action arg)
?~  action  (pure:m !>([%o (my ~[['success' [%b %.n]] ['reason' [%s (crip "failed to parse input")]]])]))
::
;<  ~             bind:m  (poke:strandio [our.bowl %lfs-client] %lfs-client-action !>([threadid=(some tid.bowl) u.action]))
;<  vmsg=vase     bind:m  (take-poke:strandio %client-action-response)
=/  resp  !<(client-action-response:lfs-client vmsg)
=/  msg
  ?-  -.resp
  %got-url
    (my ~[['success' [%b %.y]] ['key' [%s (crip "{key.resp}")]] ['url' [%s (crip url.resp)]]])
  %file-deleted
    (my ~[['success' [%b %.y]]])
  %updated-providers
    (my ~[['success' [%b %.y]]])
  %failure
    (my ~[['success' [%b %.n]] ['reason' [%s (crip reason.resp)]]])
  ==
(pure:m !>([%o msg]))
