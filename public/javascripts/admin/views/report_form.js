var ReportFormView = Backbone.View.extend({

  events: {
    "change input"    : "updateModel",
    "change textarea" : "updateModel",
    "change select" : "updateModel",
    "click .form-controls .button": "executeAction"
  },

  initialize: function(o) {
    _.bindAll(this, "render",'remove',"getFormData");
    this.column_count = o.column_count;
    this.template = o.template;
    this.bind('refresh', this.render);
    this.model.bind('destroy', this.remove);
  },
  
  getFormData: function(){
    return {
      report: this.model,
      event: this.model.getEvent(),
      user: this.model.getUser()
    };
  },
  
  render: function() {
    jq(this.el)
    .html(JST[this.template+'_form'](this.getFormData()))
    .wrapInner('<td colSpan="'+this.column_count+'">');

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
    if(jq(field).attr('model') === 'user'){
      this.model.getUser().set(attr);
    } else {
      this.model.set(attr);
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
            growl('info','Report Saved');
            this.trigger('refresh');
          },
          error: function(model,response){
            jq(e.target).removeClass('button-loading');
            growl('error','Error Saving Report');
            jq('.errors',form.el).html(rails_error(response));
          }
        });
        
        break;
    }
    return false;
  }
  
});