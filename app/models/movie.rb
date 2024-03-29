class Movie < ActiveRecord::Base
	has_many :rating
	has_many :source

  def self.runTime y
    y  = y.to_i * 60
    where("runtime <= ?", y)
  end

	def self.yearFilter y
		where("year = ?", y)
	end

	def self.yearMin y
		where("year >= ?", y)
	end

	def self.yearMax y
		where("year <= ?", y)
	end

	def self.minIMDB y
		joins(:rating).merge(Rating.where("source = 'imdb' and rating >= ? " , y))
	end

	def self.minRT y
		joins(:rating).merge(Rating.where("source = 'rt' and rating >= ? " , y))
	end

	def self.amazonIV
		joins(:source).merge(Source.where("name = 'amazon-instant-video' "))
	end

  def self.amazonPV
    joins(:source).merge(Source.where("name = 'amazon-prime' "))
  end

  def self.boxOffice
    joins(:source).merge(Source.where("name = 'boxoffice' "))
  end

	def self.obtain q
  	url = "http://imdbapi.com/?s=" + q
  	@response = HTTParty.get(URI.encode(url))
  	@result = JSON.parse(@response.body)
  	if @result["Search"] == nil
  		return {:error => "Sorry, that movie is not in the llamabase :'("}
  	end
  	@result["Search"].each do |result|
	  	if self.exists?(title: result["Title"]) and self.exists?(year: result["Year"])
	  		@movie = Movie.where(["title = ? ", result["Title"] ]).first
	  	else
	  		url = "http://imdbapi.com/?tomatoes=true&i=" + result["imdbID"]
	  		_r = HTTParty.get(URI.encode(url))
	  		_r = JSON.parse(_r.body)
	  		if(_r["Type"]!="movie")
  				next
  			end
  			oscars = _r["Awards"].match(/won[\s+](?<wins>[\d]+)\s+(o|Oscar)/)
  			oscars = ((oscars == nil || oscars["wins"] == nil) ? 0 : oscars["wins"])
        image =  getImage(_r["Poster"])
				@movie = Movie.create({:title => _r["Title"],:year => _r["Year"],:release_date => _r["Released"],:genre => _r["Genre"],:poster_url => image, :plot => _r["Plot"],:runtime => _r["Runtime"] , :oscars => oscars, :imdbid => _r["imdbID"]})
				@movie.rating.create( {:source => "imdb", :rating => _r["imdbRating"]})
  			@movie.rating.create( {:source => "rt", :rating => _r["tomatoMeter"]})
  			feedSources @movie
  		end
    end

    return {:error => "" , :result => "Added new movies :) "}
	end

	def llamaRating
		imdbscore = self.rating.where("source = ?", "imdb").first
		rtscore = self.rating.where("source = ?", "rt").first
		if imdbscore == nil or rtscore == nil
			return "Llama doesn't know"
		elsif imdbscore.rating > 7.0 and rtscore.rating > 70
			return "PASS!"
		else
			return "FAIL!"
		end
	end

	def self.feedSources m
		if m.imdbid == nil
      render json: {:lol => 'cat'}
    end
    url = "http://www.imdb.com/title/"+m.imdbid+"/"
    response = HTTParty.get(URI.encode(url))
    _url = response.match(/\shref="(?<url>\/offsite\/\?.*watch-piv&token=[A-z0-9]*[^"]+)/i)
    if _url != nil and _url["url"] != nil
      m.source.create({:name => 'amazon-prime', :url =>_url["url"]})
    end
    _price = response.match(/from[\s+]\$(?<price>\d+\.\d\d)[\s+]on/i)
    if _price != nil and _price["price"] != nil
      _url = response.match(/\shref="(?<url>\/offsite\/\?.*watch-aiv&token=[A-z0-9]*[^"]+)/i)
      m.source.create({:name => 'amazon-instant-video', :url =>_url["url"], :price => _price["price"] })
    end
    _boxoffice = response.match(/(?<theater>watch in theaters)/i)
    if _boxoffice != nil and _boxoffice["theater"] != nil
      m.source.create({:name => 'boxoffice'})
    end
	end

	def self.sourceimage s
		img = {'amazon-instant-video'=>'amazonicon.png', 'amazon-prime' =>'amazonprimeicon.png', 'boxoffice' => 'intheatersicon.png'}
		return img[s] unless img[s] == nil
		return ''
	end

	def self.obtainOld(q)
		url = "http://omdbapi.com/?t=" + q
    @response = HTTParty.get(URI.encode(url))
    @result = JSON.parse(@response.body)
    if @result["Title"] == nil
      return {:error => "No such llama :("}
    end
    if self.exists?(title: @result["Title"]) and self.exists?(year: @result["Year"])
      return {:error => "" , :result => "Already in DB :) "}
		end
		oscars = @result["Awards"].match(/(?<wins>[\d]+)\s+(o|Oscar)/)
		self.create({:title => @result["Title"],:year => @result["Year"],:release_date => @result["Released"],:genre => @result["Genre"],:poster_url => @result["Poster"],:plot => @result["Plot"],:runtime => @result["Runtime"], :oscars => oscars })
    return {:error => "" , :result => "Added new movie :) "}
	end

  def self.getImage(url)
    if ['N/A','',nil].include? url
      return ''
    end
    require 'imgur'
    require 'open-uri'
    client = Imgur::Client.new('9017a4a9f99b687')
    image = "#{Rails.root.to_s}/tmp/tempthing."+Time.now.to_i.to_s+".png"
    open(image, 'wb') do |file|
      file << open(url).read
    end
    image = Imgur::LocalImage.new(image)
    image = client.upload(image)
    return image.link
  end

end
