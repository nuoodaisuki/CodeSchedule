class Public::CalendarController < ApplicationController

  def index
    @posts = current_user.posts
    respond_to do |format|
      format.html
      format.json
    end
  end
  
end
