class HomeController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]

  def new
    logger.info "Home Controller New!"
  end

  def index
  end

end