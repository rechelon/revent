var CategoryCollection = Backbone.Collection.extend({
  url : '/admin/categories',
  model: Category,

  initialize: function(){
    this.collection_name = 'categories';
  },

  toSelect: function(options){
    var options = options || {'':'All'};
    this.each(function(category){
      options[category.get('id')] = category.get('name');
    });
    return options;
  }
  
});
