function select_field(options,attr,selected_value){
  var options = _.clone(options);
  var html = select_field_open_tag(attr);
  html += select_field_options(options, selected_value);
  html += '</select>';
  return html;
}

function select_field_with_groups(options, attr, selected_value){
  var options = _.clone(options);
  var html = select_field_open_tag(attr);
  _.each(options, function(value, text){
    if(_.isString(value)){
      var temp_field = {}
      temp_field[text] = value;
      html += select_field_options(temp_field, selected_value);
    } else {
      html += "<optgroup label='"+text+"'>";
      html += select_field_options(value, selected_value);
      html += "</optgroup>";
    }
  });
  html += '</select>';
  return html;
}

function select_field_open_tag(attr){
  var html = "<select ";
  _.each(attr,function(value,name){
    html += name+'="'+value+'" ';
  });
  html += '>'; 
  return html;
}

function select_field_options(options, selected_value){
  var html = "";
  if(options['']){
    if(!_.isArray(options[''])){
      html += '<option value="">'+options['']+'</option>';
      delete options[''];
    }
  }
  _.each(options,function(text,value){
    var selected;
    if(_.isArray(text)){
      value = text[1];
      text = text[0];
    }
    if(value == selected_value){
      selected = 'selected="selected" ';
    } else {
      selected = '';
    }
    html += '<option value="'+value+'" '+selected+'>'+text+'</option>';
  });
  return html;
}
