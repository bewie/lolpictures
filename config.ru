$:.unshift File.dirname(__FILE__)
$:.unshift File.dirname(__FILE__) + '/lib'

require 'bundler/setup'
require 'lolpictures'

set :run, false

config = YAML.load_file(File.expand_path("../config/config.yaml", __FILE__))


run Lolpictures.new(config[:lolcommits_json], config[:lolcommits_base], config[:cgit_url], config[:options])

## If you want basic HTTP authentication
## include :username and :password in config.yaml
#if config[:username] && config[:password]
#  use Rack::Auth::Basic do |username, password|
#    username == config[:username] && password == config[:password]
#  end
#end




#log = File.new("sinatra.log", "a")
#STDOUT.reopen(log)
#STDERR.reopen(log)
