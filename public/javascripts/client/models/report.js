var Report = Backbone.Model.extend({
  urlRoot: '/'+revent.calendar_permalink+'/reports',
  model_name: 'report',

  getEvent: function(){
    if(!this._event) this._event = new EventModel(this.get('event'));
    return this._event;
  },
  
  getUser: function(){
    if(!this._user) this._user = new User(this.get('user'));
    return this._user;
  }
});
