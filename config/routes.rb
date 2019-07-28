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
      get :frequency_master, controller: :schedules, action: :frequency_master
    end
  end

  namespace :api do
    namespace :v1 do
      resources :groups, only: %i[create index show destroy update], shallow: true do
        resources :jobs, only: %i[create index show destroy update], shallow: true do
          resources :steps, only: %i[create index show destroy update]
          resources :schedules, only: %i[create index show destroy update]
        end
        resources :members, only: %i[create destroy index update]
        delete :destroy_with_user_id_and_group_id, controller: :members, action: :destroy_with_user_id_and_group_id
        collection do
          get :group_id_with_job_id, controller: :groups, action: :show_group_id_with_job_id
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tags, only: %i[create destroy index] do
        collection do
          get :tags_with_job_id, controller: :tags, action: :index_with_job_id
          post :tags_with_job_id, controller: :tags, action: :create_with_job_id
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :assigns, only: %i[create destroy index] do
        collection do
          get :assign_member, controller: :assigns, action: :index_assign_members
          post :assign_with_user_id, controller: :assigns, action: :create_assign_with_user_id
          delete :assign_with_user_id, controller: :assigns, action: :destroy_assign_with_user_id
          get :test_n, controller: :assigns, action: :assign_test_n
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :taggings, only: %i[create destroy] do
        collection do
          get :taggings_with_job_id, controller: :taggings, action: :index_with_job_id
          get :taggings_with_group_id, controller: :taggings, action: :index_with_group_id
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :stocks, only: %i[create destroy index]
    end
  end

  namespace :api do
    namespace :v1 do
      get :public_jobs, controller: :jobs, action: :index_public_jobs
      get :assigned_jobs, controller: :jobs, action: :index_assigned_jobs
      get :assigned_schedules, controller: :schedules, action: :index_assigned_schedules
      get :group_schedules, controller: :schedules, action: :index_group_schedules
    end
  end
end
