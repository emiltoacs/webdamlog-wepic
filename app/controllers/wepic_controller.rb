class WepicController < ApplicationController
  include WLDatabase
  helper_method :find_picture_field
  
  def index
    order_criteria = if params[:order] then params[:order] else 'dated' end
    sorting_order = if params[:sort] || (params[:sort]!='asc'  and params[:sort]!='desc') then params[:sort] else 'asc' end
    # owner = if params[:username] then params[:username] else nil end
    @picture = Picture.new
    #These sorting options rely on getter setters that can be found in the pictures model under app/models/pictures.rb
    @order_options = ['rated','located','dated','titled'] 
    @sort_options = ['asc','desc']
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    unless @relation_classes['Picture'].nil?
      @pictures = Picture.where(:owner => Conf.env['USERNAME'])
      if sorting_order=='desc'
        @pictures.sort! {|a,b| b.send(order_criteria.to_sym) <=> a.send(order_criteria.to_sym)}
      else
        @pictures.sort! {|a,b| a.send(order_criteria.to_sym) <=> b.send(order_criteria.to_sym)}
      end
      #useful when sorting
      # if owner
        # @contact_pictures = Picture.where(:owner => owner)
      # end
    end
    @contacts = @relation_classes['Contact'].all unless @relation_classes['Contact'].nil?
  end

  #Updates all fields deriving from a picture
  def update
    picture = Picture.find(:first, :conditions => [ "_id = ?", params[:_id]])
    unless picture
      flash[:alert] = "No pictures for #{params[:_id]}"
      respond_to do |format| 
        format.json {render :json => {:saved => false, :errors => "No pictures for #{params[:_id]}"}.to_json}
        format.html {redirect_to :wepic, :notice => "No pictures for #{params[:_id]}"} 
      end
    else
      picture.titled = params[:title] if params[:title] and !params[:title].empty?
      picture.rated = params[:rating] if params[:rating] and !params[:rating].empty?
      picture.located = params[:location] if params[:location] and !params[:location].empty?
      if picture.errors.messages.empty? 
        respond_to do |format|
          format.json {render :json => {:saved => true, :title => picture.title, :rating => picture.rated, :location => picture.located}.to_json }
          format.html {redirect_to :wepic }
        end
      else
        respond_to do |format|
          format.json {render :json => {:saved => false, :errors => picture.errors.messages}.to_json }
          format.html {redirect_to :wepic, :alert => picture.errors.messages.inspect }
        end
      end
    end
  end
  
  #Updates the rating value when modified by the user
  #FIXME : DEPRECATED
  def updateRating
    ratingTuple = Picture.where(:_id => params[:_id]).first
    if ratingTuple
      ratingTuple.rated = params[:rating]
    else
      ratingTuple = Rating.new(:_id => params[:_id], :rating=>params[:rating])
    end
    if ratingTuple.save
    respond_to do |format|
      format.json {render :json => {:saved => true}.to_json }
    end      
    else
    respond_to do |format|
      format.json {render :json => {:saved => false, :errors => ratingTuple.errors}.to_json }
    end
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
  
  def send_picture
    #have to send
  end
end