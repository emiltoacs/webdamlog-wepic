# This is used by bundler to setup the gems dependencies:
# http://gembundler.com/man/gemfile.5.html
source 'https://rubygems.org'

gem 'rails'
gem 'rake'
gem 'thin'
gem 'rake'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'therubyracer'

gem 'cocaine'

# dbm is useless but required by bud without being in the dependency of bud
gem 'dbm'
gem 'bud', '0.9.5'

gem 'rmagick'

gem 'sqlite3'
gem 'pg'

gem 'json'
gem 'awesome_print'

group :development, :test do
  # To use the debugger
  gem 'debugger', :platforms => :ruby_19
  gem "ruby-debug", :platforms => :ruby_18
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'authlogic'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
#
# gem 'capistrano'