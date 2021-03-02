/-  *lfs-provider
/+  srv=server, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
    $%  state-0
    ==
+$  state-0  [%0 =server-status]
   :: files=(map fileid content-status)
   :: =pending-upload-requests
   :: active-endpoints=(map ship [password=@p])
--
%-  agent:dbug
=/  state=state-0  [%0 server-status=[%connected address="localhost:8000"]]
^-  agent:gall
=<
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  [%pass /bind %arvo %e %connect [~ /'~upload'] %lfs-provider]
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  on-load:default
++  on-poke
  |=  [=mark =vase]
  :: ^-  (quip card _this)
  ?+  mark  (on-poke:default mark vase)
  %handle-http-request
    =+  !<([id=@ta =inbound-request:eyre] vase)
    ~&   "provider handle http : {<url.request.inbound-request>}"
    :_  this
    %+  give-simple-payload:app:srv  id
    %+  require-authorization:app:srv  inbound-request
    handle-http-request:hc
  %noun
     ?+  +.vase  `this
     %bowl
        ~&  "{<bowl>}"
       `this
     %heartbeat
        :: TODO use behn
        ~&  "provider will send subscribers hearbeat"
       `this
     ==
  :: /mar/lfs-provider/action.hoon
  %lfs-provider-action
    =/  action  !<(action vase)
    ~&  "provider does {<action>}"
    ?-  -.action
    %connect-server
      ?>  (team:title [our src]:bowl)
      :: TODO set state to %connecting and test connection
      `this(state state(server-status [%connected address=+.action]))
    %request-access
      ~&  "{<src.bowl>} has requested access to {<+.action>}"
      :: TODO create personal access url based on groupstatus, btc pay, etc
      `this
    %request-upload
      :: TODO filter by allowlist, groupstatus, btc payment, etc
      =/  pass  `@uv`(cut 8 [0 1] eny.bowl)
      ?-  -.server-status.state
      %no-server  ~&  "can't upload, no server!"  `this
      %not-connected  ~&  "can't upload, server offline!"  `this
      %connected
        ~&  >  "provider poke, check {<src.bowl>} is in {<~(key by sup.bowl)>}"
        =/  up-url  "http://{address.server-status.state}/upload/file/{<pass>}"
        =/  new-url  "http://{address.server-status.state}/upload/new/{<pass>}"
        ~&  "can upload, your url is: {up-url}"
        ^-  (quip card _this)
        :_  this
        :~  [%pass /[(scot %uv pass)] %arvo %i %request [%'POST' (crip new-url) ~ ~] *outbound-config:iris]
            [%give %fact ~[/uploader/(scot %p src.bowl)] [%got-url !>(up-url)]]
            :: what wire to respond to poke?
        ==
      ==
      :: :~  [%pass /bind %arvo %e %connect [~ /'~upload'] %lfs-provider]
      :: ~[[%pass /poke-wire %agent [src.bowl %lfs-provider] %poke %noun !>([%receive-poke 2])]]
    ==
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)
    ~&  "provider on-watch http-response on path: {<path>}"
    `this
  :: only ~ship can subscribe to /uploader/~ship path
  ?>  ?=([%uploader @ ~] path)
  ?>  =((slav %p i.t.path) src.bowl)
  ~&  "provider on-watch subscription from {<src.bowl>} on path: {<path>}"
  `this
++  on-leave
  |=  path
  ~&  "provider on-leave from {<src.bowl>} on {<path>}"
  `this
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ~&  "provider on-agent got {<-.sign>} from {<dap.bowl>} on wire {<wire>}"
  `this
  :: ^-  (quip card:agent:gall _agent)
  :: ?-    -.sign
  ::     %poke-ack
  ::   ?~  p.sign
  ::     `agent
  ::   %-  (slog leaf+"poke failed from {<dap.bowl>} on wire {<wire>}" u.p.sign)
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  |^
  ?:  ?=(%eyre -.sign-arvo)
    ~&  "provider on-arvo Eyre returned: {<+.sign-arvo>}"
    `this
  ?:  ?=(%iris -.sign-arvo)
  ?>  ?=(%http-response +<.sign-arvo)
    =^  cards  state
       ~&  "provider on-arvo got on wire {<wire>} = {<client-response.sign-arvo>}"
      (handle-response -.wire client-response.sign-arvo)
    [cards this]
  (on-arvo:default wire sign-arvo)
  ::
  ++  handle-response
    |=  [url=@t resp=client-response:iris]
    ^-  (quip card _state)
    ?.  ?=(%finished -.resp)
      ~&  "provider handle-response got {<-.resp>}"
      `state
    ::  =.  files.state  (~(put by files.state) url full-file.resp)
    `state
  --
::
++  on-fail   on-fail:default
--
::  helper core
|_  =bowl:gall
++  can-upload
  ~&  'assert {<src.bowl>} can upload'
  %.y
++  handle-http-request
  |=  req=inbound-request:eyre
  ^-  simple-payload:http
  =,  enjs:format
  %-  json-response:gen:srv
  %-  pairs
  :~
    [%msg [%s 'hello my friends']]
    [%intent [%s 'peaceful']]
    [%ship [%s (scot %p our.bowl)]]
  ==
--