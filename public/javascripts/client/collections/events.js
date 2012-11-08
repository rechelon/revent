var EventCollection = Backbone.Collection.extend({
  url : '/'+revent.permalink+'/maps',
  model: EventModel,
  
  initialize: function(o){
    _.bindAll(this,'fetch');
    this.collection_name = 'events';
  },

  filterByCategory: function(category_id){
    return this.filter(function(event){
      if(event.get('category_id') == category_id) return true;
      return false;
    });
  }
});
