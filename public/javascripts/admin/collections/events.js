var EventCollection = PaginatedCollection.extend({
  url : '/admin/events',
  model: EventModel,
  
  initialize: function(o){
    _.bindAll(this,'fetch');
    this.collection_name = 'events';
    this.params = {
      order: 'start',
      limit: 25,
      current_page: 1,
      calendar_id: revent.current_calendar_id,
      date_range_start: revent.calendars.get(revent.current_calendar_id).expiration_date()
    };
    this.users = o.users;
    var events = this;
    this.users.bind('destroy',function(){
      events.fetch();
    });
  }
});
