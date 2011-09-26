describe 'filters', ->

    it 'can build hiddenNodeData for circular subgraph hidden by user', ->
      # n0--->---n1-----<-----n3
      #           \-->--n2->--/
      nodeData = [{"id":0},{"id":1},{"id":2},{"id":3}]
      relData = [{"id":0, "start_node":0, "end_node":1, "data":{"rel_type":""}},
                 {"id":1, "start_node":1, "end_node":2, "data":{"rel_type":""}},
                 {"id":2, "start_node":2, "end_node":3, "data":{"rel_type":""}}
                 {"id":2, "start_node":3, "end_node":1, "data":{"rel_type":""}}]
      graph = new Graph(nodeData, relData)

      activatedNode = graph.load(0)
      relsHiddenByUser = graph.relationships[0..0]
      hiddenNodeData =  test_buildHiddenNodeData(graph, activatedNode, relsHiddenByUser)

      expect(hiddenNodeData.nodeIds.length).toEqual(3)
      expect(hiddenNodeData.relIds.length).toEqual(4) #4: rels hidden by user should be included

