var ZipCode = Backbone.Model.extend({
  urlRoot: '/'+revent.permalink+'/zip_codes',
  model_name: 'zip_code',
  
  initialize: function(o){
    this.params = {
      zip: o.zip,
      radius: o.radius
    };
  },

  fetch: function(options){
    options || (options = {});
    options.data = this.params;
    options.processData = true;
    Backbone.Model.prototype.fetch.call(this, options);
  }
});
