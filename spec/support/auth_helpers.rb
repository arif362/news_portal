module AuthHelpers
  def sign_in(user)
    post login_path, params: { email: user.email, password: "password123" }
  end

  def sign_in_as_admin
    user = create(:user, :admin)
    sign_in(user)
    user
  end

  def sign_in_as_editor
    user = create(:user, :editor)
    sign_in(user)
    user
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
