var Report = Backbone.Model.extend({
  urlRoot: '/admin/reports',
  model_name: 'report',

  save: function(attributes, options){
    var reporter_data = this.getReporterData();
    if(reporter_data) this.set({reporter_data:reporter_data},{silent: true});
    Backbone.Model.prototype.save.call(this, attributes, options);
  },
  
  getCalendar: function(){
    return revent.calendars.get(this.get('calendar_id'));
  },
  
  getEvent: function(){
    if(!this._event) this._event = new EventModel(this.get('event'));
    return this._event;
  },
  
  getUser: function(){
    if(!this._user) this._user = new User(this.get('user'));
    return this._user;
  },
  
  getReporterData: function(){
    var user = this.getUser();
    return {
      first_name: user.get('first_name'),
      last_name: user.get('last_name'),
      email: user.get('email')   
    };
  },
  
  getCreatedAt: function(){
    return Date.parse(this.get('created_at')).toString('MM/dd/yyyy'); 
  }
});
