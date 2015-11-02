require "singleton"
require "dusty_rails_renderer/version"

module DustyRailsRenderer
  class << self
    include Singleton
    attr_writer :configuration

    #Initialize, load Dust.js library, and precompile Dust.js templates
    def initialize
      @dust_config = YAML.load_file(self.configuration.dust_config_path)
      @dust_library = File.read(self.configuration.dust_js_library_path)
      @precompiled_templates = Hash.new
      @context = V8::Context.new
      @context.eval(@dust_library, 'dustjs') 

      read_dust_files
    end

    #Return precompiled templates in JSON format (Client-side)
    def templates
      @precompiled_templates.to_json
    end

    def render(template_name, json) 
      if self.configuration.production
        @context.eval("(function() { var result; dust.render('#{template_name}', #{json}, function(err, out) { result = out; }); return result; })()")
      else 
        #Reset Context
        @context = V8::Context.new
        @context.eval(@dust_library, 'dustjs') 
       
        read_dust_files
        @context.eval("(function() { var result; dust.render('#{template_name}', #{json}, function(err, out) { result = out; }); return result; })()")
      end
    end

   	private 
    #Read in and register Dust.js templates
    def read_dust_files
      @dust_config.each do |template, info|
        file_url = self.configuration.dust_template_base_path + info["file_path"]
        template_name = info["name"]
        contents = File.read(file_url).gsub("\n","").gsub("\"","'").gsub("\t","")
        template = @context.eval("(function() {var template = dust.compile(\"#{contents}\",'#{template_name}'); dust.loadSource(template); return template; })()")  
        @precompiled_templates[template_name] = template
      end
    end 
  end
  
  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :dust_config_path
    attr_accessor :dust_js_library_path
    attr_accessor :production
    attr_accessor :dust_template_base_path

    def initialize
      @dust_config_path = "config/dust_initializer.yml"
      @dust_js_library_path = "app/assets/javascripts/libraries/dust/dust-full.js"
      @dust_template_base_path = "app/assets/javascripts/dust/"
      @production = false	  
    end
  end

end
