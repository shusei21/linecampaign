class HomeController < ApplicationController
  def top
  	@user = User.all
  	
  end
end
