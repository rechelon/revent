# patrice: changed all instances of the word site to theme
# so that we don't get confused with our own definition of site
# also allows minimal changes to existing code base.  

# Extend the Base ActionController to support themes
ActionController::Base.class_eval do 

  attr_accessor :current_theme

  # Use this in your controller just like the <tt>layout</tt> macro.
  # Example:
  #
  #  theme :get_theme
  #  def get_theme
  #    'maybe_domain'
  #  end
  def self.theme(theme_name)
    write_inheritable_attribute "theme", theme_name
    before_filter :add_theme_path
  end

  # Retrieves the current set theme
  def current_theme(passed_theme=nil)
    theme = passed_theme || self.class.read_inheritable_attribute("theme")

    @active_theme = case theme 
      when Symbol then send(theme)
      when Proc   then theme.call(self)
      when String then theme
    end
  end

  protected
  def add_theme_path
    if current_theme
      #raise "Multitheme plugin is incompatible with template caching.  You must set config.action_view.cache_template_loading to false in your environment." if ActionView::Base.cache_template_loading
      #raise "Multitheme plugin is incompatible with template extension caching.  You must set config.action_view.cache_template_extensions to false in your environment." if ActionView::Base.cache_template_extensions
      new_path = File.join(RAILS_ROOT, 'themes', @active_theme, 'views')
      self.view_paths = [new_path, self.view_paths().last]
      ActionController::Base.view_paths = [new_path, ActionController::Base.view_paths().last]
    end
    return true
  end
end
