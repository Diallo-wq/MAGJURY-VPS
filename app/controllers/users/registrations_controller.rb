# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  layout 'dashboard', only: %i[ edit ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    # on force le role depuis le param caché
    params[:user][:role] = params[:role] if %w[bidder].include?(params[:role])
    super
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  def after_sign_up_path_for(resource)
    if resource.bidder?
      # profil enchérisseur complet ?
      if resource.nom.present? &&
        resource.prenom.present? &&
        resource.phone.present? &&
        resource.address.present? &&
        resource.profile.present?

        mes_encheres_path
      else
        completion_enchere_profile_profile_path
      end
    elsif resource.admin? || resource.super_admin? || resource.redacteur?
      dashboard_index_path
    else
      user_profile_path
    end
  end

   protected
      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:nom, :prenom])
        devise_parameter_sanitizer.permit(:account_update, keys: [:nom, :prenom])
      end

      def update_resource(resource, params)
          if params[:password].present? || params[:password_confirmation].present?
          # L'utilisateur veut changer le mot de passe, on exige l'ancien mot de passe
          resource.update_with_password(params)
        else
          # Pas de changement de mot de passe, on ne demande pas l'ancien mot de passe
          filtered_params = params.except(:current_password)
          resource.update_without_password(filtered_params)
        end
      end

      # Optionnel, pour rediriger après update réussie
      def after_update_path_for(resource)
        user_profile_path # ou une autre page
      end

    private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :nom, :prenom, :role)
      end

      def account_update_params
        params.require(:user).permit(:nom, :prenom, :email, :password, :password_confirmation, :current_password, :profession, :domaine, :bio, :linkedin, :twitter, :facebook, :instagram, :tiktok)
      end


  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
