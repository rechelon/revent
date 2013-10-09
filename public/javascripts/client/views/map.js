var MapView = Backbone.View.extend({
  
  initialize: function(o) {
    _.bindAll(this,'render','addOne','addAll','filter');
    this.api = o.api;
    this.el = o.el;
    this.hide_details_link = o.hide_details_link;
    this.markers = [];
    var mv = this;
    _.each(this.adapter[this.api], function(adapter_method, method_name){
      mv[method_name] = adapter_method;
    });
    this.generateIcons(o.icons);
    this.generateLegend();
    //this.icons = o.icons;
    this.infowindow = null;
    this.collection.bind('reset',   this.render);
    this.collection.bind('add',   this.render);
    this.collection.bind('destroy',   this.render);
    this.eventEmitter = {};
    _.extend(this.eventEmitter, Backbone.Events);
    this.eventEmitter.bind('generated', this.addAll); 
    this.initialize_adapter();
  },

  render: function(o) {
    this.generateMap(o);
    return this;
  },

  generateLegend: function(){
    var html = '';
    _.each(icons, function(icon){
      if(!icon.show) return;
      html += '<li><img src="'+icon.image+'"> '+icon.name+'</li>';
    });
    jq(this.el).after('<ul class="map-legend span6">'+html+'</ul>');
  },

  adapter: {
    osm: {
      initialize_adapter: function(){
        revent.states['usa'] = {
          location: new CM.LatLng(37.0625,-95.677068), 
          zoom: 3 
        }
      },

      generateMap: function(o){
        o = o || {};
        var mv = this;
        var cloudmade = new CM.Tiles.CloudMade.Web({key: revent.cloudmade_api_key, styleId: revent.cloudmade_style_id});
        this.getCenter(o.center, function(err, center){
          mv.map = new CM.Map(mv.el, cloudmade);
          if(center.zoom){
            mv.map.setCenter(center.location, center.zoom);
          } else {
            mv.map.zoomToBounds(center.bounds);
          }
          mv.map.addControl(new CM.LargeMapControl());
          mv.map.addControl(new CM.ScaleControl());
          mv.map.addControl(new CM.OverviewMapControl());
          map_generated = true;
          mv.eventEmitter.trigger('generated');
        });
      },
      generateIcons: function(icons){
        this.icons = {};
        var mv = this;
        _.each(icons, function(icon, index){
           mv.icons[index] = new CM.Icon();
           mv.icons[index].image = icon.image;
           mv.icons[index].iconSize = new CM.Size(icon.size[0], icon.size[1]);
           mv.icons[index].iconAnchor = new CM.Point(icon.anchor[0], icon.anchor[1]);
        });
      },
      plotPoint: function(options){
        var myLatlng = new CM.LatLng(options.latitude, options.longitude);
        var marker = new CM.Marker(myLatlng, {
          title: "Event",
          icon: options.icon
        });
        marker.bindInfoWindow(options.content);
        this.map.addOverlay(marker);
      },
      recenter: function(options){
        var mv = this;
        this.getCenter(options, function(err, center){
          if(center.zoom){
            mv.map.setCenter(center.location, center.zoom);
          } else {
            mv.map.zoomToBounds(center.bounds);
          }
        });
      },
      getCenter: function(options, cb){
        options = options || {};
        var mv = this;
        var in_memory_unit;
        if(options.value == "" || options.value == undefined){
          return cb(null, revent.states.usa);
        }
        if(options.unit == "postal_code"){
          in_memory_unit = "zip_codes";
        } else {
          if(state_exceptions[options.value]){
            options.value = "country:'"+state_exceptions[options.value]+"'";
          } else {
            options.value = "county:'"+states_mapping[options.value]+"'";
            //alert(options.value);
          }
          in_memory_unit = "states";
        }
        if(!revent[in_memory_unit][options.value]){
          if(!mv.geocoder) mv.geocoder = new CM.Geocoder(revent.cloudmade_api_key);
          mv.geocoder.getLocations(options.value, function(response){
            var southWest = new CM.LatLng(response.bounds[0][0], response.bounds[0][1]),
              northEast = new CM.LatLng(response.bounds[1][0], response.bounds[1][1]);
            revent[in_memory_unit][options.value] = { bounds: new CM.LatLngBounds(southWest, northEast) };
            cb(null, revent[in_memory_unit][options.value]);
          });
        } else {
          cb(null, revent[in_memory_unit][options.value]);
        }
      }
    },
    gmaps: {
      initialize_adapter: function(){
        revent.states['usa'] = { 
          location: new google.maps.LatLng(37.0625,-95.677068),
          zoom: 3
        };
      },

      generateMap: function(o){
        o = o || {};
        var mv = this;
        this.getCenter(o.center,function(err,center){
          var myOptions = {
            center: center.location,
            scrollwheel: false,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          mv.map = new google.maps.Map(mv.el, myOptions);
          if(center.zoom){
            mv.map.setZoom(center.zoom);
          } else {
            mv.map.fitBounds(center.viewport);
          }
          map_generated = true;
          mv.eventEmitter.trigger('generated');
        });
      },

      clearMarkers: function(){
        var mv = this;
        beach.each_batch(this.markers, 50, function(marker){
          marker.setVisible(false);
        });
      },
      
      filterMarkers: function(category_id){
        var mv = this;
        beach.each_batch(this.markers, 50, function(marker){
          if(category_id){
            if(~_.indexOf(marker.category_ids, Number(category_id))){
              marker.setVisible(true);
            } else {
              marker.setVisible(false);
            }
          } else {
            marker.setVisible(true);
          }
        });
      },

      generateIcons: function(icons){
        this.icons = {};
        var mv = this;
        var origin = new google.maps.Point(0,0);
        _.each(icons, function(icon, index){
          var size = new google.maps.Size(icon.size[0], icon.size[1]);
          var anchor = new google.maps.Point(icon.anchor[0], icon.anchor[1]);
          mv.icons[index] = new google.maps.MarkerImage(icon.image, size, origin, anchor, size);
        });
      },

      plotPoint: function(options){
        var myLatlng = new google.maps.LatLng(options.latitude, options.longitude);
        var marker = new google.maps.Marker({
          position: myLatlng,
          map: this.map,
          icon: options.icon
        });
        marker.category_ids = options.category_ids;
        this.markers.push(marker);
        var mv = this;
        google.maps.event.addListener(marker, 'click', function() {
          if(mv.infowindow) mv.infowindow.close();
          mv.infowindow = new google.maps.InfoWindow({
            content: options.content,
            position: myLatlng
          });
          mv.infowindow.open(mv.map);
        });
      },

      getCenter: function(options, cb){
        options = options || {}; 
        var mv = this;
        var in_memory_unit;
        if(options.value == "" || options.value == undefined){
          return cb(null,revent.states.usa);
        }
        if(options.unit == "postal_code"){
          in_memory_unit = "zip_codes";
        } else {
          if(state_exceptions[options.value]){
            options.value = state_exceptions[options.value];
          } else {
            options.value = "State of "+options.value;
          }
          in_memory_unit = "states";
        }
        if(!revent[in_memory_unit][options.value]){
          if(!mv.geocoder) mv.geocoder = new google.maps.Geocoder();
          mv.geocoder.geocode({address: options.value}, function(results, status){
            if(status == "OK" && results.length == 1){
              revent[in_memory_unit][options.value] = results[0].geometry;
              if(in_memory_unit == "zip_codes"){
                revent[in_memory_unit][options.value].zoom = 8;
              }
              cb(null,revent[in_memory_unit][options.value]);
            } else if (results.length > 0) {
              growl('error','Invalid search - Check your search options');
              cb(new Error('Invalid search - Check your search options'));
            } else {
              growl('error','Not a valid postal code or zip');
              cb(new Error('Not a valid postal code or zip'));
            }
          });
        } else {
          cb(null,revent[in_memory_unit][options.value]);
        }
      }
    }
  },

  recenter: function(options){
    var mv = this;
    this.getCenter(options,function(err,center){
      mv.map.setCenter(center.location);
      if(center.zoom){
        mv.map.setZoom(center.zoom);
      } else {
        mv.map.fitBounds(center.viewport);
      }
    });
  },

  // overwrite to filter list
  filter: function(){
    return true;
  },
  
  addOne: function(point_obj, loc){
    //if(!this.filter(item)) return;
    var content_arr = [];
    var lat_lng_arr = loc.split(":");
    var latitude = lat_lng_arr[0];
    var longitude = lat_lng_arr[1];
    var category_ids = [];
    var icon;
    var mv = this;
    for(address in point_obj){
      var address_obj = point_obj[address];
      var name_arr = [];
      for(name in address_obj){
        var events_obj = address_obj[name];
        var events_arr = [];
        _.each(events_obj, function(item){
          if(item.get('past?') == true && icon != mv.icons.upcoming){
            icon = mv.icons.past;
          } else if(item.get('worksite_event') == true && icon != mv.icons.upcoming && icon != mv.icons.past){
            icon = mv.icons.worksite_upcoming;
          } else {
            icon = mv.icons.upcoming;
          }
          category_ids.push(item.get('category_id'));
          var tz_offset = item.get('tz_offset');
          var start_date = Date.parse(item.get('start')).add(tz_offset[0]).seconds().toString("ddd MMM d");
          var start_time = Date.parse(item.get('start')).add(tz_offset[0]).seconds().toString(" h:mmtt");
          var end_date = Date.parse(item.get('end')).add(tz_offset[1]).seconds().toString("ddd MMM d");
          var end_time = Date.parse(item.get('end')).add(tz_offset[1]).seconds().toString(" h:mmtt");
          events_arr.push(JST['map_infowindow_event']({
            item: item,
            start_date: start_date,
            start_time: start_time,
            end_date: end_date,
            end_time: end_time,
            hide_details_link: mv.hide_details_link
          }));
        });
        name_arr.push(JST['map_infowindow_name']({
          name: name,
          events: events_arr.join("<br />")
        }));
      }
      content_arr.push(JST['map_infowindow_address']({
        address: address,
        names: name_arr.join("<br /><br />")
      }));
    }
    this.plotPoint({
      icon: icon,
      latitude: latitude,
      longitude: longitude,
      category_ids: category_ids,
      content: content_arr.join("<hr />")
    });

  },
  
  addAll: function(){
    this.plot_points = this.plot_points || {};
    var mv = this;
    this.collection.each(function(item){
      var loc_key = item.get('latitude')+":"+item.get('longitude');
      var addy_key = (item.get('location') ? item.get('location')+", <br/>" : "")+
        _.compact([item.get('city'), item.get('state'), item.get('postal_code')]).join(", ");
      var name_key = item.get('name');
      mv.plot_points[loc_key] = mv.plot_points[loc_key] || {};
      mv.plot_points[loc_key][addy_key] = mv.plot_points[loc_key][addy_key] || {};
      mv.plot_points[loc_key][addy_key][name_key] = mv.plot_points[loc_key][addy_key][name_key] || [];
      item.sponsor_union = item.get('custom_attributes_data').sponsor_union;
      item.sponsor_local = item.get('custom_attributes_data').sponsor_local;
      item.sponsor_other = item.get('custom_attributes_data').sponsor_other;
      mv.plot_points[loc_key][addy_key][name_key].push(item);
    });
    for(loc in this.plot_points){
      mv.addOne(this.plot_points[loc], loc);
    }
  }

});
