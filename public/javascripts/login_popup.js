jQuery(function(){
  if(!document.cookie.match('revent_auth')){
    login.initialize();
    login.create_popup_button('.create-event-btn');
    login.create_popup_button('.manage-events-btn');
    login.create_popup_button('.create-report-btn');
    login.create_popup_button('.flash-login-btn');
    login.create_popup_button_live('.create-item-link');
    jQuery('#manage-logged-out').show();
  } else {
    jQuery('#manage-logged-in').show();
  }
});

login = {
  loaded: false,
  login_html: '',
  manage_html: '',
  html: '\
    <div id="login-popup-bg" class="modal-backdrop" style="display:none;"></div>\
    <div id="login-container" class="modal hide">\
      <div id="login-popup">\
        <div id="login-popup-padder">\
          <img id="popup-spinner" src="/images/ajax-loader.gif" />\
        </div>\
      </div>\
    </div>\
  ',

  initialize: function(){
    jQuery('body').prepend(login.html);
    jQuery('#login-popup-bg').click(function(){
      login.hide();    
    });
  },

  hide: function(){
    jQuery('#login-container').fadeOut(300);
    jQuery('#login-popup-bg').hide();
  },

  initialize_content: function(){
    jQuery('.popup-signup').click(function(){
      jQuery('.popup-pane').hide();
      jQuery('#user-signup-pane').show();
    });
    jQuery('.popup-login').click(function(){
      jQuery('.popup-pane').hide();
      jQuery('#user-login-pane').show();
    });
    jQuery('.popup-password').click(function(){
      jQuery('.popup-pane').hide();
      jQuery('#forgot-password-pane').show();
    });
    jQuery('.close','#login-popup').click(function(){
      login.hide();
    });
    /*login.fb_init();*/
  },

  create_popup_button: function(target){
    jQuery(target).click(this.popup_action);
  },

  create_popup_button_live: function(target){
    jQuery(target).live("click", this.popup_action);
  },

  popup_action: function(){
    var link = this;
    login.show(function(){
      login.set_redirect(jQuery(link).attr('href'));
    });
    return false;
  },

  set_redirect: function(redirect_url){
    jQuery('#login-popup input.redirect').val(redirect_url);
    jQuery('.oauth-btn').each(function(){
      var oauth_url = jQuery(this).attr('href');
      jQuery(this).attr('href', oauth_url+'?redirect='+redirect_url);
    });
  },

  show: function(callback){
    callback = callback || function(){};
    jQuery('#login-popup-bg').show();
    jQuery('#login-container').fadeIn(300);
    jQuery('#login-popup-bg').css('height',jQuery(document).height());
    if(login.loaded){
      callback();
    }else{
      login.load_content(callback);
    }
  },

  load_content: function(callback) {
    jQuery.ajax({
      url: '/login_popup',
      success: function(data){
        jQuery('#login-popup-padder').html(data);
        login.initialize_content();
        callback();
        login.loaded = true;
      }
    });
  },

  fb_init: function(){
    console.log('login.fb_init');
    jQuery('#fb-oauth-btn').click(function(){
      console.log('fb login clicked');
      FB.login(function(response) {
        if (response.session) {
          console.log(response, 'fb response');
          FB.api('/'+response.session.uid,function(user){
            console.log(user,'user');
            jQuery
          });
        } else {
          // user cancelled login
        }
      },{perms:'email'});
      return false;
    });  
  }
}
