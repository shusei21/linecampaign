class RichmenuController < ApplicationController

	def index

	end

	def create
		client = Line::Bot::Client.new{ |config|
		config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
		config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
		}

		if Rails.env.development?
			client = Line::Bot::Client.new{ |config|
			config.channel_secret = Rails.application.credentials[:LINE_CHANNEL_SECRET]
			config.channel_token = Rails.application.credentials[:LINE_CHANNEL_TOKEN]
			}
		end

		rich_menu = {
			
		  "size": {
		    "width": 1200,
		    "height": 810
		  },
		  "selected": true,
		  "name": "richmenu-a",
		  "chatBarText": "プレゼントキャンペーン",
		  "areas": [
		    {
		      "bounds": {
		        "x": 0,
		        "y": 0,
		        "width": 600,
		        "height": 50
		      },
		      "action": {
		        "type": "richmenuswitch",
		        "richMenuAliasId": "richmenu-alias-a",
		        "data": "richmenu-changed-to-a"
		      }
		    },{
		      "bounds": {
		        "x": 600,
		        "y": 0,
		        "width": 600,
		        "height": 50
		      },
		      "action": {
		        "type": "richmenuswitch",
		        "richMenuAliasId": "richmenu-alias-b",
		        "data": "richmenu-changed-to-b"
		      }
		    },{
		      "bounds": {
		        "x": 0,
		        "y": 50,
		        "width": 600,
		        "height": 760
		      },
		      "action": {
		        "type": "message",
		        "label": "プレゼントキャンペーン",
		        "text": "プレゼントキャンペーン"
		      }
		    },{
		      "bounds": {
		        "x": 600,
		        "y": 50,
		        "width": 600,
		        "height": 355
		      },
		      "action": {
		        "type": "uri",
		        "label": "BeGardenTop",
		        "uri": "https://www.rakuten.ne.jp/gold/be-garden/"
		      }
		    },{
		      "bounds": {
		        "x": 600,
		        "y": 405,
		        "width": 600,
		        "height": 405
		      },
		      "action": {
		        "type": "message",
		        "label": "アンケート",
		        "text": "アンケート"
		      }
		    }
		  ]
		}
		
		response = client.create_rich_menu(rich_menu)
		richmenu_id = JSON.parse(response.body)["richMenuId"]

		# アップロードファイル <- file_field
	    upload_img = params[:upload_file]

    	client.create_rich_menu_image(richmenu_id, upload_img)

    	client.set_default_rich_menu(richmenu_id)

    	uri = URI.parse("https://api.line.me/v2/bot/richmenu/alias")
	end

end
