/-  lfs-client
=,  format
|_  act=action:lfs-client
++  grab
  |%
  ++  noun  action:lfs-client
::  ++  json
::    |=  jon=^json
::    ^-  action:lfs-client
::    =<  (action jon)
::    |%
::    ++  action
::      [[%threadid (un:dejs so:dejs)] payload]
::    ++  payload
::      %-  of:dejs
::      :~  [%add-provider (su:dejs ;~(pfix sig fed:ag))]
::          [%remove-provider (su:dejs ;~(pfix sig fed:ag))]
::          [%request-upload (su:dejs ;~(pfix sig fed:ag))]
::          [%list-files ul:dejs]
::          [%request-delete (su:dejs ;~(pfix sig fed:ag)) (se:dejs %uv)]
::      ==
::    --
  --
--
