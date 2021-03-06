$ = jQuery

initFormListeners = (appContext, eventBroker) ->
  $('#node-count').change ->
    appContext.setNodeCount($(this).val())
    eventBroker.publish('refresh')

  $('#node-filter').change ->
    appContext.setNodeFilter($(this).val())
    eventBroker.publish('refresh')

  $('#key-filter').change ->
    appContext.setKeyFilter($(this).val())
    eventBroker.publish('refresh')

initSubscribers = (appContext, eventBroker) ->
  eventBroker.subscribe('nodeDataChanged', ->
    refreshRelationFilters(appContext)
  )

refreshRelationFilters = (appContext)->
  activatedNodeId = appContext.getActivatedNodeId()
  return if (activatedNodeId == null)

  graph = appContext.getGraph()
  activatedNode = graph.load(activatedNodeId)
  # Event timing issue: when reloading data we have not
  # set the new activatedNodeId yet so we might try to fetch non-existent node
  # here.
  return if (activatedNode == null)

  incomingTypes = (rel.type for rel in activatedNode.incoming()).unique()
  outgoingTypes = (rel.type for rel in activatedNode.outgoing()).unique()
  allRelTypes = incomingTypes.union(outgoingTypes).sort()

  $('#relationsFilterTable').empty()

  for relType in allRelTypes
    hasIncoming = incomingTypes.contains(relType)
    hasOutgoing = outgoingTypes.contains(relType)
    inCheckboxHtml = buildCheckboxHtml relType, "in", hasIncoming
    outCheckboxHtml = buildCheckboxHtml relType, "out", hasOutgoing

    $('#relationsFilterTable').append("<tr><td>#{relType} #{inCheckboxHtml}</td><td>#{outCheckboxHtml}</td></tr>")

  $("#relationsFilterTable input").change ->
    updateHiddenNodeData(appContext, graph, activatedNode)

updateHiddenNodeData = (appContext, graph, activatedNode) ->
  relsToHide = ({ type:"#{checkbox.name}", direction:"#{checkbox.value}"} for checkbox in $("#relationsFilterTable input") when (!checkbox.disabled && !checkbox.checked))

  incomingTypesToHide = (rel.type for rel in relsToHide when rel.direction == "in")
  outgoingTypesToHide = (rel.type for rel in relsToHide when rel.direction == "out")

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
        #console.log "node " + activatedNode.id + " and " + otherNode.id + " are not connected"
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


root = exports ? this
root.test_buildHiddenNodeData = buildHiddenNodeData # global for unit testing


$ ->

  initSubscribers(@appContext, @eventBroker)
  initFormListeners(@appContext, @eventBroker)
