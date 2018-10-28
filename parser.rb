require 'telegram/bot'
require 'pry'
require 'nokogiri'
require 'httparty'
require 'open-uri'

TOKEN = '773528899:AAE5NKCJzEpep_2bpUY9cbUBi42N0hk7WDU'

@user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'

def dns_parser
  main_url = 'https://www.dns-shop.ru/'

  products = [
    '/b53791c627593330/processor-amd-ryzen-7-2700x-oem/',
    '/50e47a6527593330/processor-amd-ryzen-7-2700x-box/',
    '/6dbe3f0b2e503330/materinskaa-plata-asrock-x470-taichi/',
    '/0a76a9cb313c3330/operativnaa-pamat-corsair-vengeance-rgb-cmr32gx4m4c3466c16-32-gb/',
    '/5f423fd499173330/operativnaa-pamat-corsair-vengeance-rgb-pro-cmw32gx4m4c3200c16w-32-gb/',
    '/e5972335bfd63330/processor-intel-core-i9-9900k-oem/'
  ]

  data = []
  products.map do |el|
    url = main_url + 'product' + el
    # uri = URI(url)
    # res = Net::HTTP.get_response(uri)
    response = Nokogiri::HTML(open(url)) # if res.is_a?(Net::HTTPSuccess)
    doc_name = response.css('.price-item-title').children
    name = "`#{doc_name.text}`" unless doc_name.text.nil?
    doc_price = response.css('.current-price-value')
    if doc_price.empty?
      price = 'Цена не установлена на сайте'
    else
      price = doc_price.children[0].text.strip unless doc_price.children[0].text.nil?
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
        text: dns_parser,
        parse_mode: 'Markdown',
        disable_web_page_preview: true
      )
    end
  end
end
