bezKandidatky =
  "Petkovy"
  "Zadní Střítež"
  "Srní"
  "Úherce"
  "Víska u Jevíčka"
  "Slavníč"
  "Růžená"
percentage = -> "#{window.ig.utils.formatNumber it * 100}&nbsp;%"

parties =
  * id: \ANO
  * id: \ODS
  * id: \CSSD
  * id: \KSCM
  * id: \KDU
  * id: \SZ
  * id: \CP
  * id: \TOP
  * id: \ostatni

partyNames =
  "ANO 2011"
  "ODS"
  "ČSSD"
  "KSČM"
  "KDU-ČSL"
  "Zelení"
  "Piráti"
  "TOP 09"
  "Ostatní"

partyColors =
  \#5434A3
  \#1C76F0
  \#FEA201
  \#F40000
  \#FEE300
  \#0FB103
  \#504E4F
  \#B560F3
  \#aaa

lineHeight = 33px

window.ig.InfoBar = class InfoBar
  (parentElement) ->
    @init parentElement

  displayData: ({nazev, okrsek_nazev}:data) ->
    obec_volicu = data["#{window.ig.displayedType}_celkem"]
    @nazev.text "#{nazev}" + if okrsek_nazev && obec_volicu then " okrsek #{okrsek_nazev}" else ''
    for party in parties
      party.votes = data["#{window.ig.displayedType}_#{party.id}"]
      if party.votes == -1
        party.votes = 0
        party.nesestavila = yes
      else
        party.nesestavila = no
      party.percent = party.votes / obec_volicu
    parties.sort (a, b) -> b.votes - a.votes
    for party, index in parties => party.index = index

    @container.classed \noData !obec_volicu
    if !obec_volicu
      if nazev in bezKandidatky
        @helpText.html "Obec nesestavila kandidátku"
      else if data.obce_celkem || data.mcmo_celkem
        @helpText.html "V obci se do zastupitelstva městské části nevolilo "
      else
        @helpText.html "Vojenský újezd"
    else
      @helpText.html "Detailní výsledky zobrazíte kliknutím na okrsek v mapě"
    @strany.style \top -> "#{it.index * lineHeight}px"
    @strany.classed \nesestavila (.nesestavila)
    @stranyPercent.html ->
      if it.nesestavila
        "Nesestavila kandidátku"
      else
        "#{percentage it.percent}"
    @stranyHlasu.html -> "#{it.votes} hl."
    @stranyBar.style \width -> "#{it.percent * 270}px"


  init: (parentElement) ->
    @container = parentElement.append \div
      ..attr \class "infoBar noData"
    @nazev = @container.append \h2
      ..text "Mapa výsledků"
    @helpText = @container.append \span
      ..attr \class \clickInvite
      ..text "Výsledky voleb v okrsku zobrazíte najetím na okrsek v mapě"
    stranyCont = @container.append \ul
      ..attr \class \strany-cont

    @strany = stranyCont.selectAll \li .data parties .enter!append \li
      ..attr \class \strana
      ..style \top (d, i) -> "#{i * lineHeight}px"
      ..append \span
        ..attr \class \nazev
        ..html (d, i) -> partyNames[i]
      ..append \span
        ..attr \class \hlasu
        ..append \span
          ..attr \class \absolute
        ..append \span
          ..attr \class \relative
      ..append \div
        ..attr \class \bar
        ..style \background-color (d, i) -> partyColors[i]
      ..append \div
        ..attr \class \kost
        ..style \background-color (d, i) -> partyColors[i]
    @stranyPercent = @strany.selectAll \.relative
    @stranyHlasu = @strany.selectAll \.absolute
    @stranyBar = @strany.selectAll \.bar
