class ZipIndices < ActiveRecord::Migration
  def self.up
    change_column :zip_codes, :latitude, :float, :precision => 10, :scale => 6
    change_column :zip_codes, :longitude, :float, :precision => 10, :scale => 6
    add_index :zip_codes, :zip, :name => 'index_zip_codes_on_zip'
    add_index :zip_codes, :latitude, :name => 'index_zip_codes_on_latitude'
    add_index :zip_codes, :longitude, :name => 'index_zip_codes_on_longitude'
    add_index :zip_codes, [:latitude, :longitude], :name => 'index_zip_codes_on_latitude_and_longitude'
  end

  def self.down
    change_column :zip_codes, :latitude, :string
    change_column :zip_codes, :longitude, :string
    remove_index :zip_codes, :name => 'index_zip_codes_on_zip'
    remove_index :zip_codes, :name => 'index_zip_codes_on_latitude'
    remove_index :zip_codes, :name => 'index_zip_codes_on_longitude'
    remove_index :zip_codes, :name => 'index_zip_codes_on_latitude_and_longitude'
  end
end
