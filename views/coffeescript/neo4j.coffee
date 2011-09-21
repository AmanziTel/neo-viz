class Graph

  constructor: (nodeDatas, relDatas) ->
    @nodes = []
    @relationships = []

    for nodeData in nodeDatas
      node = new Node(nodeData.id)
      @nodes.push(node)
      for relData in relDatas
        if relData.end_node == node.id || relData.start_node == node.id
          # TODO we should add the nodes, not the node ids, to the relationship
          rel = new Relationship(relData.id, relData.data.rel_type, relData.start_node, relData.end_node)
          @relationships.push(rel)
          if relData.end_node == node.id then node.addIncoming(rel) else node.addOutgoing(rel)

  load: (nodeId) ->
    for node in @nodes
      return node if node.id == nodeId

    throw "no such node in graph: " + nodeId if !node

  # TODO move to Node (?)
  areConnected: (nodeA, nodeB, allowedRels) ->
    for rel in nodeA.both()
      if allowedRels.contains(rel)
        otherNode = rel.other(nodeA)
        if otherNode == nodeB
          return true
        return @areConnected(otherNode, nodeB)
    return false

class Node

  constructor: (@id) ->
    @ins = []
    @outs = []

  addIncoming: (relationShip) ->
    @ins.push(relationShip)

  addOutgoing: (relationShip) ->
    @outs.push(relationShip)

  incoming: (types) ->
    (rel for rel in @ins when types.contains(rel.type))

  outgoing: (types) ->
    (rel for rel in @outs when types.contains(rel.type))

  both: (types) ->
    return @ins.concat(@outs) if !types

    @incoming(types).concat(@outgoing(types))

class Relationship

  constructor: (@id, @type, @start_node, @end_node) ->

  other: (node) ->
    return @start_node if @end_node == node
    return @end_node

root = exports ? this
root.Graph = Graph

