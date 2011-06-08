$ = jQuery

Renderer = (canvas) ->
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
      # redraw will be called repeatedly during the run whenever the node positions
      # change. the new positions for the nodes can be accessed by looking at the
      # .p attribute of a given node. however the p.x & p.y values are in the coordinates
      # of the particle system rather than the screen. you can either map them to
      # the screen yourself, or use the convenience iterators .eachNode (and .eachEdge)
      # which allow you to step through the actual node objects but also pass an
      # x,y point in the screen's coordinate system
      # 
      ctx.fillStyle = 'white'
      ctx.fillRect 0, 0, canvas.width, canvas.height
      
      particleSystem.eachEdge (edge, pt1, pt2) ->
        # edge: {source:Node, target:Node, length:#, data:{}}
        # pt1:  {x:#, y:#}  source position in screen coords
        # pt2:  {x:#, y:#}  target position in screen coords

        # draw a line from pt1 to pt2
        ctx.strokeStyle = 'rgba(0,0,0, .333)'
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(pt1.x, pt1.y)
        ctx.lineTo(pt2.x, pt2.y)
        ctx.stroke()

      particleSystem.eachNode (node, pt) ->
        # node: {mass:#, p:{x,y}, name:"", data:{}}
        # pt:   {x:#, y:#}  node position in screen coords
        
        # draw a rectangle centered at pt
        w = 50
        ctx.beginPath();
        ctx.fillStyle = if node.data.id is 0 then "blue" else "green"
        ctx.arc(pt.x, pt.y, w, 0, Math.PI*2)
        ctx.fill()

        ctx.strokeStyle = 'white'
        ctx.lineWidth = 2
        ctx.font = "14pt Arial"
        ctx.strokeText(node.data.text, pt.x-w+10, pt.y, w*2)
    
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
  

