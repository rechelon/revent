function options_for_select(collection){
  var options = []
  _.each(collection,function(item){
    options.push([item.name, item.id]);
  });
  return options;
}