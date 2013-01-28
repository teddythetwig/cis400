/* Global Variables */

// Position of current object
var x, y;

// Text variable
currTxt = new Text("Name");


// List of tables
tables = new Array();

// Unlinked Properties
props = new Array();

// Figure variable
var currFig = new Rect(0, 0, 100, 100);

// Button creation
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
		var rect = new Rect(150, 150, 150, 150).fill('blue');
		rect.name = name;
		rect.properties = new Array();
	    rect.properties.push(name + "id");
		rect.connections = new Array();
		tables.push(rect);
		
		rect.on('click', function(data){
		    currTxt = new Text("Name: " + this.name).attr({
     		fontFamily: 'Arial, sans-serif',
    	  	fontSize: '20'
    		});
    		currTxt.addTo(stage);
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
		currFig = rect;

		stage.addChild(currFig);
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

// begin modal functions
function saveNewTable(e) {
  var tableName = document.getElementById("newTableName");
  if(tableName.value != "") {
    $('#newTableModal').modal('hide'); // hide modal on save
    alert("New table name: " + tableName.value);
    addTable(tableName.value);
  }
}

function saveNewAttr(e) {
  var attrName = document.getElementById("newAttrName");
  var attrType = document.getElementById("newAttrType");
  if(attrName.value != "") {
    $('#newAttributeModal').modal('hide'); // hide modal on save
    alert("New attr name: " + attrName.value + "\nAttr type: " + attrType.options[attrType.selectedIndex].value);
  }
}

function saveEditTable(e) {
  var tableName = document.getElementById("editTableName");
  if(tableName.value != "") {
    $('#editTableModal').modal('hide'); // hide modal on save
    alert("Edited table name: " + tableName.value);
  }
}

function saveEditAttr(e) {
  var attrName = document.getElementById("editAttrName");
  var attrType = document.getElementById("editAttrType");
  if(attrName.value != "") {
    $('#editAttributeModal').modal('hide'); // hide modal on save
    alert("Edited attr name: " + attrName.value + "\nAttr type: " + attrType.options[attrType.selectedIndex].value);
  }
}
// end modal functions

