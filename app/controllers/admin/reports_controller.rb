class Admin::ReportsController < AdminController
  include ReportAPI
  before_filter :can_crud_report, :only => [:update, :destroy]
  cache_sweeper :report_sweeper, :only => [:create, :update, :destroy]
  admin = true


  def index
    respond_to do |format|
      format.html do
        redirect_to '/admin#reports'
      end
      format.json do
        params[:restrict_to_admins] = "true"
        params[:send_x_headers] = "true"
        render :json => fetch_reports(params).as_json(:include => [:event, :user])
      end
    end
  end

  def update
    params.delete :id
    params.delete :event
    params.delete :user
    new_attributes = {}
    @report.attribute_names.each{|key| new_attributes[key] = params[key] if !params[key].nil? }
    new_attributes[:reporter_data] = params[:reporter_data] unless params[:reporter_data].blank?
    logger.info new_attributes.inspect
    if @report.update_attributes(new_attributes)
      render :json => @report
    else
      render :json => @report.errors, :status => 500
    end
  end
  
  def destroy
    begin
      @report.destroy
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end

  def export
    params[:restrict_to_admins] = "true"
    params[:limit] = 8000

    @reports = fetch_reports params
    
    require 'fastercsv'
    string = FasterCSV.generate do |csv| 
      # Report Headers
      header_row = ['Published','Report Created','Reporter Name','Reporter Email','Text','Text2','Attendees','Attachment Count','Embeds Count']
      # Event Headers
      header_row.concat ["Event ID", "Event Name", "Start Date", "Start Time", "Address", "City", "State",
              "Postal Code", "District", "Directions","Short Description", "Long Description", "Host Name", "Host Email", "Host Phone",
              "Host Address", "RSVP","Report Backs","High Attendees", "Low Attendees", "Average Attendees", "Organized/Sponsored by", "Event Created","Private","Worksite Event"]
      header_row.concat Site.current.config.custom_attributes unless Site.current.config.custom_attributes.nil?
      custom_event_fields = @reports.inject([]) {|names, r| names << r.event.custom_attributes.map {|a| a.name }; names.flatten.compact.uniq }
      header_row.concat custom_event_fields
      csv << header_row
      @reports.each do |report|
        event = report.event
        host = event.host
        row = [(report.published? ? 'yes':'no'),report.created_at.to_s(:db),report.reporter_name,report.reporter_email,report.text,report.text2,report.attendees,report.attachments.count,report.embeds.count]
        row.concat [event.id, event.name, event.start.strftime("%m/%d/%Y"), event.start_time,
                event.location, event.city, event.state, event.postal_code, event.district,
                event.directions, event.short_description, event.description,
                (host ? host.full_name : nil), (host ? host.email : nil), (host ? host.phone : nil),
                (host ? host.address : nil), event.rsvps.count,event.reports.count, event.attendees_high,
                event.attendees_low, event.attendees_average, event.organization,
                event.created_at.to_s(:db), (event.private ? 'yes' : 'no'), (event.worksite_event) ]

        custom_fields = Array.new(Site.current.config.custom_attributes.length)
        if !host.nil? 
          host.custom_attributes.each do |attribute|
            index = Site.current.config.custom_attributes.index(attribute.name)
            custom_fields[index] = attribute.value unless index.nil?
          end
        end
        row.concat custom_fields
        row.concat custom_event_fields.map {|a| event.custom_attributes_data.send(a.to_sym) }
        csv << row
      end
    end
    send_data(string, :type => 'text/csv; charset=utf-8; header=present', :filename => "reports.csv")
  end 

private 

  def can_crud_report
    @report = Report.find(params[:id])
    if !current_user.site_admin?
      continue = false
      sponsors = Sponsor.find(:all, :conditions=>{:id=>current_user.user_permissions_data[:sponsor_admin]})
      sponsors.each do |s|
        if s.reports.include? @report
          continue = true
          break
        end
      end
      return unless continue
    end
  end

end
