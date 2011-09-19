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


initContextSubscribers = (eventBroker)->
  eventBroker.subscribe('nodeCountChanged nodeFilterChanged keyFilterChanged', () ->
    enableRefresh(true)
  )

enableRefresh = (enable)->
  console.log "enableRefresh " + enable
  if enable then $('#refresh').show() else $('#refresh').hide()

initFormListeners = (appContext, eventBroker) ->
  $('#node-count').change ->
    appContext.setNodeCount($(this).val())

  $('#node-filter').change ->
    appContext.setNodeFilter($(this).val())

  $('#key-filter').change ->
    appContext.setKeyFilter($(this).val())

  $('#filterForm').submit (e) ->
    e.preventDefault()
    eventBroker.publish('refresh')

$ ->

  populateRelationsFilter = (rels) =>
    console.dir rels
    $('#relationsFilterItems').empty()
    for rel in rels
      $('#relationsFilterItems').append("#{rel.data.rel_type}<br/>")

  enableRefresh(false)
  initContextSubscribers(@eventBroker)
  initFormListeners(@appContext, @eventBroker)