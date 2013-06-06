class WepicController < ApplicationController
  include WLDatabase
  helper_method :find_picture_field
  
  def index
    order_criteria = if params[:order] then params[:order] else 'date' end
    @picture = Picture.new
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    unless @relation_classes['Picture'].nil?
      @pictures = @relation_classes['Picture'].where(:owner => Conf.env['USERNAME']).order(order_criteria + ' DESC')
    end
    @contacts = @relation_classes['Contact'].all unless @relation_classes['Contact'].nil?
    flash[:notice] = "sample notice : current ordering = #{params[:order]}"
  end
  
  #This method could be enhanced to make sure caching is used.
  # def find_picture_field(picture, classname,field=:all)
    # @relation_classes = database(Conf.env['USERNAME']).relation_classes unless @relation_classes
    # unless @relation_classes[classname].nil?
      # unless field==:all
        # tuple = @relation_classes[classname].where(:title => picture.title, :owner => picture.owner)
        # if tuple.first then tuple.first[field] else nil end
      # else
        # @relation_classes[classname].where(:title => picture.title, :owner => picture.owner)
      # end
    # else
      # nil
    # end
  # end
  
  #Updates the rating value when modified by the user
  def updateRating
    ratingTuple = Rating.where(:_id => params[:_id]).first
    if ratingTuple
      ratingTuple.rating = params[:rating]
    else
      ratingTuple = Rating.new(:_id => params[:id], :rating=>params[:rating])
    end
    ratingTuple.save
    respond_to do |format|
      format.json {render :json => params.to_json }
    end
  end
  
  #Get all comments after specified date (if no date specified load all comments for picture)
  def getLatestComments(args=nil)
    arguments = if args then args else params end
    logger.debug("Dump receiving info for getLatestComments : #{params.inspect}")
    @beforeAll = DateTime.new(2012) unless @beforeAll
    date = if arguments[:date] then arguments[:date] else @beforeAll end
    @comments = Comment.where(:_id => arguments[:_id]).where("created_at > ?", date).order('created_at ASC')
    @comments = [] unless @comments #In case there are no comments
    returnval = []
    @comments.each do |comment|
      small_hash = {}
      small_hash['owner'] = comment.author
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
    @comment = Comment.new(:_id => params[:_id],:author=>Conf.env['USERNAME'],:text => params[:text])
    unless @comment.save #in case of failure
      respond_to do |format|
        format.html {render :action => :index, :notice => "Could not add comment!" }
        format.json {render :json => @picture.errors, :status => :unprocessable_entity}
      end
    else #in case of success
      params[:date] = @comment.date.-(0.0002) #take the date the comment was created - 1 second.
      getLatestComments(params)
    end
  end
end