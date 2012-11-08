Gem::Specification.new do |s|
  s.name = %q{democracy_in_action}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Seth Walker, Ethan Snyder-Frey"]
  s.date = %q{2008-06-24}
  s.description = %q{resources for interacting with the DemocracyInAction online organizing platform (http://www.democracyinaction.org)}
  s.email = ["seth@radicaldesigns.org"]
  s.extra_rdoc_files = [
    "History.txt", 
    "License.txt", 
    "Manifest.txt", 
    "PostInstall.txt", 
    "README.txt", 
    "website/index.txt"]
  s.files = [
    "History.txt", 
    "License.txt"
    "Manifest.txt"
    "PostInstall.txt"
    "README.txt"
    "Rakefile"
    "config/hoe.rb"
    "config/requirements.rb"
    "lib/democracy_in_action.rb"
    "lib/democracy_in_action/api.rb"
    "lib/democracy_in_action/result.rb"
    "lib/democracy_in_action/tables.rb"
    "lib/democracy_in_action/test_methods.rb"
    "lib/democracy_in_action/desc_parse.rb"
    "lib/democracy_in_action/util.rb"
    "lib/democracy_in_action/version.rb"
    "lib/democracy_in_action/xml_parse.rb"
    "script/console"
    "script/destroy"
    "script/generate"
    "script/txt2html"
    "setup.rb"
    "spec/democracy_in_action_spec.rb"
    "spec/spec.opts"
    "spec/spec_helper.rb"
    "tasks/deployment.rake"
    "tasks/environment.rake"
    "tasks/rspec.rake"
    "tasks/website.rake"
    "website/index.html"
    "website/index.txt"
    "website/javascripts/rounded_corners_lite.inc.js"
    "website/stylesheets/screen.css"
    "website/template.html.erb"]
  s.has_rdoc = true
  s.homepage = %q{http://democracy_in_action.rubyforge.org}
  s.post_install_message = %q{
For more information on democracy_in_action, see http://democracy_in_action.rubyforge.org

NOTE: Change this information in PostInstall.txt 
You can also delete it if you don't want it.


}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{democracy_in_action}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{resources for interacting with the DemocracyInAction online organizing platform (http://www.democracyinaction.org)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
