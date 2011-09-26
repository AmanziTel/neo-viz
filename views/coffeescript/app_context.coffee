$ = jQuery

class AppContext

  constructor: (@eventBroker)->
    @nodeFilter = ''
    @keyFilter = ''
    @nodeData = null
    @nodeCount = 10
    @activatedNodeId = null

  setNodeCount: (n) ->
    if (@nodeCount != n)
      @nodeCount = n
      @publish("nodeCountChanged")

  getNodeCount: () ->
    @nodeCount

  setKeyFilter: (keyFilter) ->
    if (@keyFilter != keyFilter)
      @keyFilter = keyFilter
      @publish("keyFilterChanged")

  getKeyFilter: ->
    @keyFilter

  setNodeFilter: (filter) ->
    if (@nodeFilter != filter)
      @nodeFilter = filter
      @publish("nodeFilterChanged")

  getNodeFilter: ->
    @nodeFilter

  setActivatedNodeId: (nodeId, suppressChangedEvent=false) ->
    if (@activatedNodeId != nodeId)
      @activatedNodeId = nodeId
      if (!suppressChangedEvent)
        @publish("activatedNodeIdChanged")

  getActivatedNodeId: ->
    @activatedNodeId

  # I.e. nodeData.nodes, nodeData.rels
  setNodeData: (nodeData) ->
    if (@nodeData != nodeData)
      @nodeData = nodeData
      @graph = new Graph(nodeData.nodes, nodeData.rels)
      console.log "Graph:"
      console.dir @graph
      @publish("nodeDataChanged")

  getNodeData: ->
    @nodeData

  getGraph: ->
    @graph

  # I.e. hiddenNodeData.nodeIds, hiddenNodeData.relIds
  setHiddenNodeData: (hiddenNodeData) ->
    if (@hiddenNodeData != hiddenNodeData)
      @hiddenNodeData = hiddenNodeData
      console.log "hiddenNodeData:"
      console.dir @hiddenNodeData
      @publish("hiddenNodeDataChanged")

  getHiddenNodeData: ->
    @hiddenNodeData

  clearHiddenNodeData: ->
    @hiddenNodeData = {nodeIds:[], relIds:[]}
    @publish("hiddenNodeDataChanged")

  # TODO: How do we make this a private method?
  publish: (eventName) ->
    @eventBroker.publish(eventName)

$ ->
  root = exports ? this
  root.appContext = new AppContext(root.eventBroker)

