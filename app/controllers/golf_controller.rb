class GolfController < ApplicationController
	load 'regex.rb'
	respond_to :json

	def lists
		res = getLists
		session[:match] = res[0]
		session[:reject] = res[1]
		session[:max] = res[2]
		session[:regex] = res[3]
		render :json => res[0..2].to_json
	end

	def matches
		render :json => score(params[:regex]).to_json
	end
end
