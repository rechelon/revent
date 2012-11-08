var SearchView = Backbone.View.extend({
  
  events: {
    'change .filter' :  'setFilter',
    'change .sort' :  'setSort',
    'change .items-per-page' :  'setItemsPerPage',
    'click .export-btn' : 'export'
  },
  
  initialize: function(o) {
    _.bindAll(this,'render','getFormData');    
    this.template = o.template;
    this.list = o.list;
    this.render();
    revent.calendars.bind('all',this.render);
    this.collection.bind('reset',this.render);   
    this.after_init();
  },
  
  after_init: function(){
    // overwrite in subclass
  },

  render: function(){
    jq(this.el).html(JST[this.template+'_search'](this.getFormData()));
    this.loader = jq('<div class="search-loader">')
                  .html('<img src="/images/ajax-loader.gif"/>')
                  .prependTo(this.el);             

    jq("input.date_range_start",this.el).datepicker({
      changeMonth:true
    });
    jq("input.date_range_end",this.el).datepicker({
      changeMonth:true
    });
  },
  
  getFormData: function(){
    throw 'overwrite in subclass';
  },
  
  beforeSetFilter: function(){
  
  },
  
  setFilter: function(e){
    var search = this;
    var param = jq(e.target).attr('filter');
    var value;
    if(e.target.type == 'checkbox'){
      value = e.target.checked;
    } else {
      value = jq(e.target).val();
    }
    search.beforeSetFilter(param,value);
    search.collection.params[param] = value;
    search.collection.params.current_page = 1;
    //hack
    if(param=='calendar_id'&&value==0){
      setTimeout(function(){search.hideLoader();},1000);
    }
    //end hack
    search.showLoader();
    search.collection.fetch({
      success:function(){
        search.hideLoader();
      },
      error:function(){
        search.hideLoader();
        growl('error','Request Not Completed');
      }
    });
  },
  
  setSort: function(e){
    this.collection.params.order = jq(e.target).val();
    this.showLoader();
    search = this;
    this.collection.fetch({
      success:function(){
        search.hideLoader();
      },
      error:function(){
        search.hideLoader();
        growl('error','Request Not Completed');
      }      
    });
  },
  
  setItemsPerPage: function(e){
    this.collection.params.limit = jq(e.target).val();  
    this.showLoader();
    var search = this;
    this.collection.fetch({
      success:function(){
        search.hideLoader();
      }
    });
  },
  
  export: function(){
    jq('.list-search-form',this.el).submit();
  },
  
  showLoader: function(){
    this.loader.show();
  },
  
  hideLoader: function(){
    this.loader.hide();
  }  
});
