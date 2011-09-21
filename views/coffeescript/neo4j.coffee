class Graph

  constructor: (nodeDatas, relDatas) ->
    @nodes = []
    @relationships = []
    for nodeData in data.nodes
      node = new Node(nodeData.id)
      @nodes.push(node)
      for relData in data.rels
        if relData.end_node == node.id || relData.start_node == node.id
          rel = new Relationship(relData.id, relData.data.rel_type, relData.start_node, relData.end_node)
          @relationships.push(rel)
          if relData.end_node == node.id then node.addIncoming(rel) else node.addOutgoing(rel)

  nodes: ->
    @nodes

  relationships: ->
    @relationships

  load: (nodeId) ->
    node for node in @nodes when node.id == nodeId
    return node

class Node

  constructor: (@id) ->
    @incoming = []
    @outgoing = []

  addIncoming: (relationShip) ->
    @incoming.push(relationShip)

  addOutgoing: (relationShip) ->
    @outgoing.push(relationShip)

  incoming: (types) ->
    (rel for rel in @incoming when types.contains(rel.type))

  outgoing: (types) ->
    (rel for rel in @outgoing when types.contains(rel.type))

  both: (type=null) ->
    @incoming.concat(@outgoing) if !type
    # todo
    throw "not implemented"


class Relationship

  constructor: (@id, @type, @start_node, @end_node) ->

  other: (node) ->
    throw "not implemented"


root = exports ? this
root.Graph = Graph

