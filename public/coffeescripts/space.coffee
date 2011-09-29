class Space
  constructor: (@sys, @nodeCount) ->
    @nodes = {}
    @rels = {}
    @allNodes = []
    @allRels = []
    @hiddenNodeIds = []
    @hiddenRelIds = []

  addData: (data) ->
    @allNodes = data.nodes
    @allRels = data.rels
    @refresh()

  setHiddenData: (data) ->
    @hiddenNodeIds = data.nodeIds
    @hiddenRelIds = data.relIds
    @refresh()

  refresh: ->
    @clear()
    @addNodes @allNodes
    @addRels @allRels

  clear: ->
    for key, node of @nodes
      @sys.pruneNode(key)
    @nodes = {}
    @rels = {}

  getSelectedNode: ->
    @selectedNode

  setFilter: (filter) ->
    @filter = if filter then new RegExp(filter, 'i') else null

  setNodeCount: (n) ->
    @nodeCount = n

  addNodes: (nodes) ->
    return if nodes.length == 0

    inspect = (node) ->
      name = (for key, value of node.data
        "#{key}:#{value}").join(' ')
      name

    @selectedNode = nodes[0]
    @selectedNode.data.first = true

    filteredNodes = nodes.slice(0)
    filteredNodes = (node for node in filteredNodes when !@hiddenNodeIds.contains(node.id))
    filteredNodes = (node for node in filteredNodes when inspect(node).match(@filter)) if @filter

    return if filteredNodes.length is 0
    return if filteredNodes[0] is @selectedNode and filteredNodes.length is 1

    filteredNodes.unshift(@selectedNode)

    filteredNodes = filteredNodes[0...@nodeCount] if filteredNodes.length > @nodeCount

    for node in filteredNodes
      @sys.addNode(node.id, node.data) unless @nodes[node.id]
      @nodes[node.id] = node

  addRels: (rels) ->

    filteredRels = (rel for rel in rels when !@hiddenRelIds.contains(rel.data._neo_id))
    for rel in filteredRels
      if @nodes[rel.start_node] and @nodes[rel.end_node]
        @sys.addEdge(rel.start_node, rel.end_node, rel.data)
        @rels[rel.id] = rel
  
  node: (id) ->
    @nodes[id]

  rel: (id) ->
    @rels[id]

root = exports ? this
root.Space = Space
