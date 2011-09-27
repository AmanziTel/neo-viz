describe 'neo4j', ->
  describe 'Graph', ->

    describe 'Node', ->

      graph = null
      node = null

      beforeEach ->
        nodeData = [{"id":0},{"id":1},{"id":2}]
        relData = [{"id":0, "start_node":0, "end_node":1, "data":{"rel_type":"friend"}},
                   {"id":1, "start_node":1, "end_node":2, "data":{"rel_type":"enemy"}},
                   {"id":2, "start_node":2, "end_node":0, "data":{"rel_type":"brother"}},
                   {"id":3, "start_node":0, "end_node":2, "data":{"rel_type":"brother"}}]
        graph = new Graph(nodeData, relData)
        node = graph.load(0)

      it 'has incoming relationships', ->
        expect(node.incoming()[0].type).toEqual("brother")

      it 'has outgoing relationships', ->
        expect(node.outgoing()[0].type).toEqual("friend")

      it 'has incoming relationships of certain type', ->
        expect(node.incoming(["foo"]).length).toEqual(0)
        expect(node.incoming(["brother"]).length).toEqual(1)

      it 'has outgoing relationships of certain type', ->
        expect(node.outgoing(["foo"]).length).toEqual(0)
        expect(node.outgoing(["friend", "brother"]).length).toEqual(2)

    describe 'Connectivity', ->

      graph = null

      beforeEach ->
        nodeData = [{"id":0},{"id":1}]
        relData = [{"id":0, "start_node":0, "end_node":1, "data":{"rel_type":"networks"}}]
        graph = new Graph(nodeData, relData)

      it 'knows two neighbors are connected', ->
        expect(graph.areConnected(graph.load(0), graph.load(1))).toEqual(true)

      it 'only considers active relations', ->
        expect(graph.areConnected(graph.load(0), graph.load(1), [])).toEqual(false)

      it 'knows circular triplet is connected when one relationship is inactive', ->
        # n0-----<-----n2
        #  \-->--n1->--/
        nodeData = [{"id":0},{"id":1},{"id":2}]
        relData = [{"id":0, "start_node":0, "end_node":1, "data":{"rel_type":""}},
                   {"id":1, "start_node":1, "end_node":2, "data":{"rel_type":""}},
                   {"id":2, "start_node":2, "end_node":0, "data":{"rel_type":""}}]
        graph = new Graph(nodeData, relData)

        # deactivate connection between n0 and n1:
        activeRels = graph.relationships[1..2]

        expect(graph.areConnected(graph.load(1), graph.load(0), activeRels)).toEqual(true)

      it 'knows a 6 node mesh is connected when one relationship is inactive', ->
        nodeData = [{"id":0},{"id":1},{"id":2},{"id":3},{"id":4},{"id":5}]
        relData = [{"id":0, "start_node":0, "end_node":1, "data":{"rel_type":""}},
                   {"id":1, "start_node":1, "end_node":2, "data":{"rel_type":""}},
                   {"id":2, "start_node":2, "end_node":3, "data":{"rel_type":""}},
                   {"id":3, "start_node":3, "end_node":0, "data":{"rel_type":""}},
                   {"id":4, "start_node":3, "end_node":4, "data":{"rel_type":""}},
                   {"id":5, "start_node":4, "end_node":5, "data":{"rel_type":""}},
                   {"id":6, "start_node":5, "end_node":0, "data":{"rel_type":""}}]
        graph = new Graph(nodeData, relData)

        # deactivate connection between n0 and n5:
        activeRels = graph.relationships[0..5]
        console.dir activeRels
        expect(graph.areConnected(graph.load(0), graph.load(5), activeRels)).toEqual(true)

