require 'sinatra'
require 'sinatra/flash'
require 'pry'
require 'shopify_api'
require 'base64'

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
  images =[]
  product["images"].each_with_index do |image|
    images.push({ attachment:  Base64.encode64(open(image[:tempfile]) { |io| io.read })})
  end

  # Create a new product
  new_product = ShopifyAPI::Product.new

  new_product.title, new_product.body_html, new_product.product_type, new_product.vendor, new_product.images = [product["title"], product["description"], product["product_type"], product["vendor"], images]
  new_product.save

  
  # add product to frontpage collection
  # set this to the id of the collection you want to add the product
# to
  fp_collection_id = "27425096"
  new_collect = ShopifyAPI::Collect.new
  new_collect.collection_id, new_collect.product_id  = fp_collection_id, new_product.id
  new_collect.save
  
  redirect '/upload',  notice: "Your artwork was successfully uploaded."
end

