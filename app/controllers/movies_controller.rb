class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    # if !session.key?(:ratings) || !session.key?(:sort_name)
    #   @hash_ratings = Hash[@ratings_to_show.map{|key| [key, '1']}]
    #   if !session.key?(:ratings)
    #     session[:ratings] = @hash_ratings
    #   end
    #   if !session.key?(:sort_name)
    #     session[:sort_name] = ''
    #   end
    #   redirect_to movies_path(:ratings => @hash_ratings, :sort_name => '') and return
    # end
    # # retrieve memory
    # if (!params.key?(:ratings) && session.key?(:ratings)) || (!params.key?(:sort_name) && session.key?(:sort_name))
    #   hash_ratings_to = Hash[session[:ratings].map{|key| [key, '1']}]
    #   redirect_to movies_path(:ratings => hash_ratings_to, :sort_name => session[:sort_name]) and return
    # end

    # session[:ratings] = params[:ratings] if params[:ratings]
    # session[:sort_name] = params[:sort_name] if params[:sort_name]
    
    if params[:ratings].nil?
      @ratings_to_show = @all_ratings
    else
      @ratings_to_show = params[:ratings].keys.map{|rating| rating.upcase}
    end
    # hash table for memorizing sort and filter
    @hash_ratings_to_show = Hash[@ratings_to_show.map{|key| [key, '1']}]

    @movies = Movie.with_ratings(@ratings_to_show)

    need_redir = false
    # check: click on movie tile or release date?
    if params.has_key? (:sort_name)
      @hl_choose = params[:sort_name]
      session[:sort_name] = params[:sort_name]
    elsif session.has_key? (:sort_name)
      @hl_choose = session[:sort_name]
      need_redir = true
    else
      @hl_choose = ''
    end
    # check filtering memory
    if params.has_key? (:ratings)
      @hash_ratings_to_show = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session.has_key? (:ratings)
      @hash_ratings_to_show = session[:ratings]
      need_redir = true
    end
 
    # implementation
    if @hl_choose == 'title'

      @title_header = 'hilite bg-warning'
      @release_date_header = 'text-primary'
      @movies = @movies.order(:title)

    elsif @hl_choose == 'release_date'

      @title_header = 'text-primary'
      @release_date_header = 'hilite bg-warning'
      @movies = @movies.order(:release_date)

    else
      @title_header = 'text-primary'
      @release_date_header = 'text-primary'
    end

    if need_redir
      redirect_to movies_path(:ratings => @hash_ratings_to_show, :sort_name => @hl_choose)
    end

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
