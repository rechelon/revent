class Account::BlogsController < AccountControllerShared
  before_filter :find_blog, :except => :create
  before_filter :login_required
  after_filter :expire_page_cache

  def create
    @blog = Blog.new(params[:blog])
    @blog.save!
    flash[:notice] = 'Announcement saved'
    redirect_to :permalink => @calendar.permalink, :controller => 'account/events', :action => 'show', :id => @blog.event_id
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = 'There were errors with your announcement'
    redirect_to :permalink => @calendar.permalink, :controller => 'account/events', :action => 'show', :id => @blog.event_id
  end

  def update
    @blog.update_attributes(params[:blog])
    @blog.save!
    flash[:notice] = 'Announcement updated'
    redirect_to :permalink => @calendar.permalink, :controller => 'account/events', :action => 'show', :id => @blog.event_id
  end

  def destroy
    @blog.destroy
    flash[:notice] = 'Announcement deleted'
    redirect_to :permalink => @calendar.permalink, :controller => 'account/events', :action => 'show', :id => @blog.event_id
  end

  protected
  def find_blog
    @blog = Blog.find(params[:id])
  end

  def authorized?
    if %w(update destroy).include?(action_name)
      @event = @blog.event
    elsif %w(create).include?(action_name)
      @event = Event.find(params[:blog][:event_id])
    end
    return true if current_user.admin? || current_user.events.include?(@event)
    false
  end

  def expire_page_cache
    expire_page :controller => '/events', :action => 'show', :id => @blog.event_id if @blog
  end
end
