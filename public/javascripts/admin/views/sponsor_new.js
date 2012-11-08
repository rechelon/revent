var SponsorNewView = Backbone.View.extend({
  
  events: {
    "click #new-sponsor-btn": "showForm"
  },
  
  initialize: function(o) {
    _.bindAll(this, "render","save","renderForm","showForm","updateModel");
    this.model = new Sponsor();
  },
  
  render: function() {
    return this;
  },
  
  showForm: function(){
    var view = this;
    dialog({
      title: 'New Sponsor',
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
    this.model = new Sponsor({site_id:revent.site_id});
    $new_form = jq('<div id="sponsor-new-form">').html(JST['sponsor_new_form']({
      sponsor: this.model
    }));
    jq('input',$new_form).bind('change',this.updateModel);
    jq('textarea',$new_form).bind('change',this.updateModel);
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
        growl('info','Sponsor Created');
        revent.sponsors.add(form.model);
        done();
      },
      error: function(model,response){
        growl('error','Error Creating Sponsors');
        cancel();
        jq('.errors','#sponsor-new-form').html(rails_error(response));
      }
    });
  }
});
