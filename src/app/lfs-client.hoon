/-  *lfs-client
/+  srv=server, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
    $%  state-0
    ==
+$  state-0  [%0]
--
%-  agent:dbug
=/  state=state-0  [%0]
^-  agent:gall
=<
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  ~&  'lfs-client loaded'
  on-load:default
++  on-poke
  |=  [=mark =vase]
  :: ^-  (quip card _this)
  ?+  mark  (on-poke:default mark vase)
  %noun
     ?+  +.vase  `this
     :: add cases as needed
     ==
  :: /mar/lfs-client/action.hoon
  %lfs-client-action
    ?>  (team:title [our src]:bowl)
    =/  action  !<(action vase)
    ~&  "received {<action>}"
    ?-  -.action
    %add-provider
      `this
    %remove-provider
      `this
    %request-upload
      `this
  ==
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card:agent:gall _agent)
  ~&  "on-agent got {<dap.bowl>} on wire {<wire>} with {<sign>}"
  `this
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  (on-arvo:default wire sign-arvo)
++  on-fail   on-fail:default
--
::
::  helper core
|_  =bowl:gall
--