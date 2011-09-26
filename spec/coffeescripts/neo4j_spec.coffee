describe 'neo4j', ->
  describe 'Graph', ->

    graph = null

    beforeEach ->
      nodeDatas = [{"id":0,"data":{"_neo_id":0}},{"id":6,"data":{"_neo_id":6}}]
      relDatas = [{"id":8, "start_node":0, "end_node":6, "data":{"rel_type":"networks"}}]
      graph = new Graph(nodeDatas, relDatas)


    it 'is built from json data', ->
      expect(graph.nodes.length).toEqual 2
      expect(graph.relationships.length).toEqual 1

