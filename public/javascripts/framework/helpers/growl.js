growl = function(type,message,parent) {
  if(type == 'info') type= 'success';
  parent = parent || 'body';

  var $parent = jq('.js-flash-container', parent);
  if($parent.length == 0) $parent = jq('body');

  $parent.show();

  jq('<div class="alert alert-'+type+'">'+message+'</div>')
  .prependTo($parent)
  .delay(1600)
  .hide('drop',{direction:'up'},800, function(){
    jq(this).remove()
  });

}

