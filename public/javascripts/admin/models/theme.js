var Theme = Backbone.Model.extend({
  urlRoot: '/admin/themes',
  model_name: 'theme',

  getElements: function(){
    if(!this._elements) this._elements = new ThemeElementCollection(this.get('elements'));
    this._elements.theme = this;
    return this._elements;
  },

  elementsToSelect: function(current_element){
    var elements_available = revent.theme_element_names;
    this.getElements().each(function(element){
      var name = element.get('name');
      if(name != current_element){
        elements_available = _.without(elements_available, name);
      }
    });
    var options = {'':''};
    _.each(elements_available, function(element_available){
      options[element_available] = element_available;
    });
    return options;
  }

});
