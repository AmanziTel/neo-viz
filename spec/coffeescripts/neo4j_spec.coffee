describe 'neo4j', ->
  describe 'Graph', ->

    it 'is built from json data', ->
      nodeData = [{"id":0},{"id":1}]
      relData = [{"id":0, "start_node":0, "end_node":1, "data":{"rel_type":"networks"}}]
      graph = new Graph(nodeData, relData)

      expect(graph.nodes.length).toEqual 2
      expect(graph.relationships.length).toEqual 1

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
