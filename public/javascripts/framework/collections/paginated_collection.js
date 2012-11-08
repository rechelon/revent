/* 
  PaginatedCollection - simple extension for dealing with pagination.

  this.params - query params sent to server on fetch()
  this.params.current_page - requested page
  
  on fetch(), expects server to return headers X-Total-Pages and X-Current-Page
*/
PaginatedCollection = Backbone.Collection.extend({

  parse: function(resp,xhr){
    this.total_pages = Number(xhr.getResponseHeader('X-Total-Pages'));
    this.params.current_page = Number(xhr.getResponseHeader('X-Current-Page'));
    return resp;
  },

  fetch: function(options){
    options || (options = {});
    options.data = this.params;
    options.processData = true;
    Backbone.Collection.prototype.fetch.call(this, options);
  },
  
  add_to_front: function(model){
    this.models.unshift(model);
    this.trigger('add');
  }  
})
