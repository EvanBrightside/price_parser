require 'telegram/bot'
require 'pry'
require 'nokogiri'
require 'httparty'
require 'open-uri'

TOKEN = '773528899:AAE5NKCJzEpep_2bpUY9cbUBi42N0hk7WDU'

@user_agent = 'Chrome/19.0.1084.56 Safari/536.5 Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.5 (KHTML, like Gecko)'

def dns_parser
  base_url = 'https://www.dns-shop.ru'
  wishlist_url = base_url + '/profile/wishlist/?list_id=46c44e2b-bbca-4458-bb59-a89b99e2ce35'

  data = []
  content = open(wishlist_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, 'User-Agent' => @user_agent)
  response = Nokogiri::HTML(content)
  wish_list_products = response.css('.wishlist-products .wishlist-product')
  wish_list_products.map do |el|
    doc_name = el.css('.name')
    name = "`#{doc_name.text}`" unless doc_name.children.nil?
    doc_url = el.css('.name a')
    url = base_url + el.css('.name a')[0]['href'] unless el.css('.name a')[0].nil?
    doc_price = el.css('.price_g span')
    if doc_price.children.empty?
      price = 'Цена не установлена на сайте'
    else
      price = doc_price.text.strip unless doc_price.nil?
    end
    data << [name, url, price]
  end
  new_data = data.map { |a, b, c| [a, b, ["#{c}\n "]] } * "\n"
  new_data
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|

    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: ['💲 Check Price'], resize_keyboard: true
    )

    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Hey, #{message.from.first_name}!",
        reply_markup: markup
      )
    when '💲 Check Price'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: dns_parser || "code: #{@code}",
        parse_mode: 'Markdown',
        disable_web_page_preview: true
      )
    end
  end
end
