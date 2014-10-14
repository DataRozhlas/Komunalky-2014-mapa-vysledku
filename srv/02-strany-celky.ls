require! {
  fs
}
lines = fs.readFileSync "#__dirname/../data/csu/kvros.csv" .toString!split "\n"
  ..shift!
out = {}
for line in lines
  [idZastup, obvod, poradi, id, nazev, zkratka] = line.split "\t"
  out["#{idZastup}_#{obvod}_#{poradi}"] = "#id\t#nazev\t#zkratka"
fs.writeFile "#__dirname/../data/strany_celky.json", JSON.stringify out, 1, 2
