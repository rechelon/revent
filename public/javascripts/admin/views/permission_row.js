var PermissionRowView = RowView.extend({
  getRowData: function(){
    return {
      permission: this.model
    };
  }
});
