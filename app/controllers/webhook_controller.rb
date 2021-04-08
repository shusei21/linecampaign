class WebhookController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'

    protect_from_forgery except: [:callback] # CSRF対策無効化

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end


    def recieve
  		body = request.body.read

	  	signature = request.env['HTTP_X_LINE_SIGNATURE']
	    unless client.validate_signature(body, signature)
	    head :bad_request
	    end


		client = Line::Bot::Client.new{ |config|
			config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
			config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
		}


  		events = client.parse_events_from(body)
  		events.each do |event|
    	
    		case event
        	when Line::Bot::Event::Message
        	  case event.type
        	  when Line::Bot::Event::MessageType::Text
        	  	case event.message['text'] 
        	  	when "プレゼントキャンペーン"
        	  		message = {
					  "type": "template",
					  "altText": "キャンペーン応募確認",
					  "template": {
					      "type": "confirm",
					      "text": "応募しますか？",
					      "actions": [
					          {
					            "type": "postback",
					            "label": "応募する！",
					            "displayText": "応募する！",
					            "data": "応募する！",
					          },
					          {
					            "type": "postback",
					            "label": "応募しない",
					            "displayText": "応募しない",
					            "data": "応募しない",
					          }
					      ]
					  }
					}
            		client.reply_message(event['replyToken'], message)

            	end
              end

	        when Line::Bot::Event::Postback
	        	case event['postback']['data']
	        	when "応募する！"

	        		uid = event['source']['userId']  #userId取得
	        		user = User.where(user_id:uid)
	        		#User.where(user_id:uid).each do |user|

		        		if user.blank?

			        		new_user = User.new(user_id: uid, campaign_flag: true)
			        		new_user.save

			        		message = {
					          type: 'text',
					          text: "ご応募ありがとうございました$\n当選者には、翌月中旬ごろにBeGarden公式アカウントより当選メッセージをお送りします$\n※「ブロック」すると、当選メッセージを受け取ることができませんのでご注意ください$\n\n来月も応募をお待ちしています$",
					          emojis: [
							      {
							        "index": 14,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "001"
							      },
							      {
							        "index": 59,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "002"
							      },
							      {
							        "index": 100,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "002"
							      },
							      {
							        "index": 115,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "002"
							      }
							  ]
					        }
					        client.reply_message(event['replyToken'], message)


				    	elsif User.where(user_id: uid).where(campaign_flag: true).blank?
				    	
					    	User.where(user_id:uid).update(campaign_flag: true)
					    	message = {
					          type: 'text',
					          text: "キャンペーンに参加しました"
					        }
					        client.reply_message(event['replyToken'], message)


				    	else
					    	message = {
					          type: 'text',
					          text: "$既に応募済です。$",
					          emojis: [
							      {
							        "index": 0,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "001"
							      },
							      {
							        "index": 9,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "002"
							      }
							  ]					        
					        }
					        client.reply_message(event['replyToken'], message)

				        end
			    	


	        	when "応募しない"
	        		message = {
			          type: 'text',
			          text: "またね"
			        }
			        client.reply_message(event['replyToken'], message)

	        	end
	        end
  		end
	end

    def callback
      body = request.body.read

      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        head :bad_request
      end

      events = client.parse_events_from(body)

      events.each do |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: event.message['text']
            }
            client.reply_message(event['replyToken'], message)
          end
        end
      end

      head :OK
    end
end