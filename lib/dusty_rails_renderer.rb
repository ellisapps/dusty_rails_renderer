require "dusty_rails_renderer/version"
require "open3"

module DustyRailsRenderer
  class << self
    include ActionView::Helpers::JavaScriptHelper
    attr_writer :configuration

    #Initialize, load Dust.js library, and precompile Dust.js templates
    def initialize
      @dust_config = YAML.load_file(self.configuration.dust_config_path)
      @dust_library = File.read(self.configuration.dust_js_library_path)
      @precompiled_templates = Hash.new
      @last_modification_hash = Hash.new
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

        if @last_modification_hash[template_name] == File.mtime(file_url)
          next
        else
          @last_modification_hash[template_name] = File.mtime(file_url)
        end

        if self.configuration.logging
          puts "file url = #{file_url}"
          puts "template name = #{template_name}"
        end

        if self.configuration.node_dust_compiler
          command = "#{self.configuration.dust_compiler_command} --name=#{template_name} #{file_url}"
          template = Open3.capture3("bash","-l","-c",command)
          escaped_template = escape_javascript(template[0])

          if self.configuration.logging
            puts "open3 result = #{template}"
            puts "compiled template = #{escaped_template}"
          end

          @context.eval("dust.loadSource(\"#{escaped_template}\")")
          @precompiled_templates[template_name] = template[0]
        else 
          contents = File.read(file_url).gsub("\n","").gsub("\"","'").gsub("\t","")
          template = @context.eval("(function() {var template = dust.compile(\"#{contents}\",'#{template_name}'); dust.loadSource(template); return template; })()")  
         
          if self.configuration.logging
            puts "compiled template = #{escaped_template}"
          end

          @precompiled_templates[template_name] = template
        end
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
    attr_accessor :node_dust_compiler
    attr_accessor :logging
    attr_accessor :dust_compiler_command
    
    def initialize
      @dust_config_path = "config/dust_initializer.yml"
      @dust_js_library_path = "app/assets/javascripts/libraries/dust/dust-full.js"
      @dust_template_base_path = "app/assets/javascripts/dust/"
      @production = false	  
      @node_dust_compiler = false
      @dust_compiler_command = "dustc"
      @logging = false
    end
  end

end
