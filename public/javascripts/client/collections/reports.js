var ReportCollection = PaginatedCollection.extend({
  url: '/'+revent.calendar_permalink+'/reports',
  model: Report,
  initialize: function(){
    this.collection_name = 'users';
    this.params = {
      order: 'created_at',
      limit: 25,
      current_page: 1,
      calendar_id: revent.current_calendar_id
    };
  }
});
