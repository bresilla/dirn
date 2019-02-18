import algorithm, times, os, strutils
  
template `%`*(a, b: string): string =
  if a.len > b.len: replace($a, $b, "")
  else: replace($b, $a, "")

template `??`(a, b: untyped): untyped =
  let x = a
  if x.isNil: b else: x
  
iterator walker*(dir: string,
  yieldFilter = {pcFile}, followFilter = {pcDir}, relative = false, 
  ignoreDirs: openarray[string]=[]): string {.tags: [ReadDirEffect].} =
  var stack = @[""]
  while stack.len > 0:
    let d = stack.pop()
    for k, p in walkDir(dir / d, relative = true):
      let rel = d / p
      if k in {pcDir, pcLinkToDir} and k in followFilter and extractFilename(p) notin ignoreDirs:
        stack.add rel
      if k in yieldFilter:
        yield if relative: rel else: dir / rel

proc createFile*(dir: string) = open(dir, fmWrite).close()

proc pathExists*(dir: string): bool =
  if dir.fileExists or dir.dirExists or dir.symlinkExists: return true

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