# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  def after_sign_in_path_for(resource)
    if resource.bidder?
      # profil enchérisseur complet ?
      if resource.nom.present? &&
        resource.prenom.present? &&
        resource.phone.present? &&
        resource.address.present? &&
        resource.profile.present?

        mes_encheres_path
      else
        completion_enchere_profile_profile_path(resource)
      end
    elsif resource.admin? || resource.super_admin? || resource.redacteur?
      dashboard_index_path
    else
      user_profile_path
    end
  end

    # Redirection après déconnexion
    def after_sign_out_path_for(resource_or_scope)
      # Exemple : rediriger vers la page d'accueil
      root_path
    end


  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
