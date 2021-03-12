/-  *lfs-provider
/+  srv=server, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
    $%  state-0
    ==
+$  state-0
  $:  %0
      =fileserver-status
      store=(map ship storageinfo)
      loopback=tape
      fileserver=tape
      fileserverauth=tape
      debug=?
  ==
--
%-  agent:dbug
=/  state=state-0
  :*  %0
      fileserver-status=%offline
      store=[~]
      loopback=""
      fileserver=""
      fileserverauth=""
      debug=%.y
  ==
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
    ~?  debug.state  "provider handle http : {<url.request.inbound-request>}"
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
        ~?  debug.state  "provider will send subscribers hearbeat"
       `this
     ==
  :: /mar/lfs-provider/action.hoon
  %lfs-provider-action
    =/  action  !<(action vase)
    ~?  debug.state  "provider does {<action>}"
    ?-  -.action
    %connect-server
      ?>  (team:title [our src]:bowl)
      :: TODO set state to %connecting and test connection
      `this(state state(loopback loopback.action, fileserver fileserver.action, fileserverauth token.action))
    %request-upload
      ?<  authorized-upload:hc
      ?.  server-accepting-upload:hc
        :_  this
        :~  [%give %fact ~[/uploader/(scot %p src.bowl)] %lfs-provider-server-update !>([%request-response id=id.action response=[%failure reason="server offline"]])]  ==
      =/  pass  `@uv`(cut 8 [0 1] eny.bowl)
      =/  up-url  "http://{fileserver.state}/upload/file/{<pass>}"
      =/  new-url  "http://{fileserver.state}/upload/new/{<pass>}"
      ~&  >  "authorizing upload to {up-url}"
      ^-  (quip card _this)
      :_  this
      :~  [%pass /[(scot %uv pass)] %arvo %i %request [%'POST' (crip new-url) ~[['auth_token' (crip fileserverauth.state)]] ~] *outbound-config:iris]
          [%give %fact ~[/uploader/(scot %p src.bowl)] [%lfs-provider-server-update !>([%request-response id=id.action response=[%got-url url=up-url id=id.action]])]]
          :: confirm file server is up before giving fact?
      ==
      :: :~  [%pass /bind %arvo %e %connect [~ /'~upload'] %lfs-provider]
      :: ~[[%pass /poke-wire %agent [src.bowl %lfs-provider] %poke %noun !>([%receive-poke 2])]]
    ==
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)
    ~?  debug.state  "provider on-watch http-response on path: {<path>}"
    `this
  :: only ~ship can subscribe to /uploader/~ship path
  ?>  ?=([%uploader @ ~] path)
  ?>  =((slav %p i.t.path) src.bowl)
  ~?  debug.state  "provider on-watch subscription from {<src.bowl>} on path: {<path>}"
  `this
++  on-leave
  |=  path
  ~?  debug.state  "provider on-leave from {<src.bowl>} on {<path>}"
  `this
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ~?  debug.state  "provider on-agent got {<-.sign>} from {<dap.bowl>} on wire {<wire>}"
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
    ~?  debug.state  "provider on-arvo Eyre returned: {<+.sign-arvo>}"
    `this
  ?:  ?=(%iris -.sign-arvo)
  ?>  ?=(%http-response +<.sign-arvo)
    =^  cards  state
       ~?  debug.state  "provider on-arvo got on wire {<wire>} = {<client-response.sign-arvo>}"
      (handle-response -.wire client-response.sign-arvo)
    [cards this]
  (on-arvo:default wire sign-arvo)
  ::
  ++  handle-response
    |=  [url=@t resp=client-response:iris]
    ^-  (quip card _state)
    ?.  ?=(%finished -.resp)
      ~?  debug.state  "provider handle-response got {<-.resp>}"
      `state
    ::  =.  files.state  (~(put by files.state) url full-file.resp)
    `state
  --
::
++  on-fail   on-fail:default
--
::  helper core
|_  =bowl:gall
++  authorized-upload
  :: TODO filter by allowlist, groupstatus, btc payment, etc
  =/  subscribers  ~(val by sup.bowl)
  =/  src-subscriber  [p=src.bowl q=/uploader/(scot %p src.bowl)]
  =(~ (find ~[src-subscriber] subscribers))
++  server-accepting-upload
  ?&  =(fileserver-status.state %online)
      ?!  =(fileserver.state "")
      ?!  =(fileserverauth.state "")
      ?!  =(loopback.state "")
  ==
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