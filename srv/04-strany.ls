require! {
  fs
  async
}
strany = {}
for line in fs.readFileSync "#__dirname/../data/vstrana.csv" .toString!.split "\n"
  [id, full, zkratka_ultralong, zkratka_long, zkratka] = line.split "\t"
  strany[id] = {full, zkratka}

files = fs.readdirSync "#__dirname/../data/okrsky_hlasy/"
# files.length = 1
async.eachLimit files, 20, (file, cb) ->
  (err, data) <~ fs.readFile "#__dirname/../data/okrsky_hlasy/#file"
  out = for line in data.toString!split "\n"
    [por_s, porci, jmeno, prijm, pstra, nstra, manda, stranaId, stranaFull, stranaZkratka, hlasu] = line.split "\t"
    [porci, jmeno, prijm, stranaId, stranaZkratka, stranaFull, nstra, strany[nstra].zkratka, strany[nstra].full, hlasu, manda].join "\t"

  out.unshift <[kand_poradi jmeno prijmeni vstranaId vstranaZkratka vstrnaFull nstranaId nstranaZkratka nstranaFull hlasu mandat ]>.join "\t"
  out .= join "\n"
  (err) <~ fs.writeFile "#__dirname/../data/okrsky_final/#{file}", out
  console.log err if err
  cb!
