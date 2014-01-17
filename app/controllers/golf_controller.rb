class GolfController < ApplicationController
	load 'regex.rb'
	respond_to :json

	def lists
		res = getLists
		session[:match] = res[0]
		session[:reject] = res[1]
		render :json => res.to_json
	end

	def matches
		render :json => score(params[:regex]).to_json
	end
end
