class Rating < ActiveRecord::Base
	belongs_to :movie

	def getParsedRating
		if self.source == 'rt'
			return self.rating.to_i
		elsif self.source == 'imdb'
			return sprintf('%.1f', self.rating)
		else
			return self.rating
		end
	end

	def ratingLabel
		dict = {"imdb" => "IMDB", "rt" => "Rotten Tomatoes"}
		return dict[self.source]
	end
end