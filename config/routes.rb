Rails.application.routes.draw do

  namespace :admin do
    resources :services, :only => [:index, :edit, :update]
    resources :service_groups
  end

end
