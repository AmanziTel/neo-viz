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
  relsHiddenByUser = activatedNode.incoming(incomingTypesToHide)
  relsHiddenByUser = relsHiddenByUser.concat(activatedNode.outgoing(outgoingTypesToHide))

  hiddenNodeData = buildHiddenNodeData graph, activatedNode, relsHiddenByUser

  appContext.setHiddenNodeData(hiddenNodeData)

buildHiddenNodeData = (graph, activatedNode, relsHiddenByUser) ->

  hiddenNodeData = nodeIds:[], relIds:(rel.id for rel in relsHiddenByUser)

  allRels = graph.relationships
  activeRels = allRels.diff(relsHiddenByUser)
  for rel in activatedNode.both()
    if relsHiddenByUser.contains(rel)
      otherNode = rel.other(activatedNode)

      if (!graph.areConnected(activatedNode, otherNode, activeRels))
        # No connections to otherNode exists, so hide otherNode and its subgraph
        appendHiddenNodeDataForSubGraph(otherNode, activeRels, hiddenNodeData)

  hiddenNodeData

appendHiddenNodeDataForSubGraph = (node, mutableActiveRels, hiddenNodeData) -> #={nodeIds: [], relIds: []}) ->

  hiddenNodeData.nodeIds.push(node.id)
  for rel in node.both()
    if mutableActiveRels.contains(rel)
      hiddenNodeData.relIds.push(rel.id)
      # Remove the relationship already traversed so that
      # next iteration does not traverse "backwards" again
      mutableActiveRels.remove(mutableActiveRels.indexOf(rel))
      other = rel.other(node)
      # Have we already hidden the other node?
      if (!hiddenNodeData.nodeIds.contains(other.id))
        # No, go ahead and hide its subgraph.
        appendHiddenNodeDataForSubGraph(other, mutableActiveRels, hiddenNodeData)


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

root = exports ? this
root.test_buildHiddenNodeData = buildHiddenNodeData # global for unit testing


$ ->

  initSubscribers(@appContext, @eventBroker)
  initFormListeners(@appContext, @eventBroker)
