class Admin::UsersController < AdminController  
  before_filter :can_crud_user, :only => [:update, :destroy, :reset_password, :log_in_as]

  def index
    respond_to do |format|
      format.html do
        redirect_to '/admin#users'
      end
      format.json do
        @query = {}
        @query[:conditions] = params_to_conditions
        @query[:limit] =  params[:limit] || 25
        @query[:joins] = "LEFT JOIN sponsors_users ON users.id=sponsors_users.user_id"
        @query[:group] = "users.id"
        
        total_pages = (User.find(:all, {:select=>'1',:conditions=>@query[:conditions], :joins=>@query[:joins], :group=>@query[:group]}).count.to_f / @query[:limit].to_f).ceil
        
        params[:current_page] = total_pages if(params[:current_page].to_i > total_pages)
        params[:current_page] = 1 if(params[:current_page].nil? || params[:current_page] == 0)        
        @query[:offset] = (params[:current_page].to_i - 1) * @query[:limit].to_i
        
        @query[:order] = query_order params[:order]      
        
        @query[:include] = [:events, :attending, :permissions]
        
        @users = User.find(:all, @query)
        
        response.etag = nil
        response.headers['X-Current-Page'] = params[:current_page].to_s
        response.headers['X-Total-Pages'] = total_pages.to_s
        render :json => @users
      end
    end
  end
  
  def query_order order_param
    case order_param
      when 'last_name'
        'ISNULL(users.last_name), users.last_name ="", users.last_name ASC'
      when 'first_name'
        'ISNULL(users.first_name), users.first_name ="", users.first_name ASC'
      when 'location'
        'ISNULL(users.state), users.state="", users.state ASC, ISNULL(users.postal_code), users.postal_code="", users.postal_code ASC, ISNULL(users.street), users.street="", users.street ASC, users.street_2 ASC'
      else  
        'ISNULL(users.last_name), users.last_name ="", users.last_name ASC'
    end        
  end
    
  def params_to_conditions
    where = 'users.site_id = :site_id'
    conditions = {:site_id => (Site.current.id)}
    if !params[:postal_code].blank?
      where += ' AND users.postal_code = :postal_code'
      conditions[:postal_code] = params[:postal_code]
    end
    if !params[:state].blank?
      where += ' AND users.state = :state'
      conditions[:state] = params[:state]
    end
    if !params[:date_range_start].blank?
      where += ' AND users.created_at > :date_range_start'
      conditions[:date_range_start] = params[:date_range_start].to_datetime
    end
    if !params[:date_range_end].blank?
      where += ' AND users.created_at < :date_range_end'
      conditions[:date_range_end] = params[:date_range_end].to_datetime
    end
    if !params[:full_text].blank?
      where += " AND ((users.email LIKE :full_text) OR (users.first_name LIKE :full_text) OR (users.last_name LIKE :full_text))"
      conditions[:full_text] = '%'+params[:full_text].to_s+'%'
    end
    if !params[:permission].blank?
      permission_name, permission_value = params[:permission].split('|')
      where += " AND user_permissions.name = :permission_name AND user_permissions.value = :permission_value"
      conditions[:permission_name] = permission_name
      conditions[:permission_value] = permission_value
    end
    if !current_user.site_admin?
      if current_user.user_permissions_data[:sponsor_admin].length > 0
        where += ' AND sponsors_users.sponsor_id IN ('+current_user.user_permissions_data[:sponsor_admin].join(',')+')'
      else 
        where += ' AND false'
      end
    end
    if !params[:sponsor].blank?
      where += " AND sponsors_users.sponsor_id = :sponsor_id"
      conditions[:sponsor_id] = params[:sponsor]
    end
    [where,conditions]
  end
 
  def create
    @user = User.new
    update
    if !current_user.site_admin?
      if current_user.user_permissions_data[:sponsor_admin].length > 0
        sponsors = Sponsor.find(:all, :conditions=>{:id=>current_user.user_permissions_data[:sponsor_admin]})
        sponsors.each do |s|
          s.users << @user unless s.users.include? @user
        end
      end
    end
  end

  def update
    if !current_user.site_admin?
      params.delete :admin
    end
    new_attributes = {}
    @user.attribute_names.each{|key| new_attributes[key] = params[key] if !params[key].nil? }
    if @user.update_attributes(new_attributes)
      render :json => @user
    else
      render :json => @user.errors, :status => 500
    end
  end
  
  def destroy
    begin
      @user.destroy
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end
  
  def reset_password
    if request.post?      
      @user.password = params[:password] if params[:password]
      @user.password_confirmation = params[:password_confirmation] if params[:password_confirmation]
      @user.activated_at = Time.now.utc
      if @user.save
        @user.sync_unless_deferred
        render :text => "Password reset for " + @user.full_name
      else
        render :json => @user.errors, :status => 500
      end
    else
      render :layout => false
    end
  end

  def export
    @query = {}
    @query[:conditions] = params_to_conditions
    @query[:include] = [:custom_attributes, :attending, :events]
    @query[:order] = query_order params[:order]
    @query[:joins] = "LEFT JOIN user_permissions ON users.id=user_permissions.user_id LEFT JOIN sponsors_users ON users.id=sponsors_users.user_id"
    @query[:group] = "users.id"
    @users = Site.current.users.find(:all, @query)
    @attribute_names = @users.inject([]) {|names, u| names << u.custom_attributes.map {|a| a.name }; names.flatten.compact.uniq }
    require 'fastercsv'
    string = FasterCSV.generate do |csv|
      csv << ["Email", "First_Name", "Last_Name", "Phone", "Street", "Street_2", "City", "State", "Postal_Code", "Partner_Code", "Effective Calendar", "Hosted_Events", "Events_Hosting_IDS", "Events_Attending_IDS"] + @attribute_names
      @users.each do |user|
        csv << [user.email, user.first_name, user.last_name, user.phone, user.street, user.street_2, user.city, user.state, user.postal_code, user.partner_id, user.effective_calendar.name] + [user.events.map{|e|e.name}.join('; '), user.event_ids.map{|id| id.to_s}.join(','), user.attending_ids.map{|id| id.to_s}.join(',') ] + @attribute_names.map {|a| user.custom_attributes_data.send(a.to_sym) }
      end
    end
    send_data(string, :type => 'text/csv; charset=utf-8; header=present', :filename => "users.csv")
  end

  def log_in_as
    self.current_user = @user
    cookies[:info] = "You are now logged in as "+@user.full_name+" &lt;"+@user.email+"&gt;"
    redirect_to home_url
  end

private
  def can_crud_user
    @user = User.find(params[:id])
    if !current_user.site_admin?
      continue = false
      sponsors = Sponsor.find(:all, :conditions=>{:id=>current_user.user_permissions_data[:sponsor_admin]})
      sponsors.each do |s|
        if s.users.include? @user
          continue = true
          break
        end
      end
      return unless continue
    end
  end

end
