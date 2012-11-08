var Router = Backbone.Router.extend({
  routes:{
    "": "index",
    "/": "index",
    "events":"events",
    "users":"users",
    "reports":"reports",    
    "calendars":"calendars",
    "themes":"themes",
    "sponsors":"sponsors"
  },
  
  setCurrent: function(button_id){
    jq('#main_menu a').removeClass('current');
    jq(button_id).addClass('current');
  },
  
  index: function(){
    this.navigate('events',true);
  },
  
  events: function(){
    jq('.page').hide();
    jq('#events-page').show();
    this.setCurrent('#events-menu-item');
  },
  
  users: function(){
    jq('.page').hide();
    jq('#users-page').show();      
    this.setCurrent('#users-menu-item');
  },
  
  reports: function(){
    jq('.page').hide();
    jq('#reports-page').show();
    this.setCurrent('#reports-menu-item');
  },
    
  calendars: function(){
    jq('.page').hide();
    jq('#calendars-page').show();      
    this.setCurrent('#calendars-menu-item');
  },

  themes: function(){
    jq('.page').hide();
    jq('#themes-page').show();      
    this.setCurrent('#themes-menu-item');
  },
   
  sponsors: function(){
    jq('.page').hide();
    jq('#sponsors-page').show();      
    this.setCurrent('#sponsors-menu-item');
  }

});
