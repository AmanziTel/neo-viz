

window.CanvasUtil =
  roundRect: (ctx, x, y, width, height, radius=5, kind='stroke') ->
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
    if kind is 'stroke'
      ctx.stroke()
    else
      ctx.fill()

  line: (ctx, fromPoint, toPoint, width = 2) ->
    ctx.lineWidth = width
    ctx.beginPath()
    ctx.moveTo fromPoint.x, fromPoint.y
    ctx.lineTo toPoint.x, toPoint.y
    ctx.stroke()
