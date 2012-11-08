var ThemeNewView = Backbone.View.extend({
  
  events: {
    "click #new-theme-btn": "showForm"
  },
  
  initialize: function(o) {
    _.bindAll(this, "render","save","renderForm","showForm","updateModel");
    this.model = new Theme();
  },
  
  render: function() {
    return this;
  },
  
  showForm: function(){
    var view = this;
    dialog({
      title: 'New Theme',
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
    this.model = new Theme({site_id:revent.site_id});
    $new_form = jq('<div id="theme-new-form">').html(JST['theme_new_form']({
      theme: this.model
    }));
    jq('input',$new_form).bind('change',this.updateModel);
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
        growl('info','Theme Created');
        revent.themes.add(form.model);
        model.trigger('refresh');
        done();
      },
      error: function(model,response){
        growl('error','Error Creating Theme');
        cancel();
        jq('.errors','#theme-new-form').html(rails_error(response));
      }
    });
  }
});
