Rails.application.routes.draw do
  get 'errors/not_found'
  get 'errors/internal_server_error'

  devise_for :users, controllers: { sessions: 'users/sessions' }
  resources :projects
  
  # Defines the root path route ("/")
  root "projects#index"
  get "projects/:id/delete" => "projects#destroy"
  # get '*path' => "errors#not_found"
  get "/404" => "errors#not_found"
  get "/500" => "errors#internal_server_error"
end
