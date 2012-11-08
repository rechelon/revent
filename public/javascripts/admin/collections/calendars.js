var CalendarCollection = Backbone.Collection.extend({
  url : '/admin/calendars',
  model: Calendar,
  
  initialize: function(){
    this.collection_name = 'calendars';
  },
  
  toSelect: function(){
    var options = {};
    this.each(function(calendar){
      options[calendar.get('id')] = calendar.get('permalink');
    });
    return options;
  },
  
  comparator: function(c){
      if(c.get('current')){
          // make sure default calendar is always first
          return '___';
      }
      return c.get('name').toLowerCase();
  }  
});
