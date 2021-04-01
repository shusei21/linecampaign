require 'csv'

class HomeController < ApplicationController
  def top
    @users = User.all
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
      header = %w(id created_at updated_at user_id campaign_flag)
      csv << header

      @users.each do |user|
        values = [user.id,user.created_at,user.updated_at,user.user_id,user.campaign_flag]
        csv << values
      end

    end
    send_data(csv_data, filename: "users.csv")
  end

end