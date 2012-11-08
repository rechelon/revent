module Admin::InvitesHelper
  def offices
    ["president", "senator", "representative"]
  end
  
  def districts
    (1..55).map {|d| [sprintf("%02d", d), d]}    
  end
end
