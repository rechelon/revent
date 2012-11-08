class Sites < ActiveRecord::Migration
  def self.up
    create_table "sites" do |t|
      t.column "host", :string
      t.column "use_democracy_in_action_auth", :boolean
      t.column "theme", :string
    end
    Site.create(:host => 'daysofaction.radicaldesigns.org')
    Site.create(:host => 'events.stepitup2007.org', :use_democracy_in_action_auth => true, :theme => 'stepitup')
    add_index "sites", "host", :name => "index_sites_on_host"
  end

  def self.down
    drop_table "sites"
  end
end
