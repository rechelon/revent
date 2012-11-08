class AddZip48033 < ActiveRecord::Migration
  def self.up
    ZipCode.new(:zip => 48033, :city => "SOUTHFIELD", :state => "MI", :latitude => 42.484757, :longitude => -83.255768).save

  end

  def self.down
    ZipCode.find_by_zip(48033).destroy
  end
end
