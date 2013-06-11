jQuery.noConflict()
starNumber = 0
pictureId = 0
contact_id = undefined
regexWS = new RegExp(' ', 'g')
menu_open = false
current_url = location.protocol + '//' + location.host + location.pathname

capitalizeFirstLetter = (string) ->
  if (typeof string)=='string'
    string.charAt(0).toUpperCase()+string.slice(1)
  else
    string

sanitize = (string) ->
  string = string.trim()
  string.replace(regexWS,'') #removes all whitespace on keys

changeTitle = (idPicture,title) ->
    html = title
    jQuery.ajax
      'url' : current_url + '/update'
      'data' :
        '_id' : idPicture
        'title' : title
      'datatype' : 'json'
      'success' : (data) ->
        #saved = (data.saved=='true') 
        if data.saved
          html = capitalizeFirstLetter(data.title)
          jQuery('#image-title').html(html)
          jQuery('#metainf-'+String(idPicture)+' #title').html(html)
        else
          jQuery('#fancybox-errors').html(display_error(data.errors))
          jQuery('#fancybox-errors').css
            'display' : 'block'
            
changeLocation = (idPicture,location) ->
    html = location
    jQuery.ajax
      'url' : current_url + '/update'
      'data' :
        '_id' : idPicture
        'location' : location
      'datatype' : 'json'
      'success' : (data) ->
        if data.saved
          html = capitalizeFirstLetter(data.location)
          jQuery('#image-location').html(html)
          jQuery('#metainf-'+String(idPicture)+' #location').html(html)
        else
          jQuery('#fancybox-errors').html(display_error(data.errors))
          jQuery('#fancybox-errors').css
            'display' : 'block'

addComment = (idPicture,text) ->
    #This methods has no support for failure yet. FIXME
    console.log('attempting to get latest comments')
    html = ''
    jQuery.ajax
      'url' : current_url + '/comments/add'
      'data' :
        '_id' : idPicture
        'text' : text
      'datatype' : 'json'
      'success' : (data) ->
        if data?
          for key in data
            console.log(key)
            html += '<div class="fancybox-comment"><div class="comment-text">' + key['owner'] + " : "
            html += key['text'] 
            html += '</div><div class="small-date">'+key['date']+'</div>' + "</div>"
            console.log(html)
        jQuery('#fancybox-comment-wrapper').append(html)

getLatestComments = (idPicture)->
    console.log('attempting to get latest comments')
    html = ''
    jQuery.ajax
      'url' : current_url + '/comments/latest'
      'data' :
        '_id' : idPicture
      'datatype' : 'json'
      'success' : (data) ->
        if data?
          for key in data
            html += '<div class="fancybox-comment"><div class="comment-text">' + key['owner'] + " : "
            html += key['text'] 
            html += '</div><div class="small-date">'+key['date']+'</div>' + "</div>"
            console.log(html)
          jQuery('#fancybox-comment-wrapper').append(html)
        else
          jQuery('#fancybox-comment-wrapper').append('<div class="fancybox-comment error"><div class="comment-text">Comments could not be obtained...</div></div>')

#This function has to be rechecked
chronJobComment = (idPicture) ->
	date = getCurrentTime()
	jQuery.ajax
	  'url' : current_url + '/comments/latest'
	  'data' :
	    '_id' : idPicture
	    'date' : date
	  'datatype' : 'json'
	  'success' : (data) ->
        if data?
          for key in data
            console.log(key)
            html += '<div class="fancybox-comment"><div class="comment-text">' + key['owner'] + " : "
            html += key['text'] 
            html += '</div><div class="small-date">'+key['date']+'</div>' + "</div>"
            console.log(html)
        jQuery('#fancybox-comment-wrapper').append(html)	  	
	    

getMetaInf = ->
  metainf = {}
  for span in currentOpts.orig.context.parentElement.childNodes[3].children
    metainf[span.id] = span.innerHTML
  metainf

sortBy = (attribute) ->
  jQuery.get(current_url+'?attribute='+attribute)

display_error = (error_msg) ->
  "The following <strong>error</strong> has been encountered : <br>" + JSON.stringify(error_msg)      

popUpMenu = ->
  jQuery('#popUpButton').html('<div id="popUpMenu">THis is the popup menu</div>')

addStar = ->
  if (starNumber<=3)
    starNumber += 1
    jQuery.ajax
      'url' : current_url + '/update'
      'data' :
        '_id' : pictureId
        'rating' : starNumber
      'datatype' : 'json'
      'success' : (data) ->
        if data.saved
          jQuery('#star-'+String(starNumber)).addClass('star-rating-on')
          jQuery('#metainf-'+String(pictureId)+' #rating').html(String(starNumber))
          jQuery('#fancybox-errors').css
            'display' : 'none'
        else
          jQuery('#fancybox-errors').html(display_error(data.errors))
          jQuery('#fancybox-errors').css
            'display' : 'block'
  else
    #don't do anything

getPicturesForContact = (contact,div_id,_html,_order,_sort) ->
  _order = _order ? 'dated'
  _sort = _sort ? 'asc'
  _html = _html ? false
  contact = String(contact)
  html = ''
  jQuery.ajax
    url : 'contacts/' + contact + '/pictures'
    data :
      action : 'send'
      order : _order
      sort : _sort
    dataType : 'json'
    success : (data) ->
      if data
        if _html
          for key,value of data
            html += '<div class="entry"><div class="image">'
            html += '<a tabindex="1" class="contact_fancybox" title="'+value['title']+'" rel="contactPictures" href="'+value['src_small']+'">'
            html += '<img src="'+data[key]['src']+'" alt="Images">'
            html += '</a>'
            html += '<div id="metainf-'+String(data[key]['_id'])+'" class="metainf" style="display:none">'
            html += '<span id="location">'+data[key]['location']+'</span>'
            html += '<span id="title">'+data[key]['title']+'</span>'
            html += '<span id="owner">'+data[key]['owner']+'</span>'
            html += '<span id="date">'+data[key]['date']+'</span>'
            html += '<span id="rating">'+String(data[key]['rating'])+'</span>'
            html += '<span id="_id">'+String(data[key]['_id'])+'</span>'
            html += '<span id="id">'+String(data[key]['id'])+'</span>'
            html += '</div>'
            html += '</div></div>'
            contact_id = 'metainf-'+String(data[key]['_id'])
        else
          html += '<div class="images choose">'
          for key,value of data
            html += '<div class="entry-select">'
            html += '<input type="checkbox" name="'+data[key]['title']+'" value="'+data[key]['id']+'">'
            html += '<div class="title-select">' + data[key]['title'] + '</div>'
            html += '<div class="image"><img alt="' + data[key]['alt'] + '" src="' + data[key]['src'] + '"></div>'
            html += '</div>'#</a>'
          html += '</div>'
        jQuery(div_id).html(html)

  
removeStar = ->
  if (starNumber>=1)
    starNumber -= 1
    jQuery.ajax
      'url' : current_url + '/update'
      'data' :
        '_id' : pictureId
        'rating' : starNumber
      'datatype' : 'json'
      'success' : (data) ->
        if data.saved
          jQuery('#star-'+String(starNumber+1)).removeClass('star-rating-on')
          jQuery('#metainf-'+String(pictureId)+' #rating').html(String(starNumber))
          jQuery('#fancybox-errors').css
            'display' : 'none'          
        else
          jQuery('#fancybox-errors').html(display_error(data.errors))
          jQuery('#fancybox-errors').css
            'display' : 'block'          

resize_box = (box_type)->
  console.log('Resizing ' + box_type + ' box.')
  leftVal = jQuery('#'+box_type+'-wrap').css('left')
  leftVal = parseInt(leftVal)
  leftVal -= 300
  leftVal = 0 if (leftVal < 0)
  leftVal = String(leftVal) + "px"
  jQuery('#'+box_type+'-wrap').css
    'left' : leftVal
  
fancybox_func = -> jQuery('a.fancybox').fancybox
    'hideOnContentClick' : false
    'hideOnOverlayClick' : true
    'padding': 10
    'autoScale' : true
    'transitionIn' : 'none'
    'transitionOut' : 'none'
    'titlePosition' : 'inside'
    'overayColor' : '#333'
    'titleFormat' : (title, currentArray, currentIndex, currentOpts) ->
      metainf={}
      for span in currentOpts.orig.context.parentElement.childNodes[3].children
        metainf[span.id] = span.innerHTML
          
      starNumber = parseInt(metainf['rating'])
      pictureId = parseInt(metainf['_id'])
      list = [0,1,2,3,4]
      star_array = new Array(5)
      for i in list
        if i <= parseInt(metainf['rating'])
          star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly star-rating-on" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
        else
          star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
      star_s = "<a id=\"plus\" type=\"submit\" style=\"background-color: #aaa;width:15px;\" class=\"nice-button\">+</a>"
      star_s += "<a id=\"minus\" type=\"submit\" style=\"background-color: #aaa;width:15px;\" class=\"nice-button\">-</a>"
      star_s += '<div class="star-wrapper">'
      for star in star_array
        star_s += star
      star_s += '</div>'      
      return '<div id="fancybox-title-inside" class="fancybox-title"><table><tr>'+
      '<td style=""><strong id="image-title" contenteditable="true" style="font-style:italic">'+capitalizeFirstLetter(metainf['title'])+'</strong></td>'+
      '<td style="text-align:right">On '+metainf['date']+'</td></tr>'+
      '<tr><td style="">By <strong>'+metainf['owner']+'</strong>, in <strong id="image-location" contenteditable="true">'+String(metainf['location'])+'</strong></td>'+
      '<td style="text-align:right">'+star_s+'</td></tr>'+
      '<tr><td><form action="/pictures/'+metainf['id']+'/images" method="LINK"><input type="submit" value="Download image"></form></td></tr>'+
      '</table><div id="fancybox-errors" class="box-errors error"></div></div>'
    'onComplete' : ->
      jQuery('#fancybox-wrap').css
        'position' : 'fixed'
        'left' : '100px'
        'top' : '100px'
        
      jQuery('#fancybox-wrap').draggable
        'handle' : '#fancybox-content' 
      
      #Setup star interaction
      jQuery('#plus').click ->
        console.log('addstar')
        addStar()
      jQuery('#minus').click ->
        console.log('removestar')
        removeStar()
      jQuery('#fancybox-outer').after('<div id="fancybox-comments"><div id="fancybox-comment-wrapper"></div>'+
      '<div id="add-comment-box" contenteditable="true"></div></div>') #TODO show greetings content when empty
      
      #Edit picture interaction
      jQuery('#fancybox-outer').not(':has(#edit_picture)').append('<a id="edit_picture">edit</a>')
      
      jQuery('#edit_picture').click ->
        console.log('edit')
        hidden = '<input id="_id" name="_id" type="hidden" value="'+String(pictureId)+'"></input>'
        jQuery('.edit-form').prepend(hidden)
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#edit_picture_form').css
          'display' : 'block'        
      
      #Setup comment listener
      jQuery('#add-comment-box').keypress ( (keypressed) ->
      	if keypressed.keyCode == 13
      	  text = jQuery('#add-comment-box').html()
      	  addComment(pictureId,text) #Add a comment with text entered up to now.
      	  jQuery('#add-comment-box').html('') #Clear the comment line
      )

      #image change forms
      jQuery('#image-title').keypress ( (keypressed) ->
        if keypressed.keyCode == 13
          keypressed.preventDefault()
          text = jQuery.trim(jQuery('#image-title').html())
          changeTitle(pictureId,text)
      )
      
      jQuery('#image-location').keypress ( (keypressed) ->
        if keypressed.keyCode == 13
          keypressed.preventDefault()
          text = jQuery.trim(jQuery('#image-location').html())
          console.log(text)
          changeLocation(pictureId,text)
      )      
      #Setup the chron job
      getLatestComments(pictureId)
      
    'onCleanup' : ->
      #Clear the entire comment section when leaving fancybox.
      jQuery('#fancybox-comments').remove()


fancybox_func_contact = -> jQuery('a.contact_fancybox').fancybox
    'hideOnContentClick' : false
    'hideOnOverlayClick' : true
    'padding': 10
    'autoScale' : true
    'transitionIn' : 'none'
    'transitionOut' : 'none'
    'titlePosition' : 'inside'
    'overayColor' : '#333'
    'titleFormat' : (title, currentArray, currentIndex, currentOpts) ->
      has_contact = contact_id
      metainf={}
      jQuery('#'+has_contact+" span").each ->
        element = jQuery(this).context
        console.log(String(element.id) + ":" + element.innerHTML)
        metainf[element.id] = element.innerHTML
      
      starNumber = parseInt(metainf['rating'])
      pictureId = parseInt(metainf['_id'])
      list = [0,1,2,3,4]
      star_array = new Array(5)
      for i in list
        if i <= parseInt(metainf['rating'])
          star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly star-rating-on" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
        else
          star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
      # star_s = "<a id=\"plus\" type=\"submit\" style=\"background-color: #aaa;width:15px;\" class=\"nice-button\">+</a>"
      # star_s += "<a id=\"minus\" type=\"submit\" style=\"background-color: #aaa;width:15px;\" class=\"nice-button\">-</a>"
      star_s = '<div class="star-wrapper">'
      for star in star_array
        star_s += star
      star_s += '</div>'      
      return '<div id="fancybox-title-inside" class="fancybox-title"><table><tr>'+
      '<td style=""><strong id="image-title" contenteditable="false" style="font-style:italic">'+capitalizeFirstLetter(metainf['title'])+'</strong></td>'+
      '<td style="text-align:right">On '+metainf['date']+'</td></tr>'+
      '<tr><td style="">By <strong>'+metainf['owner']+'</strong>, in <strong id="image-location" contenteditable="false">'+String(metainf['location'])+'</strong></td>'+
      '<td style="text-align:right">'+star_s+'</td></tr>'+
      '<tr><td><form action="/pictures/'+metainf['id']+'/images" method="LINK"><input type="submit" value="Download image"></form></td></tr>'+
      '</table><div id="fancybox-errors" class="box-errors error"></div></div>'
    'onComplete' : ->
      jQuery('#fancybox-wrap').css
        'position' : 'fixed'
        'left' : '100px'
        'top' : '100px'
        
      jQuery('#fancybox-wrap').draggable
        'handle' : '#fancybox-content' 
      
      
      # #Setup star interaction
      # jQuery('#plus').click ->
        # console.log('addstar')
        # addStar()
      # jQuery('#minus').click ->
        # console.log('removestar')
        # removeStar()
      # jQuery('#fancybox-outer').after('<div id="fancybox-comments"><div id="fancybox-comment-wrapper"></div>'+
      # '<div id="add-comment-box" contenteditable="true"></div></div>') #TODO show greetings content when empty
#       
      # jQuery('#fancybox-outer').not(':has(#edit_picture)').append('<a id="edit_picture">edit</a>')
            
      # jQuery('#edit_picture').click ->
        # console.log('edit')
        # hidden = '<input id="_id" name="_id" type="hidden" value="'+String(pictureId)+'"></input>'
        # jQuery('.edit-form').prepend(hidden)
        # jQuery('.box_wrapper').css 
          # 'display' : 'block'
        # jQuery('#edit_picture_form').css
          # 'display' : 'block'        
      
      #Setup comment listener
      jQuery('#add-comment-box').keypress ( (keypressed) ->
        if keypressed.keyCode == 13
          text = jQuery('#add-comment-box').html()
          addComment(pictureId,text) #Add a comment with text entered up to now.
          jQuery('#add-comment-box').html('') #Clear the comment line
      )

      # #image change forms
      # jQuery('#image-title').keypress ( (keypressed) ->
        # if keypressed.keyCode == 13
          # keypressed.preventDefault()
          # text = jQuery.trim(jQuery('#image-title').html())
          # changeTitle(pictureId,text)
      # )
#       
      # jQuery('#image-location').keypress ( (keypressed) ->
        # if keypressed.keyCode == 13
          # keypressed.preventDefault()
          # text = jQuery.trim(jQuery('#image-location').html())
          # console.log(text)
          # changeLocation(pictureId,text)
      # )
      
      
      #Setup the chron job
      
      getLatestComments(pictureId)
    'onCleanup' : ->
      #Clear the entire comment section when leaving fancybox.
      jQuery('#fancybox-comments').remove()
  

jQuery fancybox_func

jQuery(document).ready ->
  jQuery('#wepicbox-wrap').draggable()
  #Setup the wepic buttons
  jQuery('#my_pictures_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="my_pictures_menu" class="popUpMenu">'
      html += '<a type="submit" id="my_pictures_menu_close" class="button-close"></a><ul>'
      html += '<li><a type="submit" id="upload_new_picture">Upload New Picture...</a></li><ul>'
      html += '<li><a type="submit" id="upload_from_file" class="active_action">from file</a></li>'
      html += '<li><a type="submit" id="upload_from_url" class="active_action" >from URL</a></li>'
      html += '</ul>'
      html += '<li><a type="submit" id="sort_by">Sort By...</a></li>'
      html += '<li><a type="submit" id="send-mine-to-contact">Send To...</a></li>'
      html += '</ul></div>'
      jQuery('#my_pictures_button').html(html)
      menu_open = true
      jQuery('#my_pictures_menu_close').click ->
        console.log('close menu')
        jQuery('#my_pictures_button').html('+')
        menu_open = false
      jQuery('#upload_from_file').click ->
        console.log('upload new pic')
        jQuery('#my_pictures_button').html('+')
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#upload_file').css
          'display' : 'block'
        menu_open = false
      jQuery('#upload_from_url').click ->
        console.log('upload new pic')
        jQuery('#my_pictures_button').html('+')
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#upload_url').css
          'display' : 'block'
        menu_open = false
      jQuery('#sort_by').click ->
        console.log('edit')
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#sort').css
          'display' : 'block'
        jQuery('#my_pictures_button').html('+')
        menu_open = false
      jQuery('#send-mine-to-contact').click ->
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#send-mine-to-contact-form').css
          'display' : 'block'        
        jQuery('#my_pictures_button').html('+')
        menu_open = false
                
  jQuery('#contact_pictures_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="contact_pictures_menu" class="popUpMenu">'
      html += '<a type="submit" id="contact_pictures_menu_close" class="button-close"></a><ul>'
      html += '<li><a type="submit" id="sort_by">Sort By...</a></li>'
      html += '<li><a type="submit" id="send-contact-to-contact">Send To...</a></li>'
      html += '</ul></div>'
      jQuery('#contact_pictures_button').html(html)
      menu_open = true
      jQuery('#contact_pictures_menu_close').click ->
        console.log('close menu')
        jQuery('#contact_pictures_button').html('+')
        menu_open = false
      jQuery('#sort_by').click ->
        #jQuery('#sort-form-user').val(name)
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#contact-sort').css
          'display' : 'block'
        jQuery('#contact_pictures_button').html('+')
        menu_open = false
      jQuery('#send-contact-to-contact').click ->
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#send-contact-to-contact-form').css
          'display' : 'block'        
        jQuery('#contact_pictures_button').html('+')
        menu_open = false
        
  #Send file ui interactions
  jQuery('#send-select').change ->
    contact = jQuery('#send-select option:selected').html()
    getPicturesForContact(contact,'#pictures-to-send')
  
  jQuery('#my-pictures-to-send').change ->
    getPicturesForContact(jQuery('#username').html(),'#my-pictures-to-send')

    
  console.log("Document ready function executing...")
  
  closeBoxWrapper = ->
    console.log('box wrapper close')
    jQuery('.box_wrapper').css
      'display' : 'none'
    jQuery('#wepicbox-content').find('.content').children().css
      'display':'none'

  
  #Box wrapper close behavior
  jQuery('#box-wrapper-close').click ->
    closeBoxWrapper()
  
  
  #CONTACT PICTURES
  #After sorting
  window.sort_contact = ->
    contact = jQuery('#contact-name').html()
    _sort = jQuery('#sort option:selected').html()
    _order = jQuery('#order option:selected').html()
    _id = getPicturesForContact(contact,'#contact_pictures',true,_order,_sort)
    jQuery('#contact_pictures').on('focusin',fancybox_func_contact)
    closeBoxWrapper()  
  
  #When selecting a peer
  window.select = (element)->
    jQuery('.selected').attr('class', 'contact')
    element.className = 'selected'
    contact = element.innerHTML
    getPicturesForContact(contact,'#contact_pictures',true)
    jQuery('#contact_pictures').on('focusin',fancybox_func_contact)
    jQuery('#contact-name').html(contact)
    closeBoxWrapper()
