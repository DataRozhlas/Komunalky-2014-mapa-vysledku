require! fs
require! xml2js
data = fs.readFileSync "#__dirname/../data/csu/kvt3.xml" .toString!

obvody_okrsky = {}
(err, parsed) <~ xml2js.parseString data
for row in parsed.KV_T3.KV_T3_ROW
  obec = row.OBEC.0
  okrsek =  row.OKRSEK.0
  obvod = parseInt row.COBVODU.0, 10
  if obvod != 1
    obvody_okrsky["#{obec}_#{okrsek}"] = obvod
fs.writeFile "#__dirname/../data/obvody_okrsky.json", JSON.stringify obvody_okrsky, 1, 2

