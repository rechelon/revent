var EventRowView = RowView.extend({
  getRowData: function(){
    var tz_offset = this.model.get('tz_offset');
    var start_date = Date.parse(this.model.get('start')).add(tz_offset[0]).seconds().toString("MMM d");
    var start_time = Date.parse(this.model.get('start')).add(tz_offset[0]).seconds().toString(" h:mmtt");
    var end_date = Date.parse(this.model.get('end')).add(tz_offset[1]).seconds().toString("MMM d");
    var end_time = Date.parse(this.model.get('end')).add(tz_offset[1]).seconds().toString(" h:mmtt");
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
