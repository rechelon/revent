var CalendarListView = Backbone.View.extend({
  
  initialize: function(o) {
    _.bindAll(this,'render','addOne','addAll');
    this.collection.bind('add',   this.render);
    this.collection.bind('reset',   this.render);
    this.collection.bind('destroy',   this.render);    
  },
  
  render: function() {
    this.addAll();  
  },
  
  addOne: function(item){
    var view = new CalendarRowView({
      model: item   
    });
    view.render();
    jq(this.el).append(view.el);
  },
  
  addAll: function(){
    jq(this.el).empty();
    this.collection.each(this.addOne);
  }
});