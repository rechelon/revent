var EventFormView = Backbone.View.extend({

  events: {
    "change input"    : "updateModel",
    "change textarea" : "updateModel",
    "change select" : "updateModel",
    "change .calendar_select" : "updateCategories",
    "click .form-controls .button": "executeAction"
  },

  initialize: function(o) {
    _.bindAll(this, "render",'remove',"getFormData");
    this.column_count = o.column_count;
    this.template = o.template;
    this.model.bind('refresh', this.render);
    this.model.bind('destroy', this.remove);
  },
  
  getFormData: function(){
    return {
      event: this.model,
      calendar: this.model.getCalendar(),
      categories: this.model.getCategories(),
      calendars: revent.calendars
    };
  },
  
  render: function() {
    jq(this.el)
    .html(JST[this.template+'_form'](this.getFormData()))
    .wrapInner('<td colSpan="'+this.column_count+'">');
    
    jq("input.start",this.el).datetimepicker({
      changeMonth:true,
      ampm: true
    });
    jq("input.end",this.el).datetimepicker({
      changeMonth:true,
      ampm: true
    });    
    return this;
  },

  updateCategories: function(e){
    var field = e.target;
    var categories = revent.calendars.get(field.value).getCategories();
    jq(".category_wrapper", this.el).html(
      '<label for="sticky">Category</label>' +
      select_field(categories.toSelect(), {name:'category_id', class: 'category_select'})
    );
    this.model.set({'category_id': null});
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
  },
    
  executeAction: function(e){
    var form = this;
    switch(jq(e.target).attr('action')){
    
      case 'save':
        jq(e.target).addClass('button-loading');
        this.model.save({},{
          success:function(model,response){
            jq(e.target).removeClass('button-loading');
            growl('info','Event Saved');
            model.trigger('refresh');
          },
          error: function(model,response){
            jq(e.target).removeClass('button-loading');
            growl('error','Error Saving Event');
            jq('.errors',form.el).html(rails_error(response));
          }
        });
        break;
        
      case 'copy':
        new EventNewFormView({
          model: this.model.copy()
        }).render();
        break;
        
      case 'alert_nearby_supporters':
        jq(e.target).addClass('button-loading');
        jq.ajax({
          url: '/admin/events/alert_nearby_supporters/'+this.model.get('id'),
          success: function(data){
            dialog({
              title: 'Alert Nearby Supporters',
              content: data,
              buttons:{
                'Cancel': function(){
                }
              }
            });
            jq(e.target).removeClass('button-loading');
          }
        });
        break;
    }
    return false;
  }
  
});
