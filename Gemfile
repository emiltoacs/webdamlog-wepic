# This is used by bundler to setup the gems dependencies:
# http://gembundler.com/man/gemfile.5.html
source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '>= 3.2.0'
gem 'rake'
gem 'thin'
gem 'rake'

# dbm is useless but required by bud without being in the dependency of bud
gem 'dbm'
gem 'bud', '>= 0.9.7'
gem 'therubyracer'
gem 'cocaine'
gem 'awesome_print'
gem 'rmagick'
gem 'sqlite3'
gem 'pg'
gem 'authlogic'
gem 'json'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'fancybox-rails'
gem 'jquery-star-rating-rails'
gem 'trim_blobs'
gem 'active_attr'

group :development, :test do
  # To use the debugger
  gem 'debugger', :platforms => :ruby_19
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end
