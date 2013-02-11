class PicturesController < WepicController
  def create    
    @picture = Picture.new(params[:picture])
    @pictures = Picture.all if @pictures.nil?
    @relation_classes = database(ENV['USERNAME']).relation_classes    
    #Contact.open_connection
    @contacts = Contact.all
    #Contact.remove_connection 
    if @picture.save
      config.logger.debug "#in PicturesController, user {ENV['USERNAME']} successfully saved a new picture"
      respond_to do |format|
        format.html { render :action => "show", :notice => 'Picture was successfully created.' }
        format.json { render :json => @picture, :status => :created, :location => :wepic }
      end
    else
      config.logger.debug "#in PicturesController, user {ENV['USERNAME']} failed to save a new picture"
      respond_to do |format|        
        format.html { render :action => :index, :notice => 'Image creation was not successful.' }
        format.json { render :json => @picture.errors, :status => :unprocessable_entity }
      end
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
      format.html { redirect_to :admin }
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
