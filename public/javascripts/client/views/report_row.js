var ReportRowView = RowView.extend({
  getRowData: function(){
    return {
      report: this.model,
      event: this.model.getEvent(),
      date: Date.parse(this.model.getEvent().get("start")).toString('MMMM d'),
      user: this.model.getUser(),
      permalink: revent.permalink
    };
  }
});
