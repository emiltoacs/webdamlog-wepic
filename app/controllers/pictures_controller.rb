class PicturesController < WepicController
  
  # By convention this method create is called when the submit button of the
  # form in wepic/_upload_from_[file/url].html.erb is pressed. This convention is enforced
  # because the form is sent with an http POST requests.
  def create
    config.logger.info "Picture Parameters : #{params[:picture].inspect}" 
    @picture = Picture.new(:title => params[:picture][:title],:owner=>Conf.env['USERNAME'],:image_url=>params[:picture][:image_url]) if params[:picture][:image_url]
    @picture = Picture.new(:title => params[:picture][:title],:owner=>Conf.env['USERNAME'],:image=>params[:picture][:image]) if params[:picture][:image]
    @pictures = Picture.all if @pictures.nil?
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @contacts = Contact.all
    if @picture.save
      @picture.located = params[:location] if params[:location] #in case we have a location from the start
      config.logger.debug "#in PicturesController, user #{Conf.env['USERNAME']} successfully saved a new picture"
      respond_to do |format|
        format.html { redirect_to :wepic, :notice => 'Picture was successfully created.' }
        format.json { render :json => @picture, :status => :created, :location => :wepic }
      end
    else
      config.logger.debug "#in PicturesController, user #{Conf.env['USERNAME']} failed to save a new picture"
      respond_to do |format|        
        format.html { redirect_to :wepic, :notice => "Image creation was not successful. #{@picture.errors.messages.inspect}" }
        format.json { render :json => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    logger.debug "Update picture was called with arguments : #{params.inspect}"
    respond_to do |format|
      format.html { redirect_to :wepic, :notice => 'Picture was successfully updated.' }
      format.json { render :json => @picture, :status => :created, :location => :wepic }
    end
  end
  
  #This method returns a json representation of the pictures of a contact (not the picture data itself,
  #but enough information to display the picture thumbnail).
  def contact
    order_criteria = if params[:order] then params[:order] else 'dated' end
    sorting_order = if params[:sort] || (params[:sort]!='asc'  and params[:sort]!='desc') then params[:sort] else 'asc' end    
    #These sorting options rely on getter setters that can be found in the pictures model under app/models/pictures.rb
    @order_options = ['rated','located','dated','titled']
    @sort_options = ['asc','desc']    
    username = params[:username]
    @contact_pictures = Picture.find(:all,:conditions => {:owner=>username})
    if sorting_order=='desc'
      @contact_pictures.sort! {|a,b| b.send(order_criteria.to_sym) <=> a.send(order_criteria.to_sym)}
    else
      @contact_pictures.sort! {|a,b| a.send(order_criteria.to_sym) <=> b.send(order_criteria.to_sym)}
    end
    #Render the json data we need to send to the contact javascript/
    return_hash = {}
    @contact_pictures.each do |picture|
      key = picture.title
      value = {}
      value['title']=picture.title
      value['href']="/pictures/#{picture.id}"
      value['src']=picture.image.url(:thumb)
      value['alt']="Images?#{value['src'].split('?').last}"
      value['src_small']=picture.image.url(:small)
      value['alt_small']="Images?#{value['src_small'].split('?').last}"      
      value['id']=picture.id
      value['_id']=picture._id
      value['location']=picture.located
      value['date']=picture.dated
      value['rating']=picture.rated
      value['owner']=picture.owner
      return_hash[key]=value
    end  
    respond_to do |format|
      format.json {render :json => return_hash.to_json }
    end
  end

  def show
    @picture = Picture.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @picture }
    end
  end
  
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy
    
    respond_to do |format|
      format.html { redirect_to :wepic, :notice => "Picture was successfully deleted." }
      format.json { head :no_content }
    end    
  end
  
  def images
    @picture = Picture.find(params[:id])
    style = params[:style] ? params[:style] : 'original'
    send_data @picture.image.file_contents(style),
      :type => @picture.image_content_type
  end
end
