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
      =upload-rules
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
      upload-rules=[~]
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
  :~  [%pass /bind %arvo %e %connect [~ /'~lfs'] %lfs-provider]
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
    ::  [authenticated=%.n secure=%.n address=[%ipv4 .127.0.0.1]
    ::   request=[method=%'POST' url='/~lfs/completed/0v1a.42hat'
    ::       header-list=~[[key='host' value='localhost:8081'] [key='auth_token' value='hunter2']
    ::                 [key='accept' value='*/*']]
    ::       body=~ ]
    ::  ]
    =/  headers  header-list.request.inbound-request
    =/  auth  (skim headers |=([key=cord value=cord] =(key 'auth_token')))
    ?>  =(value.i.-.auth (crip fileserverauth.state))
    :_  this
    (snoc (give-simple-payload:app:srv id (handle-http-request:hc inbound-request)) [%give %fact ~[/uploader/(scot %p src.bowl)] %lfs-provider-server-update !>([%file-uploaded ~])])
  %noun
     ?+  +.vase  `this
     %bowl
        ~&  "{<bowl>}"
       `this
     %heartbeat
        :: TODO use behn
        ~?  debug.state  "provider will send subscribers hearbeat"
       `this
     [%add-rule *]
       =+  !<([%add-rule [=justification size=@ud]] vase)
       =/  new-rules  (snoc upload-rules.state [justification size])
       :: rut is fmap, update-store recompute storageinfo
       `this(state state(upload-rules new-rules, store (~(rut by store.state) (update-store:hc new-rules))))
     ==
  :: /mar/lfs-provider/action.hoon
  %lfs-provider-action
    =/  action  !<(action vase)
    ~?  debug.state  "provider does {<action>}"
    ?-  -.action
    %connect-server
      ?>  (team:title [our src]:bowl)
      :: TODO set state to %connecting and test connection
      ::      don't set status online until we confirm fileserver responds
      =/  setup-url  "http://{fileserver.action}/setup/{loopback.action}"
      :_  this(state state(fileserver-status %online, loopback loopback.action, fileserver fileserver.action, fileserverauth token.action))
      :~  [%pass /setup %arvo %i %request [%'POST' (crip setup-url) ~[['auth_token' (crip token.action)]] ~] *outbound-config:iris]  ==
    %request-upload
      ?<  authorized-upload:hc
      ?.  server-accepting-upload:hc
        :_  this
        :~  [%give %fact ~[/uploader/(scot %p src.bowl)] %lfs-provider-server-update !>([%request-response id=id.action response=[%failure reason="server offline"]])]  ==
      =/  pass  ?:  debug.state  0vbeef  (cut 8 [0 1] eny.bowl)
      =/  up-url  "http://{fileserver.state}/upload/file/{<pass>}"
      =/  new-url  "http://{fileserver.state}/upload/new/{<pass>}"
      ~&  >  "provider authorizing upload {up-url}"
      ^-  (quip card _this)
      :_  this
      :~  [%pass /upload/[(scot %uv pass)] %arvo %i %request [%'POST' (crip new-url) ~[['auth_token' (crip fileserverauth.state)]] ~] *outbound-config:iris]
          [%give %fact ~[/uploader/(scot %p src.bowl)] [%lfs-provider-server-update !>([%request-response id=id.action response=[%got-url url=up-url]])]]
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
  =/  updated  ((update-store upload-rules.state) [src.bowl [storage=0 used=0 upload-url=~ files=[~]]])
  :: TODO if storage is 0, then kick?
  `this(state state(store (~(gas by store.state) ~[[src.bowl updated]])))
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
  ?+  wire  (on-arvo:default wire sign-arvo)
    :: client-response = [%finished response-header=[status-code=200
    ::   headers=~[[key='content-type' value='text/plain; charset=utf-8'] [key='server' value='Rocket']
    ::   [key='content-length' value='19'] [key='date' value='Tue, 16 Mar 2021 01:23:34 GMT']]]
    ::   full-file=[~ [type='text/plain; charset=utf-8' data=[p=19 q=231.846.086.356.972.333.783.885.125.050.632.381.030.756.469]]]]
  [%setup ~]
     ?>  ?=(%finished -.client-response.sign-arvo)
     ~?  debug.state  "provider on-arvo setup response code {<status-code.response-header.client-response.sign-arvo>}"
    `this
  [%upload * ~]
    ?>  ?=(%finished -.client-response.sign-arvo)
    ~?  debug.state  "provider on-arvo upload response code {<status-code.response-header.client-response.sign-arvo>}"
    `this
  ==
  ::   =^  cards  state
  ::      ~?  debug.state  "provider on-arvo got on wire {<wire>} = {<client-response.sign-arvo>}"
  ::     (handle-response -.wire client-response.sign-arvo)
  ::   [cards this]
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
++  update-store
  |=  new-rules=(list [=justification size=@ud])
  |=  [=ship =storageinfo]
  storageinfo(storage 30) :: TODO compute
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