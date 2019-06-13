# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'auth/registrations'
      }
    end
  end
  namespace :api do
    namespace :v1 do
      resources :groups, only: %i[create index show destroy update], shallow: true do
        resources :jobs, only: %i[create index show destroy update], shallow: true do
          resources :steps, only: %i[create index show destroy update]
          resources :schedules, only: %i[create index show destroy update]
        end
      end
    end
  end
  namespace :api do
    namespace :v1 do
      resources :members, only: %i[create destroy]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tags, only: %i[create destroy index]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :assigns, only: %i[create destroy index]
    end
  end
end
