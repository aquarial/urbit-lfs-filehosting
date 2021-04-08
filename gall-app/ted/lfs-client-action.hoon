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
:: ?+  arg  (pure:m !>([%s "unexpected input"]))
:: %test  (pure:m !>([3 4]))
:: ==

::  (pure:m !>([arg ?=([* [~ %test]] arg)]))

?+  arg  (pure:m !>([%s (crip "unexpected input {<arg>}")]))
[* [~ [%a [%s %request-upload] [%s @ud] %.0]]]
   =/  target  `@p`(slav %p `@t`+>+>->:arg)
   (pure:m !>([%s (crip "requesting upload to {<target>}")]))
::
[* [~ [%a [%s %add-provider] [%s @ud] %.0]]]
   =/  target  `@p`(slav %p `@t`+>+>->:arg)
   (pure:m !>([%s (crip "adding provider {<target>}")]))
::
[* [~ [%a [%s %remove-provider] [%s @ud] %.0]]]
   =/  target  `@p`(slav %p `@t`+>+>->:arg)
   (pure:m !>([%s (crip "removing provider {<target>}")]))
::
[* [~ [%a [%s %request-delete] [%s @ud] [%s @ud] %.0]]]
    =/  target  `@p`(slav %p `@t`+>+>->:arg)
    =/  fileid  `@uv`(slav %uv `@t`+>+>+<+:arg)
    (pure:m !>([%s (crip "uploading to {<target>} and fileid is {<fileid>}")]))
==

::
:: ;<  ~             bind:m  (poke:strandio [our.bowl %lfs-client] %lfs-client-action !>([threadid=(some tid.bowl) [%request-upload ~zod]]))
:: ;<  vmsg=vase     bind:m  (take-poke:strandio %request-response)
:: =/  resp  !<(request-response:lfs-provider vmsg)
:: =/  msg
::   ?-  -.resp
::   %got-url
::     (my ~[['success' [%b %.y]] ['url' [%s (crip url.resp)]]])
::   %failure
::     (my ~[['success' [%b %.n]] ['reason' [%s (crip reason.resp)]]])
::   ==
:: (pure:m !>([%o msg]))
