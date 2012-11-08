var UserCollection = PaginatedCollection.extend({
  url : '/admin/users',
  model: User,
  initialize: function(){
    this.collection_name = 'users';
    this.params = {
      order: 'last_name',
      limit: 25,
      current_page: 1
    };
  }
});
