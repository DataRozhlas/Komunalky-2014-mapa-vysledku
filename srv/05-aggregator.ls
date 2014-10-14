require! {
  fs
  async
}
strany =
  * "ANO" 768
  * "ODS" 53
  * "CSSD" 7
  * "KSCM" 47
  * "KDU" 1
  * "SZ" 5
  * "TOP" 721
  * "CP" 720
  * "Usv" 792
  * "SSO" 714
  * "Ost" 999
stranyIds = strany.map (.1.toString!)
# console.log stranyIds
typ = "1"
files = fs.readdirSync "#__dirname/../data/okrsky_final/"
  .filter -> typ == it[*-5]

# files.length = 1
output = fs.createWriteStream "#__dirname/../data/mandaty_#typ.tsv"

header = (<[okrsek celkem]> ++ strany.map (.0))
  .join "\t"
<~ output.write header + "\n"
async.eachSeries files, (file, cb) ->
  okrsek = file.split "-" .0
  (err, data) <~ fs.readFile "#__dirname/../data/okrsky_final/#file"
  lines = data.toString!split "\n"
    ..shift!
  hlasu = strany.map -> -1
  celkem = 0
  big = 0
  for line in lines
    [porci, jmeno, prijm, _, _, _, nstrana, _, _, hlasy] = line.split "\t"
    index = stranyIds.indexOf nstrana
    hlasy = parseInt hlasy, 10
    if isNaN hlasy
      console.log file
    if index != -1
      if hlasu[index] is -1
        hlasu[index] = 0
      hlasu[index] += hlasy
      big += hlasy
    celkem += hlasy
  hlasu[*-1] = celkem - big
  lineOut = ([okrsek, celkem] ++ hlasu).join "\t"
  <~ output.write lineOut + "\n"
  cb!

