# Dusty Rails Renderer

Dusty Rails Renderer was written to make it easy to render dust.js templates server side. Please refer to <a href="www.dustjs.com">www.dustjs.com</a> for documentation on using Dust.js. This gem requires Dust.js by LinkedIn

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dusty_rails_renderer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dusty_rails_renderer

## Configuration

Run:

	$ rails generate dusty_rails_renderer:install

This will create an initializer for dusty_rails_renderer at 'config/initializers/dust_initializer.rb'. 

## Defaults

dust_initializer.rb

	$ DustyRailsRenderer.configure do |config|
	$ 	config.dust_config_path = 'config/dust_initializer.yml'
	$ 	config.dust_js_library_path = 'app/assets/javascripts/libraries/dust/dust-full.js'
	$ 	config.dust_template_base_path = 'app/assets/javascripts/dust/'
	$ 	config.production = false	  
	$   config.node_dust_compiler = false
	$ 	config.logging = false
	$	config.dust_compiler_command =  "dustc"
	$ end

	$ DustyRailsRenderer.initialize


By configuring the initializer you can update the location of your Dust templates and Dust.js library. For this gem to work property you must use the full Dust library that includes the compiler. Lastly, setting config.production = false will enable loading from disk and precompiling during request time. This
feature is great for debugging and creating new templates but not for production. Setting config.production = true will precompile the templates once
during the server initialization process and load the templates into memory. Setting config.node_dust_compiler = true will activate precompiling templates with dustc (dustjs-linkedin npm package).

## Usage

Add reference to all your Dust.js templates in config.dust/initializer.yml. Templates names must be unique. file_path is the reference to your Dust.js templates
inside the dust_template_base_path. For example using the default dusty_rails_renderer configuration 'common/header.dust' would be in 'app/assets/javascripts/dust/common/header.dust'

dust_initializer.yml

	header:
  		file_path: common/header.dust
  		name: common_header
	home:
  		file_path: home/home.dust
  		name: home

Lastly, to render Dust.js templates server side in your controllers, call  
	
	$	DustyRailsRenderer.render('{TEMPLATE_NAME_HERE}',"{JSON_HERE}"). 

Example

	$	render :text =>  DustyRailsRenderer.render('home',"{name: 'Louis'}") , :layout => "application"

Client-Side

To use your precompiled templates on the client-side you can pass the precompiled templates into javascript.

	$	<script type="text/javascript">
	$		var precompiled_templates = <%= raw DustyRailsRenderer.templates %>;
	$	</script>

Include the dust.js(full library by LinkedIn) then register and render templates

	$	<script type="text/javascript">
	$		var Utils = {
	$			load_templates: function() {
	$    			for(var key in precompile_templates) {
	$	  	  			dust.loadSource(precompile_templates[key], key);
	$    			}
	$			} 
	$		    , render_template: function(template_name, json) { 
	$				return (function() {
	$					var result = '';
	$	   				dust.render(template_name, json, function(err,out) {
	$						result = out;
	$					});
	$					return result;
	$				})();
	$			}
	$		}
	$
	$		Utils.load_templates(precompiled_templates);
	$		Utils.render_template('{TEMPLATE_NAME_HERE}',"{JSON_HERE}");
	$	</script>

## Who wrote Dusty Rails Renderer?

My name is <a href="http://louisellis.com/">Louis Ellis</a> and I wrote Dust Rails Renderer in October 2015.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ellisapps/dusty_rails_renderer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the <a href="http://contributor-covenant.org">Contributor Covenant</a> code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

