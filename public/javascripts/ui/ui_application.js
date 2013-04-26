jq(function($){
  var info, error;
  if(info = $.cookie('info')){
    growl('info', info, 'body', 999999);
    $.removeCookie('info', {'path': '/'});
  }
  if(error = $.cookie('error')){
    growl('error', error, 'body', 999999);
    $.removeCookie('error', {'path': '/'});
  }
});
