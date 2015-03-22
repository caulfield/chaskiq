Postino::Engine.routes.draw do

  root 'dashboard#show'

  #public
  resources :campaigns, only: :show do
    member do
      get :subscribe
      get :unsubscribe
      get :forward
    end

    resources :subscribers do
      member do
        get :delete
      end
    end

    resources :tracks do
      member do
        get :click
        get :open
        get :bounce
        get :spam
      end
    end
  end

  #private
  scope 'manage',as: :manage do
    resources :campaigns, controller: 'manage/campaigns' do
      resources :wizard, controller: 'manage/campaign_wizard'
      member do
        get :preview
        get :test
        get :deliver
        get :editor
      end
      resources :attachments, controller: 'manage/attachments'
    end

    resources :lists, controller: 'manage/lists' do
      resources :subscribers, controller: 'manage/subscribers'
    end
    resources :templates, controller: 'manage/templates'
  end

end