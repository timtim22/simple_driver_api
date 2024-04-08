Rails.application.routes.draw do
  namespace :v1 do
    resources :blobs, only: [:create, :show]
  end
end
