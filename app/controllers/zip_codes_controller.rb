class ZipCodesController < ApplicationController
  
  def index
    respond_to do |format|
      format.json do
        zip = ZipCode.find_by_zip(params[:zip])
        if params[:radius]
          ret = {
            :center_state => zip.state
          }
          ret[:surrounding] = zip.find_objects_within_radius(params[:radius].to_i) do |min_lat, min_lon, max_lat, max_lon|
            ZipCode.find(:all, 
              :conditions => [ "(latitude > ? AND longitude > ? AND latitude < ? AND longitude < ? ) ", 
              min_lat, 
              min_lon, 
              max_lat, 
              max_lon])
          end
        else
          ret = zip
        end
        render :json => ret.as_json({
          :except=>[
            :city,
            :latitude,
            :longitude,
            :state,
            :created_at,
            :zip_class,
            :updated_at,
            :id
          ]
        });
      end
      format.html do
        render :text => '.json formats only'
      end
    end
  end

end
