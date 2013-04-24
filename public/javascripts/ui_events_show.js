jq(document).ready(function(){
  function already_rsvped(){
    jq('#event-rsvp h3, #event-rsvp #event-rsvp-form-container, #event-rsvp #fb-rsvp-header').hide();
    jq('#event-rsvp h5').html('You have RSVPed for this event.');
  }
  if(document.cookie.indexOf('revent_auth') != -1){
    if(typeof(rsvp_success) == "undefined"){
      jq.ajax({
        url: '/'+permalink+'/rsvped/'+event_id,
        format: 'json',
        success: function(rsvped){
          jq('#event-rsvp-form .control-group').hide();
          if(rsvped){
            already_rsvped();
          }
        }
      });
    } else if(rsvp_success) {
      already_rsvped();
    }
  }
});
