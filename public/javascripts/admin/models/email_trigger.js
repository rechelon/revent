var EmailTrigger = Backbone.Model.extend({
  urlRoot: '/admin/triggers',
  model_name: 'email_trigger',
  getTypes: function(){
    return {
      "":"- select -",
      "Host Thank You":"Host Thank You",
      "RSVP Thank You":"RSVP Thank You",
      "Report Thank You":"Report Thank You",
      "Report Host Reminder":"Report Host Reminder",
      "Report Attendee Reminder":"Report Attendee Reminder",
      "Email Nearby Supporters About New Event":"Email Nearby Supporters About New Event",
      "RSVP Notify Host": "RSVP Notify Host"
    };
  }    
});
