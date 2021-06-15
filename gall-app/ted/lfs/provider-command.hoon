/-  spider, lfs-provider, lfs-client
/+  strandio
=,  strand=strand:spider
|%
++  parse-justification
  |=  arg=*
  ?+  arg  ~
  [%a [%s %group] [%s @t] [%s @tas] %.0]
    =/  host  (slaw %p +:&3:arg)
    ?:  ?=(~ host)  ~
    =/  name  +:&4:arg
    (some [%group host name])
  ::
  [%a [%s %kids] %.0]
    (some [%kids ~])
  ::
  :: TODO parse array of ships
  :: [%a [%s %ship] [%s @t] %.0]
  ::   =/  host  (slaw %p +:&3:arg)
  ::   ?:  ?=(~ host)  ~
  ::   =/  name  +:&4:arg
  ::   (some [% host name])
  ==
++  parse-command
  |=  arg=*
  ?+  arg  ~
  [* ~ %a [%s %connect-server] [%s @t] [%s @t] [%s @t] %.0]
     =/  loopback  (trip +:&5:arg)
     =/  fileserver  (trip +:&5:arg)
     =/  token  (trip +:&5:arg)
     (some [%connect-server loopback fileserver token])
  ::
  [* ~ %a [%s %disconnect-server] %.0]
     (some [%disconnect-server ~])
  ::
  [* ~ %a [%s %list-rules] %.0]
     (some [%list-rules ~])
  ::
  [* ~ %a [%s %remove-rule] [%s @t] %.0]
     =/  index  (slaw %ud +:&5:arg)
     ?:  ?=(~ index)  ~
     (some [%remove-rule u.index])
  ::
  [* ~ %a [%s %add-rule] * [%s @t] %.0]
     =/  just  (parse-justification +:&5:arg)
     ?:  ?=(~ just)  ~
     =/  size  (slaw %ud +:&6:arg)
     ?:  ?=(~ size)  ~
     (some [%add-rule u.just u.size])
  ::
  ==
--
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  command  (parse-command arg)
?~  command  (pure:m !>([%o (my ~[['success' [%b %.n]] ['reason' [%s (crip "failed to parse input")]]])]))
::
(pure:m !>([%s (crip "finished with {<command>}")]))

::
::   ::  ;<  ~             bind:m  (poke:strandio [our.bowl %lfs-client] %lfs-client-action !>(u.action))
::   ::  ;<  ~             bind:m  (poke:strandio [our.bowl %lfs-client] %lfs-provider-command !>([threadid=(some tid.bowl) u.action]))
::   ::  ;<  vmsg=vase     bind:m  (take-poke:strandio %provider-command-response)
::   ::  =/  resp  !<(provider-command-response:lfs-provider vmsg)
::   ::  (pure:m !>("finished with {<resp>}"))
::
::   :: =/  msg
::   ::   ?-  -.resp
::   ::   %got-url
::   ::     (my ~[['success' [%b %.y]] ['key' [%s (crip "{key.resp}")]] ['url' [%s (crip url.resp)]]])
::   ::   %file-deleted
::   ::     (my ~[['success' [%b %.y]]])
::   ::   %updated-providers
::   ::     (my ~[['success' [%b %.y]]])
::   ::   %failure
::   ::     (my ~[['success' [%b %.n]] ['reason' [%s (crip reason.resp)]]])
::   ::   ==
::   :: (pure:m !>([%o msg]))
