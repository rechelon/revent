module Admin::UsersHelper
  def events_column(user)
    user.events.collect do |e| 
      link_to("#{e.start.strftime('%m/%e')} - #{e.name}", :permalink => e.calendar.permalink, :controller => '/events', :action => 'show', :id => e.id)
    end.join('<br/>')    
  end

  def attending_column(user)
    user.attending.collect do |e| 
      link_to("#{e.start.strftime('%m/%e')} - #{e.name}", :permalink => e.calendar.permalink, :controller => '/events', :action => 'show', :id => e.id)
    end.join('<br/>')
  end
  
  def created_at_column(user)
    "#{user.created_at.strftime('%m/%d/%Y')}"
  end
  
  def effective_calendar_column(user)
    user.effective_calendar.name
  end
  
  def state_form_column(user, input_name)
    select_tag(input_name, options_for_select(DemocracyInAction::Helpers.state_options_for_select(:include_provinces => true).unshift(['Not set', 0]), user.state))
  end
  
=begin
  def country_form_column(user, input_name)
    select_tag(input_name, options_for_select(CountryCodes::countries_for_select('name', 'numeric').sort.unshift(['Not set', 0]), user.country_code))
  end
=end  
end
