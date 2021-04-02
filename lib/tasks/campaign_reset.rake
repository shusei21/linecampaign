namespace :campaign_reset do
  desc "ユーザーのキャンペーン参加をリセットする"
  task reset_campaign_flag: :environment do
    User.update_all(campaign_flag: false)
  end
end
