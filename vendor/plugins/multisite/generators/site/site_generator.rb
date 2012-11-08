class SiteGenerator < Rails::Generator::NamedBase
     
   def manifest
      record do |m|
          # Site folder(s)
          m.directory File.join( "themes", file_name )
          # Site content folders
          m.directory File.join( "themes", file_name, "views" )
          m.directory File.join( "themes", file_name, "public" )
      end
   end
end
