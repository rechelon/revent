var RowView = Backbone.View.extend({
  className: "list-row",
  tagName: 'tr',
  
  events: {
    "click .list-data": "toggleForm",
    "click .save-btn": "save",
    "click .delete-btn": "destroy"
  },
  
  initialize: function(o) {
    _.bindAll(this, "render","toggleForm",'remove');
    this.form_visible = false;
    this.form_view = o.form_view;
    this.template = o.template;
    this.model.bind('change', this.render);
    this.model.bind('destroy', this.remove);
  },
  
  render: function() {
    jq(this.el).html(JST[this.template+'_row'](this.getRowData()));
    return this;
  },

  toggleForm: function(){
    if(this.form_visible){
      this.hideForm();
    } else {
      this.showForm();
    }
  },
  
  hideForm: function(){
    if(this.form){
      jq(this.form.el).hide();
      this.form_visible = false;  
    }
  },
  
  showForm: function(){
    if(this.form){
      jq(this.form.el).show();
    } else {
      this.form = new this.form_view({
        id: 'form-row-'+this.model.id,
        className:"form-row",
        tagName:'tr',
        model: this.model,
        template: this.template,
        column_count: this.columnCount()
      });
      this.form.render();
      jq(this.form.el).insertAfter(this.el);
    }  
    this.form_visible = true;    
  },
  
  columnCount: function(){
    return jq('td',this.el).length;
  },
  
  save: function(){
    var view = this;
    this.model.save({},{
      success: function(model,response){
        growl('info', model.model_name+' Saved');
        jq(view.el).removeClass('error');
        jq('.errors',view.form.el).empty();
      },
      error: function(model,response){
        growl('error','Error Saving '+model.model_name);
        view.showForm();
        jq(view.el).addClass('error');
        jq('.errors',view.form.el).html(rails_error(response));
      }
    });  
  },
  
  destroy: function(e){
    var view = this;
    var item = this.model;
    dialog({
      title: 'Delete '+item.model_name,
      content: 'Are you sure you want to delete this '+item.model_name+'?',
      buttons:{
        cancel: function(id,done){
          jq(e.target).removeClass('button-loading');
          done();
        },
        'delete': function(id,done,cancel){
          item.destroy({
            success: function(){
              growl('info', item.model_name+' deleted');
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

  getRowData: function(){
    throw 'Overwrite this method';
  }
});