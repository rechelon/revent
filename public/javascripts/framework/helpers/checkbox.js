function checkbox(attr,is_checked){
  var html = '<input type="checkbox" ';
  _.each(attr,function(value,name){
    html += name+'="'+value+'" ';
  });
  if(is_checked){ 
    html+='checked="checked" ';
  }
  html+='value="1" />';
  return html;
}