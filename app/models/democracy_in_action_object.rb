class DemocracyInActionObject < ActiveRecord::Base
  belongs_to :synced, :polymorphic => true
  belongs_to :associated, :polymorphic => true

  before_save :set_table
  def set_table
    self.table ||=  synced.democracy_in_action_synced_table if synced.respond_to?(:democracy_in_action_synced_table)
    self.table ||= synced.class.downcase
  end

  serialize :local
  def local
    #has to have been defined to unserialize properly
    "DemocracyInAction#{table.classify}".constantize rescue NameError
    read_attribute :local
  end

=begin
  def unserialize
    xml = serialized_data
    listener = DemocracyInAction::DIA_Get_Listener.new
    parser = Parsers::StreamParser.new(xml, listener)
    parser.parse
    klass = Object.const_get("DemocracyInAction#{self.table.capitalize}")
    return klass.new(listener.items.first)
  rescue NameError
    return listener.items.first
  end
=end
end
