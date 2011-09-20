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
  for relType in incoming
    $('#relationsFilterItems').append("#{rel.data.rel_type}<br/>")

getIncomingRels = (nodeId, rels) ->
  result = (rel.data.rel_type for rel in rels when rel.end_node == nodeId)
  result.unique()

getOutgoingRels = (nodeId, rels) ->
  result = (rel.data.rel_type for rel in rels when rel.start_node == nodeId)
  result.unique()

$ ->

  initSubscribers(@appContext, @eventBroker)
  initFormListeners(@appContext, @eventBroker)