configure :development do |config|
  require "sinatra/reloader"
end

FACE_API_KEY = "5e41f1f1329982858319695ade828d1a"
FACE_SECRET = "339cb6c44fa7875838f7fe38f480c5cd"
FACE_NAMESPACE = 'paul.nikitochkin'

class Face
  include HTTParty
  base_uri 'http://api.face.com'
  default_params :api_key => FACE_API_KEY, :api_secret => FACE_SECRET, :namespace => FACE_NAMESPACE

  def self.detect img
    result = get '/faces/detect.json', :query => { :urls => img, :detector => 'Aggressive', :attributes => 'all' }

    puts "Detect Tags:"
    p result
    p result.request

    raise 'Cannot process image' unless result['status'] == 'success'

    result['photos'].first["tags"].first["tid"]
  rescue => e
    raise e.inspect
  end

  def self.save_tag tid
    result = post '/tags/save.json', :query => { :tids => tid, :uid => ['face_match', FACE_NAMESPACE].join('@')}

    puts "Save Tag:"
    p result
    p result.request

    raise "Cannot process image: #{result["error_message"]}" unless result['status'] == 'success'
  end

  def self.train_face tid
    result = post '/faces/train.json', :query => {:uids => 'face_match'}

    puts "Train Face:"
    p result
    p result.request

    raise "Cannot process training: #{result["error_message"]}" unless result['status'] == 'success'

    #TODO: Need to check that training in progress
 end

  def self.recognize_face img
    result = post '/faces/recognize.json', :query => { :urls => img, :detector => 'Aggressive', :attributes => 'all', :uids => 'face_match'}

    puts "Recognize Face:"
    p result
    p result.request

    raise "Cannot process training: #{result["error_message"]}" unless result['status'] == 'success'

    #TODO: Need to check that training in progress
    result['photos'].first["tags"].first["uids"].first["uid"]
  end
end

set :server, :unicorn

get '/matchface' do
  return 400 unless params[:image1] && params[:image2]
  tid = Face.detect params[:image1]
  Face.save_tag tid
  Face.train_face tid

  unless Face.recognize_face params[:image2]
    'MISMATCH'
  else
    'MATCH FOUND'
  end
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end

not_found do
  'This is nowhere to be found.'
end

