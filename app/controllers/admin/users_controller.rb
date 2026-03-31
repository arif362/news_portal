module Admin
  class UsersController < BaseController
    before_action :require_admin!
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :toggle_active ]

    def index
      users = User.order(created_at: :desc)
      users = users.where(role: params[:role]) if params[:role].present?
      if params[:q].present?
        q = "%#{params[:q]}%"
        users = users.where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR username ILIKE :q", q: q)
      end
      @pagy, @users = pagy(users)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "User created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show; end
    def edit; end

    def update
      update_attrs = user_params
      update_attrs = update_attrs.except(:password, :password_confirmation) if update_attrs[:password].blank?

      if @user.update(update_attrs)
        redirect_to admin_user_path(@user), notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "Cannot delete yourself."
      else
        @user.destroy
        redirect_to admin_users_path, notice: "User deleted."
      end
    end

    def toggle_active
      @user.update!(active: !@user.active?)
      redirect_to admin_users_path, notice: "User #{@user.active? ? 'activated' : 'deactivated'}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :username, :first_name, :last_name,
                                   :first_name_bn, :last_name_bn, :role, :bio,
                                   :password, :password_confirmation, :avatar)
    end
  end
end
