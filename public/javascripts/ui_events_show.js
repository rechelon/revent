jq(document).ready(function(){
  if(document.cookie.indexOf('revent_auth') != -1){
    jq.ajax({
      url: '/'+permalink+'/rsvped/'+event_id,
      format: 'json',
      success: function(rsvped){
        jq('#event-rsvp-form .control-group').hide();
        if(rsvped){
          jq('#event-rsvp h3, #event-rsvp #event-rsvp-form-container, #event-rsvp #fb-rsvp-header').hide();
          jq('#event-rsvp h5').html('You have RSVPed for this event.');
        }
      }
    });

  }
});
