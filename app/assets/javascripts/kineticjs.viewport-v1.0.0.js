var updateX = 0;
var updateY = 0;

var relShow = true;
var attrShow = true;
var prevRelShow = true;
var prevAttrShow = true;

function log(message) {
	if( console && console.log ) {
		console.log(message);
	}	
}

function Viewport(stage) {
	
	// begin scale at 100%
    this.scale = 1.0;
    this.minimumScale = 0.5;
    this.maximumScale = 2.0;
    this.scaleRate = 0.05;

	this.canvasWidth = stage.getWidth();
	this.canvasHeight = stage.getHeight();
        //alert("width: " + canvasWidth + ", height: " + canvasHeight);
	
	// we zero out the view -- position it at 0,0
	this.viewLeft = 0;
	this.viewTop = 0;
	this.viewRight = 0;
	this.viewBottom = 0;
	
	// compute the view right and bottom positions. the top, left will still be 0,0.
	this.updateViewBounds();
		
	this.panRate = 10.0;
	
	// nodes can be anything which inherits Node, such as Groups, Shapes, except Layers.
	this.nodes = {};
	
	// create layer
	this.layer = new Kinetic.Layer();
		
	// add layer to stage
	stage.add(this.layer);
	
	// set initial zoom
	this.setZoom(this.scale);
}

Viewport.prototype.updateViewBounds = function() {
	this.viewRight = this.viewLeft + this.canvasWidth * (1 / this.scale);
	this.viewBottom = this.viewTop + this.canvasHeight * (1 / this.scale);
}

/// <summary>
/// Returns the ID to be used when adding the next node.
/// </summary>
Viewport.prototype.getNewNodeID = function() {
	if( typeof(this.nextNodeID) == "undefined" ) {
		// init to 1
		this.nextNodeID = 1;
	}
	else
	{
		// increment by 1
		this.nextNodeID++;
	}
	// return next ID value
	return this.nextNodeID;
}

Viewport.prototype.setNodeX = function( nodeID, x ) {
	var node = this.getNode( nodeID );
	
	node.setX(this.viewLeft + x);
}

Viewport.prototype.setNodeY = function( nodeID, y ) {
	var node = this.getNode( nodeID );
	
	node.setY(this.viewTop + y);
}

// returns the game-space position, not the view-space position
Viewport.prototype.getNodeX = function( nodeID ) {
	var node = this.getNode( nodeID );
	
	return node.getX() + this.viewLeft;
}

Viewport.prototype.getNodeY = function( nodeID ) {
	var node = this.getNode( nodeID );
	
	return node.getY() + this.viewTop;
}

Viewport.prototype.addNodeX = function( nodeID, x ) {
	var node = this.getNode( nodeID );
	
	node.setX(node.getX() + x);
}

Viewport.prototype.addNodeY = function( nodeID, y ) {
	var node = this.getNode( nodeID );
	
	node.setY(node.getY() + y);
}

Viewport.prototype.getNode = function( nodeID ) {
	var node = this.nodes[nodeID];
	return node;
}

/// <summary>
/// Adds the node to the viewport and returns the ID.
/// </summary>
Viewport.prototype.add = function(node, /* only required if node doesn't have it */ radius, bottom) {

	if( typeof( node.radius ) == "undefined" || node.radius < 1 ) {
		// node didn't have a valid radius property
		if( typeof( radius ) == "undefined" || radius < 1 ) {
			// we didn't get a radius, so throw an exception
			throw new "Error: Viewport.add() requires a positive integer value for the 'radius' parameter if the provided node does not have a valid radius property.";
		}
		else
		{
			// store the provided radius
			node.radius = radius;
		}
	}
        if( typeof( bottom ) == "undefined" ) {
	    bottom = false;
	}

	// get the new node ID and store in node
	node.ID = this.getNewNodeID();

	// store node in hashmap by node ID
	this.nodes[node.ID] = node;
	
	// apply view-space position adjustment
	node.setX(node.getX() - this.viewLeft);
	node.setY(node.getY() - this.viewTop);	

	//node.isVisible = false;
	//node.setVisible(false);
	this.layer.add(node);
        
        if(bottom) {
	    node.moveToBottom();
	} 

	// log event
	log( "added a new node with ID = " + node.ID );
	
	// reurn node ID
	return node.ID;
}

Viewport.prototype.draw = function() {

	// call a method in here which calcs the viewport dimensions, position. then loops thru all nodes and calcs whether they are visible. if they are visible and not shown, then shown, and visa-versa. flag accordingly.
	this.updateViewBounds();

	// set which nodes are visible (added to layer) based on the view bounds
	this.updateVisibleNodes();

	// re-render the layer
	this.layer.draw();
}

Viewport.prototype.updateVisibleNodes = function() {

	// for each node, determine if node is in bounds. if it is, and isn't visible, add it. if it isn't and is visible, remove it.
	
	// store values in local variables for convenience and performance
	var viewLeft = this.viewLeft;
	var viewTop = this.viewTop;
	var viewRight = this.viewRight;
	var viewBottom = this.viewBottom;
	
	log( "view rect: left=" + viewLeft + ", right=" + viewRight + ", top=" + viewTop + ", bottom=" + viewBottom );
	
	for( var nodeID in this.nodes ) {
		// get current node
		var node = this.getNode(nodeID);
		
		var nodeRadius = node.radius;
		var nodeDiameter = nodeRadius * 2;
		
		// calculate node positions
		var nodeLeft = this.getNodeX( nodeID ) - nodeRadius;
		var nodeRight = nodeLeft + nodeDiameter;
		var nodeTop = this.getNodeY( nodeID ) - nodeRadius;
		var nodeBottom = nodeTop + nodeDiameter;
		
		//if( nodeID == 34 || nodeID == 1) {
			log("node " + nodeID + " bounds: left=" + nodeLeft + ", right=" + nodeRight + ", top=" + nodeTop + ", bottom=" + nodeBottom );
		//}
		
		// determine whether node is within the view bounds
		var isInView = 
			( viewLeft <= nodeRight // node's right is to the right of the view's left edge
			&& nodeLeft <= viewRight // node's left is to the left of the view's right edge
			&& viewTop <= nodeBottom // node's bottom below the view's top edge
			&& nodeTop <= viewBottom ); // node's top is above the view's bottom edge

		switch( isInView ) {
			case true:
				if( !node.isVisible() ) {
					// node isn't visible, and it needs to be
					
					// add node to layer
					//this.layer.add(node);
					
					// flag node as visible

					node.setVisible(true);
				}
				
				break;
				
			case false:
				if( node.isVisible() ) {
					// node is visible, and it shouldn't be
					
					// remove node from layer
					//this.layer.remove(node);
					
					// flag node as not visible
					node.setVisible(false);
					
				}
				break;
		}
		
	}

	if(attrShow != prevAttrShow) {
	  //Adds/Removes attribute lines from canvas
          for(var i = 0; i < attrLines.length; i++) {
            attrLines[i][0].setVisible(attrShow);
          }

          //Adds/Removes attributes from canvas
          for(var i = 0; i < attributes.length; i++) {
            attributes[i][0].setVisible(attrShow);
          }
          prevAttrShow = attrShow;
        }
        if(relShow != prevRelShow) {
          // Updates relation lines and relation table
          for(var i = 0; i < relations.length; i++) {
            var rel = relations[i][0].setVisible(relShow);
            var lines = relations[i][1];
            for(var j = 0; j < lines.length; j++) {
              lines[j].setVisible(relShow);
            }
          }
          prevRelShow = relShow;
        }
}

/*
 * Shows and Hides Relations
 */
function onRelShow() {
    viewport.draw();

    relShow = document.getElementById("showRel").checked;

    // Updates relation lines and relation table
    for(var i = 0; i < relations.length; i++) {
        var rel = relations[i][0].setVisible(relShow);
        var lines = relations[i][1];
        for(var j = 0; j < lines.length; j++) {
            lines[j].setVisible(relShow);
        }
    }
    //layer.draw();
}

Viewport.prototype.panLeft = function(amount) {
	this.panX( -amount );
}
Viewport.prototype.panRight = function(amount) {
	this.panX( amount );
}
Viewport.prototype.panUp = function(amount) {
	this.panY( -amount );
}
Viewport.prototype.panDown = function(amount) {
	this.panY( amount );
}

Viewport.prototype.panX = function(amount) {
		
	var panChange = amount * ( 1 / this.scale);
	
	for( var nodeID in this.nodes ) {
		// move node position by given amount
		//this.nodes[nodeID].x += -panChange;
		var node = this.nodes[nodeID];
		var x = node.getX();
		node.setX(x-panChange);
	}
	
	// record new view left
	this.viewLeft += panChange;
}
Viewport.prototype.panY = function(amount) {
		
	var panChange = amount * ( 1 / this.scale);
	
	for( var nodeID in this.nodes ) {
		// move node position by given amount
		//this.nodes[nodeID].y += -panChange;
		var node = this.nodes[nodeID];
		var y = node.getY();
		node.setY(y-panChange);
	}
	
	// record new view top
	this.viewTop += panChange;
}
Viewport.prototype.zoomIn = function() {
	this.setZoom(this.scale + this.scaleRate);
}
Viewport.prototype.zoomOut = function() {
	this.setZoom(this.scale - this.scaleRate);
}
Viewport.prototype.setZoom = function(scale) {
	
	// store new scale
	this.scale = scale;
	
	if( this.scale < this.minimumScale ) {
		// the scale is below the minimum - set to minimum
		this.scale = this.minimumScale;
	}
	else if( this.scale > this.maximumScale ) {
		// the scale is above the maximum - set to maximum
		this.scale = this.maximumScale;
	}
	
	// apply new scale
	this.layer.setScale(this.scale);
}
