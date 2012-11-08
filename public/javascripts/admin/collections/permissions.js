var PermissionCollection = Backbone.Collection.extend({
  url : '/admin/permissions',
  model: Permission,

  initialize: function(){
    this.collection_name = 'permissions';
  }
});
