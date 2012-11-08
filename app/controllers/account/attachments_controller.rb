class Account::AttachmentsController < AccountControllerShared
  before_filter :find_attachment
  before_filter :login_required

  def primary
    @attachment.primary!
    flash[:notice] = "updated primary image"
    redirect_to :controller => 'account/events', :action => 'show', :id => @event
  end

  def update
    @attachment.update_attributes(params[:attachment])
    respond_to do |format|
      format.js {
        render :update do |page|
          page.alert "updated caption"
          page.hide "attachment-spinner-#{@attachment.id}"
          page.visual_effect :highlight, "attachment_#{@attachment.id}_caption"
        end
      }
    end
  end

  def destroy
    @attachment.destroy
    respond_to do |format|
      format.js {
        render :update do |page|
          page.alert "deleted attachment"
          page.remove "attachment-#{@attachment.id}"
        end
      }
    end
  end

  protected
  def find_attachment
    @attachment = Attachment.find(params[:id])
    @event = @attachment.event || @attachment.report.event
  end
  def authorized?
    return true if current_user.admin?
    return true if current_user.events.include?(@event)
  end
end
