var EventSearchView = Backbone.View.extend({

  events: {
    'change .filter' :  'setFilter',
    'keyup .filter' : 'zipSearch'
  },

  initialize: function(o) {
    this.collections = o.collections;
    this.categories = o.categories;
    this.mapview = o.mapview;
    _.bindAll(this,'render','getFormData');
    this.template = o.template;
    this.render();
    this.after_init();
  },

  after_init: function(){
    // overwrite in subclass
  },

  render: function(){
    jq(this.el).html(JST[this.template+'_search'](this.getFormData()));
    emitter.trigger("event_search:rendered");
    this.loader = jq('.search-loader', this.el);
  },
  
  getFormData: function(){
    return {
      params: this.getSearchParams(),
      categories: this.categories
    };
  },

  beforeSetFilter: function(){
  
  },

  zipSearch: function(e){
    var param = jq(e.target).attr('filter');
    var value = jq(e.target).val();
    if(param == 'postal_code' && value.search(/^[0-9]{5}$/) != -1){
      this.setFilter(e);
    }
  },

  setFilter: function(e){
    var param = jq(e.target).attr('filter');
    var value;
    if(e.target.type == 'checkbox'){
      value = e.target.checked;
    } else {
      value = jq(e.target).val();
    }
    this.beforeSetFilter(param,value);
    this.fetch_and_recenter(param, value);
    this.routerNavigate();
    this.setSearchHeader();
    jq(e.target).blur();
  },

  setSearchHeader: function(){
    var p = this.getSearchParams();
    var search_string = "Search";
    if(p.category_id || p.state || p.zip) search_string += " results ";
    if(p.category_id) search_string += ' for <span class="label label-warning">'+jq('#category_id option[value='+jq('#category_id', this.el).val()+']', this.el).html()+'</span>';
    if(p.state || p.zip) search_string += ' in <span class="label label-info">'+(p.state ? p.state : "")+(p.zip ? p.zip : "")+'</span>';
    jq('.search-results',this.el).html(search_string);
  },

  routerNavigate: function(){
    var p = this.getSearchParams();
    var nav_array = [];
    if(p.zip) nav_array.push("zip/"+p.zip);
    if(p.state) nav_array.push("state/"+p.state);
    if(p.category_id) nav_array.push("category/"+p.category_id);
    if(nav_array.length == 0) nav_array.push('n'); // since routing to # moves the entire page up
    revent.router.navigate(nav_array.join('/'));
  },

  getSearchParams: function(){
    var state, zip, category_id;
    if(this.collections.upcoming.params.parent_conditionals.state){
      state = this.collections.upcoming.params.parent_conditionals.state;
    }
    if(this.collections.upcoming.params.parent_conditionals.category_id){
      category_id = this.collections.upcoming.params.parent_conditionals.category_id;
    }
    if(this.collections.upcoming.params.nearby_zip){
      zip = this.collections.upcoming.params.nearby_zip;
    }
    return {state: state, zip: zip, category_id: category_id};
  },

  fetch_and_recenter: function(param, value){
    var search = this;
    this.showLoader();
    switch(param){
      case "postal_code":
        jq('.filter[filter="state"]', this.el).attr('value', '');
        delete this.collections.upcoming.params.parent_conditionals.state;
        if(this.collections.upcoming_worksite != undefined){
          delete this.collections.upcoming_worksite.params.parent_conditionals.state;
        }
        if(value == ""){
          delete this.collections.upcoming.params.nearby_zip;
          if(this.collections.upcoming_worksite != undefined)
            delete this.collections.upcoming_worksite.params.nearby_zip;
        } else {
          this.collections.upcoming.params.nearby_zip = value;
          if(this.collections.upcoming_worksite != undefined)
            this.collections.upcoming_worksite.params.nearby_zip = value;
        }
        break;
      case "state":
        jq('.filter[filter="postal_code"]', this.el).attr('value', '');
        delete this.collections.upcoming.params.nearby_zip;
        if(this.collections.upcoming_worksite != undefined){
          delete this.collections.upcoming_worksite.params.nearby_zip;
        }
        if(value == ""){
          delete this.collections.upcoming.params.parent_conditionals.state;
          if(this.collections.upcoming_worksite != undefined)
            delete this.collections.upcoming_worksite.params.parent_conditionals.state;
        } else {
          this.collections.upcoming.params.parent_conditionals.state = value;
          if(this.collections.upcoming_worksite != undefined)
            this.collections.upcoming_worksite.params.parent_conditionals.state = value;
        }
        break;
      case "category_id":
        if(value == ""){
          delete this.collections.upcoming.params.parent_conditionals.category_id;
          if(this.collections.upcoming_worksite != undefined){
            delete this.collections.upcoming_worksite.params.parent_conditionals.category_id;
          }
          this.mapview.filterMarkers();
        } else {
          this.collections.upcoming.params.parent_conditionals.category_id = value;
          if(this.collections.upcoming_worksite != undefined){
            this.collections.upcoming_worksite.params.parent_conditionals.category_id = value;
          }
          this.mapview.filterMarkers(value);
        }
        break;
    }
    this.collections.upcoming.params.current_page = 1;
    if(this.collections.upcoming_worksite != undefined)
      this.collections.upcoming_worksite.params.current_page = 1;
    var async_functions = [this.collection_fetch(this.collections.upcoming)];
    if(this.collections.upcoming_worksite != undefined)
      async_functions.push(this.collection_fetch(this.collections.upcoming_worksite));
    async.parallel(
      async_functions,
      function(err, results){
        if(err){
          growl('error','Search could not be completed - Check your search options');
        }
        search.hideLoader();
      }
    );
    if(param == 'postal_code' || param == 'state'){
      this.mapview.recenter({
        unit: param,
        value: value
      });
    }
  },

  collection_fetch: function(collection){
    return function(done){
      collection.fetch({
        success:function(){
          done();
        },
        error:function(){
          done('error');
        }
      });
    }
  },


  showLoader: function(){
    this.loader.show();
  },
  
  hideLoader: function(){
    this.loader.hide();
  }  
});
