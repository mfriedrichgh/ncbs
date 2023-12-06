Rails.application.routes.draw do
    resources :projects
  
    # Defines the root path route ("/")
    root "projects#index"
  
    # Users
    get "/users" => "users#index"
    get "/:userid" => "users#show"
    get "/:userid/:projectid" => "projects#show"
    get "/projects" => "projects#index"
end
