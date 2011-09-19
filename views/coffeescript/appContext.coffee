$ = jQuery

class AppContext

  constructor: (eventBroker)->
    @eventBroker = eventBroker
    @nodeFilter = ''
    @keyFilter = ''
    @nodeData = null
    @nodeCount = 10
    @selectedNode = null

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

  setSelectedNode: (node) ->
    if (@selectedNode != node)
      @selectedNode = node
      @publish("selectedNodeChanged")

  getSelectedNode: ->
    @selectedNode

  setNodeData: (nodeData) ->
    if (@nodeData != nodeData)
      @nodeData = nodeData
      @publish("nodeDataChanged")

  getNodeData: ->
    @nodeData


  # TODO: How do we make this a private method?
  publish: (eventName) ->
    @eventBroker.publish(eventName)

$ ->
  root = exports ? this
  root.appContext = new AppContext(root.eventBroker)

