var EmailTriggerFormView = Backbone.View.extend({

  events: {
    "change input"    : "updateModel",
    "change textarea" : "updateModel",
    "change select" : "updateModel"
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
      trigger: this.model
    }
  },
  
  render: function() {
    // check if we are a row in a table
    if(this.column_count){
      jq(this.el)
      .html(JST[this.template+'_form'](this.getFormData()))
      .wrapInner('<td colSpan="'+this.column_count+'">');
    }else{
      jq(this.el).html(JST[this.template+'_form'](this.getFormData()));
    }
    
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
    this.model.set(attr);
  }
  
});