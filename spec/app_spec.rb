require 'spec_helper'

describe 'App' do
  it "handles GET to '/'" do
    get '/'
    expect(last_response).to be_ok
  end

  private
    def app
      Rack::Builder.parse_file('config.ru').first
    end
end
