require 'faye'
require "bundler/setup"

Faye::WebSocket.load_adapter('thin')
FAYE_TOKEN='dsadasdasdsa'

#require File.expand_path('../config/initializers/faye_config.rb', __FILE__)
#require File.expand_path('../config/initializers/core_extensions.rb', __FILE__)

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message.get_deep('ext', 'auth_token') != FAYE_TOKEN
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end

  # IMPORTANT: clear out the auth token so it is not leaked to the client
  def outgoing(message, callback)
    if message.get_deep('ext', 'auth_token')
      message['ext'] = {} 
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(ServerAuth.new)
run faye_server