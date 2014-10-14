window.ig.DataTable = class DataTable
  (@parentElement, @headerFields, @fullData) ->
    window.ig.Events @
    @table = @parentElement.append \table
      ..attr \class \data-table
    @currentSort = {fieldIndex: null direction: 0}
    @currentSearch = new Array @headerFields.length
    @currentData = @fullData.slice!
    @transformedData = @transformData @currentData
    @currentTransformedData = @transformedData.slice!
    @drawHead!
    @prepareContent!
    @drawContent!

  drawHead: ->
    that = this
    @table.append \thead .append \tr
      ..selectAll \th .data @headerFields .enter!append \th
        ..classed \has-filter (.filterable)
        ..append \span
          ..attr \class \name
          ..html (.name)
          ..on \click (d, i) ~>
            if d.sortable
              @sortBy i
        ..append \select
          ..attr \class \filter
          ..selectAll \option .data @~getFilterData .enter!append \option
            ..html ->
              out = it.value
              if it.count
                out += " (#{it.count}x)"
              out
            ..attr \value (.value)
          ..on \change (headerField, index) ->
            value = if @value != headerField.name
              @value
            else
              void
            that.filterValues index, value
            that.emit 'filterChange' {headerField, index, value}

  prepareContent: ->
    @tbody = @table.append \tbody

  drawContent: ->
    @tbody.html ''
    @lines = @tbody.selectAll \tr .data @currentTransformedData
      ..enter!append \tr
    @fields = @lines.selectAll \td .data(-> it) .enter!append \td
      ..html (.value)

  transformData: (input) ->
    input.map (inputLine) ~>
      out = @headerFields.map (headerField) ~>
        out = {}
          ..value = headerField.value inputLine
        out.sortable = switch typeof! headerField.sortable
          | \Function => headerField.sortable inputLine
          | otherwise => out.value
        out
      out.data = inputLine
      out

  sortBy: (fieldIndex) ->
    if fieldIndex != @currentSort.fieldIndex
      @currentSort
        ..fieldIndex = fieldIndex
        ..direction = 1
    else
      @currentSort.direction *= -1
    @sortCurrent!
    @drawContent!

  sortCurrent: ->
    return if @currentSort.fieldIndex is null
    @currentTransformedData.sort (a, b) ~>
      r = if a[@currentSort.fieldIndex].sortable > b[@currentSort.fieldIndex].sortable
        1
      else if a[@currentSort.fieldIndex].sortable < b[@currentSort.fieldIndex].sortable
        -1
      else
        0
      r * @currentSort.direction

  filterValues: (fieldIndex, value) ->
    @currentSearch[fieldIndex] = value
    @currentTransformedData = @transformedData.filter ~>
      for value, index in @currentSearch
        if value != void and it[index].value != value
          return false
      true
    @emit 'data', @currentTransformedData
    @sortCurrent!
    @drawContent!

  getFilterData: (headerField, index) ->
    return [] unless headerField.filterable
    options_assoc = {}
    for line in @transformedData
      value = line[index].value
      options_assoc[value] = options_assoc[value] + 1 || 1
    out = for value, count of options_assoc
      {value, count}
    out.sort (a, b) -> b.count - a.count
    out.unshift {value: headerField.name}
    out
