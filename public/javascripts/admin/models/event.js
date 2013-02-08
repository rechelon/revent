var EventModel = Backbone.Model.extend({
  urlRoot: '/admin/events',
  model_name: 'event',  

  copy: function(){
    var new_attr = this.attributes;
    delete new_attr.id;
    _.each(new_attr.custom_attributes,function(attribute){
      delete attribute.id;
    });
    return new EventModel(new_attr);
  },
    
  getCalendar: function(){
    return revent.calendars.get(this.get('calendar_id'));
  },
  
  getCategories: function(){
    return this.getCalendar().getCategories();
  },
  
  getCustomAttributes: function(){
    if(!this._custom_attributes_initialized){
      var custom_attributes = [];
      var attr;
      var all_attributes = revent.config.custom_event_attributes;
      var current_attributes = this.get('custom_attributes');
      // make an array of all custom attributes, including blank ones that haven't been set
      _.each(all_attributes,function(name){
        attr = _.detect(current_attributes,function(attr){return attr.name == name;});
        if(attr){
          custom_attributes.push(attr);
        } else {
          custom_attributes.push({name:name,value:''});
        }
      });
      this.set({custom_attributes: custom_attributes},{silent:true});
      this._custom_attributes_initialized = true;
    }
    return this.get('custom_attributes');
  },
  
  setCustomAttributes: function(updates){
    var custom_attributes = this.getCustomAttributes();
    _.each(custom_attributes,function(attr,i){
      if(attr.name && (updates[attr.name] !== undefined)){
        custom_attributes[i]['value'] = updates[attr.name];
      }
    });
    this.set({custom_attributes: custom_attributes});
  },
  
  renderCustomAttributes: function(){
    var label,html = '';
    _.each(this.getCustomAttributes(),function(attr){
      label = attr.name.replace('_',' ');
      if(revent.config.custom_event_options[attr.name]){
        html += '<div><label>'+label+'</label>';
        html += select_field( revent.config.custom_event_options[attr.name],
                              {name:attr.name,custom_attribute:true},
                              attr.value);
        html += '</div>';
      } else {
        html += '<div><label>'+label+'</label><input custom_attribute="true" name="'+attr.name+'" value="'+attr.value+'" /></div>';
      }
    });
    return html;
  },
  
  get_start: function(){
    var start = this.get('start');
    return start ? Date.parse(this.get('start')).toString('MM/dd/yyyy hh:mm tt') : null;
  },

  get_end: function(){
    return Date.parse(this.get('end')).toString('MM/dd/yyyy hh:mm tt'); 
  }  
});
