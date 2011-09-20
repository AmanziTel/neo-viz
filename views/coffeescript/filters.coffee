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

initSubscribers = (appContext, eventBroker) ->
  eventBroker.subscribe('nodeDataChanged', ->
    refreshRelationFilters(appContext)
  )

refreshRelationFilters = (appContext)->
  rels = appContext.getNodeData().rels
  activatedNodeId = appContext.getActivatedNodeId()
  return if (activatedNodeId == null)

  incoming = getIncomingRels(activatedNodeId, rels)
  outgoing = getOutgoingRels(activatedNodeId, rels)

  console.log "Incoming:"
  console.dir incoming
  console.log "Outgoing:"
  console.dir outgoing

  $('#relationsFilterItems').empty()
  for rel in rels
    $('#relationsFilterItems').append("#{rel.data.rel_type}<br/>")

getIncomingRels = (nodeId, rels) ->
  (rel for rel in rels when rel.end_node == nodeId)

getOutgoingRels = (nodeId, rels) ->
  (rel for rel in rels when rel.start_node == nodeId)


$ ->

  initSubscribers(@appContext, @eventBroker)
  initFormListeners(@appContext, @eventBroker)