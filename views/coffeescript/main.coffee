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
        ctx.fillStyle = if node.data.id is 0 then "blue" else "green"
        util.roundRect(ctx, point.x-w/2, point.y-w/2, w, w, 10, 'fill')

        ctx.strokeStyle = 'white'
        ctx.lineWidth = 2
        ctx.font = "14pt Times"
        ctx.strokeText(node.data.text, point.x-w/2+10, point.y, w*2, 'fill')
    
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

  addNode: (node) ->
    @sys.addNode(@id(node), @props(node)) unless @nodes[@id(node)]
    @nodes[@id(node)] = 'yes'
    rels = node['rels']
    for rel in rels
      other_node = rel['other_node']
      unless @nodes[@id(other_node)]
        @sys.addNode(@id(other_node), @props(other_node))
        @sys.addEdge(@id(node), @id(other_node), @props(rel)) 
        @nodes[@id(other_node)] = 'no'
  
  id: (node) ->
    node['_neo_id']

  props: (node) ->
    {
      id: @id(node),
      text: "id: #{@id(node)}"
    }



$ ->
  sys = arbor.ParticleSystem(1000, 600, 0.5) # create the system with sensible repulsion/stiffness/friction
  sys.parameters({gravity:true}) # use center-gravity to make the graph settle nicely (ymmv)
  sys.renderer = Renderer("#viewport") # our newly created renderer will have its .init() method called shortly by sys...

  data = {
    "_neo_id":0,
    "gemFile": "source :rubygems\ngem 'jruby-openssl'\ngem 'neo4j' #, :path : '/home/andreas/projects/neo4j'\ngem 'birdies-backend', :git : 'git://github.com/andreasronge/birdies-backend.git'   #:path : '/home/andreas/projects/birdies-backend'\n",
    "rels": [
      {
        "_neo_id":4,
        "direction":"outgoing",
        "other_node":{"_count__all__classname":53, "_neo_id":5},
        "rel_type":"BirdiesBackend::User"},
      {
        "_neo_id":0,
        "direction":"outgoing",
        "other_node":{"_count__all__classname":148, "_neo_id":1},
        "rel_type":"Neo4j::Rails::Model"},
      {
        "_neo_id":1,
        "direction":"outgoing",
        "other_node":{"_count__all__classname":10, "_neo_id":2},
        "rel_type":"BirdiesBackend::Link"},
      {
        "_neo_id":5,
        "direction":"outgoing",
        "other_node":{"_count__all__classname":1, "_neo_id":6},
        "rel_type":"BirdiesBackend::Tweeters"},
      {
        "_neo_id":3,
        "direction":"outgoing",
        "other_node":{"_count__all__classname":65, "_neo_id":4},
        "rel_type":"BirdiesBackend::Tweet"},
      {
        "_neo_id":2,
        "direction":"outgoing",
        "other_node":{"_count__all__classname":19, "_neo_id":3},
        "rel_type":"BirdiesBackend::Tag"}]}


  space = new Space(sys)
  space.addNode(data)
  

