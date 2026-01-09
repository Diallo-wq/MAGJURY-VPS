class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  layout 'dashboard'
  before_action :require_admin!
  before_action :set_user, only: [:show, :edit, :update, :block, :unblock]


  def index
    @users = User.all

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.contributor = params[:user][:contributor] == '1'
    if @user.save
      redirect_to admin_user_path(@user), notice: "Utilisateur créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Profil mis à jour."
    else
      puts @user.errors.full_messages
      render :edit
    end
  end

  def block
    @user.update(blocked: true)
    redirect_to admin_users_path, notice: "Compte bloqué."
  end

  def unblock
    @user.update(blocked: false)
    redirect_to admin_users_path, notice: "Compte débloqué."
  end

  private

  # def check_admin
  #   redirect_to root_path, alert: "Accès refusé" unless current_user.admin?
  # end

  def set_user
    @user = User.find(params[:id])
  end


  def user_params
    base = params.require(:user).permit(:nom, :prenom, :email, :blocked, :phone, :address,
                                :profession, :domaine, :role, :bio, :status,
                                :linkedin, :twitter, :facebook, :instagram, :tiktok)
                                .merge(contributor: params[:user][:contributor] == '1')
    if params[:user][:password].present?
      base.merge(params.require(:user).permit(:password, :password_confirmation))
    else
      base
    end
  end
end
