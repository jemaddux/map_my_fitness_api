require "sinatra"
require "omniauth"
require "omniauth-mapmyfitness"
require "rest-client"

enable :sessions

CONSUMER_KEY = ENV["MAPMYFITNESS_CONSUMER_KEY"]
CONSUMER_SECRET = ENV["MAPMYFITNESS_CONSUMER_SECRET"]
CALLBACK_URL = "http://localhost:4567/oauth/callback"

use OmniAuth::Builder do
  provider :mapmyfitness, CONSUMER_KEY, CONSUMER_SECRET, strategy_class: OmniAuth::Strategies::MapMyFitness
end

get '/auth/:name/callback' do
  auth = request.env["omniauth.auth"]
  session[:user_id] = auth[:uid]
  session[:email] = auth[:info][:email]
  session[:token] = auth[:credentials][:token]
  session[:secret] = auth[:credentials][:secret]
  session[:raw_info] = auth[:raw_info]
  redirect '/'
end

# any of the following routes should work to sign the user in:
# /sign_up, /signup, /sign_in, /signin, /log_in, /login
["/sign_in/?", "/signin/?", "/log_in/?", "/login/?", "/sign_up/?", "/signup/?"].each do |path|
  get path do
    redirect '/auth/mapmyfitness'
  end
end

# either /log_out, /logout, /sign_out, or /signout will end the session and log the user out
["/sign_out/?", "/signout/?", "/log_out/?", "/logout/?"].each do |path|
  get path do
    session[:user_id] = nil
  redirect '/'
end


get '/' do
  if session[:user_id]
    %Q{
    name: #{session[:name]}\n
    user_id: #{session[:user_id]}\n
    token: #{session[:token]}\n
    secret: #{session[:secret]}\n
    #{session[:raw_info]}
    }
  else
    "blah"
  end
end

get "/search" do
  RestClient.get("http://api.mapmyfitness.com/3.1/users/search_users?#{session[:secret]}&o=json&zip=30030&limit=5")
end


def blah
  oauth_consumer_key = CONSUMER_KEY
  oauth_token = session[:token]
  oauth_signature_method = session[:signature_method]
  oauth_signature = session[:signature]
  oauth_timestamp = session[:timestamp]
  oauth_nonce = session[:nonce]
end

end
