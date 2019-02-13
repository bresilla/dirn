import algorithm, times, os, ospaths, strutils

iterator walker(dir: string, ignore: openArray[string] = [], yieldFilter = {pcFile}, followFilter = {pcDir}): string {.tags: [ReadDirEffect].} =
  var stack = @[dir]
  while stack.len > 0:
    for k, p in walkDir(stack.pop()):
      if k in {pcDir, pcLinkToDir} and k in followFilter and extractFilename(p) notin ignore:
        stack.add(p)
      if k in yieldFilter:
        yield p

type Sorter* = enum
    byType, bySize, byDate

proc sorter(dirs: var Dirents, sorter: Sorter) =
  if sorter == byType:
    dirs.sort do (x, y: Dirent) -> int:
      result = cmp(x.isHidden, y.isHidden)
      if result == 0: result = cmp(x.isFile(), y.isFile())
      if result == 0: result = cmp(x.nick, y.nick)
  elif sorter == bySize:
    dirs.sort do (x, y: Dirent) -> int: 
      result = cmp(x.file.size, y.file.size)
      if result == 0: result = cmp(x.nick, y.nick)
  elif sorter == byDate:
    dirs.sort do (x, y: Dirent) -> int: 
      result = cmp(x.file.creationTime, y.file.creationTime)
      if result == 0: result = cmp(x.nick, y.nick)

proc byteSize(b: int64): string =
  const size = @["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
  var 
    expp: int = 0
    bytt: int64 = b
  while bytt > 1024:
    bytt = bytt div 1024
    inc(expp)
  result = $bytt & size[expp]

proc parentInfo(dir: string): string =
  result = dir.parentDir()
  if result.isRootDir: result = "/"

proc elementInfo(dir: string): seq[string] =
  for kind, path in walkDir(dir):
    result.add(path)

proc ancestorInfo(dir: string): seq[string] =
  var joiner: string = ""
  for each in dir.split('/'):
    joiner &= "/" & each
    result.add(joiner)