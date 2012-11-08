module EventAPI

  def fetch_events options
    query = {}
    query[:conditions] = options_to_conditions options
    query[:limit] = options[:limit].to_i || 25
    query[:joins] = "LEFT JOIN events_sponsors ON events.id=events_sponsors.event_id"
    query[:joins] += " INNER JOIN users ON events.host_id = users.id" if options[:realhosts]
    query[:group] = "events.id"

    total_pages = (Event.find(:all, {
      :select=>'1',
      :conditions=>query[:conditions],
      :joins=>query[:joins],
      :group=>query[:group]
    }).count.to_f / query[:limit].to_f).ceil

    query[:include] = :custom_attributes
    
    options[:current_page] = total_pages if(options[:current_page].to_i > total_pages)
    options[:current_page] = 1 if(options[:current_page].nil? || options[:current_page] == 0)
    query[:offset] = (options[:current_page].to_i - 1) * query[:limit].to_i

    query[:order] = query_order options[:order]
    events = Event.find(:all, query)

    if options[:send_x_headers] == "true"
      response.etag = nil
      response.headers['X-Current-Page'] = options[:current_page].to_s
      response.headers['X-Total-Pages'] = total_pages.to_s
    end

    events
  end

  def query_order order_param
    case order_param
      when 'start'
        'events.start DESC'
      when 'start-asc'
        'events.start ASC'
      when 'end'
        'events.end DESC'
      when 'end-asc'
        'events.end ASC'
      when 'location'
        'events.State ASC, events.City ASC, events.Location ASC'
      when 'name'
        'events.name ASC'
      when 'host_last_name'
        'ISNULL(events.host_last_name), events.host_last_name ASC'
      else  
        'events.start DESC'
    end  
  end

  def options_to_conditions options
    throw "calendar or calendar_id required" unless options[:calendar] || options[:calendar_id]
    calendar = options[:calendar] || Calendar.find(options[:calendar_id])
    throw "calendar not valid" unless calendar.id

    calendar_ids = [calendar.id]
    calendar.calendars.each do |c|
      calendar_ids.push(c.id)
    end
    where = 'events.calendar_id in (:calendar_ids)'
    conditions = {:calendar_ids => calendar_ids}

    if !options[:category_id].blank?
      where += ' AND events.category_id = :category_id'
      conditions[:category_id] = options[:category_id]
    end

    if !options[:postal_code].blank?
      where += ' AND events.postal_code = :postal_code'
      conditions[:postal_code] = options[:postal_code]
    end

    if !options[:state].blank?
      where += ' AND events.state = :state'
      conditions[:state] = options[:state]
    end
    
    if !options[:date_range_start].blank?
      where += ' AND events.end > :date_range_start'
      conditions[:date_range_start] = options[:date_range_start].to_datetime
    else
      where += ' AND events.end > :date_range_start'
      conditions[:date_range_start] = calendar.past_event_cutoff
    end

    if !options[:date_range_end].blank?
      where += ' AND events.start <= :date_range_end'
      conditions[:date_range_end] = options[:date_range_end].to_datetime
    end

    if !options[:full_text].blank?
      where += " AND ((events.name LIKE :full_text) OR (events.location LIKE :full_text) OR (events.host_first_name LIKE :full_text) OR (events.host_last_name LIKE :full_text))"
      conditions[:full_text] = '%'+options[:full_text].to_s+'%'
    end

    if !options[:sponsor].blank?
      where += " AND events_sponsors.sponsor_id = :sponsor_id"
      conditions[:sponsor_id] = options[:sponsor]
    end

    if options[:restrict_to_admins] == "true"
      if !current_user.site_admin?
        if current_user.user_permissions_data[:sponsor_admin].length > 0
          where += ' AND events_sponsors.sponsor_id IN ('+current_user.user_permissions_data[:sponsor_admin].join(',')+')'
        else 
          where += ' AND false'
        end
      end
    end

    if options[:show_private_events] == "false"
      where += " AND events.private is not TRUE"
    end

    [where,conditions]
  end
end
