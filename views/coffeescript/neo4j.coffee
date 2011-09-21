class Graph

  constructor: (nodeDatas, relDatas) ->
    @nodes = []
    @nodeHash = {}
    @relationships = []

    for nodeData in nodeDatas
      node = new Node(nodeData.id)
      @nodeHash[node.id] = node
      @nodes.push(node)

    for relData in relDatas
      start_node = @nodeHash[relData.start_node]
      end_node = @nodeHash[relData.end_node]
      rel = new Relationship(relData.id, relData.data.rel_type, start_node, end_node)
      @relationships.push(rel)
      start_node.addOutgoing(rel)
      end_node.addIncoming(rel)


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
        else
          # TODO hmm we get inifinte loop since we will navigate back and
          # forth between nodeA-nodeB rel. Must remember which rels
          # already have traversed
          return @areConnected(otherNode, nodeB, allowedRels)
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

