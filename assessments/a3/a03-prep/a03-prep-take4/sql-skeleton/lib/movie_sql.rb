require 'singleton'
require 'sqlite3'

class MovieDatabase < SQLite3::Database
  include Singleton

  def initialize
    super(File.dirname(__FILE__) + "/../movie.db")

    self.results_as_hash = true
    self.type_translation = true
  end

  def self.execute(*args)
    self.instance.execute(*args)
  end
end

# List the films in which 'Chuck Norris' has appeared; order by movie
# title.
def bearded_films
  MovieDatabase.execute(<<-SQL)
    SELECT
      movies.title
    FROM
      movies
      JOIN castings ON castings.movie_id = movies.id
      JOIN actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Chuck Norris'
    ORDER BY
      movies.title
  SQL
end

# Obtain the cast list for the movie "Zombies of the Stratosphere";
# order by the actor's name.
def zombie_cast
  MovieDatabase.execute(<<-SQL)
    SELECT
      actors.name
    FROM
      movies
      JOIN castings on castings.movie_id = movies.id
      join actors on castings.actor_id = actors.id
    where
      movies.title = "Zombies of the Stratosphere"
    order by
      actors.name
  SQL
end

# Which were the busiest years for 'Danny DeVito'? Show the year and
# the number of movies he acted in for any year in which he was part of
# >2 movies. Order by year. Note the 'V' is capitalized.
def biggest_years_for_little_danny
  MovieDatabase.execute(<<-SQL)
    select
      movies.yr,
      count(movies.title) as count
    from
      movies
      join castings on movies.id = castings.movie_id
      join actors on actors.id = castings.actor_id
    where
      actors.name = 'Danny DeVito'
    group by
      movies.yr
    having
      count(*) > 2
  SQL
end

# List the films where 'Nicolas Cage' has appeared, but not in the
# star role. Order by movie title.
def more_cage_please
  MovieDatabase.execute(<<-SQL)
    select
      movies.title
    from movies
    join castings on castings.movie_id = movies.id
    join actors on castings.actor_id = actors.id
    where
      actors.name = 'Nicolas Cage' and castings.ord != 1
    order by
      movies.title
  SQL
end

# List the films together with the leading star for all 1908
# films. Order by movie title.
def who_is_florence_lawrence
  MovieDatabase.execute(<<-SQL)
    select movies.title, actors.name
    from movies
      join castings on castings.movie_id = movies.id
      join actors on castings.actor_id = actors.id
    where
      movies.yr = 1908 AND castings.ord = 1
    order by movies.title
  SQL
end

# Some actors listed in our database are not associated with any actual
# movie role(s). How many such actors are there? Alias this number as
# 'num_bad_actors'.
def count_bad_actors
  MovieDatabase.execute(<<-SQL)
    select count(actors.name) as num_bad_actors
    from actors
      left outer join castings on castings.actor_id = actors.id
    where
      castings.actor_id is null
  SQL
end

# Obtain a list in alphabetical order of actors who've had exactly 20
# starring roles. Order by actor name.
def twenty_roles
  MovieDatabase.execute(<<-SQL)
    select
      actors.name
    from actors
      join castings on castings.actor_id = actors.id
    where castings.ord = 1
    group by actors.name
    having count(*) = 20
  SQL
end

# List the film title and the leading actor for all of the films
# 'Chris Farley' played in.
def chris_is_missed
  MovieDatabase.execute(<<-SQL)
    select
      far_movies.movie_title as title,
      actors.name as name
    from
      (
        select
          movies.title as movie_title,
          movies.id as movie_id
        from movies
          join castings on castings.movie_id = movies.id
          join actors on castings.actor_id = actors.id
        where
          actors.name = 'Chris Farley'
      ) as far_movies

      join castings on castings.movie_id = far_movies.movie_id
      join actors on castings.actor_id = actors.id
    where
      castings.ord = 1

  SQL
end
