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

  incoming = getIncomingRelTypes(activatedNodeId, rels)
  outgoing = getOutgoingRelTypes(activatedNodeId, rels)
  allRelTypes = incoming.union(outgoing).sort()

  $('#relationsFilterTable').empty()

  for relType in allRelTypes
    hasIncoming = (rel for rel in incoming when relType == rel).length > 0
    hasOutgoing = (rel for rel in outgoing when relType == rel).length > 0
    inCheckboxHtml = buildCheckboxHtml relType, "in", hasIncoming
    outCheckboxHtml = buildCheckboxHtml relType, "out", hasOutgoing

    $('#relationsFilterTable').append("<tr><td>#{relType} #{inCheckboxHtml}</td><td>#{outCheckboxHtml}</td></tr>")

  $("#relationsFilterTable input").change ->
    updateHiddenNodeData(appContext)

updateHiddenNodeData = (appContext) ->
  relsToHide = ({ type:"#{checkbox.name}", direction:"#{checkbox.value}"} for checkbox in $("#relationsFilterTable input") when (!checkbox.disabled && !checkbox.checked))

  incomingTypesToHide = (rel.type for rel in relsToHide when rel.direction == "in")
  outgoingTypesToHide = (rel.type for rel in relsToHide when rel.direction == "out")

  graph = appContext.getGraph()
  #console.dir graph

  activatedNode = graph.load(appContext.getActivatedNodeId())

  hiddenRels = activatedNode.incoming(incomingTypesToHide)
  hiddenRels = hiddenRels.concat(activatedNode.outgoing(outgoingTypesToHide))

  allRels = graph.relationships
  activeRels = allRels.diff(hiddenRels)
  for rel in activatedNode.both()
    if hiddenRels.contains(rel)
      hideRel(rel, appContext)
      otherNode = rel.other(activatedNode)

      # (here we could use memoization to improve performance: return if (isHidden(otherNode)))
      if (!graph.areConnected(activatedNode, otherNode, activeRels))
        # No connections to otherNode exists, so hide otherNode and its subgraph
        hideSubGraph(otherNode, activeRels)

hideRel = (rel, appContext) ->
  console.log "hiding rel:"
  console.dir rel
  # TODO

hideSubGraph = (startNode, allowedRels) ->
  console.log "hiding subgraph starting on node:"
  console.dir startNode
  # TODO

buildCheckboxHtml = (relType, value, enabled) ->
  html = "<input type='checkbox' name=\"#{relType}\" value='#{value}'"
  html += " checked='true'" if enabled
  html += " disabled='disabled'" if !enabled
  html += " />"
  html += "<del>" if !enabled
  html += value
  html += "</del>" if !enabled
  html

getIncomingRelTypes = (nodeId, rels) ->
  result = (rel.data.rel_type for rel in rels when rel.end_node == nodeId)
  result.unique()

getOutgoingRelTypes = (nodeId, rels) ->
  result = (rel.data.rel_type for rel in rels when rel.start_node == nodeId)
  result.unique()

$ ->

  initSubscribers(@appContext, @eventBroker)
  initFormListeners(@appContext, @eventBroker)
