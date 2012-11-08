# Initializes multisite support by adding a macro to ActionController::Base
require 'patches/actioncontroller_ex'

# Add the tag helpers for rhtml and, optionally, liquid templates
require 'helpers/rhtml_theme_tags'
begin
   require 'helpers/liquid_theme_tags'   
rescue
   # I guess Liquid isn't being used...
end
