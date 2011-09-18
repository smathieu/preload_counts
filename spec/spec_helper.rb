require 'rspec'
require 'active_record'
require 'preload_counts'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

