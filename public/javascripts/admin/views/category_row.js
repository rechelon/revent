var CategoryRowView = RowView.extend({
  getRowData: function(){
    return {
      category: this.model
    };
  }
});