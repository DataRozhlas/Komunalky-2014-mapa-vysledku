container = d3.select \.ig
wrap = container.append \div
  ..attr \class \kandidatka-wrap
content = wrap.append \div
  ..attr \class \kandidatka

heading = content.append \h1
subheading = content.append \h2
kostiColors =
  "ANO 2011" : \#5434A3
  "ODS"      : \#1C76F0
  "ČSSD"     : \#FEA201
  "KSČM"     : \#F40000
  "KDU-ČSL"  : \#FEE300
  "SZ"       : \#0FB103
  "Pirátí"   : \#504E4F
  "TOP 09"   : \#B560F3
tableContainer = content.append \div
  ..attr \class \tableContainer

closeBtn = content.append \a
  ..attr \class \closebtn
  ..html '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" baseProfile="full" width="76" height="76" viewBox="0 0 76.00 76.00" enable-background="new 0 0 76.00 76.00" xml:space="preserve"><path fill="#000000" fill-opacity="1" stroke-width="0.2" stroke-linejoin="round" d="M 57,42L 57,34L 32.25,34L 42.25,24L 31.75,24L 17.75,38L 31.75,52L 42.25,52L 32.25,42L 57,42 Z "/></svg>'
  ..on \click ->
      container.classed \kandidatka-active no
      if window.top
        window.ig.hashChanged = true
        window.top.location.hash = "000000"

tableHeadings =
  * value: -> "<span class='mandat mandat-#{it.mandat}'></span>"
    name: "Mandát"
  * value: -> parseInt it.hlasu, 10
    sortable: 1
    name: 'Hlasů'
  * value: -> "#{it.jmeno}  #{it.prijmeni}"
    sortable: -> "#{it.prijmeni}#{it.jmeno}"
    name: "Jméno"
  * value: -> parseInt it.kand_poradi, 10
    sortable: 1
    name: 'Číslo'
  * value: ->
      str = it.vstranaZkratka || it.vstranaFull || "Ostatní"
      color = if kostiColors[it.vstranaZkratka] then that else '#aaa'
      str += "<span class='kost' style='background-color: #color'></span>"
      str
    filterable: 1
    name: "Volební uskupení"
  * value: ->
      str = it.nstranaZkratka || it.nstrana || "Ostatní"
      color = if kostiColors[it.nstranaZkratka] then that else '#aaa'
      str += "<span class='kost' style='background-color: #color'></span>"
      str
    filterable: 1
    name: "Navrhující strana"

window.ig.showKandidatka = (obecId, obecName, okrsekId, filterByParty = null) ->
  container.classed \kandidatka-active yes
  heading.html "Výsledky okrsku #obecName #{okrsekId}"
  typ = if window.ig.displayedType == "mcmo" then 2 else 1
  subheading.html if typ == 2
    "Zastupitelstvo městské části, městského obvodu"
  else
    "Obecní zastupitelstvo, magistrát"
  tableContainer.html ''
  (err, obec) <~ d3.tsv "../data/okrsky_final/#{obecId}_#{okrsekId}-#{typ}.tsv"
  for kandidat in obec
    kandidat["hlasu"] = parseInt kandidat["hlasu"], 10
    kandidat["mandat"] = parseInt kandidat["mandat"], 10
    kandidat["kand_poradi"] = parseInt kandidat["kand_poradi"], 10
  obec.sort (a, b) ->
    | b.mandat - a.mandat => that
    | b.hlasu - a.hlasu => that
    | b.kand_poradi - a.kand_poradi => that
  dataTable = new window.ig.DataTable tableContainer, tableHeadings, obec
    ..on \data (filteredData) ->
      displaySubset obecName, filteredData.map (.data)
    ..on \filterChange ({index, value}) ->
      return if index != 5
      if window.top
        window.ig.hashChanged = true
        window.top.location.hash = "#obecId|#value"

  if filterByParty
    dataTable.filterValues 5, filterByParty
  # if window.top
  #   window.ig.hashChanged = true
  #   window.top.location.hash = obecId

displaySubset = (obecName, data) ->
  nazev = obecName
  veky = [0 to 14].map -> 0
  zeny = 0
  tituly = [0 to 6].map -> 0
  ruzumnyTituly = <[ing mgr mudr judr]>
  celkem = data.length
  for datum in data
    vekGroup = groupVek parseInt datum.vek, 10
    if datum.pohlavi != 'PRAVDA'
      zeny++
    titul = (datum.titulpred + datum.titulza).toLowerCase!
    maRozumnyTitul = false
    if titul.length == 0
      tituly[5]++
    else
      for rozumnyTitul, titulIndex in ruzumnyTituly
        if hasTitul titul, rozumnyTitul
          if rozumnyTitul == 'mvdr' then rozumnyTitul = 'mudr'
          tituly[titulIndex]++
          maRozumnyTitul = true
      if not maRozumnyTitul
        tituly[6]++
    veky[vekGroup]++
  window.ig.infoBar.displayData {nazev, celkem, tituly, veky, zeny}

hasTitul = (tituly, titul) ->
  -1 != tituly.indexOf titul

groupVek = (vek) ->
  if vek <= 25
    return 0
  if vek > 95
    return 14
  vek -= 25
  Math.ceil vek / 5
