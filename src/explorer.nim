import dirk, os

proc renameExist(name: string): string =
  if pathExists(name):
    var i: int = 1
    while true:
      if pathExists(name & "(" & $i & ")"): inc(i) else: break
    return name & "(" & $i & ")"    
  else: result = name

proc listDirs*(dir: Dirent): Dirents =
  result = choseFile(dir, true, true, true, false)

proc selected*(files: varargs[Dirent]): Dirents =
  var selectDir: Dirents
  var activeDir: Dirent
  for file in files:
    if file.select: selectDir.add(file)
    if file.active: activeDir = file
  if selectDir.len == 0: result.add(activeDir) else: return selectDir

proc touch*(dir: Dirent, names: varargs[string]): Dirents =
  for name in names:
    var newName: string = renameExist($dir & "/" & name)
    try: createFile(newName) except OSError: continue
    result.add(makeDir(newName))

proc mkdir*(dir: Dirent, names: varargs[string]): Dirents =
  for name in names:
    let newName: string = renameExist($dir & "/" & name)
    try: createDir(newName) except OSError: continue
    result.add(makeDir(newName))

proc copy*(dir: Dirent, files: varargs[Dirent]) =
  var newDir: string
  for file in files:
    if not ($file).pathExists: continue
    newDir = renameExist(joinPath($dir, extractFilename($file)))
    if file.isDir: 
      try: copyDir(($file), newDir) except OSError: continue
    elif file.isFile:
      try: copyFile(($file), newDir) except OSError: continue
    else: continue

proc move*(dir: Dirent, files: varargs[Dirent]) =
  var newDir: string
  for file in files:
    if not ($file).pathExists: continue
    newDir = renameExist(joinPath($dir, extractFilename($file)))
    if file.isDir: 
      try: moveDir(($file), newDir) except OSError: continue
    elif file.isFile:
      try: moveFile(($file), newDir) except OSError: continue
    else: continue

proc delete*(files: varargs[Dirent]) =
  for file in files:
    if not ($file).pathExists: continue
    if file.isDir: 
      try: removeDir(($file)) except OSError: continue
    elif file.isFile:
      try: removeFile(($file)) except OSError: continue
    else: continue


let test: Dirent = makeDir("/tmp")
let test2: Dirent = makeDir("/tmp/Test(1)")
var files: Dirents = listDirs(test2)
#for file in files: echo file
files[1].select = true
files[2].select = true
files[2].active = true

for file in files:
  echo ~file