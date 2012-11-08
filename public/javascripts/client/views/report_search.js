var ReportSearchView = SearchView.extend({

  getFormData: function(){
    return{
      current_calendar_id: this.collection.params.calendar_id,
      params: this.collection.params
    };
  }

});
