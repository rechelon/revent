var SponsorRowView = RowView.extend({
  getRowData: function(){
    return {
      sponsor: this.model
    };
  }
});
