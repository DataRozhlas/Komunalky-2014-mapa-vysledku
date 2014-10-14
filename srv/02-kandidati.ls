require! fs
require! async
require! iconv.Iconv
i = 0
iconv = new Iconv "cp1250" "utf-8"
lastLine = ""
current = {
  KODZA: null
  COBVO: null
  POR_S: null
  PORCI: null
  JMENO: null
  PRIJM: null
  PSTRA: null
  NSTRA: null
  PLATN: null
  MANDA: null
}
readSome = (chunk) ->
  chunk = iconv.convert chunk
  chunk .= toString!
  chunk = lastLine + chunk
  lines = chunk.split "\n"
  lastLine := lines.pop!
  stream.pause!
  c = 0
  <~ async.eachSeries lines, (line, cb) ->
    c++
    id = line.substr 3, 5
    switch id
      | \KODZA, \COBVO, \POR_S, \PORCI, \JMENO, \PRIJM, \PSTRA, \NSTRA, \PLATN
        value = line.split "<" .1.split ">" .1
        current[id] = value
        cb!
      | "MANDA"
        value = line.split "<" .1.split ">" .1
        current[id] = value
        <~ saveLine!
        cb!
      | otherwise
        cb!
  # stream.close!
  stream.resume!
  i++
  # if i > 5
  #   stream.close!
currentOpenId = null
currentOpenStream = null
j = 0
saveLine = (cb) ->
  id = "#{current.KODZA}_#{current.COBVO}"
  return cb! if current.PLATN != "0"
  if currentOpenId != id
    currentOpenId := id
    # if currentOpenStream
    #   process.exit!
    currentOpenStream?close!
    currentOpenStream := fs.createWriteStream "#__dirname/../data/kandidati/#id.tsv" 'a'
  data =
    current.POR_S
    current.PORCI
    current.JMENO
    current.PRIJM
    current.PSTRA
    current.NSTRA
    current.MANDA
  <~ currentOpenStream.write (data.join "\t") + "\n"
  j++
  # if 0 == j % 10000
  #   console.log j
  cb!


stream = fs.createReadStream "#__dirname/../data/csu/kvrk.xml"
  ..on \error -> console.log it, '!!'
  ..on \data readSome
  ..resume!
