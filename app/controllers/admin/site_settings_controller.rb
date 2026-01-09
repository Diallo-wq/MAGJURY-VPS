# app/controllers/admin/site_settings_controller.rb
class Admin::SiteSettingsController < ApplicationController
  before_action :require_admin!
  layout 'dashboard'
  def edit
    @setting = SiteSetting.current
  end

  def update
    @setting = SiteSetting.current
    if @setting.update(site_setting_params)
      redirect_to edit_admin_site_setting_path, notice: "Paramètres mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def site_setting_params
    params.require(:site_setting).permit(
      :site_name, :logo, :currency, :time_zone, :tel1, :tel2, :whatsapp, :description,
      :facebook, :linkedin, :instagram, :tiktok, :youtube, :twitter, :localisation, :devise, :site_email
    )
  end
end