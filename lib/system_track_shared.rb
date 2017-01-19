Dir["#{File.dirname(__FILE__)}/**/*.rb"].each {|f| 
#  puts "Requiring: #{f}"
  require f
}


