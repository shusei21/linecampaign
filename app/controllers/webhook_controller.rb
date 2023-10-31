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

		if Rails.env.development?
			client = Line::Bot::Client.new{ |config|
			config.channel_secret = Rails.application.credentials[:LINE_CHANNEL_SECRET]
			config.channel_token = Rails.application.credentials[:LINE_CHANNEL_TOKEN]
			}
		end
			


  		events = client.parse_events_from(body)
  		events.each do |event|

  			uid = event['source']['userId']  #userId取得
    	
    		case event
        	when Line::Bot::Event::Message
        	  case event.type
        	  when Line::Bot::Event::MessageType::Text
        	  	case event.message['text'] 
        	  	when "プレゼントキャンペーン"
        	  		message = [
        	  				{
					          type: 'text',
					          text: "キャンペーン内容、応募規約をご確認ください。\n→https://bit.ly/3dHwivC",
					          
					        },
					        {
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
					]
            		client.reply_message(event['replyToken'], message)


            	when "アンケート"
            		user = User.where(user_id:uid)
            		if user.blank?
			        		new_user = User.new(user_id: uid)
			        		new_user.save
			        end

            		message = [
        	  				{
					          type: 'text',
					          text: "あなたが興味のあるカテゴリを教えて下さい！$\n好みに合った情報が届く様になります♪\nまた、このアンケートは何度でも回答可能です。\n\n質問は６問ございます。",
					          emojis: [
					              {
							        "index": 21,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "009"
							      }
							  ]
					        },
					        {
							  "type": "template",
							  "altText": "ヘアケア",
							  "template": {
							      "type": "confirm",
							      "text": "「ヘアケア」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "ヘアケア興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "ヘアケア興味なし",
							          }
							      ]
							  }
							}
					]
            		client.reply_message(event['replyToken'], message)
            	end
              end

	        when Line::Bot::Event::Postback
	        	case event['postback']['data']
	        	when "応募する！"

	        		
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
							        "emojiId": "009"
							      },
							      {
							        "index": 60,
							        "productId": "5ac21a18040ab15980c9b43e",
							        "emojiId": "107"
							      },
							      {
							        "index": 102,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "042"
							      },
							      {
							        "index": 119,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "001"
							      }
							  ]
					        }
					        client.reply_message(event['replyToken'], message)


				    	elsif User.where(user_id: uid).where(campaign_flag: true).blank?
				    	
					    	User.where(user_id:uid).update(campaign_flag: true)
					    	message = {
					          type: 'text',
					          text: "ご応募ありがとうございました$\n当選者には、翌月中旬ごろにBeGarden公式アカウントより当選メッセージをお送りします$\n※「ブロック」すると、当選メッセージを受け取ることができませんのでご注意ください$\n\n来月も応募をお待ちしています$",
					          emojis: [
							      {
							        "index": 14,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "009"
							      },
							      {
							        "index": 60,
							        "productId": "5ac21a18040ab15980c9b43e",
							        "emojiId": "107"
							      },
							      {
							        "index": 102,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "042"
							      },
							      {
							        "index": 119,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "001"
							      }
							  ]
					        }
					        client.reply_message(event['replyToken'], message)


				    	else
					    	message = {
					          type: 'text',
					          text: "ご応募ありがとうございます$今月はすでにご応募済です$\n当選者には、翌月中旬ごろにBeGarden公式アカウントより当選メッセージをお送りします$\n※「ブロック」すると、当選メッセージを受け取ることができませんのでご注意ください$\n\n来月も応募をお待ちしています$",
					          emojis: [
							      {
							        "index": 13,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "009"
							      },
							      {
							        "index": 26,
							        "productId": "5ac21a18040ab15980c9b43e",
							        "emojiId": "028"
							      },
							      {
							        "index": 72,
							        "productId": "5ac21a18040ab15980c9b43e",
							        "emojiId": "107"
							      },
							      {
							        "index": 114,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "042"
							      },
							      {
							        "index": 131,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "001"
							      }
							  ]
					        }
					        client.reply_message(event['replyToken'], message)

				        end
			    	


	        	when "応募しない"
	        		message = {
			          type: 'text',
			          text: "ご不明な点がございましたか？\n\nお問い合わせは下記URLから$\nhttps://ask.step.rakuten.co.jp/inquiry-form/index.phtml?shop_id=253896&act=input&ms=500&fidmmy=1",
			          emojis: [
			          		  {
							    "index": 30,
							    "productId": "5ac1bfd5040ab15980c9b435",
							    "emojiId": "009"
							  }
					  ]
			        }
			        client.reply_message(event['replyToken'], message)

			    when "ヘアケア興味あり"
			    	User.where(user_id:uid).update(haircare_flag: true)
			    	message = {
							  "type": "template",
							  "altText": "スキンケア",
							  "template": {
							      "type": "confirm",
							      "text": "「スキンケア」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "スキンケア興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "スキンケア興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "ヘアケア興味なし"
			    	User.where(user_id:uid).update(haircare_flag: false)
			    	message = {
							  "type": "template",
							  "altText": "スキンケア",
							  "template": {
							      "type": "confirm",
							      "text": "「スキンケア」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "スキンケア興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "スキンケア興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "スキンケア興味あり"
			    	User.where(user_id:uid).update(skincare_flag: true)
			    	message = {
							  "type": "template",
							  "altText": "ボディケア",
							  "template": {
							      "type": "confirm",
							      "text": "「ボディケア」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "ボディケア興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "ボディケア興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "スキンケア興味なし"
			    	User.where(user_id:uid).update(skincare_flag: false)
			    	message = {
							  "type": "template",
							  "altText": "ボディケア",
							  "template": {
							      "type": "confirm",
							      "text": "「ボディケア」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "ボディケア興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "ボディケア興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "ボディケア興味あり"
			    	User.where(user_id:uid).update(bodycare_flag: true)
			    	message = {
							  "type": "template",
							  "altText": "健康食品",
							  "template": {
							      "type": "confirm",
							      "text": "「健康食品」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "健康食品興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "健康食品興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "ボディケア興味なし"
			    	User.where(user_id:uid).update(bodycare_flag: false)
			    	message = {
							  "type": "template",
							  "altText": "健康食品",
							  "template": {
							      "type": "confirm",
							      "text": "「健康食品」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "健康食品興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "健康食品興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "健康食品興味あり"
			    	User.where(user_id:uid).update(healthfood_flag: true)
			    	message = {
							  "type": "template",
							  "altText": "香水・アロマ",
							  "template": {
							      "type": "confirm",
							      "text": "「香水・アロマ」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "香水興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "香水興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "健康食品興味なし"
			    	User.where(user_id:uid).update(healthfood_flag: false)
			    	message = {
							  "type": "template",
							  "altText": "香水・アロマ",
							  "template": {
							      "type": "confirm",
							      "text": "「香水・アロマ」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "香水興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "香水興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "香水興味あり"
			    	User.where(user_id:uid).update(perfume_flag: true)
			    	message = {
							  "type": "template",
							  "altText": "アルコール",
							  "template": {
							      "type": "confirm",
							      "text": "「除菌アルコール」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "アルコール興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "アルコール興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "香水興味なし"
			    	User.where(user_id:uid).update(perfume_flag: false)
			    	message = {
							  "type": "template",
							  "altText": "アルコール",
							  "template": {
							      "type": "confirm",
							      "text": "「除菌アルコール」に興味はありますか？",
							      "actions": [
							          {
							            "type": "postback",
							            "label": "興味あり！",
							            "displayText": "興味あり！",
							            "data": "アルコール興味あり",
							          },
							          {
							            "type": "postback",
							            "label": "興味なし",
							            "displayText": "興味なし",
							            "data": "アルコール興味なし",
							          }
							      ]
							  }
					}
					client.reply_message(event['replyToken'], message)

				when "アルコール興味あり"
			    	User.where(user_id:uid).update(alcohol_flag: true)
			    	message = {
							  type: "text",
							  text: "質問は以上です。\nご回答ありがとうございました$\n今後の配信をお楽しみに$",
					          emojis: [
							      {
							        "index": 23,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "009"
							      },
							      {
							        "index": 36,
							        "productId": "5ac21a18040ab15980c9b43e",
							        "emojiId": "028"
							      }
							  ]
					}
					client.reply_message(event['replyToken'], message)

				when "アルコール興味なし"
			    	User.where(user_id:uid).update(alcohol_flag: false)
			    	message = {
							  type: "text",
							  text: "質問は以上です。\nご回答ありがとうございました$\n今後の配信をお楽しみに$",
					          emojis: [
							      {
							        "index": 23,
							        "productId": "5ac1bfd5040ab15980c9b435",
							        "emojiId": "009"
							      },
							      {
							        "index": 36,
							        "productId": "5ac21a18040ab15980c9b43e",
							        "emojiId": "028"
							      }
							  ]
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