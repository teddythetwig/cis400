
// Position of current object
var x, y;

// Text variable
currentTxt = new Text("Name");

//List of tables
tables = new Array();

//Unlinked Properties
props = new Array();

//Button creation
var button_connect = new Group().addTo(stage);

button_connect.bg = new Rect(50, 50, 100, 40, 5).attr({
	fillGradient: gradient.radial(['#19D600', '#0F8000'], 100, 50, -20),
	strokeColor: '#000',
	strokeWidth: 0
}).addTo(button_connect);

button_connect
	.on('mouseover', function() {
		button_connect.bg.animate('.2s', {
			fillGradient: gradient.radial(['#9CFF8F', '#0F8000'], 100, 50, -20),
            strokeColor: '#000',
			strokeWidth: 3
		})
	})
	.on('mouseout', function() {
		button_connect.bg.animate('.2s', {
			fillGradient: gradient.radial(['#19D600', '#0F8000'], 100, 50, -20),
            strokeColor: '#000',
			strokeWidth: 0
		})
	})
	.on('click', function() {
	    addTable("Test");
	})

button_connect.text = new Text('New Table').attr({
  x: 57,
  y: 65,
  fontFamily: 'Arial',
  fontSize: '18px',
  textFillColor: 'white',
}).addTo(button_connect);



//Table constructor
function addTable(name){
	//if(uniqueTable(name)){
		var rect = bonsai.Path.rect(150, 150, 150, 150).attr({fillColor: 'blue'});
		rect.name = name;
		rect.properties = new Array();
	    rect.properties.push(name + "id");
		rect.connections = new Array();
		tables.push(rect);
		
		rect.on('click', function(data){
		    new Text("Name: " + this.name).addTo(stage).attr({
     		fontFamily: 'Arial, sans-serif',
    	  	fontSize: '20'
    		});
		});

		rect.on('multi:pointerdown', function(e) {
			//Catch the new x and y @ beginning of the drag
			x = this.attr('x');
			y = this.attr('y');
	
		});

		rect.on('multi:drag', function(e) {
			this.attr({
				x: x + e.diffX,
				y: y + e.diffY
			});
		});

		stage.addChild(rect);
	//} else{
	//	return -1; //Show some visual error
	//}
	return (tables.length - 1); //Not necessary but keeping it just in case
}

//Property constructor
function property(name){
	this.name = name;
	this.type = null;
	this.connected = -1;
	props.push(this);
	return (props.length - 1);
}

//TODO Check if tables are connected
function tablesConnected(tableAId, tableBId){
	
}


function uniqueTable(name){
	for(var i = 0; i < tables.length; i++){
		if(name.toLowerCase() == tables[i].name.toLowerCase()){
			return false;
		}
	}
	return true;
}

function uniqueProperty(tableId, name){
	var table = tables[tableId];
	for(var i = 0; i < table.properties.length; i++){
		if(table.properties[i].name == name){
			return false;
		}
	}
	return true;
}

function addPropToTable(tableId, propId){
	var table = tables[tableId];
	var property= props[propId];
	if(uniqueProperty(table, property.name)){
		table.properties.push(property);
		props.splice(propId, 1);
	} else{
		return false;
	}
}

function connectTables(tableAId, tableBId){
	if(tablesConnected(tableAId, tableBId)){
		tableA.connections.push(tableBId);
		tableB.connections.push(tableAId);
	}
	
}