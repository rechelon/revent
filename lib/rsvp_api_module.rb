module RsvpAPI
  def fetch_rsvps options
    query = {}
    query[:conditions] = options_to_conditions options
    query[:limit] = options[:limit].to_i || 25

    total_pages = (Rsvp.find(:all, {
      :select=>'1',
      :conditions=>query[:conditions],
    }).count.to_f / query[:limit].to_f).ceil

    options[:current_page] = total_pages if(options[:current_page].to_i > total_pages)
    options[:current_page] = 1 if(options[:current_page].nil? || options[:current_page] == 0)
    query[:offset] = (options[:current_page].to_i - 1) * query[:limit].to_i

    query[:order] = query_order options[:order]
    rsvps = Rsvp.find(:all, query)

    if options[:send_x_headers] == "true"
      response.etag = nil
      response.headers['X-Current-Page'] = options[:current_page].to_s
      response.headers['X-Total-Pages'] = total_pages.to_s
    end

    rsvps
  end

  def options_to_conditions options
    throw "event or event_id required" unless options[:event] || options[:event_id]
    event = options[:event] || Event.find(options[:event_id])

    where = 'rsvps.event_id = :event_id'
    conditions = {:event_id => event.id}

    [where, conditions]
  end

  def query_order sort_param
  end
end
