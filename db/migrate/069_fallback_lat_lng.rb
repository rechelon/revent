# need to set config.active_record.allow_concurrency = true when using this migration
class FallbackLatLng < ActiveRecord::Migration
  def self.up
    add_column :events, :fallback_latitude,  :float
    add_column :events, :fallback_longitude, :float

=begin
    puts 'Processing all events...'
    Event.find(:all, :conditions => "latitude IS NULL AND fallback_latitude IS NULL").each_threaded(:num_threads => 30, :verbose => true) do |event|
      event.save unless event.latitude and event.longitude 
    end
=end
  end

  def self.down
    remove_column :events, :fallback_latitude
    remove_column :events, :fallback_longitude
  end
end

=begin
# tried this threaded thing out on zheng but never got it working
# required setting config.active_record.allow_concurrency = true
# in one of the environment config files but still doesn't seem to work
class Array
  def chunk(pieces=2)
    len = self.length;
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << self[start..last] || []
      start = last+1
    end
    chunks
  end

  def each_threaded(options = {})
    num_threads = options[:num_threads] || 4
    num_threads = (num_threads > 40) ? 40 : num_threads        
    verbose = options[:verbose] || false
    start_time = Time.now
    threads = []
    self.chunk(num_threads).each do |chunk|
      threads << Thread.new(chunk) do |items|
        items.each do |item|
          yield(item)
          if verbose
            print '.' 
            STDOUT.flush 
          end
        end
      end
    end
    threads.each {|thr| thr.join}
    end_time = Time.now
    puts "Avg time (in seconds) per item: #{(end_time - start_time) / self.length}" if verbose
  end
end
=end