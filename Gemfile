source "http://rubygems.org"

# Specify your gem's dependencies in preload_counts.gemspec
gemspec

activerecord_version = ENV["ACTIVERECORD_VERSION"] || "default"

activerecord_version = case activerecord_version
when "master"
  {github: "rails/rails"}
when "default"
  ">= 3.2.0"
else
  "~> #{activerecord_version}"
end


gem "activerecord", activerecord_version
gem "pry"
gem "awesome_print"
