var EventNewFormView = Backbone.View.extend({

  events: {
    "change input"    : "updateModel",
    "change textarea" : "updateModel",
    "change select" : "updateModel"
  },

  initialize: function(o) {
    _.bindAll(this, "render",'remove',"getFormData");
  },
  
  getFormData: function(){
    return {
      event: this.model,
      calendar: this.model.getCalendar(),
      categories: this.model.getCategories()
    };
  },
  
  render: function() {
    var event = this.model;
    
    var form = dialog({
      title: 'New Event',
      width: '600px',
      content: JST['event_new_form'](this.getFormData()),
      buttons: {
        save: function(e,done,cancel){
          event.save({},{
            success: function(model,response){
              growl('info','New Event Created');
              revent.events.add_to_front(event);
              done();
              jq('html, body').animate({scrollTop:0}, 500);              
            },
            error: function(model,response){
              growl('error','Error Saving Event');
              jq('.errors',form).html(rails_error(response));
              cancel();
            }
          });
          return true;
        },
        cancel: function(e,done,cancel){
          return false;
        }
      }
    });
    
    // reset the form element and re-bind events to the dialog window
    this.el = form[0];
    this.delegateEvents();
    
    jq("input.start",form).datetimepicker({
      changeMonth:true,
      ampm: true
    });
    jq("input.end",form).datetimepicker({
      changeMonth:true,
      ampm: true
    });    
    return this;
  },
  
  updateModel: function(e){
    var field = e.target;
    var attr = {};
    if(field.type == 'checkbox'){
      attr[field.name] = field.checked;
    } else {
      attr[field.name] = field.value;
    }
    // check to see if input is a custom attribute
    if(field.attributes.custom_attribute === undefined){
      this.model.set(attr);
    } else {
      this.model.setCustomAttributes(attr);
    }
  }
  
});