/-  spider, lfs-provider, lfs-client
/+  strandio, lfs-utils
=,  strand=strand:spider
|%
++  parse-str-ship
  |=  arg=*
  ^-  (unit ship)
  ?+  arg  ~
  [%s @ta]
    (slaw %p +:arg)
  ==
++  parse-justification
  |=  arg=*
  ^-  (unit justification:lfs-provider)
  ?+  arg  ~
  [%a [%s %group] [%s @t] [%s @tas] %.0]
    =/  host  (slaw %p +:&3:arg)
    ?:  ?=(~ host)  ~
    =/  name  +:&4:arg
    (some [%group u.host name])
  ::
  [%a [%s %kids] %.0]
    (some [%kids ~])
  ::
  [%a [%s %ship] [%a *] %.0]
    =/  shps  ((list *) +:&3:arg)
    =/  shiplst  (murn shps parse-str-ship)
    (some [%ship ships=(murn shps parse-str-ship)])
  ==
++  parse-command
  |=  arg=*
  ^-  (unit command-payload:lfs-provider)
  ?+  arg  ~
  [%a [%s %connect-server] [%s @t] [%s @t] [%s @t] %.0]
     =/  loopback  (trip +:&3:arg)
     =/  fileserver  (trip +:&4:arg)
     =/  token  (trip +:&5:arg)
     (some [%connect-server loopback fileserver token])
  ::
  [%a [%s %disconnect-server] %.0]
     (some [%disconnect-server ~])
  ::
  [%a [%s %list-rules] %.0]
     (some [%list-rules ~])
  ::
  [%a [%s %remove-rule] [%s @t] %.0]
     =/  index  (slaw %ud +:&3:arg)
     ?:  ?=(~ index)  ~
     (some [%remove-rule u.index])
  ::
  [%a [%s %add-rule] * [%n @t] %.0]
     =/  just  (parse-justification &3:arg)
     ?:  ?=(~ just)  ~
     =/  size  (slaw %ud +:&4:arg)
     ?:  ?=(~ size)  ~
     (some [%add-rule u.just u.size])
  ::
  [%a [%s %overwrite-store] * %.0]
     =/  store  (json &3:arg)
     =/  newstore  (to-store:from-json:lfs-utils (ship-metas:dejs:from-json:lfs-utils store))
     (some [%overwrite-store newstore])
  ::
  ==
--
::
^-  thread:spider
|=  arg=vase
=/  argjson  !<([~ json] arg)
=/  m  (strand ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  argjson  !<([~ json] arg)
=/  command  (parse-command (need argjson))
?~  command  (pure:m !>([%o (my ~[['success' [%b %.n]] ['reason' [%s (crip "failed to parse input")]]])]))
;<  ~          bind:m  (poke:strandio [our.bowl %lfs-provider] %lfs-provider-command !>([threadid=(some tid.bowl) u.command]))
;<  vmsg=vase  bind:m  (take-poke:strandio %provider-command-response)
=/  resp  !<(provider-command-response:lfs-provider vmsg)
=/  msg
  ?-  -.resp
  %success
    (my ~[['success' [%b %.y]]])
  %failure
    (my ~[['success' [%b %.n]] ['reason' [%s (crip reason.resp)]]])
  %rules
    =/  rules  (turn upload-rules.resp json-rule:lfs-utils)
    (my ~[['success' [%b %.y]] ['rules' [%a rules]]])
  ==
(pure:m !>([%o msg]))
