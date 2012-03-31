data = {
  "nodes": [
    {"data": { "_neo_id":0, "gemFile": "source :rubygems\ngem"}, "id":0 },
    {"data":{"_count__all__classname":53, "_neo_id":5}, "id":5},
    {"data":{"_count__all__classname":148, "_neo_id":1}, "id":1},
    {"data":{"_count__all__classname":10, "_neo_id":2}, "id":2},
    {"data":{"_count__all__classname":1, "_neo_id":6}, "id":6},
    {"data":{"_count__all__classname":65, "_neo_id":4}, "id":4},
    {"data":{"_count__all__classname":19, "_neo_id":3}, "id":3}
  ],
  "rels": [
    {
      "data":{"_neo_id":4, "rel_type":"BirdiesBackend::User"},
      "end_node":5,
      "id":4,
      "start_node":0},
    {
      "data":{"_neo_id":0, "rel_type":"Neo4j::Rails::Model"},
      "end_node":1,
      "id":0,
      "start_node":0},
    {
      "data":{"_neo_id":1, "rel_type":"BirdiesBackend::Link"},
      "end_node":2,
      "id":1,
      "start_node":0},
    {
      "data":{"_neo_id":5, "rel_type":"BirdiesBackend::Tweeters"},
      "end_node":6,
      "id":5,
      "start_node":0},
    {
      "data":{"_neo_id":3, "rel_type":"BirdiesBackend::Tweet"},
      "end_node":4,
      "id":3,
      "start_node":0},
    {
      "data":{"_neo_id":2, "rel_type":"BirdiesBackend::Tag"},
      "end_node":3,
      "id":2,
      "start_node":0}
  ]
}


