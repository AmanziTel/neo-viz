class Graph

  constructor: (nodeDatas, relDatas) ->
    @nodes = []
    @relationships = []

    for nodeData in nodeDatas
      node = new Node(nodeData.id)
      @nodes.push(node)
      for relData in relDatas
        if relData.end_node == node.id || relData.start_node == node.id
          rel = new Relationship(relData.id, relData.data.rel_type, relData.start_node, relData.end_node)
          @relationships.push(rel)
          if relData.end_node == node.id then node.addIncoming(rel) else node.addOutgoing(rel)

  load: (nodeId) ->
    node for node in @nodes when node.id == nodeId
    return node

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
    throw "not implemented"


root = exports ? this
root.Graph = Graph

