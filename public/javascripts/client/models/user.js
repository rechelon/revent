var User = Backbone.Model.extend({
  urlRoot: '/admin/users',
  model_name: 'user',

  getPermissions: function(){
    if(!this._permissions){
      this._permissions = new PermissionCollection(this.get('permissions'));
    }
    return this._permissions;
  },

  getSponsorPermissions: function(){
    return  this.getPermissions().filter(function(permission){
              return (permission.name == 'sponsor_admin');
            });
  }
});
