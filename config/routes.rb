Rails.application.routes.draw do

  resources :custom_services

  namespace :admin do
    resources :services, :only => [:index, :edit, :update]
    resources :service_groups
  end

end
