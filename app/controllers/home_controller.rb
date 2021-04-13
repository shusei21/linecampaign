require 'csv'

class HomeController < ApplicationController
  before_action :authenticate_admin!
  def top
    @users = User.all
    @campaign_users = User.where(campaign_flag: true)
    @haircare_users = User.where(haircare_flag: true)
    @skincare_users = User.where(skincare_flag: true)
    @bodycare_users = User.where(bodycare_flag: true)
    @healthfood_users = User.where(healthfood_flag: true)
    @perfume_users = User.where(perfume_flag: true)
    @alcohol_users = User.where(alcohol_flag: true)
  end

  def index
  	@users = User.all

    respond_to do |format|
      format.html
      format.csv do |csv|
        send_users_csv(@users)
      end
    end
  end

  def send_users_csv(users)
    csv_data = CSV.generate do |csv|
      header = %w(id created_at updated_at user_id campaign_flag haircare_flag skincare_flag bodycare_flag healthfood_flag perfume_flag alcohol_flag)
      csv << header

      @users.each do |user|
        values = [user.id,user.created_at,user.updated_at,user.user_id,user.campaign_flag,user.haircare_flag,user.skincare_flag,user.bodycare_flag,user.healthfood_flag,user.perfume_flag,user.alcohol_flag]
        csv << values
      end

    end
    send_data(csv_data, filename: "users.csv")
  end

  def reset_campaign
  	User.update_all(campaign_flag: false)

  	redirect_to root_path
  end

end