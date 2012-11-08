var ThemeElementRowView = RowView.extend({
  getRowData: function(){
    return {
      theme_element: this.model
    };
  }
});
