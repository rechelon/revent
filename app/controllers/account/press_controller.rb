class Account::PressController < AccountControllerShared
  before_filter :find_press_link
  before_filter :login_required

  def update
    @press_link.update_attributes(params[:press_link])
    respond_to do |format|
      format.js {
        render :update do |page|
          page.alert "updated press links"
          page.visual_effect :highlight, "press_link_#{@press_link.id}_text"
          page.visual_effect :highlight, "press_link_#{@press_link.id}_url"
          page.hide "press-spinner-#{@press_link.id}"
        end
      }
    end
  end

  def destroy
    @press_link.destroy
    respond_to do |format|
      format.js {
        render :update do |page|
          page.alert "deleted press link"
          page.remove "press-#{@press_link.id}"
        end
      }
    end
  end

  protected
  def find_press_link
    @press_link = PressLink.find(params[:id])
    @event = @press_link.report.event
  end

  def authorized?
    return true if current_user.admin?
    return true if current_user.events.include?(@event)
  end
end
