class PicturesController < WepicController
  
  # By convention this method create is called when the submit button of the
  # form in wepic/_upload.html.erb is pressed. This convention is enforced
  # because the form is sent with an http POST requests.
  def create
    config.logger.info "Picture Parameters : #{params[:picture].inspect}"
    @picture = Picture.new(:title => params[:picture][:title],:owner=>Conf.env['USERNAME'],:image_url=>params[:picture][:image_url]) if params[:picture][:image_url]
    @picture = Picture.new(:title => params[:picture][:title],:owner=>Conf.env['USERNAME'],:image=>params[:picture][:image]) if params[:picture][:image]
    @pictures = Picture.all if @pictures.nil?
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @contacts = Contact.all
    if @picture.save
      config.logger.debug "#in PicturesController, user #{Conf.env['USERNAME']} successfully saved a new picture"
      respond_to do |format|
        format.html { render :action => "show", :notice => 'Picture was successfully created.' }
        format.json { render :json => @picture, :status => :created, :location => :wepic }
      end
    else
      config.logger.debug "#in PicturesController, user #{Conf.env['USERNAME']} failed to save a new picture"
      respond_to do |format|        
        format.html { render :action => :index, :notice => 'Image creation was not successful.' }
        format.json { render :json => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    logger.debug "Update picture was called with arguments : #{params.inspect}"
    respond_to do |format|
      format.html { render :action => "show", :notice => 'Picture was successfully updated.' }
      format.json { render :json => @picture, :status => :created, :location => :wepic }
    end
  end
  
  #This method returns a json representation of the pictures of a contact (not the picture data itself,
  #but enough information to display the picture thumbnail).
  def contact
    username = params[:username]
    @contact_pictures = Picture.find(:all,:conditions => {:owner=>username})  
    #Render the json data we need to send to the contact javascript/
    return_hash = {}
    @contact_pictures.each do |picture|
      key = picture.title
      value = {}
      value['title']=picture.title
      value['href']="/pictures/#{picture.id}"
      value['src']=picture.image.url(:thumb)
      value['alt']="Images?#{value['src'].split('?').last}"
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
      format.html { render :action => :index, :notice => "Picture was successfully deleted." }
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
