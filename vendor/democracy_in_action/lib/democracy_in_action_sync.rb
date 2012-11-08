# DemocracyInActionSync is a library for automatically syncing activerecord models with DIA; please see the radicaldesigns/rockwood project for an example of how to use
module DemocracyInActionSync

  def self.included( base )
    base.instance_eval { include Client }
  end

  module Client
    def democracy_in_action
      DemocracyInActionSync::Config.client
    end
  end

  class Config
    @@mappings = {}
    @@merges = {}
    @@email_keys = {}
    @@keys = {}
    @@default_keys = {}
    
    def self.setup
      yield self 
    end

    def self.client(reconnect=false)
      @api = nil if reconnect
      return @api if @api

      return false if !File.exists?(dia_config_path) || DemocracyInAction::API.disabled?

      all_dia_config = YAML.load_file(dia_config_path )
      return false unless all_dia_config
      dia_config = all_dia_config[RAILS_ENV]
      
      new_conn = DemocracyInAction::API.new( dia_config ) if dia_config and !dia_config.empty?

      return false unless new_conn and new_conn.connected?
      @api = new_conn
    end

    def self.dia_config_path 
      File.join(RAILS_ROOT, "config", "democracy_in_action.yml")
    end
  

    def self.map( model_name, &blk)
      @@mappings[ model_name ] = blk
    end
    def self.merge_for( model_name, merge_name, &blk)
      @@merges[model_name]  ||= {}
      @@merges[model_name][merge_name] = blk
    end
    def self.email_key( model_name, key_name, &blk) 
      @@email_keys[model_name]  ||= {}
      @@email_keys[model_name][key_name] = blk
    end
    def self.keys( model_name, keys ) 
      @@keys[ model_name ] = keys
    end
    def self.default_key( model_name, key ) 
      @@default_keys[ model_name ] = key
    end

    def self.namify(model)
      model.class.class_name.underscore.to_sym
    end
    def self.translate( model, merge_name =nil )
      model_name = namify model 

      if @@mappings[model_name]
        return @@mappings[model_name].call( model ) unless merge_name
      end

      return {} unless @@merges[model_name] && @@merges[model_name][merge_name]
      return @@merges[model_name][merge_name].call( model )
    end

    def self.default_key_for( model)
      model_name = namify model
      @@default_keys[model_name]  
    end

    def self.predefined_email_keys
      @@predefined_email_keys ||= ( Rockwood::Config.email_keys || {} )
    end

    def self.add_email_key( email_key_name, value )
      predefined_email_keys
      @@predefined_email_keys[ email_key_name ] = value
    end

    def self.email_key_for( model, email_key_name )
      model_name = namify model 
      unless @@email_keys[model_name] && @@email_keys[model_name][email_key_name]
        return predefined_email_keys[email_key_name] 
      end
      @@email_keys[ model_name ][ email_key_name ].call(model)
    end
    def self.dia_object( model, local_key_name, data = {} )
      dia_obj = { :key => model.send("#{local_key_name}_key")} 
      dia_obj.delete(:key) unless dia_obj[:key]
      return dia_obj unless @@keys
      @@keys[(namify model)].inject( dia_obj) do |dia_obj, key_def|
        if key_def == local_key_name
           dia_obj[:object] = local_key_name.to_s
        end

        if key_def.respond_to?(:has_key?) && key_def.has_key?(local_key_name)
          dia_obj[:object] = key_def[local_key_name].to_s
        end

        dia_obj
      end
    end
  end

  def to_dia(*args)
    options = args.extract_options!

    if requested_merges = options[:merge]
      requested_merges = [ requested_merges ] unless requested_merges.respond_to?(:inject) 
      requested_data = requested_merges.inject( {} ) do |requested_data, merge_name |
        requested_data.merge( self.to_dia(merge_name) )
      end
    end
    merge_name = args.first
    base = DemocracyInActionSync::Config.translate( self, merge_name )
    base.merge(requested_data || {})
  end

  def save_to_dia(options = {})
    return true unless democracy_in_action
    self.default_dia_key = democracy_in_action.save( { :object => self.default_dia_object_name }.merge(self.to_dia))
  end

  def mail_via_dia( mail_key_name, data=nil )
    data ||= self.to_dia
    if mail_key_name.is_a? Fixnum
      mail_key = mail_key_name
    else
      mail_key = DemocracyInActionSync::Config.email_key_for(self,mail_key_name)
    end
    return false unless mail_key
    TemplatedSpam.create_for_dia( mail_key, data )  
  end

  def default_dia_key
    return unless default_dia_key_name
    self.read_attribute( default_dia_key_name )
  end

  def default_dia_key=(value)
    return unless default_dia_key_name
    self.write_attribute( default_dia_key_name, value )
  end

  def default_dia_key_name
    obj_name = DemocracyInActionSync::Config.default_key_for( self)
    return nil unless obj_name
    "#{obj_name}_key"
  end

  def default_dia_object_name
    DemocracyInActionSync::Config.default_key_for( self)
    
  end

  def delete_from_dia( local_key )
    local_key_name = "#{local_key}_key".to_sym
    return unless democracy_in_action && read_attribute( local_key_name )
    dia_object = DemocracyInActionSync::Config.dia_object( self, local_key)
    democracy_in_action.delete( dia_object )
    update_attribute local_key_name, nil
  end
  def create_for_dia( local_key )
    local_key_name = "#{local_key}_key".to_sym
    return unless democracy_in_action 
    dia_object = DemocracyInActionSync::Config.dia_object( self, local_key)
    dia_key = democracy_in_action.save( dia_object.merge( to_dia(local_key)))
    update_attribute local_key_name, dia_key
  end
  
end
