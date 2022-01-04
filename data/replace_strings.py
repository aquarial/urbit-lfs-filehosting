import sys
with open(sys.argv[1], 'r') as i:
  with open(sys.argv[2], 'w') as o:
    for l in i:
      if " BUILD_COMMENT" in l:
          o.write(":: ")
          o.write(l)
          print('    [COMMENT]: ', l.strip())
          continue
      if " BUILD_REPLACE " in l:
        ls = l.strip().split(" ")
        for (ix,w) in enumerate(ls):
           if w == "BUILD_REPLACE":
             o.write(l.replace(ls[ix+1], ls[ix+2]))
             print('    [replace]: ', l.replace(ls[ix+1], ls[ix+2]).strip())
      else:
         o.write(l)
