describe 'neo4j', ->
  describe 'Graph', ->
    it 'builds the graph from json data', ->
      nodeDatas = [{"id":0,"data":{"_neo_id":0}},{"id":6,"data":{"_neo_id":6}}]
      relDatas = [{"id":8, "start_node":0, "end_node":6, "data":{"rel_type":"networks"}}]

      graph = new Graph(nodeDatas, relDatas)

      expect(graph.load(0).outgoing().length).toEqual 1
      expect(graph.load(6).incoming().length).toEqual 1

