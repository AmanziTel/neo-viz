$ = jQuery

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


initContextListeners = ->
  $("body").bind('nodeCountChanged', () ->
    enableRefresh(true)
  )


enableRefresh = (enable)->
  if enable then $('#refresh').show else $('#refresh').hide

initFormListeners = () ->
  $('#node-count').change ->
    appContext.setNodeCount($(this).val())
  $('#filterForm').submit (e) ->
    e.preventDefault()
    trigger('refresh')

trigger = (eventName) ->
  $("body").trigger(eventName)
  console.log 'triggered ' + eventName

$ ->

  populateRelationsFilter = (rels) =>
    console.dir rels
    $('#relationsFilterItems').empty()
    for rel in rels
      $('#relationsFilterItems').append("#{rel.data.rel_type}<br/>")

  enableRefresh(false)
  initFormListeners()