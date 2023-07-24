Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/messages', to: 'messages#create'
      post '/messages/callback', to: 'messages#callback'
    end
  end
end
