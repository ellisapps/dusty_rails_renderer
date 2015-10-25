module DustyRailsRenderer
  module Generators
    class InstallGenerator < Rails::Generators::Base
    	def copy_initializer
    		File.open(File.join('config/initializers', 'dust_initializer.rb'), 'w') do |f|
    			f.puts "DustyRailsRenderer.configure do |config|"
    			f.puts "\n"
    			f.puts "end"
    			f.puts "\n"
  				f.puts "DustyRailsRenderer.initialize"
			end
    	end
    end
  end
end
