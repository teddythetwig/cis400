// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

//List of tables
tables = new Array();

//Unlinked Properties
props = new Array();

//Table constructor
function table(name){
	if(uniqueTable(name)){
		this.name = name;
	} else{
		return -1;
	}
	this.properties = new Array();
	this.properties.push(name + "id");
	this.connections = new Array();
	tables.push(this);
	return (tables.length - 1);
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


/////////////////////
// Bonsai JS
////////////////////

