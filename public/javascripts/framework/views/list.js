var ListView = Backbone.View.extend({
  
  events:{
    'click .pagination .prev-page' : 'previousPage',
    'click .pagination .next-page' : 'nextPage',
    'click .pagination .go-to-page' : 'goToPage'
  },
  
  initialize: function(o) {
    _.bindAll(this,'render','addOne','addAll','filter');
    if(o.debug) this.debug = true;
    this.current_row = 0;
    this.template = o.template;
    this.row_view = o.row_view;
    this.form_view = o.form_view;
    if(o.paginated !== false) this.paginated = true;
    if(this.paginated) this.setupPaginator();
    this.no_results_html = o.no_results_html || "<h2>No Results Matched Your Query</h2>";
    this.message = jq('<div class="list-msg">').appendTo(this.el);
    this.table = jq('<table class="list" cellspacing="0">').appendTo(this.el);
    this.collection.bind('reset',   this.render);
    this.collection.bind('add',   this.render);
    this.collection.bind('destroy',   this.render);
  },

  setupPaginator: function(){
    this.paginator = jq('<div class="paginator-container">').prependTo(this.el);
  },
  
  render: function(blah) {
    if(this.collection.length > 0){
      jq('.no-rows', this.el).hide();
    }
    if(this.paginated){
      this.paginator.empty();
      this.paginator_view = new PaginationView({
        current_page: this.collection.params.current_page,
        total_pages: this.collection.total_pages
      });
      this.paginator_view.render();
      jq(this.paginator_view.el).appendTo(this.paginator);
    }
    if((this.collection.total_pages > 0) || !this.paginated){
      this.message.empty();
      this.addAll();
    } else {
      var message = this.no_results_html;
      var nearby_zip = this.collection.params.nearby_zip;
      if(nearby_zip){
        var state = revent.nearby_zips[nearby_zip].attributes.center_state;
        if(state) message += "No results found, try searching the <a href='#state/"+state+"'>state of "+state+"</a>";
      }
      this.message.html(message);
      this.table.empty();
    }
  },  
  
  // overwrite to filter list
  filter: function(){
    return true;
  },
  
  addOne: function(item){
    
    if(!this.filter(item)) return;
    var view = new this.row_view({
      model: item,
      template: this.template,
      form_view: this.form_view
    });
    view.render();
    if(this.current_row % 2) jq(view.el).addClass('even-row');
    this.table.append(view.el);
    this.current_row++;
  },
  
  addAll: function(){
    this.table.empty();
    this.table.append(JST[this.template+'_list_headers']());
    this.current_row = 0;
    this.collection.each(this.addOne);
  },
  
  previousPage: function(){
    this.paginator_view.showLoader();
    if(this.collection.params.current_page > 1){
      --this.collection.params.current_page;
    }
    var list = this;
    this.collection.fetch({success:function(){
      list.paginator_view.hideLoader();
    }});
  },
  
  nextPage: function(){
    this.paginator_view.showLoader();
    if(this.collection.params.current_page < this.collection.total_pages){
      ++this.collection.params.current_page;
    }
    var list = this;    
    this.collection.fetch({success:function(){
      list.paginator_view.hideLoader();
    }});
  },
  
  goToPage: function(e){
    this.paginator_view.showLoader();
    var page = Number(e.target.innerHTML);
    if(this.collection.params.current_page !== page){
      this.collection.params.current_page = page;
    }
    var list = this;    
    this.collection.fetch({success:function(){
      list.paginator_view.hideLoader();
    }});
  }
  
});
