import dirk, os

proc renameExist(name: string): string =
  if pathExists(name):
    var i: int = 1
    while true:
      if pathExists(name & "(" & $i & ")"): inc(i) else: break
    return name & "(" & $i & ")"    
  result = name

proc listDirs*(file: Dirent): Dirents =
  for i, value in choseFile(file, true, true, true, false):
    result.add(value)


var files: Dirents = listDirs(makeDir("/home/bresilla/DATA"))
for file in files: echo file