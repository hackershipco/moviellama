class HomeController < ApplicationController


  def test
    client = Imgur::Client.new('9017a4a9f99b687')
    render json: {hola: 'lynn'}
  end


  def index
  	@q = params[:q].to_s
    @ymin = params[:ymin]
    @ymax = params[:ymax]
    @y = params[:y]
    @imdbmin = params[:imdbmin]
    @rtmin = params[:rtmin]

    url = "http://omdbapi.com/?t=" + @q
    @response = HTTParty.get(URI.encode(url))

    @movies = Movie

  	if(params[:s]!='search')
  		@movies = @movies.limit(0)
      @home = true
    end
    if(@q != "" and @q != nil)
  		Movie.obtain(@q)
  		@movies =  Movie.where("lower(title) like ? AND lower(genre) not like ? ", "%#{@q}%", "%short%")
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
    if @rtmin != "" and @rtmin != nil
      @movies = @movies.minRT @rtmin
    end
    @movies = @movies.includes(:rating).order('ratings.rating desc') #where('ratings.source == "imdb"')
  end



end