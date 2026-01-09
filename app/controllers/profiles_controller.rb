# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_bidder!

  # Formulaire de completion
  def completion_enchere_profile
    # @user déjà disponible via current_user
  end

  # Soumission
  def save_enchere_profile
    if current_user.update(profile_params)
      redirect_to encheres_path, notice: "Profil complet ! Vous pouvez désormais enchérir."
    else
      render :completion_enchere_profile, status: :unprocessable_entity
    end
  end

  private

  def ensure_bidder!
    redirect_to root_path, alert: "Accès réservé aux enchérisseurs." unless current_user.bidder?
  end

  def profile_params
    params.require(:user).permit(:nom, :prenom, :phone, :address, :profile)
  end
end