var UserRowView = RowView.extend({
  getRowData: function(){
    return {
      user: this.model
    };
  }
});