var ThemeElementFormView = Backbone.View.extend({

  events: {
    "change select" : "updateModel",
  },

  initialize: function(o) {
    _.bindAll(this, "render",'remove',"getFormData");
    this.column_count = o.column_count;
    this.template = o.template;
    this.model.bind('destroy', this.remove);
  },

  render: function() {
    jq(this.el)
    .html(JST[this.template+'_form'](this.getFormData()))
    .wrapInner('<td colSpan="'+this.column_count+'">');

    var theme_element = this.model; 
    var editor = ace.edit(jq('.markdown-text', this.el)[0]);
    editor.setTheme("ace/theme/monokai");
    editor.getSession().setMode("ace/mode/html");
    editor.setValue(_.unescape(this.model.get('escaped_markdown')));
    editor.getSession().getSelection().clearSelection();
    editor.getSession().on('change', function(e) {
      theme_element.set({'markdown': editor.getValue()});
    });
    
    return this;
  },

  getFormData: function(){
    return {
      theme_element: this.model,
      collection: this.collection
    };

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
