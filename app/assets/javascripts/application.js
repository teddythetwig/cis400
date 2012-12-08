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
		return;
	}
	this.properties = new Array();
	this.properties.push(name + "id");
	this.square = new Rect(0, 0, 100, 100);
	this.square.addTo(stage);d
	this.square.fill('red');
	
	tables.push(this);	
}

//Property constructor
function property(name){
	this.name = name;
	this.type = null;
	props.push(this);
}


function uniqueTable(name){
	for(var i = 0; i < tables.length; i++){
		if(name.toLowerCase() == tables[i].name.toLowerCase()){
			return false;
		}
	}
	return true;
}

function uniqueProperty(table, name){
	for(var i = 0; i < table.properties.length; i++){
		if(table.properties[i].name == name){
			return false;
		}
	}
	return true;
}

function addPropToTable(table, propId){
	var property= props[propId];
	if(uniqueProperty(table, property.name)){
		table.properties.push(property);
		props.splice(propId, 1);
	} else{
		return false;
	}
}

