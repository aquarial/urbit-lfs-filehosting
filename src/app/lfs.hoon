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
=/  state  ^-  state-0  [%0 server-status=[%no-server ~] files=~ active-endpoints=~]
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
  %handle-http-request
    =+  !<([id=@ta =inbound-request:eyre] vase)
    ~&  >>  "handle http : {<url.request.inbound-request>}"
    :_  this
    %+  give-simple-payload:app:srv  id
    :: %+  require-authorization:app:srv  inbound-request
    handle-http-request
  %noun
     ~&  "poked with a {<vase>} of {<mark>}"
    `this
  %lfs-action
    ?+  -.q.vase  `this
    %connect-server
      ?>  (team:title [our src]:bowl)
      ~&  "connecting to localhost:{<+.q.vase>}"
      `this
    %request-access
      ~&  "{<src.bowl>" has requested access to {<+.q.vase>}"
      `this
    %request-upload
      :: filter by allowlist, groupstatus, btc payment, etc
      ~&   "checking permissions"
      ~&  "creating upload link for {<src.bowl>}"
      =/  pass  `@p`(cut 3 [0 10] eny.bowl) :: todo
      =/  endpoint  src.bowl
      ~&  "your endpoint is /~lfs/upload/{<endpoint>} with {<pass>}"
      `this
    ==
  ==
++  on-watch
  |=  =path
  ?:  ?=([%http-response *] path)
    ~&  >>>  "watch request on path: {<path>}"
    `this
  (on-watch:default path)
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  |^
  ?:  ?=(%eyre -.sign-arvo)
    ~&  >>  "Eyre returned: {<+.sign-arvo>}"
    `this
  ?:  ?=(%iris -.sign-arvo)
  ?>  ?=(%http-response +<.sign-arvo)
    =^  cards  state
      (handle-response -.wire client-response.sign-arvo)
    [cards this]
  (on-arvo:default wire sign-arvo)
  ::
  ++  handle-response
    |=  [url=@t resp=client-response:iris]
    ^-  (quip card _state)
    ?.  ?=(%finished -.resp)
      ~&  >>>  -.resp
      `state
    ~&  >>  "got data from {<url>}"
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