var UserSearchView = SearchView.extend({
  
  getFormData: function(){
    return{
      params: this.collection.params,
      permission_merge: this.permissionMerge
    };
  },

  permissionMerge: function(){
    var sponsors_select = revent.sponsors.toSelect(false);
    var permissions_select = {'':'Chose a permission','site_admin|true': 'Site Admin'};
    for(i in sponsors_select){
      permissions_select['sponsor_admin|' + sponsors_select[i][1]] = "Sponsor Admin: " + sponsors_select[i][0];
    }
    return permissions_select;
  },

  after_init: function(){
    revent.sponsors.bind('all',this.render);
  }
  
});
