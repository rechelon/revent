var EmailTriggerRowView = RowView.extend({
  getRowData: function(){
    return {
      trigger: this.model
    }
  }
});