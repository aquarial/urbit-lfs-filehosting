/-  *lfs-client
/+  srv=server, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  request-src
  $%  [%local-poke ~]
  ::  [%http-request =connection] todo
  ==
+$  state-0  [%0 pending-requests=(list [id=@uv =request-src])]
--
%-  agent:dbug
=/  state=state-0  [%0 pending-requests=[~]]
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
  on-load:default
++  on-poke
  |=  [=mark =vase]
  :: ^-  (quip card _this)
  ?+  mark  (on-poke:default mark vase)
  %noun
     ?+  +.vase  `this
     :: add cases as needed
     %bowl
        ~&  "{<bowl>}"
       `this
     ==
  :: /mar/lfs-client/action.hoon
  %lfs-client-action
    ?>  (team:title [our src]:bowl)
    =/  action  !<(action vase)
    ~&  "lfs client does {<action>}"
    ?-  -.action
    %add-provider
      :_  this
      :~
      [%pass /lfs %agent [ship.action %lfs-provider] %watch /uploader/(scot %p our:bowl)]
      ==
    %remove-provider
      :_  this
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %leave ~]  ==
    %request-upload
      =/  id  (cut 6 [0 1] eny.bowl)
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  >  "client on-poke upload request {<`@uv`id>}"
        :_  this(state state(pending-requests (snoc pending-requests.state [id=id request-src=[%local-poke ~]])))
        :~  [%pass /lfs %agent [ship.action %lfs-provider] %poke %lfs-provider-action !>([%request-upload id=id])]  ==
      ::
      ~&  "not subscribed to {<ship.action>}!"
      `this
    ==
  ==
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ~&   "client on-agent got {<-.sign>} from {<dap.bowl>} on wire {<wire>}"
  ?+   wire  (on-agent:default wire sign)
  [%lfs ~]
    ?+  -.sign  (on-agent:default wire sign)
    :: %watch-ack
    :: %poke-ack
    %fact
      ?+  p.cage.sign  (on-agent:default wire sign)
      %got-url
         =/  info  !<([url=tape id=@uv] q.cage.sign)
         ~&  >  "upload url {<`@uv`id.info>} = {url.info}"
         `this
      ==
    ==
  ==
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