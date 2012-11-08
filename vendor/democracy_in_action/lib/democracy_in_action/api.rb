module DemocracyInAction

  # = Direct usage
  #
  # Once you have initialized your API, you can send a direct request to the service:
  # 
  #   @api.request :save, { :object => 'supporter', :Email => 'jones@example.org' } 
  # 
  # This method will ping any url that the API was initialized with,
  # and append the options hash directly to the query string.
  # 
  # Most actions can be accomplished via the REST methods ( get, post,
  # put, and delete ).
  #
  #   @api.get    :object => 'groups', :condition => { :Group_Name => 'Peaceful Warriors' }
  #   @api.post   :object => 'groups', :Group_Name => 'Grannies Against the Surge'
  #   @api.put    :object => 'groups', :Group_Name => 'Grannies Against McSame', :key => 234 # requires a key
  #   @api.delete :object => 'groups', :key => 234
  #
  # To retrieve a count of records, use the :count method:
  #   @api.count :object => 'groups', :condition => "Group Name LIKE '%Grannies%'"
  #
  # To save a record that may or may not already exist, use :post or :save
  # 
  #   @api.save   :object => 'supporter', :Email => 'jesus@example.org', 
  #               :First_Name => 'Jesus', :Last_Name => 'Murphy'
  #
  # All actions called with this direct usage syntax *require* an
  # :object to be specified in the options hash.
  #
  # This syntax does not permit single integer arguments for keys,
  # only { :key => value }
  #
  # = Object syntax
  # 
  # Because every API request requires an object type, the API
  # provides you with a set of instance methods to improve the
  # readablity of your code.  The examples above could be written:
  #
  #   @api.groups.get    :condition => { :Group_Name => 'Peaceful Warriors' }
  #   #  => [ DIA::Result ]
  #   @api.groups.post   :Group_Name => 'Grannies Against the Surge'
  #   #  => 234
  #   @api.groups.put    :key => 234, :Group_Name => 'Grannies Against McSame'
  #   #  => 234
  #   @api.groups.count :condition => "Group Name LIKE '%Grannies%'"
  #   #  => 1
  #   @api.groups.delete :key => 234
  #   #  => true
  #   @api.supporter.save :Email => 'jesus@example.org', :First_Name => 'Jesus', :Last_Name => 'Murphy'
  #   #  => 76543
  #
  # == Retrieving data
  # Restrict the number of desired results using the :limit option
  #
  #   @api.groups.get    :condition => 'Group_Name LIKE '%Peaceful%', :limit => 5
  #   # => [ DIA::Result ]
  #
  # Retrieve only one record with the first method. 
  #
  #   @api.groups.first  :condition => 'Group_Name LIKE '%Peaceful%'
  #   #  => DIA::Result ( first returns a single result rather than an array of results )
  #
  # Sort your results with the :orderBy option.
  # 
  #   @api.groups.first  :condition => 'Group_Name LIKE '%Peaceful%', :orderBy => 'Date_Created DESC'
  #   #  => DIA::Result (the most recent group)
  #
  # For readability, you may prefer to call get with the all alias.
  #
  #   @api.groups.all     :condition => { :Group_Name => 'Peaceful Warriors' }
  #   # => [ DIA::Result ]
  #
  # If you already have the key(s) of the results you want, you can
  # pass those to get directly:
  #
  #   @api.groups.get(234)
  #   # => DIA::Result
  #   @api.groups.get(234, 235, 236, 237)
  #   # => [ DIA::Result, DIA::Result, DIA::Result, DIA::Result ]
  #
  # == Creating new records
  # 
  # All options passed to post or save will attempt to match a field
  # on the object.  Matching options will be saved to the service.
  # 
  #   @api.event.post   :Event_Name => 'Mango Street Block Party', :City => 'New York', :State => 'NY'
  #   #  => 334455
  #   @api.event.save   :Event_Name => 'Papaya Way Block Party'
  #   #  => 334456
  #
  # == Linking records
  # 
  # It is possible to link records together by passing a :link option
  # to put, post, or save.
  # 
  #   @api.supporter.post   :Email => 'dropkick@example.com', :link => { :event => 334455 }
  #   #  => 76544  This supporter is attending Mango Street Block Party
  # 
  # Multiple Records can be linked with a single request.
  # 
  #   @api.supporter.put   :key => 76544 , :link => { :event => 334455, :group => [ 234, 235 ] }
  #   #  => 76544  This supporter is attending Mango Street Block Party, and is a member of Grannies Against McSame and another group
  #
  # == Updating records
  # 
  # Passing a key or email identifier in your save, put, or post
  # request tells the service to update the existing record.
  # 
  #   @api.supporter.put   :key => 76544 , :City => 'Albany', :State => 'NY'
  #   #  => 76544  
  #
  # == Deleting records
  # 
  # Delete returns true or nil if the delete operation fails.  A
  # numeric key is the only valid option for delete.
  # 
  #   @api.groups.delete :key => 234
  #   # => true
  #   @api.groups.delete(234)
  #   # => nil  ( record not found, we deleted it in the previous example )
  #
  # == Restrictions
  # 1. Only these characters are accepted in the :condition clause 
  #      [0-9a-zA-Z_ .'"<>!=%+&@-]
  #    Putting other characters in names ( like , ) make searching by name not work.
  # 2. Cannot search the supporter_groups links by groups_KEY.
  # 3. DIA does not validate link ids.  You can link supporters to
  #    invalid group keys (and vice versa).  You are responsible for
  #    your data integrity
  # 4. When deleting a group, the linked records in supporter_groups
  #    are not erased (but when deleting supporter, they are)
  
  class API
    class InvalidKey < ArgumentError #:nodoc:
    end
    class InvalidData < ArgumentError #:nodoc:
    end
    class InvalidUrl < ArgumentError #:nodoc:
    end
    class NoTableSpecified < ArgumentError #:nodoc:
    end
    class ConnectionInvalid < ArgumentError #:nodoc:
    end

    # A list of known DIA nodes and their associated urls
    NODES = { 
      :salsa3 => {
        :authenticate   => 'https://salsa3.salsalabs.com/api/authenticate.sjs',
        :get_by_key     => 'https://salsa3.salsalabs.com/api/getObject.sjs',
        :get            => 'https://salsa3.salsalabs.com/api/getObjects.sjs',
        :save           => 'https://salsa3.salsalabs.com/save',
        :delete         => 'https://salsa3.salsalabs.com/api/delete',
        :count          => 'https://salsa3.salsalabs.com/api/getCount.sjs',
        :email          => 'https://salsa3.salsalabs.com/email'
        },
      :afl => {
        :authenticate   => 'https://afl.salsalabs.com/api/authenticate.sjs',
        :get_by_key     => 'https://afl.salsalabs.com/api/getObject.sjs',
        :get            => 'https://afl.salsalabs.com/api/getObjects.sjs',
        :save           => 'https://afl.salsalabs.com/save',
        :delete         => 'https://afl.salsalabs.com/api/delete',
        :count          => 'https://afl.salsalabs.com/api/getCount.sjs',
        :email          => 'https://afl.salsalabs.com/email'
        },
      :sandbox => {
        :authenticate   => 'https://sandbox.salsalabs.com/api/authenticate.sjs',
        :get_by_key     => 'https://sandbox.salsalabs.com/api/getObject.sjs',
        :get            => 'https://sandbox.salsalabs.com/api/getObjects.sjs',
        :save           => 'https://sandbox.salsalabs.com/save',
        :delete         => 'https://sandbox.salsalabs.com/api/delete',
        :count          => 'https://sandbox.salsalabs.com/api/getCount.sjs',
        :email          => 'https://sandbox.salsalabs.com/email'
        },
      :salsa => { 
        :authenticate   => 'https://salsa.democracyinaction.org/api/authenticate.sjs',
        :get_by_key     => 'https://salsa.democracyinaction.org/api/getObject.sjs',
        :get            => 'https://salsa.democracyinaction.org/api/getObjects.sjs',
        :save           => 'https://salsa.democracyinaction.org/save',
        :delete         => 'https://salsa.democracyinaction.org/api/delete',
        :count          => 'https://salsa.democracyinaction.org/api/getCount.sjs',
        :email          => 'https://salsa.democracyinaction.org/email'
        },
      :wiredforchange => { 
        :authenticate   => 'https://salsa.wiredforchange.com/api/authenticate.sjs',
        :get            => 'http://salsa.wiredforchange.com/dia/api/get.jsp',
        :save           => 'http://salsa.wiredforchange.com/dia/api/process.jsp',
        :delete         => 'http://salsa.wiredforchange.com/dia/deleteEntry.jsp',
        :email          => 'https://salsa.wiredforchange.com/email'
        },
      :org2 => { 
        :authenticate   => 'https://org2.democracyinaction.org/api/authenticate.sjs',
        :get_by_key     => 'https://org2.democracyinaction.org/api/getObject.sjs',
        :get            => 'https://org2.democracyinaction.org/api/getObjects.sjs',
        :save           => 'https://org2.democracyinaction.org/save',
        :delete         => 'https://org2.democracyinaction.org/api/delete',
        :count          => 'https://org2.democracyinaction.org/api/getCount.sjs',
        :email          => 'https://org2.democracyinaction.org/email',
        :tag            => 'https://org2.democracyinaction.org/dia/processEditValues.jsp'
        }
      }

    # The username used to login to your Democracy in Action account.
    attr_reader :username

    # The password used to login to your Democracy in Action account.
    attr_reader :password

    # node is a short key representing DIA servers that are known to the library ( see NODES )
    attr_reader :node

    # For new nodes or custom scripts you may wish to specify a hash of custom urls
    attr_reader :urls

    # Requires an options hash containing: :username, :password, and :node
    #   
    # :node can be skipped if :urls hash is included instead.
    #
    # If a :urls hash is used, it should have the form:
    #   :urls => { :get => "get_url", :save => "save_url", :delete => "delete_url" }
    # 
    # TODO(adam): Please write a test to test this assumption.
    # 
    # Cavet: Its okay to initialize w/out validaton data; but a
    # ConnectionInvalid error will be raised on the first attempt to
    # make an RPC call that requires validaton.
    # 
    def initialize(options={}, username=nil, password=nil, node=nil, urls=nil)
      @options = options.clone 

      @username = username
      @password = password
      @node = node 
      @urls = urls 

      set_auth_parameters 
    end

    def set_auth_parameters
      @username ||= @options.delete(:username) || @options.delete(:email)
      @password ||= @options.delete(:password)
      @node     ||= @options.delete(:node)
      @urls     ||= @options[:urls] || NODES[node]
    end

    def load_config(keyword)
      YAML.load_file("#{File.dirname(__FILE__)}/../../config/nodes/#{keyword}.yml")
    end

    def test_auth_parameters
      raise ConnectionInvalid.new("Must specify :username, :password, and ( :node or :url )") unless self.username && self.password && ( self.node || @options[:urls] )
    end

    def validate_connection
      test_auth_parameters
      raise ConnectionInvalid.new("Requested node is not supported.  Use (#{NODES.keys.join(', ')}) or specify a custom array in :urls") unless urls
      raise ConnectionInvalid.new("Urls must be a hash") unless urls.is_a?(Hash)
      raise ConnectionInvalid.new("Urls must include at least :get and :authenticate ( :save, :delete, and :count are nice too )") unless urls[:get] && urls[:authenticate]
    end

    # Confirm that the API is enabled and the remote service is reachable
    def connected?
      begin
        return @authenticated || authenticate 
      rescue SocketError, ConnectionInvalid 
        # The library cannot reach the DIA server.  Connectivity problem?
        false
      end
    end

    attr_reader :auth_response

    # Connect to the service and check the current credentials
    def authenticate
      validate_connection
      raise ConnectionInvalid if authentication_request =~ /Invalid login/
      @authenticated = true
    end

    def authentication_request
      @client = HTTPClient.new
      @auth_response = @client.post(@urls[:authenticate],"email=#{username}&password=#{password}")
      @auth_response.body
    end

    def authenticated?
      !@authenticated.nil?
    end

    # A raw request.  Requires the symbol for the url to hit ( ie :save, :get ) and a hash of options to be appended to the query string.
    def request( url_symbol, options = {} )
      raise InvalidUrl.new("Could not find :#{url_symbol} in api url keys") unless @urls.include?(url_symbol)
      send_request @urls[ url_symbol ], options 
    end


    # Return one or more records from the service
    #   
    # Supports
    #   :condition 
    #      * a string or array of strings in the format of SQL WHERE clauses
    #        = and LIKE operators may be used
    #      * a hash in the form of { :field_name => value, :field_name => value }
    #   :limit - an integer or equivalent string representing the maximum number of desired results
    #   :orderBy - a string in the form of an SQL ORDER BY clause, representing the desired sorting pattern of the result set
    #   :key - an integer representing the id of the desired result
    def get(options = {})
      validate_connection
      url = options[:key] ? urls[:get_by_key] : urls[:get]
      body = send_request(url, options_for_get(options))
      if has_error?( body )
        error(body)
      else 
        if options[:key]
          parse(body).result.first
        else
          parse(body).result
        end
      end
    end

    alias :all :get

    # Returns only the first result in a result set.  
    #
    # Accepts :condition and :orderBy.
    def first(options = {} )
      get( options.merge( :limit => 1 )).first
    end

    # Writes data to the service
    #
    # Supports these identifiers but does not require them.
    #   :key, or [object name]_KEY - identifies the record to write
    #   :Email will also identify a record in the Supporter table
    #   :link - a hash for linking new records to objects already on the service
    #
    # Links should be passed in the form
    #   options = { :link => { :[object name] => key, :[second object name] => key }}
    #
    # Additional options are attributes which should be set on the record
    def save(options = {})
      options[:xml] = true
      send_request(@urls[:save], options.merge(param_key(options))).strip[/key="(\d+)/, 1]
    end

    # Create a new record
    #
    # The options are attributes which should be set on the new record
    def post( options = {})
      save( options ) 
    end

    # Update an existing record
    #
    # Requires an identifying key such as :key, :[object_name]_KEY, or Email
    #
    # Also requires the attributes to be updated, included in the options hash
    def put( options = {} )
      required_keys = [ :key, 'key', options[:object] + '_KEY', ( options[:object] + '_KEY').to_sym ]
      required_keys += [ 'Email', :Email ] if options[:object] == 'supporter' || options[:object] == :supporter
      raise InvalidKey.new( "You must specify :key, :Email, or #{options[:object]}_KEY to update a record" ) unless options.any? { |optkey, value| required_keys.include?(optkey) }
      save( options ) 
    end

    # Delete an existing record.
    #
    # Requires an identifying key such as :key.
    #
    # Accepts a single integer argument or an array if called via @api.[_object type_].delete()
    #
    # Returns true if it works, nil otherwise.
    def delete(options={})
      options[:xml] = true
      body = send_request(@urls[:delete], options.merge(param_key(options)))
    
      # if it contains '<success', it worked, otherwise a failure
      body.include?('<success')
    end

    # Send a freeform email via salsa API
    #
    # requires the following options :to, :from, :body, :subject
    def email(options = {} )
      client.get(@urls[:email], build_body(options)).body
    end

    # Tag an item via salsa API
    #
    # requires the following options :tag, :object, :key of the item to be tagged
    def make_tag(options = {} )
      options[:xml] = true
      body = send_request(@urls[:tag], options.merge(param_key(options)))

      # if it contains '<success', it worked, otherwise a failure
      return unless body.include?('<success')

      tagged_object_key = body.strip[/key="(\d+)/, 1]
      new_tag = tag.first :condition => "tag=#{options[:tag]}"
      new_tag_data = tag_data.first :condition => [ "tag_KEY=#{new_tag.key}", "table_key=#{tagged_object_key}" ]
      new_tag_data.key
    end

    # Returns an integer for the number of records specified.
    #

    # Returns an integer for the number of records specified.
    #

    # Returns an integer for the number of records specified.
    #
    # Allows a :condition to restrict the result set.
    def count(options = {})
      xml = send_request(@urls[:count], options_for_get(options))
      parse(xml).count unless has_error?(xml)
    end
    
    # Return a description of the columns for a given object.
    # 
    # The response is a Hash of Result objects, with field names as keys.
    #
    # The fields are described with the keys :field, :type, :null, :key, :default, and :extra
    #
    # Not all keys are specified for all fields.
    def columns(options = {}) #:nodoc:
      body = send_request @urls[:get], options_for_get(options)
      parse( body, DIA_Desc_Listener ).result unless has_error?(body)
    end


    ###################### INTERNAL CODE ###################

    protected
    #private

    #evaluates xml and returns true if it contains an error
    def has_error?(xml)
      xml =~ /<error>Invalid login/
    end

    # Accepts XML and returns an array of DIA::Result objects
    #
    # Accepts a class name to serve as the StreamListener as an optional second argument
    #
    # Returns a populated instance of the passed class 
    def parse(xml, listener_class = DIA_Get_Listener )
      listener = listener_class.new
      parser = REXML::Parsers::StreamParser.new(xml, listener)
      parser.parse
      listener
    end

    # Encodes values for transmission in a POST.
    # ( copied from private function in Net::HTTP )
    def urlencode(str)
      str.gsub(/[^a-zA-Z0-9_\.\-]/n) {|s| sprintf('%%%02x', s[0]) }
    end

    # Evaluates an options hash for use with a GET request, returning a valid version for the current service.
    def options_for_get(options={})
      return {} unless options
      options.merge( param_key(options)).merge param_condition( options )
    end

    # Evaluates an options hash for the presence of a key and returns a hash in the form { :key => value }
    # if a key is present.  
    #
    # Returns an empty Hash when no key is present.
    def param_key( options = {} )
      return { :key => options } if options && !options.is_a?(Hash)
      
      key_type = options[:key] ? :key : 'key'
      return {} unless key_value = options[key_type]
      key_value = key_value.join(', ') if key_value.is_a?(Array)
      { key_type => key_value }
    end

    # Evaluates an options hash for :condition, returning a valid version.
    #
    # Converts a hash of conditions into a single string
    #
    # Returns an empty hash if no :condition is found in the param, otherwise returns a hash { :condition => value }
    def param_condition( options = {} )
      return {} unless condition = options.delete(:condition) 
      return { :condition => condition }  unless condition.is_a?(Hash)
      { :condition => condition.inject( [] ) { |memo, (column, value)| memo << "#{column}=#{value}" } }
    end

    # Converts a link hash to DIA format.
    # 
    # Every key is a object name, with values that are single or multiple records in that table.
    #
    # Returns an empty array if no :link parameter is passed, otherwise returns an array of query param strings.
    def param_link_hash(links={})
      return [] unless links
      raise InvalidData.new("Links should be a hash of the form :link => ( {object => key } or { object => [ key1, key2 ] } )") unless links.is_a?(Hash)

      links.inject([]) do |memo, (table, record_key)|
        record_key = [ record_key ] unless record_key.is_a?( Array )
        memo << record_key.map{ |k| "link=#{table}&linkKey=#{k}" }
      end.flatten
    end

    # Returns the options hash as a url-encoded string of key-value pairs.
    # 
    # Array values have their keys duplicated, creating key-value pairs for each element in the array.
    def build_body(options={})
      options[:object] ||= options.delete(:table) if options[:table]
      initial_memo = param_link_hash(options.delete(:link))
      return initial_memo.join('&') if options.empty?
      options.inject(initial_memo) do |memo, (key, value)|
        value = [ value ] unless value.is_a?( Array )
        memo << value.map { |v| "#{urlencode(key.to_s)}=#{urlencode(v.to_s)}" }
      end.join('&')
    end

    # Sends an HTTP::Request to the base_url. Builds up the request based on the passed options hash.
    #
    # Returns the body of the response.
    def send_request(base_url, options={})
      raise NoTableSpecified.new("You must either include :object in the options hash or use the proxy methods API#[objectname].get") unless options[:object]
      client.get(base_url, build_body(options)).body
    end

    def client
      @client || authenticate
    end

    # Checks for a method being one of the supported objects and
    # returns a TableProxy if it is
    
    def method_missing(*args) #:nodoc:
      table_name = args.first
      
      if Tables.list.include?(table_name)
        return TableProxy.new(self, table_name)
      end
      super *args
    end

  end

  # This class acts as a placeholder for DIA objects.  It
  # automatically includes :object => [object_name] in the options
  # hash that is passed along to the API.
  #
  # All methods not listed in TABLE_PROXY_METHODS are passed along to
  # the API with their original arguments.

  class TableProxy #:nodoc:
    TABLE_PROXY_METHODS = [:get, :save, :delete, :columns, :count, :put, :post, :first, :all, :make_tag ]
    TABLE_PROXY_METHODS.each { |method| undef_method( method ) if instance_methods.include?( method.to_s ) }

    def initialize(api, table_name)
      @api = api
      @table_name = table_name
    end

    private

    def method_missing(*args)
      start_args = args.dup
      method_name = args.shift
      if TABLE_PROXY_METHODS.include?(method_name)
        options = args.shift || {}
        return @api.send(method_name, options.merge( :object => @table_name.to_s ) )
      end
      @api.send(method_name, *args)
    end
  end
end
