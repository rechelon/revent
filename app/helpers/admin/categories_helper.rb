module Admin::CategoriesHelper
  def calendar_form_column(calendar, input_name)
    select_tag(input_name, options_for_select(Site.current.calendars.map{|c| [c.name, c.id]}, calendar.id))
  end
end
