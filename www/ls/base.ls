document.body.removeChild document.getElementById 'fallback'
body = d3.select \body
window.ig.infoBar = new ig.InfoBar body
fields =
  "iczuj"
  "nazev"
  "obce_ANO"
  "obce_ODS"
  "obce_CSSD"
  "obce_KSCM"
  "obce_KDU"
  "obce_SZ"
  "obce_CP"
  "obce_TOP"
  "obce_celkem"
  "mcmo_ANO"
  "mcmo_ODS"
  "mcmo_CSSD"
  "mcmo_KSCM"
  "mcmo_KDU"
  "mcmo_SZ"
  "mcmo_CP"
  "mcmo_TOP"
  "mcmo_celkem"
  "okrsek_nazev"

parties =
  \ANO
  \ODS
  \CSSD
  \KSCM
  \KDU
  \SZ
  \CP
  \TOP

window.ig.displayData = (data) ->
  out = {}
  sumParties = {mcmo: 0, obce: 0}
  for field, index in fields
    [typ, party] = field.split "_"
    out[field] = data[index]
    if party in parties
      sumParties[typ] += data[index] if data[index] > 0
  out.mcmo_ostatni = out['mcmo_celkem'] - sumParties['mcmo']
  out.obce_ostatni = out['obce_celkem'] - sumParties['obce']
  window.ig.infoBar.displayData out

selectedOutline = null
suggesterContainer = body.append \div
  ..attr \class \suggesterContainer
  ..append \span .html "Najít obec"

suggester = new window.ig.Suggester suggesterContainer
  ..on 'selected' (obec) ->
    window.ig.map.setView [obec.lat, obec.lon], 14
    setOutline obec.id
setOutline = (iczuj) ->
  if selectedOutline
    window.ig.map.removeLayer selectedOutline
  (err, data) <~ d3.json "/tools/suggester/0.0.1/geojsons/#{iczuj}.geo.json"
  return unless data
  style =
    fill: no
    opacity: 1
    color: '#000'
  selectedOutline := L.geoJson data, style
    ..addTo window.ig.map

setView = (hash) ->
  [iczuj, party] = hash.slice 1 .split '|'
  return unless iczuj.length
  iczuj = parseInt iczuj, 10
  <~ suggester.downloadSuggestions
  obec = suggester.suggestions.filter (.id == iczuj) .0
  return unless obec
  if obec
    setOutline iczuj
    return if window.ig.hashChanged
    {lat, lon, nazev} = obec
    latlng = L.latLng [lat, lon]
    window.ig.map.setView latlng, 12
    window.ig.showKandidatka iczuj, nazev, party
    queueIterations = 0
    checkQueue = ->
      try
        {data} = window.ig.utfgrid._objectForEvent {latlng: latlng}
      if data
        window.ig.displayData data
      else
        ++queueIterations
        setTimeout checkQueue, 100 if queueIterations < 100
    checkQueue!

if window.location.hash
  setView that

window.onhashchange = ->
  setView window.location.hash
<~ setTimeout _, 20
window.ig.displayData ["562998","Blatno",-1,-1,578,164,-1,170,-1,-1,2063,null,null,null,null,null,null,null,null,null,1]
