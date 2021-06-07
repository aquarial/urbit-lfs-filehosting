|%
++  transform-map
  |*  [m=(map * *) f=gate]
  (~(gas by *(map * *)) (turn ~(tap by m) f))
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
--