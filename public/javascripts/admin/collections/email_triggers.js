var EmailTriggerCollection = Backbone.Collection.extend({
  url : '/admin/triggers',
  model: EmailTrigger,
  initialize: function(){
    this.collection_name = 'email_triggers';
  }
});