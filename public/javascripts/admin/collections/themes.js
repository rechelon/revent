var ThemeCollection = Backbone.Collection.extend({
  url : '/admin/themes',
  model: Theme,

  initialize: function(){
    this.collection_name = 'themes';
  },

  toSelect: function(){
    var options = {'':''};
    this.each(function(theme){
      options[theme.get('id')] = theme.get('name');
    });
    return options;
  }

});
