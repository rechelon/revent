dialog = function(o){
  var id = o.id || 'standard-dialog-box';
  var title = o.title || '';
  var content = o.content || jq('<div></div>');
  delete o.title;
  delete o.content;
  
  o.height = o.height || 'auto';
  o.resizable = o.resizable || false;
  if(o.modal === undefined) o.modal = true;
  
  if(o.buttons){
    var buttons = {};
    
    _.each(o.buttons, function( action, text){
      buttons[text] = function(e){
          var done = function(){
            jq( '#'+id ).dialog( "destroy" );
            jq( '#'+id ).remove();
          }; 
          var cancel = function(){
            jq(e.target).removeClass('button-loading');
            jq(e.target).addClass('ui-state-default');            
          };  
          var result = action(e,done,cancel);
          if(result === true){
            //jq(e.target).addClass('button-loading');
            //jq(e.target).removeClass('ui-state-default');            
          } else {
            jq( '#'+id ).dialog( "destroy" );
            jq( '#'+id ).remove();
          }
      };
    });
    o.buttons = buttons;
  }
  
  return jq('<div id="'+id+'" title="'+title+'"></div>').html(content).dialog(o);
  
};
