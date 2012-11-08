var EventRowView = RowView.extend({
  getRowData: function(){
    return {
      event: this.model
    };
  }
});