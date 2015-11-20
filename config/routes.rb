Rails.application.routes.draw do

  resources :custom_services
  resources :configs do
    collection do
      get :list_services
      post :edit_service
      post :preview_service
      post :apply_service
      delete :remove_service
    end
  end

  namespace :admin do
    resources :services, :only => [:index, :edit, :update] do
      resources :configs, :only => [:index, :edit, :update]
    end
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
