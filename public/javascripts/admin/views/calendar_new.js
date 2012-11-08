var CalendarNewView = Backbone.View.extend({
  
  events: {
    "click #new-calendar-btn": "showForm"
  },
  
  initialize: function(o) {
    _.bindAll(this, "render","save","renderForm","showForm","updateModel");
    this.model = new Calendar();
  },
  
  render: function() {
    return this;
  },
  
  showForm: function(){
    var view = this;
    dialog({
      title: 'New Calendar',
      content:  this.renderForm(),
      width:'400px',
      buttons:{
        save: function(e,done,cancel){
          view.save(e,done,cancel);
          return true;          
        },
        cancel: function(){
          return false;
        }
      }
    });
  },
  
  renderForm: function(){
    this.model = new Calendar({site_id:revent.site_id});
    $new_form = jq('<div id="calendar-new-form">').html(JST['calendar_new_form']({
      calendar: this.model
    }));
    jq("input.event_start",$new_form).datetimepicker({
      changeMonth:true,
      ampm: true
    });
    jq("input.event_end",$new_form).datetimepicker({
      changeMonth:true,
      ampm: true
    });
    jq('input',$new_form).bind('change',this.updateModel);
    jq('textarea',$new_form).bind('change',this.updateModel);
    return $new_form;
  },
  
  updateModel: function(e){
    var field = e.target;
    var attr = {};
    if(field.type == 'checkbox'){
      attr[field.name] = field.checked;
    } else {
      attr[field.name] = field.value;
    }
    this.model.set(attr);
  },
  
  save: function(e,done,cancel){
    var form = this;
    this.model.save({},{
      success:function(model,response){
        growl('info','Calendar Created');
        revent.calendars.add(form.model);
        done();
      },
      error: function(model,response){
        growl('error','Error Creating Calendar');
        cancel();
        jq('.errors','#calendar-new-form').html(rails_error(response));
      }
    });
  }
});