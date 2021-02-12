/-  *lfs
/+  srv=server, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
    $%  state-0
    ==
+$  state-0  [%0 =server-status files=(map fileid content-status) active-endpoints=(map ship [password=@p])]
   :: =pending-upload-requests
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this(state [%0 server-status=[%no-server ~] files=[~] active-endpoints=[~]])
  :~  [%pass /bind %arvo %e %connect [~ /'~upload'] %lfs]
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  ~&  'lfs loaded'
  on-load:default
++  on-poke
  |=  [=mark =vase]
  :: ^-  (quip card _this)
  ?+  mark  (on-poke:default mark vase)
  %noun
     ~&  "poked with a {<vase>} of {<mark>}"
    `this
  %lfs-action
    ?+  -.q.vase  `this
    %connect-server
      ?>  (team:title [our src]:bowl)
      ~&  "connecting to localhost:{<+.q.vase>}"
      `this
    %request-upload
      :: filter by allowlist, groupstatus, btc payment, etc
      ~&  "creating upload link for {<src.bowl>}"
      =/  pass  `@p`(cut 3 [0 10] eny.bowl) :: todo
      =/  endpoint  src.bowl
      ~&  "your endpoint is /~lfs/upload/{<endpoint>} with {<pass>}"
      `this
    ==
  ==
++  on-watch  on-watch:default 
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
::  helper core
|_  =bowl:gall
++  can-upload
  ~&  'assert {<src.bowl>} can upload'
  %.y
--