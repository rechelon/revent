class ZipCodeSearchExampleController < ApplicationController
   layout nil 

   def index
      return unless request.post?
      @zip = ZipCode.find_by_zip(params[:zip])
      @results = @zip.find_objects_within_radius(params[:radius].to_i) do |min_lat, min_lon, max_lat, max_lon|
            ZipCode.find(:all, 
                        :conditions => [ "(latitude > ? AND longitude > ? AND latitude < ? AND longitude < ? ) ", 
                        min_lat, 
                        min_lon, 
                        max_lat, 
                        max_lon])
      end
   end

end
