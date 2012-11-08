var EventSearchView = SearchView.extend({
  
  beforeSetFilter: function(name,value){
    if(name !== 'calendar_id') return;
    if(value !== this.collection.params.calendar_id){
      this.collection.params.category_id = undefined;
    }  
  },

  getFormData: function(){
    var current_calendar = revent.calendars.get(this.collection.params.calendar_id);
    return {
      params: this.collection.params,
      current_calendar_id: current_calendar.get('id'),
      calendars: revent.calendars,
      categories: current_calendar.getCategories()
    };
  },

  after_init: function(){
    revent.sponsors.bind('all',this.render);
  }
  
});
