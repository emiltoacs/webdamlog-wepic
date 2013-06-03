class WepicController < ApplicationController
  include WLDatabase
  helper_method :find_picture_field
  
  def index
    @picture = Picture.new
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @pictures = @relation_classes['Picture'].all unless @relation_classes['Picture'].nil?
    @contacts = @relation_classes['Contact'].all unless @relation_classes['Contact'].nil?
  end
  
  #This method could be enhanced to make sure caching is used.
  def find_picture_field(picture, classname,field=:all)
    @relation_classes = database(Conf.env['USERNAME']).relation_classes unless @relation_classes
    unless @relation_classes[classname].nil?
      unless field==:all
        tuple = @relation_classes[classname].where(:title => picture.title, :owner => picture.owner)
        if tuple.first then tuple.first[field] else nil end
      else
        @relation_classes[classname].where(:title => picture.title, :owner => picture.owner)
      end
    else
      nil
    end
  end
  
  #Updates the rating value when modified by the user
  def updateRating
    #TODO Think about if this is a performance issue.
    picture = Picture.find(params[:id])
    ratingTuple = Rating.where(:title => picture.title, :owner => picture.owner).first
    ratingTuple.rating = params[:rating]
    ratingTuple.save
    respond_to do |format|
      format.json {render :json => params.to_json }
    end    
  end
  
  #Get all comments after specified date (if no date specified load all comments for picture)
  def getLatestComments(args=nil)
    arguments = if args then args else params end
    logger.debug("Dump receiving info for getLatestComments : #{params.inspect}")
    picture = Picture.find(params[:id])
    @beforeAll = DateTime.new(2012) unless @beforeAll
    date = if arguments[:date] then arguments[:date] else @beforeAll end
    @comments = Comment.where(:title=>picture.title,:owner=>picture.owner).where("created_at > ?", date).order('created_at ASC')
    returnval = []
    @comments.each do |comment|
      small_hash = {}
      small_hash['owner'] = comment.comment_owner
      small_hash['text'] = comment.text
      small_hash['date'] = comment.created_at.strftime('%H:%M:%D')
      returnval << small_hash
    end
    respond_to do |format|
      format.json {render :json => returnval.to_json }
    end
  end
  
  #Add a comment to a given picture
  def addComment
    picture = Picture.find(params[:id])
    @comment = Comment.new(:title=>picture.title,:owner=>picture.owner,:comment_owner=>Conf.env['USERNAME'],:text => params[:text])
    unless @comment.save #in case of failure
      respond_to do |format|
        format.html {render :action => :index, :notice => "Could not add comment!" }
        format.json {render :json => @picture.errors, :status => :unprocessable_entity}
      end
    else #in case of success
      params[:date] = @comment.created_at.-(0.0002) #take the date the comment was created - 1 second.
      getLatestComments(params)
    end
  end
end