var RowView = Backbone.View.extend({
  className: "list-row",
  tagName: 'tr',
  
  events: {
    "click .save-btn": "save",
    "click .delete-btn": "destroy"
  },
  
  initialize: function(o) {
    this.template = o.template;
    this.model.bind('change', this.render);
    this.model.bind('destroy', this.remove);
  },
  
  render: function() {
    jq(this.el).html(JST[this.template+'_row'](this.getRowData()));
    return this;
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
      },
      error: function(model,response){
        growl('error','Error Saving '+model.model_name);
        jq(view.el).addClass('error');
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
