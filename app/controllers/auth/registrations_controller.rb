# frozen_string_literal: true

module Auth
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    private

    def sign_up_params
      params.require(:registration).permit(:name, :email, :team, :password, :password_confirmation, :image, :description)
    end

    def account_update_params
      params.require(:registration).permit(:name, :email, :team, :image, :description)
    end
  end
end
