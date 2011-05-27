source "http://rubygems.org"

#gem "rails", "~> 2.3.5"
gem "chronic"
gem "geoip"
gem "daemons", :require => false
gem "hoe", :require => false
gem "echoe", :require => false
gem "ruby-yadis", :require => "yadis"
gem "ruby-openid", :require => "openid"
gem "rdiscount", "1.3.1.1", :platforms => :ruby
gem "stomp", "1.1"
gem "mime-types", :require => "mime/types"
gem "diff-lcs", :require => "diff/lcs"
gem "oauth"
gem "paperclip", "~> 2.2.8"
gem "state_machine"
gem "rack", "~> 1.0.1"
gem "riddle" # For the ultrasphinx plugin
gem "builder"
gem "mysql", :platforms => :ruby
gem "oauth"
gem "validates_url_format_of"
gem "acts-as-taggable-on"
gem "will_paginate"
gem "resque"
gem "SystemTimer"

# TODO: replace the lines below while upgrading to Rails 3
# gem "exception_notification", :require => 'exception_notifier'
gem "exception_notification", "~> 1.0.20090728", :require => 'exception_notifier'
# gem "bartt-ssl_requirement" # TODO: use this with Rails 3
gem "revo-ssl_requirement"

# Ruby 1.8 gems
gem "ruby-hmac", :platforms => :ruby_18
gem "json", "~> 1.4.6", :platforms => :ruby_18

group :test do
  gem "mocha", :require => false
  gem "factory_girl", "~> 1.3.0"
  gem "shoulda", "~> 2.9.1"
end

group :git_proxy do
  gem "proxymachine"
  gem "rake"
end

group :messaging do
  gem "json", "~> 1.4.6", :platforms => :ruby_18
  gem "resque"
  gem "SystemTimer"
end
