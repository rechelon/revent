var ThemeRowView = Backbone.View.extend({

  events: {
    "change .theme-form-page input" : "updateTheme",
    "change .theme-form-page textarea" : "updateTheme",
    "change .theme-form-page select" : "updateTheme",
    "click .theme-save-btn": "save",
    "click .theme-clone-btn": "clone",
    "click .theme-delete-btn": "destroy",
    "click .new-theme-element-btn" : "newThemeElement"
  },

  initialize: function(o) {
    _.bindAll(this, "render",'remove',"updateClone");
    this.model.bind('refresh', this.render);
    this.model.bind('destroy', this.remove);
  },

  render: function() {
    jq(this.el).html(JST['theme_row'](this.getRowData()));
    this.renderElements();
    
    return this;
  },

  renderElements: function(){
    new ListView({
      el: jq(".theme-element-list", this.el)[0],
      collection: this.model.getElements(),
      template: 'theme_element',
      row_view: ThemeElementRowView,
      form_view: ThemeElementFormView,
      paginated: false
    }).render();
  },

  getRowData: function(){
    return {
      theme: this.model
    };
  },

  updateModel: function(e, model){
    var field = e.target;
    var attr = {};
    if(field.type == 'checkbox'){
      attr[field.name] = field.checked;
    } else {
      attr[field.name] = field.value;
    }
    model.set(attr);
  },

  updateTheme: function(e){
    this.updateModel(e, this.model);
  },

  updateClone: function(e){
    this.updateModel(e, this.cloned_model);
  },

  renderCloneForm: function(){
    this.cloned_model = new Theme();
    $new_form = jq('<div id="theme-new-form">').html(JST['theme_new_form']({}));
    jq('input',$new_form).bind('change',this.updateClone);
    return $new_form;
  },

  save: function(e){
    var view = this;
    jq(e.target).addClass('button-loading');
    this.model.save({},{
      success:function(model,response){
        jq(e.target).removeClass('button-loading');
        growl('info','Theme Saved');
        model.trigger('refresh');
      },
      error: function(model,response){
        jq(e.target).removeClass('button-loading');
        growl('error','Error Saving Theme');
        jq('.errors',view.el).html(rails_error(response));
      }
    });
    return false;
  },

  clone: function(e){
    var view = this;
    dialog({
      title: 'Clone Theme',
      content:  this.renderCloneForm(),
      width:'400px',
      buttons:{
        save: function(e,done,cancel){
          $.ajax({
            url: view.cloned_model.urlRoot+'/clone/'+view.model.id,
            type: 'POST',
            data: {name: view.cloned_model.get('name')},
            success: function(response){
              growl('info','Theme Cloned');
              view.cloned_model = new Theme(response);
              revent.themes.add(view.cloned_model);
              view.cloned_model.trigger('refresh');
              done();
            },
            error: function(){
              growl('error','Error Cloning Theme');
              done();
            }
          });
          return true;          
        },
        cancel: function(){
          return false;
        }
      }
    });

  },

  destroy: function(e){
    var view = this;
    var theme = this.model;
    dialog({
      title: 'Delete Theme',
      content: 'Are you sure you want to delete this theme?',
      buttons:{
        cancel: function(id,done){
          jq(e.target).removeClass('button-loading');
          done();
        },
        'delete': function(id,done,cancel){
          theme.destroy({
            success: function(){
              growl('info', 'theme deleted');
              done();              
            },
            error: function(model,resp,options){
              growl('error',resp.responseText);
              jq(view.el).addClass('error');              
              done();
            }
          });
          return true;
        }
      }
    });    
    return false;
  },

  newThemeElement: function(e) {
    var element = new ThemeElement({theme_id: this.model.get('id')});
    var form = new ThemeElementFormView({
      model:element,
      template:'theme_element_new',
      collection: this.model.getElements()
    });
    var theme = this.model;
    form.render();
    dialog({
      title: 'New Theme Element',
      content: form.el,
      width:'550px',
      buttons:{
        Cancel: function(){
          return false;
        },
        Save: function(e, done, cancel){
          if(
            element.get('name') == "" ||
            element.get('name') == undefined
          ){
            growl('warning','Not creating element without name');
            cancel();
            return true;
          }
          element.save({},{
            success: function(model,response){
              growl('info','Theme Element Created');
              done();
              theme.getElements().add(element);
            },
            error: function(model,response){
              growl('error','Error Creating Theme Element');
              jq('.errors',form.el).html(rails_error(response));
              cancel();
            }
          });
          return true;
        }
      }
    });
  }
 
});
