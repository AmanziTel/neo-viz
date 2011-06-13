root = exports ? window

root.CanvasUtil =
  centerToEdge: (val, delta) ->
    val - delta/2

  roundRect: (ctx, point, width, height, radius=5, kind='fill') ->
    x = @centerToEdge(point.x, width)
    y = @centerToEdge(point.y, height)
    ctx.beginPath()
    ctx.moveTo(x + radius, y)
    ctx.lineTo(x + width - radius, y)
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
    ctx.lineTo(x + width, y + height - radius)
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
    ctx.lineTo(x + radius, y + height)
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
    ctx.lineTo(x, y + radius)
    ctx.quadraticCurveTo(x, y, x + radius, y)
    ctx.closePath()
    if kind is 'fill'
      ctx.fill()
    else
      ctx.stroke()

  line: (ctx, fromPoint, toPoint, width = 2) ->
    ctx.lineWidth = width
    ctx.beginPath()
    ctx.moveTo fromPoint.x, fromPoint.y
    ctx.lineTo toPoint.x, toPoint.y
    ctx.stroke()

  textSize: (ctx, text) ->
    lineHeight = ctx.measureText(text[0]).height or 20
    width = 0
    count = text.length
    height = count * lineHeight + 20
    for line in text
      width = Math.max ctx.measureText(line).width, width
    {width, height, count, lineHeight }

  drawText: (ctx, text, left, top) ->
    textSize = @textSize(ctx, text)
    for i in [0...textSize.count]
      line = text[i]
      ctx.fillText(line, left, top + i*textSize.lineHeight, 100)

