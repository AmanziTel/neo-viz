$ = jQuery

Renderer = ->
  keyFilter = null

  init: (system) ->

  defaultView: (data) ->
    text = []
    usedKeys = {first: true} 
    if keyFilter?.length > 0
      for regex in keyFilter
        for key, value of data
          if key.match(regex)
            text.push "#{value} (#{key})" unless usedKeys[key]
            usedKeys[key] = true
    else
      for key, value of data
        text.push "#{value} (#{key})" unless key is 'first'
      text = text[0..10]
    line[0..28] for line in text


class Filters

  setFilter: (filter) ->
    @filter = if filter then new RegExp(filter, 'i') else null

  setNodesToShow: (n) ->
    @nodesToShow = n

  setKeyFilter: (keyFilterString) ->
    if keyFilterString?.trim() is ''
      keyFilter = null
    else
      string = "_neo_id, #{keyFilterString}"
      keyFilter = (new RegExp(key.trim()) for key in string.split(','))


initFormListeners= (space, renderer, getData) ->
  $('#node-count').change ->
    space.setNodesToShow $(this).val()
  $('#node-filter').change ->
    space.setFilter $(this).val()
  $('#key-filter').change ->
    renderer.setKeyFilter $(this).val()
  $('form').submit  (e) ->
    e.preventDefault()
    console.log 'submit'
    getData space.getSelectedNode().id

$ ->

  populateRelationsFilter = (rels) =>
    console.dir rels
    $('#relationsFilterItems').empty()
    for rel in rels
      $('#relationsFilterItems').append("#{rel.data.rel_type}<br/>")

  initFormListeners(TODO)