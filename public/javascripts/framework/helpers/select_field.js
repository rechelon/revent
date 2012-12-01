function select_field(options,attr,selected_value){
  var html = "<select ";
  _.each(attr,function(value,name){
    html += name+'="'+value+'" ';
  });
  html += '>';
  if(options['']){
    html += '<option value="">'+options['']+'</option>';
    delete options[''];
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
  html += '</select>';
  return html;
}
