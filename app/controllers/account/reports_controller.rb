class Account::ReportsController < AccountControllerShared
  before_filter :find_report
  before_filter :login_required
  cache_sweeper :report_sweeper

  def edit
    @report = Report.find(params[:id])
  end

  def update
    @report.update_attributes(params[:report])
    current_user.associate_dia_report @calendar
    current_user.sync_unless_deferred
    flash[:notice] = "report updated"
    redirect_to :controller => 'account/events', :action => 'show', :id => @report.event
  end

  def publish
    @report.publish
    respond_to do |format|
      format.js {
        render :update do |page|
          page.alert 'published report'
          page.replace_html "publish-control-#{@report.id}", :partial => 'account/events/publish_control', :locals => {:report => @report}
        end
      }
      format.html { redirect_to :controller => "/account/events", :action => "show", :id => @report.event_id }
    end
  end

  def unpublish
    @report.unpublish
    respond_to do |format|
      format.js {
        render :update do |page|
          page.alert 'unpublished report'
          page.replace_html "publish-control-#{@report.id}", :partial => 'account/events/publish_control', :locals => {:report => @report}
        end
      }
      format.html { redirect_to :controller => "/account/events", :action => "show", :id => @report.event_id }
    end
  end

  def destroy
    @report.destroy
    respond_to do |format|
      format.js {
        render :update do |page|
          page.remove "report-#{@report.id}"
        end
      }
    end
  end

  def primary
    @report.primary!
    flash[:notice] = "updated primary report"
    redirect_to :controller => 'account/events', :action => 'show', :id => @report.event
  end

  protected
  def find_report
    @report = Report.find(params[:id])
  end
  def authorized?
    return true if current_user.admin?
    return true if current_user.events.include? @report.event
  end
end
