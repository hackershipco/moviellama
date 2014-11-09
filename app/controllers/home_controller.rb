class HomeController < ApplicationController


  def index
  	@q = params[:q].to_s


    url = "http://omdbapi.com/?t=" + @q
    @response = HTTParty.get(URI.encode(url))

    @ymin = params[:ymin]
    @ymax = params[:ymax]
    @y = params[:y]
    @imdbmin = params[:imdbmin]
  	if(@q == "" || @q == nil)
  		@movies = []
      @home = true
    else
  		Movie.obtain(@q)
  		@movies =  Movie.where("lower(title) like ?", "%#{@q}%")
  	end
    if @y != "" and @y != nil
      @movies = @movies.yearFilter @y
    end
    if @ymin != "" and @ymin != nil
      @movies = @movies.yearMin @ymin
    end
    if @ymax != "" and @ymax != nil
      @movies = @movies.yearMax @ymax
    end
    if @imdbmin != "" and @imdbmin != nil
      @movies = @movies.minIMDB @imdbmin
    end
    
    
    
  end


 
end