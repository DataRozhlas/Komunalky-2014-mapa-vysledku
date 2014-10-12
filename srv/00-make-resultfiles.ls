require! fs
require! async
i = 0

lastLine = ""
current = {
  obecId: null
  okrsekId: null
  typZastup: null
  strana: null
}
readSome = (chunk) ->
  lines = chunk.toString!split "\n"
  lines[0] = lastLine + lines[0]
  lastLine := lines.pop!
  stream.pause!
  k = 0
  <~ async.eachSeries lines, (line, cb) ->
    switch
      | "<OBEC>" == line.substr 2, 6
        current.obecId = line.substr 8, 6
      | "<OKRSEK>" == line.substr 2, 8
        current.okrsekId = line.substr 10 .split "<" .0
      | "<TYPZASTUP>" == line.substr 2, 11
        current.typZastup = line.substr 13, 1
      | "<POR_STR_HL>" == line.substr 2, 12
        current.strana = line.substr 14 .split "<" .0
      | "<HLASY_" == line.substr 2, 7
        poradi = parseInt do
          line.substr 9, 2
          10
        hlasu = parseInt do
          line.substr 12 .split "<" .0
          10

        <~ saveLine poradi, hlasu
        cb!
    cb! if "<HLASY_" != line.substr 2, 7
  stream.resume!
  i++
  # if i > 5
  #   stream.close!
currentOpenId = null
currentOpenStream = null
j = 0
saveLine = (poradi, hlasu, cb) ->
  id = "#{current.obecId}_#{current.okrsekId}-#{current.typZastup}"
  if currentOpenId != id
    currentOpenId := id
    # if currentOpenStream
    #   process.exit!
    currentOpenStream?close!
    currentOpenStream := fs.createWriteStream "#__dirname/../data/okrsky/#id.tsv" 'a'
  <~ currentOpenStream.write [current.strana, poradi, hlasu, "\n"].join "\t"
  j++
  if 0 == j % 10000
    console.log j
  cb!


stream = fs.createReadStream "#__dirname/../data/csu/kvhl.xml"
  ..on \error -> console.log it, '!!'
  ..on \data readSome
  ..resume!
