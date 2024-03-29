/-  *lfs-client, lfs-provider
/+  *lfs-utils, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  request-src
  $%  [%local-poke ~]
      [%thread id=@ta]
  ==
:: TODO only allow one reqeust, don't send id
+$  state-0  [%0 pending-requests=(list [id=@uv =request-src]) store=(map ship storageinfo:lfs-provider)]
--
%-  agent:dbug
=/  state=state-0  [%0 pending-requests=[~] store=[~]]
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
  |=  old-state=vase
  ^-  (quip card _this)
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
      :: remove pending-requests in on-load
      :: stop leftover threads
  %0  :_  this(state prev(pending-requests [~]))
      =/  tocard  |=  =request-src
                  ^-  (unit card)
                  ?:  ?=(%local-poke -.request-src)  ~
                  (some [%pass /thread-stop/[(scot %da now.bowl)] %agent [our.bowl %spider] %poke %spider-stop !>([id.request-src %.y])])
      =/  rs=(list request-src)  (turn pending-requests.prev |=([id=@uv =request-src] request-src))
      (murn rs tocard)
  ==
++  on-poke
  |=  [=mark =vase]
  :: ^-  (quip card _this)
  ?+  mark  ~&  "client unexpected on-poke from {<src.bowl>} with {<vase>}"
            (on-poke:default mark vase)
  %noun
     ?+  +.vase  `this
     :: add debugging pokes as necessary
     %bowl
        ~&  "{<bowl>}"
       `this
     ==
  :: /mar/lfs-client/action.hoon
  %lfs-client-action
    ?>  (team:title [our src]:bowl)
    =/  action  !<(action vase)
    ~&  "client does {<action>}" :: BUILD_COMMENT
    =/  request-src=request-src  ?:  ?=(~ threadid.action)  [%local-poke ~]  [%thread id=u.threadid.action]
    ?-  +<.action
    %list-files
      =/  files=(list [ship tape])  (zing (turn ~(tap by store.state) |=([=ship =storageinfo:lfs-provider] (turn ~(tap by files.storageinfo) |=([fid=tape =fileinfo:lfs-provider] [ship fid])))))
      ~&  >  "client has the following files: {<files>}"
      `this
    %add-provider
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ?~  threadid.action
           ~&  >  "client already subscribed to {<ship.action>}"
          `this
        =/  tid  u.threadid.action
        :_  this
        :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%updated-providers ~])])]
        ==
      :_  this
      ?~  threadid.action
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %watch (subscriber-path:hc our:bowl)]  ==
      ::
      =/  tid  u.threadid.action
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %watch (subscriber-path:hc our:bowl)]
          [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%updated-providers ~])])]
      ==
    %remove-provider
      :_  this(state state(store (~(del by store.state) ship.action)))
      ?~  threadid.action
        ~&  >  "client unsubscribing from {<ship.action>}"
        :~  [%pass /lfs %agent [ship.action %lfs-provider] %leave ~]
        ==
      =/  tid  u.threadid.action
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %leave ~]
          [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%updated-providers ~])])]
      ==
    %request-upload
      =/  id  (cut 6 [0 1] eny.bowl)
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  "client on-poke upload request to {<ship.action>} {<`@uv`id>}" :: BUILD_COMMENT
        :_  this(state state(pending-requests (snoc pending-requests.state [id=id request-src=request-src])))
        :~  [%pass /(scot %da now.bowl) %agent [ship.action %lfs-provider] %poke %lfs-provider-action !>([%request-upload filename=filename.action id=id])]  ==
      ::
      ?~  threadid.action
         ~&  >  "client won't request upload to {<ship.action>} because we are not subscribed to them"
        `this
      =/  tid  u.threadid.action
      :_  this
      :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%failure reason="not subscribed to {<ship.action>}"])])]  ==
    %request-delete
      =/  id  (cut 6 [0 1] eny.bowl)
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  "client on-poke delete request to {<ship.action>} {<`@uv`id>}" :: BUILD_COMMENT
        :_  this(state state(pending-requests (snoc pending-requests.state [id=id request-src=request-src])))
        :~  [%pass /(scot %da now.bowl) %agent [ship.action %lfs-provider] %poke %lfs-provider-action !>([%request-delete fileid=fileid.action id=id])]  ==
      ::
      ?~  threadid.action
         ~&  >  "not subscribed to {<ship.action>}!"
        `this
      =/  tid  u.threadid.action
      :_  this
      :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%failure reason="not subscribed to {<ship.action>}"])])]  ==
    ==
  ==
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek
  |=  pax=path
  ^-  (unit (unit cage))
  ?+    pax  (on-peek:default pax)
  [%x %providers ~]
      =/  subs  ~(tap in ~(key by wex.bowl))
      :: (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
      ``json+!>([%a (turn subs |=([wire=* =ship term=*] [%s (crip "{<ship>}")]))])
  ::
  [%x %all-storage-info ~]
      ``json+!>([%a (turn ~(tap by store.state) json-storage-map)])
  ::
  [%x %list-files ~]
      =/  files=(list [ship tape])  (zing (turn ~(tap by store.state) |=([=ship =storageinfo:lfs-provider] (turn ~(tap by files.storageinfo) |=([fid=tape =fileinfo:lfs-provider] [ship fid])))))
      =/  jsonfiles  (turn files |=([=ship id=tape] [%o (my ~[['provider' [%s (crip "{<ship>}")]] ['fileid' [%s (crip id)]]])]))
      ``json+!>([%a jsonfiles])
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ?+   wire
    ~&  "client on-agent got {<-.sign>} from {<dap.bowl>} on wire {<wire>}" :: BUILD_COMMENT
    `this
  :: [%poke-ack ~]  `this
  [%lfs ~]
    ?+  -.sign
          ~&  "client on-agent got unknown {<-.sign>} on {<wire>}" :: BUILD_COMMENT
          (on-agent:default wire sign)
    :: %watch-ack
    %kick
      ~&  >  "client was kicked from provider: {<src.bowl>}" :: BUILD_COMMENT
      :_  this(state state(store (~(del by store.state) src.bowl)))
      :~  [%pass /lfs %agent [src.bowl %lfs-provider] %watch (subscriber-path:hc our:bowl)]  ==
    %fact
      ?+  p.cage.sign  (on-agent:default wire sign)
      %lfs-provider-server-update
        =/  resp  !<(server-update:lfs-provider q.cage.sign)
        ?-  -.resp
        %heartbeat
          ~&  >>  "lfs-client received unexpected heartbeat : {<resp>}" :: BUILD_COMMENT
          `this
        %storage-rules-changed
          ~&  "client was notified that provider updated our storage updated to {<newsize.resp>}" :: BUILD_COMMENT
          =/  old  (~(gut by store.state) src.bowl [current-state=0 storage=0 used=0 files=[~]])
          =/  new  old(storage newsize.resp)
          `this(state state(store (~(put by store.state) src.bowl new)))
        %storageinfo
          ~&  "client received provider's cache : {<storageinfo.resp>}" :: BUILD_COMMENT
          `this(state state(store (~(put by store.state) src.bowl storageinfo.resp)))
        %file-uploaded
          ~&  >  "client knows file upload {fileid.resp} succeeded!" :: BUILD_COMMENT
          =/  old=storageinfo:lfs-provider  (~(gut by store.state) src.bowl [current-state=0 storage=0 used=0 files=[~]])
          =/  new=storageinfo:lfs-provider  old(used (add used.old filesize.resp), files (~(put by files.old) fileid.resp [download-url.resp filesize.resp upload-time.resp]))
          `this(state state(store (~(put by store.state) src.bowl new)))
        %request-response
           =/  split-reqs  (skid pending-requests.state |=(r=[id=@uv =request-src] =(id.r id.resp)))
           =/  cards
             ?:  ?=(~ p.split-reqs)  ~
             ?.  ?=(%thread -.request-src.i.p.split-reqs)  ~
             =/  tid  id.request-src.i.p.split-reqs
             :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>(response.resp)])]  ==
           =/  messenger  ?~  p.split-reqs  %unknown-src  -.request-src.i.p.split-reqs
           ?-  -.response.resp
           %failure
             ~&  >  "client tells {<messenger>} that request failed : {reason.response.resp}" :: BUILD_COMMENT
             :_  this(state state(pending-requests q.split-reqs))
             cards
           %file-deleted
             ~&  >  "client tells {<messenger>} that we deleted : {key.response.resp}" :: BUILD_COMMENT
             =/  old=storageinfo:lfs-provider  (~(gut by store.state) src.bowl [current-state=0 storage=0 used=0 files=[~]])
             =/  size  size:(~(got by files.old) key.response.resp)
             =/  new=storageinfo:lfs-provider  old(used (sub used.old size), files (~(del by files.old) key.response.resp))
             :_  this(state state(pending-requests q.split-reqs, store (~(put by store.state) src.bowl new)))
             cards
           %got-url
             ~&  >  "client tells {<messenger>} to upload with : {url.response.resp}" :: BUILD_COMMENT
             :_  this(state state(pending-requests q.split-reqs))
             cards
           ==
        ==
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
++  subscriber-name
  |=  =ship
  ?:  ?=(%earl (clan:title ship))
    (sein:title our.bowl now.bowl ship)
  ship
++  subscriber-path
  |=  =ship
  :: moons count as the planet
  (path /uploader/(scot %p (subscriber-name ship)))
--