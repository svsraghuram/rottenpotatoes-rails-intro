class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if !params[:submit_clicked] and !params[:sort] and !params[:ratings] and request.env['PATH_INFO'] == '/'
      session.clear
    end

    @sort_with = params[:sort]
    @all_ratings = Movie.select(:rating).map(&:rating).uniq
    selectedRatings = {}
    @all_ratings.each{ |r| selectedRatings[r] = 1 }
    
    ratings = {}
    
    if(params[:sort])
      session[:sort_with] = params[:sort]
      @movies = Movie.order(params[:sort])
    elsif(session[:sort_with])
      @movies = Movie.order(session[:sort_with])
      @sort_with = session[:sort_with]
    else
      @movies = Movie.all
      session[:sort_with] = nil
    end

    if(params[:submit_clicked])
      if(!params[:ratings])
        ratings = selectedRatings
        session[:ratings] = nil
      else
        ratings = params[:ratings]
        session[:ratings] = ratings
      end
    elsif(params[:ratings]) 
      ratings = params[:ratings]
      session[:ratings] = ratings
    elsif(session[:ratings])
      ratings = session[:ratings]
    else
      ratings = selectedRatings
      session[:ratings] = nil
    end

    @ratings_to_show = ratings == selectedRatings ? selectedRatings.keys : ratings.keys
    @movies = @movies.with_ratings(ratings.keys)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end