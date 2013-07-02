var SiteFormView = Backbone.View.extend({
  initialize: function(o){
    _.bindAll(this, "render","getFormData");
    this.template = o.template;
  },

  getFormData: function(){
    return {
      site: this.model
    };
  },

  render: function(){
    jq(this.el)
    .html(JST['site_form'](this.getFormData()))
    return this;
  }

});
