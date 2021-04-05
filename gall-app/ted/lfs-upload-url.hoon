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
    (crip "yes: {url.resp}")
  %failure
    (crip "no:  {reason.resp}")
  ==
  (pure:m !>([%s msg]))
