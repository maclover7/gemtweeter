require 'sinatra'
require 'logger'
require 'active_support/core_ext/string/filters'
require 'digest/sha2'
require 'twitter'

class Whisper
  attr_reader :name, :version, :url, :info

  def initialize(hash)
    @hash = @hash
    ###
    @name    = @hash['name']
    @version = @hash['version']
    @url     = @hash['project_uri']
    @info    = @hash['info']
  end
end

class GemTweeter < Sinatra::Base
  Log = Logger.new(STDOUT)
  Log.level = Logger::INFO
  $twitter = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end

  get '/' do
    'It works!'
  end

  post '/hook' do
    data = request.body.read
    Log.info "got webhook: #{data}"

    hash = JSON.parse(data)
    Log.info "parsed json: #{hash.inspect}"

    authorization = Digest::SHA2.hexdigest(hash['name'] + hash['version'] + ENV['RUBYGEMS_API_KEY'])
    if env['HTTP_AUTHORIZATION'] == authorization
      Log.info "authorized: #{env['HTTP_AUTHORIZATION']}"
    else
      Log.info "unauthorized: #{env['HTTP_AUTHORIZATION']}"
      error 401
    end

    whisper = Whisper.new(hash)
    Log.info "created whisper"

    # Maximum length of a tweet sans URL is currently 140 characters - 22 (short URL length) - 1 space = 117 characters
    whisper_text = "#{whisper.name} (#{whisper.version}): #{whisper.info}".truncate(117, omission: "…", separator: " ") + " #{whisper.url}"

    response = $twitter.update(whisper_text)
    Log.info "TWEETED! #{response}"
  end
end
