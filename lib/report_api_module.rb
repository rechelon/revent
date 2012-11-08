module ReportAPI

  def fetch_reports options
    query = {}
    query[:conditions] = options_to_conditions options
    query[:limit] =  options[:limit] || 25
    query[:joins] = "INNER JOIN `events` ON `events`.id = `reports`.event_id INNER JOIN `users` ON `users`.id = `reports`.user_id LEFT JOIN reports_sponsors ON reports.id=reports_sponsors.report_id"
    query[:joins] += options_to_joins options
    query[:group] = "reports.id"

    total_pages = (Report.find(:all, {:select=>'1',:conditions=>query[:conditions],:joins=>query[:joins]}).count.to_f / query[:limit].to_f).ceil

    options[:current_page] = total_pages if(options[:current_page].to_i > total_pages)
    options[:current_page] = 1 if(options[:current_page].nil? || options[:current_page] == 0)
    query[:offset] = (options[:current_page].to_i - 1) * query[:limit].to_i
    
    query[:order] = query_order options[:order]
    
    query[:include] = :event, :user
    
    reports = Report.find(:all, query)
    
    if options[:send_x_headers] == "true"
      response.etag = nil
      response.headers['X-Current-Page'] = options[:current_page].to_s
      response.headers['X-Total-Pages'] = total_pages.to_s
    end

    reports
  end

  def query_order sort_param
    case sort_param
      when 'event_date'
        'events.start desc'
      when 'event_name'
        'events.name asc'
      when 'first_name'
        'ISNULL(users.first_name), users.first_name ="", users.first_name ASC'
      when 'last_name'
        'ISNULL(users.last_name), users.last_name ="", users.last_name ASC'
      when 'email'
        'users.email asc'
      when 'location'
        'events.state ASC, events.city ASC, events.location ASC'
      when 'status'
        'reports.status asc'
      when 'attendees'
        'reports.attendees desc'
      else
        'reports.created_at desc'
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
    where = 'reports.calendar_id in (:calendar_ids)'
    conditions = {:calendar_ids => calendar_ids}

    if !options[:postal_code].blank?
      where += ' AND events.postal_code = :postal_code'
      conditions[:postal_code] = options[:postal_code]
    end

    if !options[:nearby_zip].blank?
      zip = ZipCode.find_by_zip(options[:nearby_zip])
      zips = zip.find_objects_within_radius(100) do |min_lat, min_lon, max_lat, max_lon|
        ZipCode.find(
          :all,
          :conditions => [
            "(latitude > ? AND longitude > ? AND latitude < ? AND longitude < ? ) ",
            min_lat, 
            min_lon, 
            max_lat, 
            max_lon
          ]
        )
      end
      zip_codes = []
      zips.each do |z|
        zip_codes.push(z.zip)
      end
      where += ' AND events.postal_code IN ( '+ zip_codes.join(',') +' )'
    end

    if !options[:state].blank?
      where += ' AND events.state = :state'
      conditions[:state] = options[:state]
    end

    if !options[:status].blank?
      where += ' AND reports.status = :status'
      conditions[:status] = options[:status]
    end

    if !options[:date_range_start].blank?
      where += ' AND events.start > :date_range_start'
      conditions[:date_range_start] = options[:date_range_start].to_datetime
    end
    if !options[:date_range_end].blank?
      where += ' AND events.start <= :date_range_end'
      conditions[:date_range_end] = options[:date_range_end].to_datetime
    end

    if !options[:full_text].blank?
      where += " AND ((events.name LIKE :full_text) OR (users.email LIKE :full_text) OR (users.first_name LIKE :full_text) OR (users.last_name LIKE :full_text))"
      conditions[:full_text] = '%'+options[:full_text].to_s+'%'
    end

    if !options[:sponsor].blank?
      where += " AND reports_sponsors.sponsor_id = :sponsor_id"
      conditions[:sponsor_id] = options[:sponsor]
    end

    if !options[:published].blank?
      where += " AND reports.status = 'published'"
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

    [where,conditions]
  end

  def options_to_joins options
    join = ""
    if options[:content_image] == 'true'
      join += " INNER JOIN attachments ON attachments.report_id = reports.id AND attachments.content_type LIKE '%image%'"
    end
    if options[:content_document] == 'true'
      join += " INNER JOIN attachments AS attachments2 ON attachments2.report_id = reports.id AND attachments2.content_type IN ('"+Attachment.document_content_types.join("','")+"')"
    end
    if options[:content_video] == 'true'
      join += " INNER JOIN embeds ON embeds.report_id = reports.id"
    end
    join
  end

end
