
// css
var pointStyle = {
  fillColor:'#ccc',
  strokeColor:'#aaa',
  strokeWidth:1,
  filters:filter.DropShadow(1,1,2, '#ccc')
};
var lineStyle = {
  strokeWidth:1,
  strokeColor: '#aaa'
};

function drawPointAtOrigin(x, y) {

  var connectedPoints = [];

  var group = new Group().addTo(stage).attr({
    x: x || 0,
    y: y || 0
  });

  var line = new Path().attr(lineStyle).addTo(group);

  var circle = Path.circle(50, 50, 7).attr(pointStyle).attr({
    x:0,
    y:0
  }).on('drag', function(data) {
    group.attr({x: data.x, y:data.y});
    group.updateConnections();
  }).addTo(group);

  group.updateConnections = function() {
    var thisAttr = this.attr(); //circle
    connectedPoints.forEach(function(aPoint) {
      var attr = aPoint.attr(); //circle
      line.clear().moveTo(0,0).lineTo(attr.x - thisAttr.x, attr.y - thisAttr.y);
    });
    this.delegates.forEach(function(delegate) {
      delegate.updateConnections();
    });
  };
  group.delegates = [];
  group.connect = function(anotherPoint) {
    connectedPoints.push(anotherPoint);
    anotherPoint.delegates.push(this);
    this.updateConnections();
  };

  return group;
}

// linear (first order)
var point1 = drawPointAtOrigin(50, 80);
var point2 = drawPointAtOrigin(100, 200);
point1.connect(point2);

var point3 = drawPointAtOrigin(100, 200);
var point4 = drawPointAtOrigin(300, 350);
point3.connect(point4);

var point5 = drawPointAtOrigin(150, 80);
var point6 = drawPointAtOrigin(100, 200);
point5.connect(point6);

var point7 = drawPointAtOrigin(300, 350);
var point8 = drawPointAtOrigin(400, 280);
point7.connect(point8);


var circPath = bonsai.Path.circle(50, 75, 25).attr({fillColor: 'blue'});
stage.addChild(circPath);
var rectPath = bonsai.Path.rect(50, 150, 100, 100).attr({fillColor: 'red'});
stage.addChild(rectPath);
var rectPath1 = bonsai.Path.rect(250, 300, 100, 100).attr({fillColor: 'red'});
stage.addChild(rectPath1);
var circPath1 = bonsai.Path.circle(150, 75, 25).attr({fillColor: 'blue'});
stage.addChild(circPath1);
var circPath2 = bonsai.Path.circle(400, 280, 25).attr({fillColor: 'blue'});
stage.addChild(circPath2);







