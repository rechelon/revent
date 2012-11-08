var ReportSearchView = SearchView.extend({
  
  getFormData: function(){
    return{
      current_calendar: revent.calendars.get(this.collection.params.calendar_id),
      calendars: revent.calendars,
      current_calendar_id: this.collection.params.calendar_id,
      params: this.collection.params
    };
  },

  after_init: function(){
    revent.sponsors.bind('all',this.render);
  }
 
  
});
