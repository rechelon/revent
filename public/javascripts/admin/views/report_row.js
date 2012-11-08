var ReportRowView = RowView.extend({
  getRowData: function(){
    return {
      report: this.model,
      event: this.model.getEvent(),
      user: this.model.getUser()
    };
  }
});