$ = jQuery

Renderer = (canvas, handler) ->
  util = CanvasUtil
  canvas = $(canvas).get(0)
  ctx = canvas.getContext '2d'
  particleSystem = null
  objectHandler = handler
  view = null
  keyFilter = null

  init: (system) ->
    particleSystem = system
    particleSystem.screenSize(canvas.width, canvas.height)
    particleSystem.screenPadding(80)
    @initMouseHandling()
    view = @defaultView

  defaultView: (data) ->
    # If keyfilter is active then show all properties ("keys") passing the filter.
    # Otherwise only show 3 props but indicate how many there really are.
    text = []
    usedKeys = {first: true}
    if keyFilter?.length > 0
      for regex in keyFilter
        for key, value of data
          if key.match(regex)
            text.push "#{value} (#{key})" unless usedKeys[key]
            usedKeys[key] = true
    else
      for key, value of data
        text.push "#{value} (#{key})" unless key is 'first'

      nbrProps = text.length - 1 # -1 since we don't count _neo_id
      nbrPropsToShow = 3
      addEllipsis = text.length > nbrPropsToShow
      text = text[0..nbrPropsToShow]
      text.push "(and #{nbrProps-nbrPropsToShow} more)" if addEllipsis

    line[0..40] for line in text

  setKeyFilter: (keyFilterString) ->
    if keyFilterString?.trim() is ''
      keyFilter = null
    else
      string = "_neo_id, #{keyFilterString}"
      keyFilter = (new RegExp(key.trim()) for key in string.split(','))

  redraw: ->
    ctx.fillStyle = 'white'
    ctx.fillRect 0, 0, canvas.width, canvas.height

    particleSystem.eachNode (node, point) =>
      @drawNode(node, point)

    particleSystem.eachEdge (edge, fromPoint, toPoint) =>
      @drawEdge(edge, fromPoint, toPoint)

  drawNode: (node, point) ->
      MARGIN = 10

      nodeView = view node.data
      ctx.font = "10pt Times"
      {width, height, count} = util.textSize ctx, nodeView
      width = Math.max(width, 160)
      height = Math.max(height, 60)

      color = if node.data.first then "blue" else "green"
      util.roundRect(ctx, point, width+(MARGIN*2), height, color, 10)

      ctx.fillStyle ='white'
      x = util.centerToEdge(point.x, width)
      y = util.centerToEdge(point.y, height) + MARGIN*2
      util.drawText(ctx, nodeView, x, y)


  drawEdge: (edge, fromPoint, toPoint) ->
    ctx.strokeStyle = 'rgba(0,0,0, .333)'
    util.line ctx, fromPoint, toPoint

    x = (fromPoint.x + toPoint.x) / 2 - 30
    y = (fromPoint.y + toPoint.y) / 2
    ctx.font = "10pt Times"
    ctx.fillStyle ='red'
    util.drawText(ctx, [edge.data.rel_type], x, y)

  initMouseHandling: ->
    handler =
      dblclick: (e) ->
        pos = $(canvas).offset()
        _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
        object = particleSystem.nearest(_mouseP)
        objectHandler.activated object.node.name
        false

      click: (e) ->
        pos = $(canvas).offset()
        _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
        object = particleSystem.nearest(_mouseP)
        objectHandler.selected object.node.name
        false
    $(canvas)
      .dblclick(handler.dblclick)
      .click(handler.click)


root = exports ? this
root.Renderer = Renderer

