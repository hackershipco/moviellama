RAILS_ENV=production bundle exec rake assets:precompile
git add --all .
git commit -am 'compiled assets and prepped for heroku'
git push heroku master