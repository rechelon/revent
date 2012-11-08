#require 'DIA_API'
require 'democracy_in_action'

# This is the parent class for all resources representing a table
# in the DIA API.  The method_missing function dynamically
# enables all the accessors, so they are not listed in java doc.
# This is a thin wrapper between the Rails world and DIA_API.rb
# that can be found in vendor/DIA.

class DemocracyInActionResource 
  cattr_accessor :logger
  self.logger = ActiveRecord::Base.logger
  require 'democracy_in_action'
  
  @@apis = []

  def self.api
    key = Site.current ? Site.current.id : 0
    @@apis[key] ||= api = DemocracyInAction::API.new(Site.current.config.salsa_api_keys)
  end

  def api
    self.class.api.authenticate
    self.class.api
  end

  # create a data set from a hash, verifying the contents...
  protected 
  def initialize(hash = nil)
    if hash == nil
      @data = Hash.new
    elsif bad_key = hash.keys.detect { |k| !self.class.atts[k] }
      raise 'Bad argument to initialize: ' + bad_key
    else
      @data = hash.dup
    end
  end

  public
  # type is :all, :first, or key number (or array of keys)
  # options is a hash, as for all rails find
  def DemocracyInActionResource.find(type, options = nil)
    raise ArgumentError, "Invalid option for find - #{type.class}: #{type.to_s}" unless type
    # transform their style into DIA form to allow more searches
    opts = process_opts(options)

    case type
    when :all
    when :first
      opts['limit'] = 1
    else
      opts['key'] = type
    end
    records = api.get(:object => self.table, :condition => opts)
    records.map! { |r| self.new(r) }
    if type == :all or records.size > 1
      return records
    else
      return records[0]
    end
  end

  # this transforms rails-speak into DIA-speak
  # we support (only) :limit, :order, :conditions
  # unfortunately, DIA doesn't seem to support offset
  def DemocracyInActionResource.process_opts(opts)
    result = Hash.new
    return result if !opts
    
    opts.each do |key, val|
      case key
      when :limit
        result['limit'] = val
      when :order
        result['order'] = val
      when :conditions
        result['where'] = val
      else
        # TODO: better logging mechanism
        logger.warn 'Cannot process find argument: ' + key.to_s + '=>' + val.to_s
      end
    end
    return result
  end

  # This writes an existing object to the db (make with new)
  def save
    data = self.get_hash
    data[:object] = self.class.table
    result = api.save(data)
    self.key = result if result
  end

  # destroys an existing object
  def destroy
    api.deleteKey(self.class.table, @data['key'])
  end

  # destroy by id
  def DemocracyInActionResource.destroy(id)
    api.deleteKey(self.table, id)
  end

  # check if a column links to another table. 
  # return linked class if so, otherwise nil
  def DemocracyInActionResource.isLink(column)
    if column[-4..-1] == '_KEY'
      link = column[0..-5]
      return self.links[link]
    else
      return nil
    end
  end
  
  # return data as a hash table.  mainly used for DIA API, cuz we
  # have pretty accessors already (ie. g.key, not g.get_hash()['key'])
  def get_hash
    @data.dup
  end

  # this updates the internal attributes with values from a hash
  def update_atts(hash)
    hash.each do |key, val|
      if !self.class.atts[key]
        raise 'Setting invalid attribute: ' + key
      elsif val and val.size > 0
        @data[key] = val
      end
    end
  end

  # MAGIC FUNCTION.... look at with strong eyes...
  # this enables all the attributes and links all the models
  #
  # this allows a magic atts list define what our args are
  # it also transparently support _KEY and _KEYS links...
  # eg. supporter.organization_KEY returns a number, but
  #     supporter.organization returns an Organization object
  #     event.groups_KEY returns a string (comma separated numbers)
  #     event.groups returns an array of Groups object
  # note, that every time a link is followed, we send an HTTP request to DIA
  def method_missing(method_id, *args)
    # sort out what the attribute is and whether it is read or write
    func = method_id.id2name
    write = false 
    if func[-1] == '='[0]  # this is an ugly hack cuz [] doesn't return string
      write = true
      func = func[0..-2]
    end

    # if we define that attribute, do a read or write
    atts = self.class.atts
    if atts[func]
      if write
        @data[func] = args[0]
      else
        return @data[func]
      end
    elsif (l_class = self.class.links[func])
      if write
        # check validity of class to link to
        if args[0].class != l_class
          raise 'Invalid Class for link: ' + self.class.to_s + '.' + func +
                ' wants ' + l_class.to_s + ', not ' + args[0].class.to_s
        end
        @data[func + '_KEY'] = args[0].key
      else
        key = @data[func + '_KEY']
        return nil if !key
        return l_class.find(key)
      end
    # handle multiple keys...
    elsif (l_class = self.class.multilinks[func])
      if write
        # check valid classes for links
        if args[0].class != Array
          raise 'Multilink (' + self.class.to_s + '.' + func + ') needs Array arg'
        elsif bad = args.find{|a| a.class != l_class}
          raise 'Invalid Class for link: ' + self.class.to_s + '.' + func +
                ' wants ' + l_class.to_s + ', not ' + bad.class.to_s
        end
        # actually assign data
        @data[func + '_KEYS'] = args[0].map{|a| a.key}.join(',')
      else
        keys = @data[func + '_KEYS']
        return [] if !keys
        return l_class.find(keys.split(','))
      end
    else
      # raise an exception
      self.class.superclass.method_missing(method_id, args)
    end
  end
        
  # and a little compare for equals...
  def equals(compare)
    if (compare.class == self.class) and (compare.get_hash == self.get_hash)
      return true
    else
      return false
    end
  end

  def ==(compare)
    equals(compare)
  end
end
