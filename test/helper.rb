require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rr'
require 'test/unit'
require 'test/unit/rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fluent/log'
require 'fluent/test'

$log = Fluent::Log.new(Fluent::Test::DummyLogDevice.new, Fluent::Log::LEVEL_WARN)

require 'fluent/plugin/in_jstat'
