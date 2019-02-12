import os, threadpool

type Dirent* = ref object
    name: string
    path: string
    file: os.FileInfo
    mode: set[FilePermission]
    number*: int
    active*: bool
    select*: bool
    ignore*: bool
    nick*: string
type Dirents* = seq[Dirent]

proc makeDir*(path: string): Dirent =
  let dir = normalizedPath(path)
  var dirent = Dirent(
    path: dir,
    name: extractFilename(dir),
    file: getFileInfo(dir),
    mode: getFilePermissions(dir))
  dirent.nick = dirent.name
  return dirent

method isDir*(this: Dirent): bool {.base.} = dirExists(this.path)
method isFile*(this: Dirent): bool {.base.} = fileExists(this.path)
method isRegular*(this: Dirent): bool {.base.} = this.isDir or this.isFile
method isSymlink*(this: Dirent): bool {.base.} = symlinkExists(this.path)
method isHidden*(this: Dirent): bool {.base.} = this.name[0] == '.'

include help

proc fileList*(dir: Dirent, recurr = false, ignore = @[".git", "node_modules"]): Dirents =
  if not recurr:
    for kind, path in walkDir(dir.path):
      var temp: Dirent = makeDir(path)
      result.add(temp)
  else:
    for path in walker(dir.path, ignore):
      var temp: Dirent = makeDir(path)
      result.add(temp)

proc choseFile*(dir: Dirent, incDir = true, incFile = true, incHidden = true, recurrent = false): Dirents =
  if not dir.isDir: return
  var 
    paths: Dirents = fileList(dir, recurrent)
  for file in paths:
    if recurrent: file.nick = file.path else: file.nick = file.name
    if (file.isDir and incDir) or (file.isFile and incFile):
      if not file.isHidden or incHidden: result.add(file)

var files: Dirents = choseFile(makeDir("/home/bresilla"), true, true, true, false)
files.sorter(byType)
for file in files:
  echo(file.path)


