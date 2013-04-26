var UserFormView = Backbone.View.extend({

  events: {
    "change input"    : "updateModel",
    "change textarea" : "updateModel",
    "click .form-controls .button": "executeAction",
    "change .admin-user" : "adminChanged"
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
      user: this.model
    };
  },
  
  render: function() {
    jq(this.el)
    .html(JST[this.template+'_form'](this.getFormData()))
    .wrapInner('<td colSpan="'+this.column_count+'">');
    
    if(revent.current_user.is_site_admin()){
      this.renderPermissions();
    }
    return this;
  },
  
  renderPermissions: function(){
    new ListView({
      el: jq(".permission-list",this.el)[0],
      paginated: false,
      collection: this.model.getPermissions(),
      template: 'permission',
      row_view: PermissionRowView,
      form_view: PermissionFormView
    }).render();
    
    new PermissionNewView({
      el: jq('.create-permission',this.el)[0],
      user: this.model
    });
  },

  newPermission: function(){
    var permission = new Permission({user_id: this.model.get('id')});
    var form = new PermissionFormView({ model:permission, template:'permission'});
    var user = this.model;
    form.render();
    dialog({
      title: 'New Permission',
      content: form.el,
      buttons:{
        Cancel: function(){
          return false;
        },
        Save: function(e, done, cancel){
          permission.save({},{
            success: function(model,response){
              growl('info','Permission Created');
              done();
              user.getPermissions().add(permission);
            },
            error: function(model,response){
              growl('error','Error Creating Permission');
              jq('.errors',form.el).html(rails_error(response));
              cancel();
            }
          });
          return true;
        }
      }
    });
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
  
  executeAction: function(e){
    var form = this;
    switch(jq(e.target).attr('action')){
      case 'save':
        jq(e.target).addClass('button-loading');
        this.model.save({},{
          success:function(model,response){
            jq(e.target).removeClass('button-loading');
            growl('info','User Saved');
            this.trigger('refresh');
          },
          error: function(model,response){
            jq(e.target).removeClass('button-loading');
            growl('error','Error Saving User');
            jq('.errors',form.el).html(rails_error(response));
          }
        });
        
        break;
      case 'reset_password':
        dialog({
          title: 'Reset Password',
          content: JST.user_reset_password({
            name: form.model.get('first_name')+' '+form.model.get('last_name')
          }),
          buttons:{
            Cancel: function(){},
            Reset: function(e,done,cancel){
              jq.ajax({
                url: '/admin/users/reset_password/'+form.model.get('id'),
                type: 'POST',
                data: jq('#reset-password-form').serialize(),
                success: function(data){
                  growl('info',data);
                  done();
                },
                error: function(data){
                  growl('error','Unable to reset password');
                  jq('#reset-password-form-errors').html(rails_error(data));
                  cancel();
                }
              });
              return true;
            }
          }
        });
        break;
      case 'log_in_as':
        document.location = '/admin/users/log_in_as/'+form.model.id; 
        break;
    }
    return false;
  },

  adminChanged: function(e){
    if(e.target.checked){
      jq('.permission-list, .create-permission',this.el).show();
    } else {
      jq('.permission-list, .create-permission',this.el).hide();
    }
  }
});
