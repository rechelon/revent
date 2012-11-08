var Router = Backbone.Router.extend({
  routes:{
    "state/:state" : "state",
    "state/:state/category/:category" : "state",
    "zip/:zip" : "zip",
    "zip/:zip/category/:category" : "zip",
    "category/:category" : "category"
  },

  state: function(state, category_id){
    revent.upcoming_events.params.parent_conditionals['state'] = state;
    if(revent.upcoming_worksite_events != undefined)
      revent.upcoming_worksite_events.params.parent_conditionals['state'] = state;
    this.route_generic('state', state);
    if(category_id){
      this.setCategory(category_id);
      this.route_generic('category_id', category_id);
    }
  },

  zip: function(zip, category_id){
    revent.upcoming_events.params.nearby_zip = zip;
    if(revent.upcoming_worksite_events != undefined)
      revent.upcoming_worksite_events.params.nearby_zip = zip;
    this.route_generic('postal_code', zip);
    if(category_id){
      this.setCategory(category_id);
      this.route_generic('category_id', category_id);
    }
  },

  category: function(category_id){
    this.setCategory(category_id);
    this.route_generic('category_id', category_id);
  },

  setCategory: function(category_id){
    revent.upcoming_events.params.parent_conditionals['category_id'] = category_id;
    if(revent.upcoming_worksite_events != undefined)
      revent.upcoming_worksite_events.params.parent_conditionals['category_id'] = category_id;
  },

  route_generic: function(unit, value){
    jq('.filter[filter="'+unit+'"]').attr('value', value);
    var waiting_functions = [];
    if(total_events_fetched == false){
      waiting_functions.push(function(done){
        revent.total_events.bind('reset', done)
      });
    }
    if(map_generated == false){
      waiting_functions.push(function(done){
        events_map.eventEmitter.bind('generated', done);
      });
    }
    async.parallel(waiting_functions, function(){
      event_search.fetch_and_recenter(unit, value);
      event_search.setSearchHeader();
    });
  }
});
