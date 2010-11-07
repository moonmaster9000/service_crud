require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "service_crud"
    gemspec.summary     = "DRY service crud."
    gemspec.description = "A simple mixin for providing crud actions for a RESTful, ActiveResource style service (xml and json)." 
    gemspec.email       = "moonmaster9000@gmail.com"
    gemspec.files       = FileList['lib/**/*.rb', 'README.markdown']
    gemspec.homepage    = "http://github.com/moonmaster9000/service_crud"
    gemspec.authors     = ["Matt Parker"]
    gemspec.add_dependency('rails', '>= 3.0')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
