class HomeController < ApplicationController


  def test
    require 'Imgur'
    require 'open-uri'
    require 'net/http'
    client = Imgur::Client.new('9017a4a9f99b687')
    url = 'http://ia.media-imdb.com/images/M/MV5BOTA2NjUwODM4MF5BMl5BanBnXkFtZTgwODY4ODkzMzE@._V1._SX200_CR0,0,200,200_.jpg'
    # resp = HTTParty.get(url)
    image = 'tmp/tempthing.'+Time.now.to_i.to_s+'.png'
    open(image, 'wb') do |file|
      file << open(url).read
    end

    # resp = open(url).read
    # return render text: resp

    image = Imgur::LocalImage.new(image)
    image = client.upload(image)
    # uploaded = client.upload(image)
    render json: {hola:'lynn',img: image.link}
  end


  def index
  	@q = params[:q].to_s
    @genre = params[:genre]
    @runtime = params[:runtime]
    @ymin = params[:ymin]
    @ymax = params[:ymax]
    @y = params[:y]
    @imdbmin = params[:imdbmin]
    @rtmin = params[:rtmin]
    @source = params[:source]

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
    if @genre != "" and @genre != nil
      @movies =  @movies.where("lower(genre) like ? ", "%#{@genre}%")
    end
    if @runtime != nil and @runtime.to_i > 0
      @movies = @movies.runTime @runtime
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

    if @imdbmin != nil and @imdbmin.to_i > 0
      @movies = @movies.minIMDB @imdbmin
    end
    if @rtmin != nil and @rtmin.to_i > 0
      @movies = @movies.minRT @rtmin
    end
    if @source == 'aiv'
      @movies =  @movies.amazonIV
    elsif @source == 'apv'
      @movies =  @movies.amazonPV
    elsif @source == 'box'
      @movies =  @movies.boxOffice
    end
    @movies = @movies.includes(:rating).order('ratings.rating desc') #where('ratings.source == "imdb"')
    # render json: @movies
  end



end