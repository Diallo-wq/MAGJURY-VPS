class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?

    def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :nom, :prenom,])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role, :nom, :prenom,])
    end

    # 1) admin + redacteur + super_admin    def require_redacteur!
    def require_redacteur!
      forbidden unless user_signed_in? && (current_user.admin? || current_user.redacteur? || current_user.super_admin?)
    end

    # 2) admin + super_admin
    def require_admin!
      forbidden unless user_signed_in? && (current_user.admin? || current_user.super_admin?)
    end

   

    before_action :ensure_profile_complete

    # app/controllers/application_controller.rb
    before_action :set_recent_posts

    def set_recent_posts
      @recent_posts = Post.with_featured_first.limit(6)
    end

   private

    def forbidden
      render file: Rails.root.join('public/403.html'), status: :forbidden, layout: false
    end

  def ensure_profile_complete
    return unless user_signed_in?
    return unless current_user.bidder?
    return if controller_name == "profiles" && action_name.in?(%w[completion_enchere_profile save_enchere_profile])

    if current_user.nom.blank? || current_user.prenom.blank? || current_user.phone.blank? || current_user.address.blank?
      redirect_to completion_enchere_profile_profile_path(current_user),
                  alert: "Veuillez finaliser votre profil pour continuer."
    end
  end
    # def require_role(role)
    #     unless current_user && current_user.role == role
    #         redirect_to root_path, alert: "Accès refusé"
    #     end
    #     #before_action -> { require_role("admin") }

    # end
end
