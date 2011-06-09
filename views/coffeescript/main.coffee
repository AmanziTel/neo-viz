$ = jQuery

Renderer = (canvas) ->
  util = CanvasUtil
  canvas = $(canvas).get(0)
  ctx = canvas.getContext '2d'
  particleSystem = null

  that = 
    init: (system) ->
      particleSystem = system
      particleSystem.screenSize(canvas.width, canvas.height)
      particleSystem.screenPadding(80)
      that.initMouseHandling()
    
    redraw: ->
      ctx.fillStyle = 'white'
      ctx.fillRect 0, 0, canvas.width, canvas.height
      
      particleSystem.eachEdge (edge, fromPoint, toPoint) ->
        ctx.strokeStyle = 'rgba(0,0,0, .333)'
        util.line ctx, fromPoint, toPoint

      particleSystem.eachNode (node, point) ->
        w = 80
        ctx.fillStyle = if node.name is 0 then "blue" else "green"
        util.roundRect(ctx, point.x-w/2, point.y-w/2, w, w, 10, 'fill')

        ctx.strokeStyle = 'white'
        ctx.lineWidth = 2
        ctx.font = "12pt Times"
        ctx.strokeText(node.data, point.x-w/2+10, point.y, w*2)
    
    initMouseHandling: ->
      # no-nonsense drag and drop (thanks springy.js)
      dragged = null;

      # set up a handler object that will initially listen for mousedowns then
      # for moves and mouseups while dragging
      handler =
        clicked: (e) ->
          pos = $(canvas).offset()
          _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
          dragged = particleSystem.nearest(_mouseP)

          # while we're dragging, don't let physics move the node
          dragged.node.fixed = true if (dragged && dragged.node isnt null)

          $(canvas).bind('mousemove', handler.dragged)
          $(window).bind('mouseup', handler.dropped)

          false

        dragged: (e) -> 
          pos = $(canvas).offset();
          s = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
          
          if (dragged && dragged.node isnt null)
            dragged.node.p = particleSystem.fromScreen(s) 

          false

        dropped: (e) ->
          return if (dragged is null || dragged.node is undefined)
          dragged.node.fixed = false if (dragged.node isnt null)
          dragged.node.tempMass = 1000
          dragged = null
          $(canvas).unbind('mousemove', handler.dragged)
          $(window).unbind('mouseup', handler.dropped)
          _mouseP = null
          false
      
      # start listening
      $(canvas).mousedown(handler.clicked)
  that


class Space
  constructor: (@sys) ->
    @nodes = {}
    @rels = {}
    @view = (data) ->
      for key, value of data
        console.log "#{key}: #{value}"
        "#{key}: #{value}"

  setView: (@view) ->

  addData: (data) ->
    @addNodes data.nodes
    @addRels data.rels

  addNodes: (nodes) ->
    for node in nodes
      @sys.addNode(node.id, @props(node)) unless @nodes[node.id]
      @nodes[node.id] = node
  addRels: (rels) ->
    for rel in rels
      @sys.addEdge(rel.start_node, rel.end_node, @props(rel)) unless @rels[rel.id]
      @rels[rel.id] = rel
  
  props: (obj) ->
    @view(obj.data)



$ ->
  sys = arbor.ParticleSystem(1000, 600, 0.5) # create the system with sensible repulsion/stiffness/friction
  sys.parameters({gravity:true}) # use center-gravity to make the graph settle nicely (ymmv)
  sys.renderer = Renderer("#viewport") # our newly created renderer will have its .init() method called shortly by sys...

  data = {
    "nodes": [
      {"data": {
        "_neo_id":0,
        "gemFile": "source :rubygems\ngem",
        "id":0
      }},
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

  space = new Space(sys)
  space.addData(data)
  

