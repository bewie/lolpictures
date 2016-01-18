# myapp.rb

require 'sinatra'
require 'json'
require 'yaml'
require 'uri'
require 'net/http'

require 'erb'


class Lolpictures < ::Sinatra::Base

	def initialize(lolcommits_json, lolcommits_base, cgit_url, options = {})

		@lolcommits_json = lolcommits_json
		@lolcommits_base = lolcommits_base
		@cgit_url = cgit_url
		@refresh_rate = options.delete(:refresh_rate) || 300
		@prefix = options.delete(:prefix) || ""
		@title = options.delete(:title) || 'lolcommit Gallery'
		@pics_by_page = options.delete(:pics_by_page) || 80
      super()
    end

	before do
		expires 500, :public, :must_revalidate
	end


	get '/' do
		status, headers, body = call env.merge("PATH_INFO" => '/1')
  	end

	get '/:page' do
		get_json(@lolcommits_json)
		@lol_pictures = @pics.sort
		if @lol_pictures.empty?
			@error = "No picture found in the directory"
		else
			pager()
		end

		erb :index
	end

	helpers do
		include Rack::Utils
		alias_method :h, :escape_html
		def pager()
			size = @pics.length - 1
			@nb_pages = size / @pics_by_page + 1
			@to = size - ((params[:page].to_i - 1 ) * @pics_by_page)
			@from = @to - @pics_by_page
			@page_up = params[:page].to_i + 1
			@page_down = params[:page].to_i - 1
			@page = params[:page].to_i
		end

		def get_json(lolcommits_json)
			uri =  URI("#{lolcommits_json}")
			req = Net::HTTP::Get.new(uri.request_uri)
			#req.basic_auth params[:user], params[:password]

			res = Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') {|http|
				http.request(req)
			}
			if res.is_a?(Net::HTTPSuccess)
				json_res = JSON.parse(res.body)

				# debug messages:
				# puts res.body
				@pics = Array.new
				json_res.each do |p|
			#		#2012 12 27 10 27 30.jpg
					if p["name"] =~ /(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])\d\d\d\d\d\d\.(jpg|png|gif)$/
						@pics << @lolcommits_base + "/" + p["name"]
					end
				end
			end
		end
	end
end
