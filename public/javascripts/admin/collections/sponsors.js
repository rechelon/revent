var SponsorCollection = Backbone.Collection.extend({
  url : '/admin/sponsors',
  model: Sponsor,

  initialize: function(){
    this.collection_name = 'sponsors';
  },

  toSelect: function(include_choose){
    include_choose = !(include_choose === false);
    var options = [];
    if(include_choose){
      options.push(['Choose a sponsor', '']);
    }
    this.each(function(sponsor){
      options.push([sponsor.get('name'), sponsor.get('id')]);
    });
    return options;
  }

});
