Rails.application.routes.draw do

  namespace :admin do
    resources :services, :only => [:index, :edit, :update]
  end

end
