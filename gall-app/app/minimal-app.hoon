/+  srv=server, default-agent, dbug
|%
+$  versioned-state
  $%  state-0
  ==
::
+$  state-0  [%0 val=@]
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this      .
    default   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  `this
++  on-save
  !>(state)
++  on-load
  |=  old-state=vase
  `this
++  on-poke
  |=  [=mark =vase]
  `this
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  `this
++  on-fail   on-fail:default
--