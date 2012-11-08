var beach = {
  chunk: function(start, end, cb){
    setTimeout(function(){
      for(var i = start; i < end; i++){
        cb(i);
      }
    },0);
  },

  each_batch: function(elems, chunksize, cb){
    for(var i = 0; i < elems.length; i+= chunksize){
      this.chunk(i, Math.min(i+chunksize, elems.length - 1), function(index){
        cb(elems[index], index);
      });
    }
  }
}
