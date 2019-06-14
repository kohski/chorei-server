# frozen_string_literal: true

server '3.113.114.91', user: 'app', roles: %w[app db web]
set :ssh_options, keys: '/Users/kosukekimura/.ssh/id_rsa'
