var Permission = Backbone.Model.extend({
  urlRoot: '/admin/permissions',
  model_name: 'permission',
  get_value: function(){
    if(this.get("name") == "sponsor_admin"){
      return revent.sponsors._byId[this.get("value")].attributes.name;
    } else {
      return this.get("value");
    }
  }
},{
  permissionTypesToSelect: function(){
    return {
      '': 'Choose a Permission',
      sponsor_admin: "Admin for Sponsor",
      site_admin: "Admin for Site"
    };
  }
});
