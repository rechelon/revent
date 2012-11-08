var EventRowView = RowView.extend({
  getRowData: function(){
    var start_date = Date.parse(this.model.get('start')).toString("MMM d");
    var start_time = Date.parse(this.model.get('start')).toString(" h:mmtt");
    var end_date = Date.parse(this.model.get('end')).toString("MMM d");
    var end_time = Date.parse(this.model.get('end')).toString(" h:mmtt");
    return {
      event: this.model,
      start_date: start_date,
      start_time: start_time,
      end_date: end_date,
      end_time: end_time,
      permalink: revent.permalink
    };
  }
});
