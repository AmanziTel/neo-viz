/* DO NOT MODIFY. This file was compiled Wed, 08 Jun 2011 07:56:50 GMT from
 * /Users/andersjanmyr/Projects/neo-viz/app/coffeescripts/main.coffee
 */

(function() {
  var $, Renderer;
  $ = jQuery;
  Renderer = function(canvas) {
    var ctx, particleSystem, that;
    canvas = $(canvas).get(0);
    ctx = canvas.getContext('2d');
    particleSystem = null;
    that = {
      init: function(system) {
        particleSystem = system;
        particleSystem.screenSize(canvas.width, canvas.height);
        particleSystem.screenPadding(80);
        return that.initMouseHandling();
      },
      redraw: function() {
        ctx.fillStyle = 'white';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        particleSystem.eachEdge(function(edge, pt1, pt2) {
          ctx.strokeStyle = 'rgba(0,0,0, .333)';
          ctx.lineWidth = 1;
          ctx.beginPath();
          ctx.moveTo(pt1.x, pt1.y);
          ctx.lineTo(pt2.x, pt2.y);
          return ctx.stroke();
        });
        return particleSystem.eachNode(function(node, pt) {
          var w;
          w = 10;
          ctx.fillStyle = node.data.alone ? "orange" : "black";
          return ctx.fillRect(pt.x - w / 2, pt.y - w / 2, w, w);
        });
      },
      initMouseHandling: function() {
        var dragged, handler;
        dragged = null;
        handler = {
          clicked: function(e) {
            var pos, _mouseP;
            pos = $(canvas).offset();
            _mouseP = arbor.Point(e.pageX - pos.left, e.pageY - pos.top);
            dragged = particleSystem.nearest(_mouseP);
            if (dragged && dragged.node !== null) {
              dragged.node.fixed = true;
            }
            $(canvas).bind('mousemove', handler.dragged);
            $(window).bind('mouseup', handler.dropped);
            return false;
          },
          dragged: function(e) {
            var pos, s;
            pos = $(canvas).offset();
            s = arbor.Point(e.pageX - pos.left, e.pageY - pos.top);
            if (dragged && dragged.node !== null) {
              dragged.node.p = particleSystem.fromScreen(s);
            }
            return false;
          },
          dropped: function(e) {
            var _mouseP;
            if (dragged === null || dragged.node === void 0) {
              return;
            }
            if (dragged.node !== null) {
              dragged.node.fixed = false;
            }
            dragged.node.tempMass = 1000;
            dragged = null;
            $(canvas).unbind('mousemove', handler.dragged);
            $(window).unbind('mouseup', handler.dropped);
            _mouseP = null;
            return false;
          }
        };
        return $(canvas).mousedown(handler.clicked);
      }
    };
    return that;
  };
  $(function() {
    var sys;
    sys = arbor.ParticleSystem(1000, 600, 0.5);
    sys.parameters({
      gravity: true
    });
    sys.renderer = Renderer("#viewport");
    sys.addEdge('a', 'b');
    sys.addEdge('a', 'c');
    sys.addEdge('a', 'd');
    sys.addEdge('a', 'e');
    return sys.addNode('f', {
      alone: true,
      mass: .25
    });
  });
}).call(this);
