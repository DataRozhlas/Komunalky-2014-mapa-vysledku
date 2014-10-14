mapElement = document.createElement 'div'
  ..id = \map
document.body.appendChild mapElement
window.ig.map = map = L.map do
  * mapElement
  * minZoom: 6,
    maxZoom: 14,
    zoom: 8,
    center: [49.78, 15.5]
    maxBounds: [[48.4,11.8], [51.2,18.9]]
dataLayers = {}
window.ig.displayedType = "obce"
layerDefs =
  * id: \winners name: "Vítězové voleb"
  * id: \ano     name: "ANO 2011"
  * id: \ods     name: "ODS"
  * id: \cssd    name: "ČSSD"
  * id: \kscm    name: "KSČM"
  * id: \kdu     name: "KDU-ČSL"
  * id: \sz      name: "Zelení"
  * id: \top     name: "TOP 09"
  * id: \cp      name: "Piráti"

for definition in layerDefs
  dataLayers["obce-#{definition.id}"] = L.tileLayer do
    * "../data/tiles/obce-#{definition.id}-2014/{z}/{x}/{y}.png"
    * attribution: '<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/cz/" target = "_blank">CC BY-NC-SA 3.0 CZ</a> <a target="_blank" href="http://rozhlas.cz">Rozhlas.cz</a>, data <a target="_blank" href="http://www.volby.cz">ČSÚ</a>'
      zIndex: 2

  dataLayers["mcmo-#{definition.id}"] = L.tileLayer do
    * "../data/tiles/mcmo-#{definition.id}-2014/{z}/{x}/{y}.png"
    * attribution: '<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/cz/" target = "_blank">CC BY-NC-SA 3.0 CZ</a> <a target="_blank" href="http://rozhlas.cz">Rozhlas.cz</a>, data <a target="_blank" href="http://www.volby.cz">ČSÚ</a>'
      zIndex: 2


baseLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
  * zIndex: 1
    opacity: 1
    attribution: 'mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

labelLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_l1/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.75

displayedId = null
window.ig.utfgrid = grid = new L.UtfGrid "../data/tiles/meta/{z}/{x}/{y}.json", useJsonP: no
  ..on \mouseover ({data}:e) ->
    displayedId := "#{data[0]}_#{data[*-1]}"
    window.ig.displayData data
  ..on \click ({data}) ->
    return unless data
    return unless data.3
    if displayedId == "#{data[0]}_#{data[*-1]}"
      window.ig.showKandidatka data[0], data[1], data[*-1]
    else
      window.ig.displayData data
      displayedId := "#{data[0]}_#{data[*-1]}"

map.on \zoomend ->
  z = map.getZoom!
  if z > 9 && !map.hasLayer baseLayer
    map
      ..addLayer baseLayer
      ..addLayer labelLayer
    layers.forEach (.layer.setOpacity 0.7)
  else if z <= 9 && map.hasLayer baseLayer
    map
      ..removeLayer baseLayer
      ..removeLayer labelLayer
    layers.forEach (.layer.setOpacity 1)
currentParty = "winners"
typy =
  * typ: "obce"
    name: 'Obce a magistráty'
  * typ: "mcmo"
    name: 'Městské části, obvody'

currentLayer = null

selectLayer = ->
  layer = dataLayers["#{window.ig.displayedType}-#{currentParty}"]
  if currentLayer
    lastLayer = currentLayer
    map.removeLayer
    setTimeout do
      ->
        map.removeLayer lastLayer.layer
      300

  map.addLayer layer
  currentLayer := {layer}

d3.select mapElement .append \div
  ..attr \class \layer-selector
  ..append \select
    ..on \change ->
      currentParty := @value
      selectLayer!
    ..selectAll \option .data layerDefs .enter!append \option
      ..html (.name)
      ..attr \value (.id)
  ..selectAll \label.item .data typy .enter!append \label
    ..attr \class \item
      ..append \input
        ..attr \type \radio
        ..attr \name \layer
        ..attr \checked (d, i) -> if i == 0 then \checked else void
        ..on \change ->
            window.ig.displayedType := it.typ
            selectLayer!
      ..append \span
        ..html (.name)


selectLayer!
<~ setTimeout _, 50
map.addLayer grid
