var EventSubCollection = PaginatedCollection.extend({
  url : '/',
  model: EventModel,
  
  initialize: function(o){
    if(o.parent_collection) this.parent_collection = o.parent_collection;
    _.bindAll(this,'fetch');
    this.collection_name = 'eventsSub';
    this.params = {
      parent_conditionals: {
        worksite_event: o.worksite_event,
        'past?': o['past?']
      },
      current_page: 1,
      limit: revent.events_limit
    };
  },

  fetch: function(options){
    var events_sub = this;
    this.reset(null, {silent: true});

    if(this.params.nearby_zip){
      if(revent.nearby_zips[this.params.nearby_zip]){
        this.filter(options);
      } else {
        var z = new ZipCode({zip: this.params.nearby_zip, radius: 50});
        revent.nearby_zips[this.params.nearby_zip] = z;
        z.fetch({
          success: function(){
            events_sub.filter(options);
          },
          error: function(err){
            if(options && options.error) options.error(err);
          }
        })
      }
    } else {
      this.filter(options);
    }
  },

  filter: function(options){
    var megaset = [];
    var events_sub = this;
    _.each(this.parent_collection.models, function(item){
      var passes_params = true;
      _.each(events_sub.params.parent_conditionals, function(param, paramIndex){
        if(param == false){
          if((item.attributes[paramIndex] != undefined) && (item.attributes[paramIndex] != false)){ 
            passes_params = false;
          }
        } else {
          if(param !== ""){
            if(item.attributes[paramIndex] != param) passes_params = false;
          }
        }
      });
      if(events_sub.params.nearby_zip){
        var passes_zip = false;
        var x = 0;
        if(revent.nearby_zips[events_sub.params.nearby_zip].attributes.surrounding){
          while(revent.nearby_zips[events_sub.params.nearby_zip].attributes.surrounding[x]){
            if(item.attributes.postal_code && item.attributes['postal_code'].substr(0,5) == revent.nearby_zips[events_sub.params.nearby_zip].attributes.surrounding[x].zip) passes_zip = true;
            x++;
          }
        }
        if(passes_zip == false) passes_params = false;
      }
      if(passes_params) megaset.push(item);
    });
    var minorset = megaset.slice((events_sub.params.current_page - 1) * events_sub.params.limit, events_sub.params.current_page * events_sub.params.limit);
    _.each(minorset, function(item){
      events_sub.add(item, {silent: true});
    });
    events_sub.total_pages = Math.ceil(megaset.length / events_sub.params.limit);
    events_sub.trigger('add'); // only fire the add event after all from minorset are added and we've set total_pages
    if(options && options.success) options.success();
  }

});
