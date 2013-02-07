require 'action_dispatch/middleware/session/dalli_store'
Revent::Application.config.session_store(
  :dalli_store,
  :memcache_server => MEMCACHE_SERVERS,
  :key => '_revent_session_id',
  :namespace => 'revent_session'
)
