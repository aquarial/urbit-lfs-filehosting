/-  spider, lfs-provider
/+  strandio
=,  strand=strand:spider
|%
++  arm  0
--
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
;<  ~             bind:m  (poke:strandio [our.bowl %lfs-client] %lfs-client-action !>([threadid=(some tid.bowl) [%request-upload ~zod]]))
;<  vmsg=vase     bind:m  (take-poke:strandio %request-response)
=/  resp  !<(request-response:lfs-provider vmsg)
=/  msg
  ?-  -.resp
  %got-url
    (my ~[['success' [%b %.y]] ['url' [%s (crip url.resp)]]])
  %failure
    (my ~[['success' [%b %.n]] ['reason' [%s (crip reason.resp)]]])
  ==
(pure:m !>([%o msg]))
