require 'sinatra'
require 'sinatra/flash'
require 'pry'
require 'shopify_api'
require 'base64'
require 'firebase'

enable :sessions
use Rack::Session::Cookie, :key => 'rack.session',
:path => '/',
:expire_after => 2592000, # In seconds
:secret => 'makesuretochangeme!'


API_KEY = ENV["API_KEY"]
PASSWORD = ENV["PASSWORD"]
SHOP_NAME = ENV["SHOP_NAME"] 

# shop config
shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

# firebase config
base_uri = 'https://palette3.firebaseio.com/'
firebase = Firebase::Client.new(base_uri)


get '/signup' do
  erb :"signup.html"
end

get '/signout' do
  session['user'] = nil
  redirect '/'
end

post '/signup' do
  new_user = params["user"]
  response = firebase.push("users", { :email => new_user["email"], :password => Digest::SHA1.hexdigest(new_user["password"]), :name => new_user["name"] })
  if response.success?
    session['user'] = new_user["email"]
    redirect '/upload'
  else
    redirect '/signup'
  end
end

get '/signin' do
  erb :"signin.html"
end

                 
post '/signin' do
  user = params["user"]
  db_users = firebase.get("users").body.map { |k, v| v }

  maybe_user = db_users.select { |artist| (artist["email"] == user["email"])  and (artist["password"] == Digest::SHA1.hexdigest(user["password"]))  }

  if maybe_user.length >= 1

    session['user'] = maybe_user[0]["email"]
    redirect '/upload'
  else
    redirect '/signin'
  end
end


get '/' do
  
end

get '/upload' do
  erb :"upload.html"
end

post '/upload' do
  shop = ShopifyAPI::Shop.current
  product = params["product"]
  images =[]
  product["images"].each_with_index do |image|

    #images.push({ attachment:  Base64.encode64(open(image[:tempfile]) { |io| io.read })})
    images.push({ attachment:  Base64.encode64(image[:tempfile].read) })
  end

  # Create a new product
  new_product = ShopifyAPI::Product.new
  
  new_product.title, new_product.body_html, new_product.product_type, new_product.vendor, new_product.images, new_product.variants = [product["title"], product["description"], product["product_type"], session['user'], images, { "price" => 29.99 }]

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

