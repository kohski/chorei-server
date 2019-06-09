# frozen_string_literal: true

module AuthenticationProcedure
  def login
    let(:user) { create(:user) }
    # user = FactoryBot.build(:user)
    before do
      sign_in user
    end
  end
end
