var ThemeElementCollection = Backbone.Collection.extend({
  url : '/admin/theme_elements',
  model: ThemeElement,

  initialize: function(){
    this.collection_name = 'theme_elements';
  }
});
