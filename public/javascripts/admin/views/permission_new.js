var PermissionNewView = Backbone.View.extend({
  
  events: {
    "click .create-permission-btn": "showForm"
  },
  
  initialize: function(o) {
    _.bindAll(this, "render","save","renderForm","showForm","updateModel");
    this.template = o.template || 'permission_form';
    this.user = o.user;
  },
  
  render: function() {
    return this;
  },
  
  showForm: function(){
    var view = this;
    dialog({
      title: 'New Permission',
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
    this.model = new Permission({user_id:this.user.id});
    this.$form = jq('<div id="permission-new-form">').html(JST[this.template]({
      permission: this.model
    }));
    jq('select',this.$form).bind('change',this.updateModel);
    jq('select.permission_name_selector', this.$form).bind('change',function(e){
      switch(e.target.value){
        case 'sponsor_admin':
          jq('.sponsor-permission', this.$form).show();
          break;
        case 'site_admin':
          jq('.sponsor-permission', this.$form).hide();
          jq('.sponsor_admin_selector').val('');
          break;
      }
    });

    return this.$form;
  },
  
  updateModel: function(e){
    var field = e.target;
    var attr = {};
    switch(field.name){
      case 'name':
        attr['name'] = field.value;
        if(field.value == 'site_admin'){
          attr['value'] = "true";
        }
        break;
      case 'value':
        attr['value'] = field.value;
        break;
      default:
        attr[field.name] = field.value;
        break;
    }
    this.model.set(attr);
  },
  
  save: function(e,done,cancel){
    var user = this.user;
    var $form = this.$form;
    this.model.save({},{
      success:function(model,response){
        growl('info','Permission Created');
        user.getPermissions().add(model);
        done();
      },
      error: function(model,response){
        growl('error','Error Creating Permission');
        cancel();
        jq('.errors',$form).html(rails_error(response));
      }
    });
  }
});
