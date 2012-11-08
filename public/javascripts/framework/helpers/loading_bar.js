loading_bar = {

  progress_timer_id: undefined,
  
  loader: undefined,

  show : function(o){
    o = o || {};
    // set starting position
    var tick = o.start || 2;
    var stop_position = o.max || 95;
    var speed = o.speed || 10;
    
    // creat dialog box
    if(!this.loader){
      this.loader = jq(
        '<div id="loading" class="modal">'+
        '<div class="modal-header">'+
        '<strong>Loading</strong>'+
        '</div>'+
        '<div class="modal-body">'+
        '<div id="progress-bar" class="progress progress-striped active">'+
        '<div id="loading-bar" class="bar" stye="width:0%;">'+
        '</div></div></div></div>'
      ).appendTo('body')
      .modal({keyboard:false});
    }

    this.loader.modal('show');

    // stop current loading bar if there already is one
    if(loading_bar.progress_timer_id){
      loading_bar.hide();
    }

    // automatically increase loading bar
    loading_bar.progress_timer_id = setInterval(function(){
      tick = tick + (speed / tick);
      if(tick > stop_position){
        clearInterval(loading_bar.progress_timer_id);
      } else {
        jq( "#loading-bar" ).css({width: tick+'%'});
      }
    },0);
  },

  hide : function(){
    clearInterval(loading_bar.progress_timer_id);
    jq("#loading-bar").progressbar({value: 100});
    jq("#loading-bar").progressbar({value: 0});
    jq("#loading").modal('hide');
    loading_bar.progress_timer_id = undefined;
  }
};