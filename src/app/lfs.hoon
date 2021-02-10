::  lfs.hoon
::  poke endpoints to request upload files 
::  http endpoints to upload, download data
::
/-  lfs
/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0
  $:  srv=local-server  :: valid syntax?
      
  ==
--
%-  agent:dbug
=|  state-0
=*  state  [%no-server ~]
^-  agent:gall
|_  =bowl:gall
+*  this     .
    default   ~(. (default-agent this %|) bowl)
::
++  on-init
~&  >  'on-init'
  `this(state [%running port=10])
++  on-save
  ^-  vase
  !>(state)
++  on-load
  ~&  >  'on-load'
  on-load:default
++  on-poke  on-poke:default
::
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
