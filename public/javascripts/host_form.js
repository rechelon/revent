host_form = {
  event_saved_values: {},

  field_map : {
    'dataStreet' : 'event_location',
    'dataCity' :  'dataEventCity',
    'dataState' : 'dataEventState',
    'dataZip' :   'postal_code'
  },

  copy : function(){
    jq.each( host_form.field_map, function(host_field_id, event_field_id){
      jq('#'+event_field_id).val( jq('#'+host_field_id).val() );
    });
  },

  delete_current_values : function(){
    jq.each( host_form.field_map, function(host_field_id, event_field_id){
      jq('#'+event_field_id).val( '' );
    });
  },

  save_current_values : function(){
    jq.each( host_form.field_map, function(host_field_id, event_field_id){
      host_form.event_saved_values[event_field_id] = jq('#'+event_field_id).val();
    });
  },

  restore_previous_values : function(){
    jq.each( host_form.field_map, function(host_field_id, event_field_id){
      jq('#'+event_field_id).val( host_form.event_saved_values[event_field_id] );
    });
  }

};

jq(function(jq){
  // Hide address info when user clicks #locationlss
  jq('#locationless').live('click',function(){ 
    if(jq(this).attr('checked')){
      host_form.save_current_values();
      jq('.address-info').hide();
      host_form.delete_current_values();
      jq('#same-address-container').hide();
      jq('.address-info input').removeClass('required');
    } else {
      host_form.restore_previous_values();
      jq('.address-info').show();
      jq('#same-address-container').show();
      jq('.address-info input').addClass('required');
    }
  });

  // Copy host location to event location when user clicks #copy_host_info
  jq('#copy_host_info').live('click',function(){ 
    jq('#dataEvent_Name').focus();
    if(jq(this).attr('checked')){
      host_form.save_current_values();
      host_form.copy();
      jq('.address-info').hide();
      jq('#locationless-container').hide();
    } else {
      jq('.address-info').show();
      jq('#locationless-container').show();
      host_form.restore_previous_values();
    }
  });
  
  // event date picker
  var start_date_selected = false;
  var end_date_selected = false;
  var start_date = jq("input.event_start_date").datepicker({
    changeMonth:true,
    onSelect: function(selected_date){
      if(!end_date_selected) end_date.datepicker('setDate',selected_date);
      start_date_selected = true;
    }
  });
  var end_date = jq("input.event_end_date").datepicker({
    changeMonth:true,
    onSelect: function(selected_date){
      if(!start_date_selected) start_date.datepicker('setDate',selected_date);
      end_date_selected = true;
    }
  });

  jq("#tbd").change(function(){
    if(jq(this).is(':checked')) {
      jq('.time-fields').hide()
      jq('.time-labels').hide()
    } else {
      jq('.time-fields').show()
      jq('.time-labels').show()
    }
  });

  jq("#event_host").change(function(){
    if(jq(this).is(':checked')){
      jq('#not_event_host').hide();
      jq('#host_first_name, #host_last_name, #host_email').removeClass('required');
    } else {
      jq('#not_event_host').show();
      jq('#host_first_name, #host_last_name, #host_email').addClass('required');
    }
  });

});
