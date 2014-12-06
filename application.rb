require 'sinatra'
require 'sinatra/flash'
require 'pry'
require 'shopify_api'

enable :sessions

API_KEY = ENV["API_KEY"]
PASSWORD = ENV["PASSWORD"]
SHOP_NAME = ENV["SHOP_NAME"] 

shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

get '/upload' do
  erb :"upload.html"
end

post '/upload' do
  shop = ShopifyAPI::Shop.current
  product = params["product"]
  # Create a new product
  new_product = ShopifyAPI::Product.new
  new_product.title, new_product.body_html, new_product.product_type, new_product.vendor = [product["title"], product["description"], product["product_type"], product["vendor"]]

  new_product.save
  
  redirect '/upload',  notice: "Your artwork was successfully uploaded."
end

