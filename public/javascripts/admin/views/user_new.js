var UserNewView = Backbone.View.extend({
  
  events: {
    "click .upsert-user-btn": "showForm"
  },
  
  initialize: function(o) {
    _.bindAll(this, "render","save","renderForm","showForm","updateModel");
    this.template = o.template || 'user_form';
  },
  
  render: function() {
    return this;
  },
  
  showForm: function(){
    var view = this;
    dialog({
      title: 'New User',
      content:  this.renderForm(),
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
    this.model = new User({site_id:revent.site_id});
    var $form = jq('<div id="user-new-form">').html(JST[this.template]({
      user: this.model
    }));
    jq('input',$form).bind('change',this.updateModel);
    jq('textarea',$form).bind('change',this.updateModel);
    return $form;
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
        growl('info','User Created');
        revent.users.add(form.model);
        done();
      },
      error: function(model,response){
        growl('error','Error Creating User');
        cancel();
        jq('.errors','#user-new-form').html(rails_error(response));
      }
    });
  }
});
