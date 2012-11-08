var ReportCollection = PaginatedCollection.extend({
  url : '/admin/reports',
  model: Report,
  initialize: function(){
    this.collection_name = 'reports';
    this.params = {
      order: 'created_at',
      limit: 25,
      current_page: 1,
      calendar_id: revent.current_calendar_id
    };
  }
});
