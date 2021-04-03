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
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  on-load:default
++  on-poke
  |=  [=mark =vase]
  :: ^-  (quip card _this)
  ~&  "client on-poke from {<src.bowl>} with {<vase>}"
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
    =/  request-src=request-src  ?:  =(threadid.action ~)  [%local-poke ~]  [%thread id=(need threadid.action)]
    :: =/  request-src=request-src  [%local-poke ~]
    ?-  +<.action
    %list-files
      =/  files=(list [ship @uv])  (zing (turn ~(tap by store.state) |=([=ship =storageinfo:lfs-provider] (turn ~(tap by files.storageinfo) |=([fid=@uv =fileinfo:lfs-provider] [ship fid])))))
      ~&  >  "client has the following files: {<files>}"
      `this
    %add-provider
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  >  "lfs client already subscribed to {<ship.action>}"
        `this
      :_  this
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %watch /uploader/(scot %p our:bowl)]  ==
    %remove-provider
      :: unsubscribe and remove unused providers
      =/  used  (skip ~(tap by store.state) |=([=ship =storageinfo:lfs-provider] =(used.storageinfo 0)))
      :_  this(state state(store (~(gas by *(map ship storageinfo:lfs-provider)) used)))
      :~  [%pass /lfs %agent [ship.action %lfs-provider] %leave ~]  ==
    %request-upload
      =/  id  (cut 6 [0 1] eny.bowl)
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  "client on-poke upload request to {<ship.action>} {<`@uv`id>}"
        :_  this(state state(pending-requests (snoc pending-requests.state [id=id request-src=request-src])))
        :~  [%pass /(scot %da now.bowl) %agent [ship.action %lfs-provider] %poke %lfs-provider-action !>([%request-upload id=id])]  ==
      ::
      ~&  >  "client won't request upload to {<ship.action>} because we are not subscribed to them"
      `this
    %request-delete
      =/  id  (cut 6 [0 1] eny.bowl)
      ?:  (~(has by wex.bowl) [wire=/lfs ship=ship.action term=%lfs-provider])
        ~&  "client on-poke delete request to {<ship.action>} {<`@uv`id>}"
        :_  this(state state(pending-requests (snoc pending-requests.state [id=id request-src=request-src])))
        :~  [%pass /(scot %da now.bowl) %agent [ship.action %lfs-provider] %poke %lfs-provider-action !>([%request-delete fileid=fileid.action id=id])]  ==
      ::
      ~&  >  "not subscribed to {<ship.action>}!"
      `this
    ==
  ==
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ?+   wire  ~&  "client on-agent got un-handled {<-.sign>} from {<dap.bowl>} on wire {<wire>}"
             (on-agent:default wire sign)
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
          =/  new=storageinfo:lfs-provider  old(used (add used.old filesize.resp), upload-key key, files (~(put by files.old) fileid.resp filesize.resp))
          `this(state state(store (~(put by store.state) src.bowl new)))
        %request-response
           =/  split-reqs  (skid pending-requests.state |=(r=[id=@uv =request-src] =(id.r id.resp)))
           ?:  ?=(~ p.split-reqs)
             ~|  "client received unexpected response for request {<id.resp>}"
             !!
           ?-  -.request-src.i.p.split-reqs
           %thread
             =/  tid  id.request-src.i.p.split-reqs
             :_  this
             :~  [%pass /thread/[tid] %agent [our.bowl %spider] %poke %spider-input !>([tid %request-response !>(response.resp)])]
             ==
           %local-poke
             ?-  -.response.resp
             %failure
               ~&  >  "client tells {<request-src.i.p.split-reqs>} that the upload request failed : {reason.response.resp}"
               `this(state state(pending-requests q.split-reqs))
             %got-url
               ~&  >  "client tells {<request-src.i.p.split-reqs>} to upload with : {url.response.resp}"
               =/  old=storageinfo:lfs-provider  (~(gut by store.state) src.bowl [storage=0 used=0 upload-url=~ files=[~]])
               =/  new=storageinfo:lfs-provider  old(upload-key (some key.response.resp))
               `this(state state(pending-requests q.split-reqs, store (~(put by store.state) src.bowl new)))
             ==
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
--