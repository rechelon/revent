AdminUser = Backbone.Model.extend({
  urlRoot: '/admin/users',
  model_name: 'admin_user',
  
  get_permissions: function(){
   return this.get('permissions');  
  },
  
  can_view_calendar: function(){
    return this.is_site_admin();
  },

  can_view_theme: function(){
    return this.is_site_admin();
  },

  is_site_admin: function(){
    var site_admin = _.detect(this.get_permissions(),function(permission){
      if(permission.name == 'site_admin' && permission.value == 'true'){
        return true;
      }
    });

    return (site_admin ? true : false);
  }
});
