class AddingHostsTable < ActiveRecord::Migration
  def self.up
    create_table "hosts" do |t|
      t.column :site_id,                    :int
      t.column :hostname,                   :string
    end

    execute <<-SQL
    INSERT INTO `hosts` (site_id, hostname) SELECT s.id, s.host FROM sites as s LEFT JOIN hosts as h ON h.hostname != s.host;
    SQL
  end

  def self.down
    drop_table "hosts"
  end
end
