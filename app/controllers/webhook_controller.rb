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
					            "displaytext": "応募する！",
					            "data": "応募する！",
					          },
					          {
					            "type": "postback",
					            "label": "応募しない",
					            "displaytext": "応募しない",
					            "data": "応募しない",
					          }
					      ]
					  }
					}
            		client.reply_message(event['replyToken'], message)
            	end
              end

	        when Line::Bot::Event::Postback
	        	case event.postback['data']
	        	when "応募する！"
	        		message = {
			          type: 'text',
			          text: "ありがとう！"
			        }
			        client.reply_message(event['replyToken'], postback)

	        	when "応募しない"
	        		message = {
			          type: 'text',
			          text: "またね"
			        }
			        client.reply_message(event['replyToken'], postback)

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