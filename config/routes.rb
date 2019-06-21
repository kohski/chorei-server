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
        resources :members, only: %i[create destroy index]
        delete :destroy_with_user_id_and_group_id, controller: :members, action: :destroy_with_user_id_and_group_id
        collection do
          get :group_id_with_job_id, controller: :groups, action: :group_id_with_job_id
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tags, only: %i[create destroy index]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :assigns, only: %i[create destroy index] do
        collection do
          get :assign_member, controller: :assigns, action: :assign_members
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :taggings, only: %i[create destroy]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :stocks, only: %i[create destroy index]
    end
  end

  namespace :api do
    namespace :v1 do
      get :public_jobs, controller: :jobs, action: :public_jobs
    end
  end
end
