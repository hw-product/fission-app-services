Rails.application.routes.draw do

  resources :custom_services

  namespace :admin do
    resources :services, :only => [:index, :edit, :update]
    resources :service_groups do
      collection do
        get :add_filter
        delete :remove_filter
        get :add_filter_rule
        post :apply_filter_rule
        delete :remove_filter_rule
      end
    end
  end

end
