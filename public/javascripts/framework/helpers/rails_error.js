function rails_error(response){
  var html = "<ul>";
  _.each(JSON.parse(response.responseText),function(msg){
    html += "<li>"+msg[0]+' '+msg[1]+"</li>";
  });
  html += '<ul>';
  return html;
}