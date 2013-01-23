class PicturesController < WepicController
  def create
    @picture = Picture.new(params[:picture])
    @pictures = Picture.all if @pictures.nil?
    if @picture.save
      respond_to do |format|
        format.html { render :action => "show", :notice => 'Picture was successfully created.' }
        format.json { render :json => @picture, :status => :created, :location => :wepic }
      end
    else
      respond_to do |format|        
        format.html { render :action => :index, :alert => 'Image creation was not successful.' }
        format.json { render :json => @picture.errors, :status => :unprocessable_entity }
      end
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
