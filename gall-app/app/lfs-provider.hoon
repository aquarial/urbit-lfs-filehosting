/-  *lfs-provider
/+  srv=server, default-agent, dbug, group-store, group
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
  ==
--
%-  agent:dbug
=/  unsafe-reuse-upload-urls  %.n
=/  unsafe-http  %.y
=/  state=state-0
  :*  %0
      fileserver-status=%offline
      store=[~]
      upload-rules=[~]
      loopback=""
      fileserver=""
      fileserverauth=""
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
      [%pass /groups %agent [our.bowl %group-store] %watch /groups]
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
  %0  `this(state prev)
  ==
++  on-poke
  |=  [=mark =vase]
  :: ^-  (quip card _this)
  ?+  mark  (on-poke:default mark vase)
  %handle-http-request
    =+  !<([id=@ta =inbound-request:eyre] vase)
    ::  [authenticated=%.n secure=%.n address=[%ipv4 .127.0.0.1]
    ::   request=[method=%'POST' url='/~lfs/completed/0v1a.42hat'
    ::       header-list=~[[key='host' value='localhost:8081'] [key='authtoken' value='hunter2']
    ::                 [key='accept' value='*/*']]
    ::       body=~ ]
    ::  ]
    =/  headers  header-list.request.inbound-request
    =/  auth  (skim headers |=([key=cord value=cord] =(key 'authtoken')))
    ?>  =(value.i.-.auth (crip fileserverauth.state))
    =/  url  (parse-request-line:srv url.request.inbound-request)
    ?+  site.url  `this
    [%'~lfs' %completed @t @t * ~]
      :: extra param * needed because parse-request-line remoes trailing ".stuff"
      =/  fileid=tape  (trip &3:site.url)
      =/  filesize=@ud  (slav %ud &4:site.url)
      ~&  >  "provider knows someone uploaded {<filesize>} bytes of {fileid}, notifying them"
      =/  storelist  ~(tap by store.state)
      =/  match  (skim storelist |=([=ship =storageinfo] =(upload-key.storageinfo (some fileid))))
      ?~  match
        ~&  >>  "provider could not identify who uploaded fileid {fileid}"
        :_  this
        (give-simple-payload:app:srv id (handle-http-request:hc inbound-request 'failure'))
      =/  down-url  "{protocol:hc}://{fileserver.state}/download/file/{fileid}"
      =/  ship=ship  p.i.match
      =/  old=storageinfo  q.i.match
      =/  new=storageinfo  old(used (add used.old filesize), upload-key ~, files (~(put by files.old) fileid [down-url filesize]))
      :_  this(state state(store (~(put by store.state) ship new)))
      (snoc (give-simple-payload:app:srv id (handle-http-request:hc inbound-request %success)) [%give %fact ~[/uploader/(scot %p ship)] %lfs-provider-server-update !>([%file-uploaded fileid=fileid filesize=filesize download-url=down-url])])
    ==
  %noun
     ?+  +.vase  `this
     %bowl
        ~&  "{<bowl>}"
       `this
     %heartbeat
        :: TODO use behn
        ~&  "provider will send subscribers hearbeat"
       `this
     %list-rules
       ~&  "rules are: {<upload-rules.state>}"
       `this
     [%remove-rule *]
       =+  !<([%remove-rule index=@ud] vase)
       =/  new-rules  (oust [index 1] upload-rules.state)
       =/  new-store  (~(gas by store.state) (turn ~(tap by store.state) (compute-ship-storage:hc new-rules)))
       `this(state state(upload-rules new-rules, store new-store))
     [%add-rule *]
       =+  !<([%add-rule [=justification size=@ud]] vase)
       =/  new-rules  (snoc upload-rules.state [justification size])
       =/  new-store  (~(gas by store.state) (turn ~(tap by store.state) (compute-ship-storage:hc new-rules)))
       :: TODO give out new upload rules (changed storage)
       `this(state state(upload-rules new-rules, store new-store))
     ==
  :: /mar/lfs-provider/action.hoon
  %lfs-provider-action
    =/  action  !<(action vase)
    ?-  -.action
    %connect-server
      ?>  (team:title [our src]:bowl)
      :: TODO set state to %connecting and test connection
      ::      don't set status online until we confirm fileserver responds
      :: TODO invalidate all the urls, send updates to all clients
      =/  setup-url  "{protocol:hc}://{fileserver.action}/setup"
      =/  body  (some (as-octt:mimes:html "{protocol:hc}://{loopback.action}"))
      :_  this(state state(fileserver-status %online, loopback loopback.action, fileserver fileserver.action, fileserverauth token.action))
      :~  [%pass /setup %arvo %i %request [%'POST' (crip setup-url) ~[['authtoken' (crip token.action)]] body] *outbound-config:iris]  ==
    %request-delete
      ?>  src-is-subscriber:hc
      =/  storageinfo  (need (~(get by store.state) src.bowl))
      =/  ufile  (~(get by files.storageinfo) fileid.action)
      ?~  ufile
        :_  this
        :~  [%give %fact ~[/uploader/(scot %p src.bowl)] %lfs-provider-server-update !>([%request-response id=id.action response=[%failure reason="no such fileid"]])]  ==
      =/  del-url  "{protocol:hc}://{fileserver.state}/upload/remove/{<fileid.action>}"
      =/  newstorage  storageinfo(used (sub used.storageinfo size.u.ufile), files (~(del by files.storageinfo) fileid.action))
      :_  this(state state(store (~(put by store.state) src.bowl newstorage)))
      :~  [%pass /upload/remove/[(crip fileid.action)] %arvo %i %request [%'DELETE' (crip del-url) ~[['authtoken' (crip fileserverauth.state)]] ~] *outbound-config:iris]
          [%give %fact ~[/uploader/(scot %p src.bowl)] [%lfs-provider-server-update !>([%request-response id=id.action response=[%file-deleted key=fileid.action]])]]
      ==
    %request-upload
      ?>  src-is-subscriber:hc
      ?.  server-accepting-upload:hc
        :_  this
        :~  [%give %fact ~[/uploader/(scot %p src.bowl)] %lfs-provider-server-update !>([%request-response id=id.action response=[%failure reason="server offline"]])]  ==
      ::
      =/  space  upload-space:hc
      ?:  =(space 0)
        :_  this
        :~  [%give %fact ~[/uploader/(scot %p src.bowl)] %lfs-provider-server-update !>([%request-response id=id.action response=[%failure reason="no space left"]])]  ==
      =/  storageinfo=storageinfo  (need (~(get by store.state) src.bowl))
      =/  code  (fall upload-key.storageinfo ?:(unsafe-reuse-upload-urls "0vbeef" "{<`@uv`(cut 8 [0 1] eny.bowl)>}"))
      =/  name  (sanitize-filename:hc (fall filename.action "file"))
      =/  pass  "{code}-{name}"
      =/  up-url  "{protocol:hc}://{fileserver.state}/upload/file/{pass}"
      =/  new-url  "{protocol:hc}://{fileserver.state}/upload/new/{pass}/{(format-number space)}"
      ~&  >  "provider sends authorizing url to {new-url}"
      ^-  (quip card _this)
      :_  this(state state(store (~(put by store.state) src.bowl storageinfo(upload-key (some pass)))))
      :~  [%pass /upload/[(crip pass)] %arvo %i %request [%'POST' (crip new-url) ~[['authtoken' (crip fileserverauth.state)]] ~] *outbound-config:iris]
          [%give %fact ~[/uploader/(scot %p src.bowl)] [%lfs-provider-server-update !>([%request-response id=id.action response=[%got-url url=up-url key=pass]])]]
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
    ~&  "provider on-watch http-response on path: {<path>}"
    `this
  :: only ~ship can subscribe to /uploader/~ship path
  ?>  ?=([%uploader @ ~] path)
  ?>  =((slav %p i.t.path) src.bowl)
  ~&  "provider on-watch subscription from {<src.bowl>} on path: {<path>}"
  =/  updated  ((compute-ship-storage:hc upload-rules.state) [src.bowl (~(gut by store.state) src.bowl [storage=0 used=0 upload-url=~ files=[~]])])
  ?>  (gth storage.storageinfo.updated 0)
  :_  this(state state(store (~(gas by store.state) ~[updated])))
  :~  [%give %fact ~[/uploader/(scot %p src.bowl)] [%lfs-provider-server-update !>([%storageinfo storageinfo=storageinfo.updated])]]  ==
++  on-leave
  |=  =path
  `this
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ~&  "provider on-agent got {<-.sign>} from {<dap.bowl>} on wire {<wire>}"
  ?+   wire  (on-agent:default wire sign)
  [%groups ~]
    ?+  -.sign  (on-agent:default wire sign)
    :: %watch-ack
    :: %poke-ack
    %fact
      ?+  p.cage.sign  (on-agent:default wire sign)
      %group-update-0
        =/  resp  !<(update:group-store q.cage.sign)
        ~&  "provider received group-update {<resp>}"
        ?+  -.resp  `this
        %initial
          :: TODO filter to only look at groups referenced in upload rules
          :: TODO give out new upload rules (changed storage)
          =/  groups  ~(val by groups.resp)
          =/  ship-sets  (turn groups |=(g=group:group members.g))
          =/  ships  (roll ship-sets |=([s1=(set ship) s2=(set ship)] (~(uni in s1) s2)))
          `this(state state(store (compute-ships-to-store:hc ships)))
        %add-members
          `this(state state(store (compute-ships-to-store:hc ships.resp)))
        %remove-members
          `this(state state(store (compute-ships-to-store:hc ships.resp)))
        ==
      ==
    ==
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  |^
  ?:  ?=(%eyre -.sign-arvo)
    ~&  "provider on-arvo Eyre returned: {<+.sign-arvo>}"
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
     ~&  "provider on-arvo setup response code {<status-code.response-header.client-response.sign-arvo>}"
    `this
  [%upload * ~]
    ?>  ?=(%finished -.client-response.sign-arvo)
    ~&  "provider on-arvo upload response code {<status-code.response-header.client-response.sign-arvo>}"
    `this
  [%upload %remove * ~]
    ?>  ?=(%finished -.client-response.sign-arvo)
    ~&  "provider on-arvo file deleted code {<status-code.response-header.client-response.sign-arvo>}"
    `this
  ==
  ::   =^  cards  state
  ::      ~&  "provider on-arvo got on wire {<wire>} = {<client-response.sign-arvo>}"
  ::     (handle-response -.wire client-response.sign-arvo)
  ::   [cards this]
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
++  src-is-subscriber
  =/  subscribers  ~(val by sup.bowl)
  =/  src-subscriber  [p=src.bowl q=/uploader/(scot %p src.bowl)]
  ?!  =(~ (find ~[src-subscriber] subscribers))
++  upload-space
  =/  m  (~(get by store.state) src.bowl)
  ?:  =(m ~)  0
  ?:  (lte storage:(need m) used:(need m))  0
  (sub storage:(need m) used:(need m))
++  server-accepting-upload
  ?&  =(fileserver-status.state %online)
      ?!  =(fileserver.state "")
      ?!  =(fileserverauth.state "")
      ?!  =(loopback.state "")
  ==
++  protocol
  ?:  unsafe-http  "http"  "https"
++  handle-http-request
  |=  [req=inbound-request:eyre status=@t]
  ^-  simple-payload:http
  =,  enjs:format
  %-  json-response:gen:srv
  %-  pairs
  :~  [%status [%s status]]  ==
++  format-number
  |=  n=@ud
  :: 1.234 -> "1234"
  (tape (skim ((list @tD) "{<n>}") |=(c=@tD ?!(=(c '.')))))
++  sanitize-char
  |=  c=@t
  ?:  ?|  =(c '_')  =(c '-')  =(c '.')
          &((gte c 'a') (lte c 'z'))
          &((gte c 'A') (lte c 'Z'))
          &((gte c '0') (lte c '9'))
      ==
    c
  '-'
:: TODO allow any filename by url-encoding it? allow more than 40 chars?
++  sanitize-filename
  |=  in=tape
  ^-  tape
  (swag [0 40] (turn in sanitize-char))
++  compute-ships-to-store
  |=  ships=(set ship)
  :: called when groups update, ships might not be subscribers
  =/  pair-with-storageinfo
      |=  =ship
      ((lift |=(=storageinfo [ship storageinfo])) (~(get by store.state) ship))
  =/  updated  (turn (murn ~(tap in ships) pair-with-storageinfo) (compute-ship-storage upload-rules.state))
  =/  store  (~(gas by store.state) updated)
  store.state
++  compute-ship-storage
  |=  rules=(list [=justification size=@ud])
  |=  [=ship =storageinfo]
  :: TODO fix inefficiency. re-asks for group object for each ship
  ::      add custom methods for adding ships vs changing rules
  =/  izes  (turn (skim rules (match-rule ship)) |=([=justification size=@ud] size))
  =/  space  (roll (snoc izes 0) max)
  ~&  "  compute-ship-storage gave {<ship>} {<space>} bytes"
  [ship=ship storageinfo=storageinfo(storage space)]
++  match-rule
  |=  =ship
  |=  [=justification size=@ud]
  ?-  -.justification
  %group
    =/  x  group:justification
    =/  ginfo  .^((unit group:group) %gx /(scot %p our.bowl)/group-store/(scot %da now.bowl)/groups/ship/(scot %p our.bowl)/[x]/noun)
    =/  ppp  ?~  ginfo  "~"  "{<members:+<:ginfo>}"
    ?&  ?!  =(ginfo ~)
        (~(has in members:+<:ginfo) ship)
    ==
  %ship
    ?!  =(~ (find ~[ship] ships.justification))
  %kids
    =(our.bowl (sein:title our.bowl now.bowl ship))
  ==
--
