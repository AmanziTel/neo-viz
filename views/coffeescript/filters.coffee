$ = jQuery

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

  initFormListeners(@appContext, @eventBroker)