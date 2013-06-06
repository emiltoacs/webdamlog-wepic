jQuery.noConflict()
starNumber = 0
pictureId = 0
metainf = {}
regexWS = new RegExp(' ', 'g')
menu_open = false

capitalizeFirstLetter = (string) ->
  string.charAt(0).toUpperCase()+string.slice(1)

sanitize = (string) ->
  string = string.trim()
  string.replace(regexWS,'') #removes all whitespace on keys

addComment = (idPicture,text) ->
    #This methods has no support for failure yet. FIXME
    console.log('attempting to get latest comments')
    html = ''
    jQuery.ajax
      'url' : window.location.href + '/comments/add'
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
      'url' : window.location.href + '/comments/latest'
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
	  'url' : window.location.href + '/comments/latest'
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
  jQuery.get(window.location.href+'?attribute='+attribute)
      

popUpMenu = ->
  jQuery('#popUpButton').html('<div id="popUpMenu">THis is the popup menu</div>')

addStar = ->
  if (starNumber<=3)
    starNumber += 1
    jQuery('#star-'+String(starNumber)).addClass('star-rating-on')
    jQuery.ajax
      'url' : window.location.href + '/ratings'
      'data' :
        '_id' : pictureId
        'rating' : starNumber
      'datatype' : 'json'
      'success' : (data) ->
        if data?
          jQuery('#metainf-'+String(pictureId)+' #rating').html(String(starNumber))
  else
    #don't do anything
  
removeStar = ->
  if (starNumber>=0)
    jQuery('#star-'+String(starNumber)).removeClass('star-rating-on')
    starNumber -= 1
    jQuery.ajax
      'url' : window.location.href + '/ratings'
      'data' :
        '_id' : pictureId
        'rating' : starNumber
      'datatype' : 'json'
      'success' : (data) ->
        if data?
          jQuery('#metainf-'+String(pictureId)+' #rating').html(String(starNumber))

jQuery ->
  jQuery('a.fancybox').fancybox
    'hideOnContentClick' : true
    'hideOnOverlayClick' : true
    'padding': 10
    'titlePosition' : 'over'
    'overayColor' : '#333'
    'titleFormat' : (title, currentArray, currentIndex, currentOpts) ->
      for span in currentOpts.orig.context.parentElement.childNodes[3].children
        metainf[span.id] = span.innerHTML
      console.log("META-INF : " + metainf['_id'] + ", " + metainf['owner'] + ", " + metainf['location']  + ", " + metainf['date']  + ", " + metainf['rating'])
      starNumber = parseInt(metainf['rating'])
      pictureId = parseInt(metainf['_id'])
      list = [0,1,2,3,4]
      star_array = new Array(5)
      star_s = "<a id=\"plus\" type=submit style=\"background: transparent url(/assets/plus.png) center no-repeat;\" class=\"nice-button\"></a>"
      star_s += "<a id=\"minus\" type=submit style=\"background: transparent url(/assets/minus.png) center no-repeat;\" class=\"nice-button\"></a>"
      for i in list
        if i <= parseInt(metainf['rating'])
          star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly star-rating-on" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
        else
          star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
      star_s += '<div class="star-wrapper">'
      for star in star_array
        star_s += star
      star_s += '</div>'
      return '<div id="fancybox-title-over"><table><tr>'+
      '<td style=""><strong style="font-style:italic">'+capitalizeFirstLetter(title)+'</strong></td>'+
      '<td style="text-align:right">On '+metainf['date']+'</td></tr>'+
      '<tr><td style="">By <strong>'+metainf['owner']+'</strong>, in <strong>'+metainf['location'].toString()+'</strong></td>'+
      '<td style="text-align:right">'+star_s+'</td></tr></table></div>'
    'onComplete' : ->
      
      #Setup star interaction
      jQuery('#plus').click ->
        console.log('addstar')
        addStar()
      jQuery('#minus').click ->
        console.log('removestar')
        removeStar()
      jQuery('#fancybox-right').after('<div id="fancybox-comments"><div id="fancybox-comment-wrapper"></div>'+
      '<div id="add-comment-box" contenteditable="true"></div></div>') #TODO show greetings content when empty
      
      #Setup comment listener
      jQuery('#add-comment-box').keypress ( (keypressed) ->
      	if keypressed.keyCode == 13
      	  text = jQuery('#add-comment-box').html()
      	  addComment(pictureId,text) #Add a comment with text entered up to now.
      	  jQuery('#add-comment-box').html('') #Clear the comment line
      )
      
      #Setup the chron job
      
      getLatestComments(pictureId)
    'onCleanup' : ->
      #Clear the entire comment section when leaving fancybox.
      jQuery('#fancybox-comments').remove()
      
      #Stop the chron job
      

jQuery(document).ready ->
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
      html += '<li><a type="submit" id="remove_picture">Sort By...</a></li>'
      html += '<ul>'
      html += '<li><a href="/wepic?order=date" type="submit" id="sort_by_date" class="active_action">date</li>'
      html += '<li><a href="/wepic?order=rating" type="submit" id="sort_by_rating" class="active_action">rating</li>'
      html += '<li><a href="/wepic?order=owner" type="submit" id="sort_by_owner" class="active_action">owner</li>'
      html += '</ul>'
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
      jQuery('#remove_picture').click ->
        console.log('remove pic')
        jQuery('#my_pictures_button').html('+')
        menu_open = false
      # jQuery('#sort_by_owner').click ->
        # console.log('sort by owner')
        # jQuery('#my_pictures_button').html('+')
        # sortBy('owner')
        # menu_open = false
      # jQuery('#sort_by_rating').click ->
        # console.log('sort by rating')
        # jQuery('#my_pictures_button').html('+')
        # sortBy('rating')
        # menu_open = false
      # jQuery('#sort_by_date').click ->
        # console.log('sort by date')
        # jQuery('#my_pictures_button').html('+')
        # sortBy('date')
        # menu_open = false
                
  jQuery('#contact_pictures_button').click ->
    console.log('button')
  console.log("Document ready function executing...")
  
  closeBoxWrapper = ->
    console.log('box wrapper close')
    jQuery('.box_wrapper').css
      'display' : 'none'
    # jQuery('.box_content').css
      # 'display' : 'none'
    jQuery('#wepicbox-content').children().css
      'display':'none'

  
  #Box wrapper close behavior
  jQuery('#box-wrapper-close').click ->
    closeBoxWrapper()

