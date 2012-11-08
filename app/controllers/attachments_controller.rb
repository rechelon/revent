class AttachmentsController < ApplicationController
#  skip_before_filter :set_site
  skip_before_filter :set_calendar
  skip_before_filter :set_cache_root

  before_filter :login_required, :only => [:destroy]
  def authorized?
    current_user.admin?
  end

  def show
    if params[:id]
      @id = params[:id]
    elsif params[:id1] && params[:id2]
      @id = (params[:id1] + params[:id2]).gsub(/^0+/, '')
    else
      raise ActiveRecord::RecordNotFound
    end
    @filename = params[:file].first
    @attachment = Attachment.find_by_parent_id_and_filename(@id, @filename) || Attachment.find_by_id_and_filename(@id, @filename) 
    raise ActiveRecord::RecordNotFound unless @attachment
    redirect_to @attachment.public_filename
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    expire_page :controller => "reports", :action => "show", :id => @attachment.report_id
    respond_to do |wants|
      wants.html { redirect_to admin_url(:controller => "reports", :action => "show", :id => @attachment.report_id) }
      wants.js do
        render :update do |page|
          page.remove "attachment_#{@attachment.id}" if @attachment
        end
      end
    end
  end
end
