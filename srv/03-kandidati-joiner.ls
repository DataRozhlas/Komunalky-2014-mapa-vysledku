require! {
  fs
  async
  zatup_obec: '../data/kod-zastup-to-obec.json'
  '../data/obvody_okrsky.json'
  '../data/strany_celky.json'
}
obceWithZastup = {}
for zastupId, obce of zatup_obec
  for obec in obce
    obceWithZastup[obec] = zastupId

dir = "#__dirname/../data/okrsky"
currentSrcId = null
currentSrcData = null
fs.readdir dir, (err, files) ->
  # files.length = 1
  i = 0
  async.eachSeries files, (filename, cb) ->
    i++
    console.log i if 0 == i % 10000
    hlasy = {}
    lines = fs.readFileSync dir + "/" + filename .toString!split "\n"
      ..pop!
    for line in lines
      [strana, poradi, hlasu] = line.split "\t"
      hlasy[strana + "_" + poradi] = hlasu
    [obecId, okrsekId, typId] = filename.split /[\._-]/
    zastupId =
      | obceWithZastup[obecId] && typId == "1" => obceWithZastup[obecId]
      # | obceWithZastup[obecId] == "505927" => "505927"
      # | obceWithZastup[obecId] == "563889" => "563889"
      | otherwise => obecId
    obvodId = obvody_okrsky["#{zastupId}_#okrsekId"] || 1
    srcId = "#{zastupId}_#{obvodId}"
    if currentSrcId != srcId
      # console.log srcId, filename, zastupId, obvodId
      getSrcData srcId

    kandidati = for kandidat in currentSrcData
      [strana, poradi] = kandidat.split "\t"
      hlasu = hlasy["#{strana}_#{poradi}"]
      kandidat += "\t" + strany_celky["#{zastupId}_#{obvodId}_#{strana}"] + "\t" + hlasu
    <~ fs.writeFile "#__dirname/../data/okrsky_hlasy/#filename", kandidati.join "\n"
    cb!

getSrcData = (id) ->
  data = fs.readFileSync "#__dirname/../data/kandidati/#id.tsv"
  currentSrcData := data.toString!split "\n"
    ..pop!
