var PaginationView = Backbone.View.extend({
  initialize: function(o){
    _.bindAll(this, 'showLoader','hideLoader');
    this.current_page = o.current_page;
    this.total_pages = o.total_pages;
    this.show_pages = 5;
  },

  render: function(){
    this.loader = jq('<div class="paginator-loader">')
                  .html('<img src="/images/ajax-loader.gif"/>')
                  .appendTo(this.el);
    this.paginator = jq('<div class="pagination">')
                  .appendTo(this.el);  
    if(this.total_pages == 1 || this.total_pages == 0){
      this.paginator.html("");
      jq(this.el).hide();
    } else {
      jq(this.el).show();
      var lower_bound;
      if(this.current_page - Math.floor(this.show_pages / 2) < 1){
        lower_bound = 1;
      } else {
        lower_bound = this.current_page - Math.floor(this.show_pages / 2);
        if(lower_bound + this.show_pages > this.total_pages) lower_bound = Math.max(this.total_pages - (this.show_pages - 1), 1);
      }
      this.paginator.html(JST.paginator({
        current_page:this.current_page,
        total_pages:this.total_pages,
        show_pages:this.show_pages,
        lower_bound: lower_bound
      }));
    }
  },

  showLoader: function(){
    this.loader.show();
  },

  hideLoader: function(){
    this.loader.hide();
  }


});
