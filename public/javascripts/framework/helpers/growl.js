growl = function(type,message,parent, delay) {
  if(type == 'info') type= 'success';
  parent = parent || 'body';
  delay = delay || 1600;

  var $parent = jq('.js-flash-container', parent);
  if($parent.length == 0) $parent = jq('body');

  $parent.show();

  jq('<div class="alert alert-'+type+'">'+message+'</div>')
  .prependTo($parent)
  .delay(delay)
  .hide('drop',{direction:'up'},800, function(){
    jq(this).remove()
  });

}

