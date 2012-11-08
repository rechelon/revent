ActionController::Base.session_store = :mem_cache_store
ActionController::Base.session = { 
  :key => '_daysofaction_session_id', 
  :secret => 'JPXCeqhYCnQduzY98nscgbnHDprEALMna9SuqZMfvjzvWvRG',
  :cache => CACHE
}

