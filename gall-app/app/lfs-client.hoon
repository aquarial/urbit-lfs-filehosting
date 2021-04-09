/-  *lfs-client, lfs-provider
/+  srv=server, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  request-src
  $%  [%local-poke ~]
      [%thread id=@ta]
  ::  [%http-request =connection] todo
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
  =/  private-filea  [%file-server-action !>([%serve-dir /'~filemanager' /app/filemanager %.n %.n])]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke private-filea]
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
  ?+  mark  ~&  "client unexpected on-poke from {<src.bowl>} with {<vase>}"
            (on-poke:default mark vase)
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
    ~&  "client does {<action>}"
    =/  request-src=request-src  ?:  =(threadid.action ~)  [%local-poke ~]  [%thread id=(need threadid.action)]
    ?-  +<.action
    %list-files
      =/  files=(list [ship @uv])  (zing (turn ~(tap by store.state) |=([=ship =storageinfo:lfs-provider] (turn ~(tap by files.storageinfo) |=([fid=@uv =fileinfo:lfs-provider] [ship fid])))))
      ~&  >  "client has the following files: {<files>}"
      `this
    %add-provider
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  >  "client already subscribed to {<ship.action>}"
        ?~  threadid.action  `this
        =/  tid  (need threadid.action)
        :_  this
        :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%updated-providers ~])])]
        ==
      :_  this
      ?~  threadid.action
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %watch /uploader/(scot %p our:bowl)]  ==
      ::
      =/  tid  (need threadid.action)
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %watch /uploader/(scot %p our:bowl)]
          [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%updated-providers ~])])]
      ==
    %remove-provider
      :: TODO clean this up!
      =/  subs=(set ship)  (~(run in ~(key by wex.bowl)) |=([wire=* =ship term=*] ship))
      =/  used  (skip ~(tap by store.state) |=([=ship =storageinfo:lfs-provider] &(=(used.storageinfo 0) !(~(has in subs) ship))))
      :_  this(state state(store (~(gas by *(map ship storageinfo:lfs-provider)) used)))
      ?~  threadid.action
        :~  [%pass /lfs %agent [ship.action %lfs-provider] %leave ~]  ==
        =/  tid  (need threadid.action)
        :~  [%pass /lfs %agent [ship.action %lfs-provider] %leave ~]
            [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%updated-providers ~])])]
        ==
    %request-upload
      =/  id  (cut 6 [0 1] eny.bowl)
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  "client on-poke upload request to {<ship.action>} {<`@uv`id>}"
        :_  this(state state(pending-requests (snoc pending-requests.state [id=id request-src=request-src])))
        :~  [%pass /(scot %da now.bowl) %agent [ship.action %lfs-provider] %poke %lfs-provider-action !>([%request-upload id=id])]  ==
      ::
      ~&  >  "client won't request upload to {<ship.action>} because we are not subscribed to them"
      ?~  threadid.action  `this
      =/  tid  (need threadid.action)
      :_  this
      :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>([%failure reason="not subscribed to {<ship.action>}"])])]  ==
    %request-delete
      =/  id  (cut 6 [0 1] eny.bowl)
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  "client on-poke delete request to {<ship.action>} {<`@uv`id>}"
        :_  this(state state(pending-requests (snoc pending-requests.state [id=id request-src=request-src])))
        :~  [%pass /(scot %da now.bowl) %agent [ship.action %lfs-provider] %poke %lfs-provider-action !>([%request-delete fileid=fileid.action id=id])]  ==
      ::
      ~&  >  "not subscribed to {<ship.action>}!"
      ?~  threadid.action  `this
      =/  tid  (need threadid.action)
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
      =/  json-fileinfo  |=  [fileid=@uv download-url=tape size=@ud]  [(crip "{<fileid>}") [%o (my ~[['download-url' [%s (crip download-url)]] ['size' [%n (crip (format-number:hc size))]]])]]
      =/  json-storage  |=  =storageinfo:lfs-provider  [%o (my ~[['storage' [%n (crip (format-number:hc storage.storageinfo))]] ['used' [%n (crip (format-number:hc used.storageinfo))]] ['upload-key' (fall ((lift |=(key=@uv [%s (crip "{<key>}")])) upload-key.storageinfo) ~)] ['files' [%o ((map @ta json) (transform-map:hc files.storageinfo json-fileinfo))]]])]
      =/  json-storage-map  |=  [=ship =storageinfo:lfs-provider]  [(crip "{<ship>}") (json-storage storageinfo)]
      ``json+!>([%o ((map @ta json) (transform-map:hc store.state json-storage-map))])
  [%x %list-files ~]
      =/  files=(list [ship @uv])  (zing (turn ~(tap by store.state) |=([=ship =storageinfo:lfs-provider] (turn ~(tap by files.storageinfo) |=([fid=@uv =fileinfo:lfs-provider] [ship fid])))))
      =/  jsonfiles  (turn files |=([=ship id=@uv] [%o (my ~[['provider' [%s (crip "{<ship>}")]] ['fileid' [%s (crip "{<id>}")]]])]))
      ``json+!>([%a jsonfiles])
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ?+   wire  ~&  "client on-agent got un-handled {<-.sign>} from {<dap.bowl>} on wire {<wire>}"
             `this
  [%lfs ~]
    ?+  -.sign  (on-agent:default wire sign)
    :: %watch-ack
    :: %poke-ack
    %fact
      ?+  p.cage.sign  (on-agent:default wire sign)
      %lfs-provider-server-update
        =/  resp  !<(server-update:lfs-provider q.cage.sign)
        ?-  -.resp
        %heartbeat
          ~&  >>  "client received unexpected heartbeat : {<resp>}"
          `this
        %storageinfo
          ~&  "client received provider's cache : {<storageinfo.resp>}"
          `this(state state(store (~(put by store.state) src.bowl storageinfo.resp)))
        %file-uploaded
          ~&  >  "client knows file upload {<fileid.resp>} succeeded!"
          =/  old=storageinfo:lfs-provider  (~(gut by store.state) src.bowl [storage=0 used=0 upload-url=~ files=[~]])
          =/  key  ?:  =(upload-key.old (some fileid.resp))  ~  upload-key.old
          =/  new=storageinfo:lfs-provider  old(used (add used.old filesize.resp), upload-key key, files (~(put by files.old) fileid.resp [download-url.resp filesize.resp]))
          `this(state state(store (~(put by store.state) src.bowl new)))
        %request-response
           =/  split-reqs  (skid pending-requests.state |=(r=[id=@uv =request-src] =(id.r id.resp)))
           ?:  ?=(~ p.split-reqs)
             ~|  "client received unexpected response for request {<id.resp>}"
             !!
           =/  cards
             ?:  ?=(%thread -.request-src.i.p.split-reqs)
               =/  tid  id.request-src.i.p.split-reqs
               :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %client-action-response !>(response.resp)])]  ==
             ~
           ?-  -.response.resp
           %failure
             ~&  >  "client tells {<request-src.i.p.split-reqs>} that request failed : {reason.response.resp}"
             :_  this(state state(pending-requests q.split-reqs))
             cards
           %file-deleted
             ~&  >  "client tells {<request-src.i.p.split-reqs>} that we deleted : {<key.response.resp>}"
             =/  old=storageinfo:lfs-provider  (~(gut by store.state) src.bowl [storage=0 used=0 upload-url=~ files=[~]])
             =/  size  size:(~(got by files.old) key.response.resp)
             =/  new=storageinfo:lfs-provider  old(used (sub used.old size), files (~(del by files.old) key.response.resp))
             :_  this(state state(pending-requests q.split-reqs, store (~(put by store.state) src.bowl new)))
             cards
           %got-url
             ~&  >  "client tells {<request-src.i.p.split-reqs>} to upload with : {url.response.resp}"
             =/  old=storageinfo:lfs-provider  (~(gut by store.state) src.bowl [storage=0 used=0 upload-url=~ files=[~]])
             =/  new=storageinfo:lfs-provider  old(upload-key (some key.response.resp))
             :_  this(state state(pending-requests q.split-reqs, store (~(put by store.state) src.bowl new)))
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
++  format-number
  |=  n=@ud
  :: 1.234 -> "1234"
  (tape (skim ((list @tD) "{<n>}") |=(c=@tD ?!(=(c '.')))))
++  transform-map
  |*  [m=(map * *) f=gate]
  (~(gas by *(map * *)) (turn ~(tap by m) f))
--