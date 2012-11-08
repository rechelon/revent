var Calendar = Backbone.Model.extend({
  urlRoot: '/admin/calendars',
  model_name: 'calendar',

  save: function(){
    this.set({'hostform':this.getHostForm().toJSON()});
    return Backbone.Model.prototype.save.apply(this,arguments);
  },

  expiration_date: function(){
    if(this.get('days_before_event_expiration')){
      return Date.parse('t - '+this.get('days_before_event_expiration')+' d').toString('MM/dd/yyyy'); 
    }
  },

  getStart: function(){
    if(!this.get('event_start')) return;
    return Date.parse(this.get('event_start')).toString('MM/dd/yyyy hh:mm tt'); 
  },

  getEnd: function(){
    if(!this.get('event_end')) return;
    return Date.parse(this.get('event_end')).toString('MM/dd/yyyy hh:mm tt'); 
  },

  getSuggestedStart: function(){
    if(!this.get('suggested_event_start')) return;
    return Date.parse(this.get('suggested_event_start')).toString('MM/dd/yyyy hh:mm tt'); 
  },

  getHostForm: function(){
    if(!this._hostform) this._hostform = new HostForm(this.get('hostform'));
    return this._hostform;
  },

  getEmailTriggers: function(){
    if(!this._triggers) this._triggers = new EmailTriggerCollection(this.get('triggers'));
    return this._triggers;
  },

  getCategories: function(){
    if(!this._categories) this._categories = new CategoryCollection(this.get('categories'));
    return this._categories;
  }
});
