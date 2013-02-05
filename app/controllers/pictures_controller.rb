class PicturesController < WepicController
  def create
    @picture = Picture.new(params[:picture])
    #require 'debugger' ; debugger
    @pictures = Picture.all if @pictures.nil?
    @relation_classes = database(ENV['USERNAME']).relation_classes
    #FIXME check how to optimize database connections.
    Contact.open_connection
    @contacts = Contact.all
    Contact.remove_connection 
    if @picture.save
      respond_to do |format|
        format.html { render :action => "show", :notice => 'Picture was successfully created.' }
        format.json { render :json => @picture, :status => :created, :location => :wepic }
      end
    else
      respond_to do |format|        
        format.html { render :action => :index, :notice => 'Image creation was not successful.' }
        format.json { render :json => @picture.errors, :status => :unprocessable_entity }
      end
    end   
  end
  
  def contact
    username = params[:username]
    Contact.open_connection
    @contact = Contact.find(:first,:conditions => {:username=>username})
    Contact.remove_connection
    @contact_pictures = Picture.find(:all,:conditions => {:owner=>username})
    respond_to do |format|
      format.json {render :json => @contact_pictures }
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
