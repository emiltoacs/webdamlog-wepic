jQuery.noConflict()
starNumber = 0
window.pictureId = 0
contact_id = undefined
regexWS = new RegExp(' ', 'g')
menu_open = false #Check if menu is active (avoid several menus colliding or behaving strangely)
active_form = false #Check if popUp form window already active
window.active_window = true
current_url = location.protocol + '//' + location.host + location.pathname

window.capitalizeFirstLetter = (string) ->
  if (typeof string)=='string'
    string = jQuery.trim(string)
    string.charAt(0).toUpperCase()+string.slice(1)
  else
    string

sanitize = (string) ->
  string = string.trim()
  string.replace(regexWS,'') #removes all whitespace on keys

rating_string = (value) ->
  star_array = new Array(5)
  for i in [0..4]
    if i <= value
      star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly star-rating-on" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
    else
      star_array[i] = '<div class="star-rating rater-0 star star-rating-applied star-rating-readonly" id="star-'+String(i)+'" aria-label="" role="text"><a title="on"></a></div>'
  star_s = '<div class="star-wrapper">'
  for star in star_array
    star_s += star
  star_s += '</div>'
  return star_s

changeRating = (idPicture,rating) ->
    jQuery.ajax
      'url' : current_url + '/update'
      'data' :
        '_id' : idPicture
        'rating' : rating
      'datatype' : 'json'
      'success' : (data) -> 
        if data.saved
          jQuery('#metainf-'+String(idPicture)+' #my_rating').html(String(data.my_rating))
          jQuery('#metainf-'+String(idPicture)+' #rating').html(String(data.rating))
          html = 'My rating : '
          html += rating_string(data.my_rating)
          jQuery('#rate_select').unbind("change") #Close the callback       
          jQuery('#my_rating_box').html(html)
          html = 'Average Rating : ' + rating_string(data.rating)
          jQuery('#avg_rating_box').html(html)
        else
          jQuery('#fancybox-errors').html(display_error(data.errors))
          jQuery('#fancybox-errors').css
            'display' : 'block'

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
          jQuery('#image-title').val(html)
          jQuery('#image-title').blur()
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
          jQuery('#image-location').val(html)
          jQuery('#image-location').blur()
          jQuery('#metainf-'+String(idPicture)+' #location').html(html)
        else
          jQuery('#fancybox-errors').html(display_error(data.errors))
          jQuery('#fancybox-errors').css
            'display' : 'block'

addComment = (idPicture,text) ->
    #This methods has no support for failure yet. FIXME
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

window.getLatestComments = (idPicture)->
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
          jQuery('#fancybox-comment-wrapper').html(html)
        else
          jQuery('#fancybox-comment-wrapper').html('<div class="fancybox-comment error"><div class="comment-text">Comments could not be obtained...</div></div>')

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
        '_id' : window.pictureId
        'rating' : starNumber
      'datatype' : 'json'
      'success' : (data) ->
        if data.saved
          jQuery('#star-'+String(starNumber)).addClass('star-rating-on')
          jQuery('#metainf-'+String(window.pictureId)+' #rating').html(String(starNumber))
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
            html += '<a tabindex="1" class="contact_fancybox" title="'+value['title']+'" href="'+value['src_small']+'" rel="contact_pictures">'
            html += '<img src="'+data[key]['src']+'" alt="Images">'
            html += '</a>'
            html += '<div id="metainf-'+String(data[key]['_id'])+'" class="metainf" style="display:none">'
            html += '<span id="location">'+data[key]['location']+'</span>'
            html += '<span id="title">'+data[key]['title']+'</span>'
            html += '<span id="owner">'+data[key]['owner']+'</span>'
            html += '<span id="date">'+data[key]['date']+'</span>'
            html += '<span id="rating">'+String(data[key]['rating'])+'</span>'
            html += '<span id="my_rating">'+String(data[key]['my_rating'])+'</span>'
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
            html += '</div>'
          html += '</div>'
        jQuery(div_id).html(html)


removeStar = ->
  if (starNumber>=1)
    starNumber -= 1
    jQuery.ajax
      'url' : current_url + '/update'
      'data' :
        '_id' : window.pictureId
        'rating' : starNumber
      'datatype' : 'json'
      'success' : (data) ->
        if data.saved
          jQuery('#star-'+String(starNumber+1)).removeClass('star-rating-on')
          jQuery('#metainf-'+String(window.pictureId)+' #rating').html(String(starNumber))
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
      window.pictureId = parseInt(metainf['_id'])
      star_s = rating('rating',parseInt(metainf['rating']))
      my_star_s = rating('my_rating',parseInt(metainf['my_rating']))      
      return '<div id="fancybox-title-inside" class="fancybox-title"><table><tr>'+
      '<td style=""><input id="image-title" style="font-style:italic" title="Click to edit" value="'+capitalizeFirstLetter(metainf['title'])+'"></td>'+
      '<td style="text-align:right">On '+metainf['date']+'</td></tr>'+
      '<tr><td style="">By <strong>'+metainf['owner']+'</strong>, in <input title="Click to edit" id="image-location" value="'+capitalizeFirstLetter(String(metainf['location']))+'"></td>'+
      '<td style="text-align:right"><span id="my_rating_box">'+my_star_s+'</span></td></tr>'+
      '<tr><td><form action="/pictures/'+metainf['id']+'/images" method="LINK" style="text-align:left"><input type="submit" value="Download image" class="download"></form>'+
      '</td><td style="text-align:right"><span id="avg_rating_box">'+star_s+'</span></td></tr>'+
      '</table><div id="fancybox-errors" class="box-errors error"></div></div>'
    'onComplete' : ->
      jQuery('#fancybox-wrap').css
        'position' : 'fixed'
        'left' : '100px'
        'top' : '100px'
        
      jQuery('#fancybox-wrap').draggable
        'handle' : '#fancybox-content' 
      
      jQuery('#fancybox-outer').after('<div id="fancybox-comments"><div id="fancybox-comment-wrapper"></div>'+
      '<textarea id="add-comment-box" placeholder="Type a comment here"></textarea></div>') #TODO show greetings content when empty    
      
      #Setup rating interaction
      jQuery('#rate_select').change ->
        value = parseInt(jQuery('#rate_select option:selected').html())
        changeRating(window.pictureId,value)      
      
      #Setup comment listener
      jQuery('#add-comment-box').keypress ( (keypressed) ->
      	if keypressed.keyCode == 13
      	  text = jQuery('#add-comment-box').val()
      	  addComment(window.pictureId,text) #Add a comment with text entered up to now.
      	  jQuery('#add-comment-box').val('') #Clear the comment line
      )
      #image change forms
      # jQuery('#image-title').keypress ( (keypressed) ->
        # if keypressed.keyCode == 13
          # keypressed.preventDefault()
          # text = jQuery.trim(jQuery('#image-title').val())
          # changeTitle(window.pictureId,text)
      # )
#       
      # jQuery('#image-location').keypress ( (keypressed) ->
        # if keypressed.keyCode == 13
          # keypressed.preventDefault()
          # text = jQuery.trim(jQuery('#image-location').val())
          # changeLocation(window.pictureId,text)
      # )
      
      jQuery('#fancybox-wrap').unbind("keydown")
      #Setup the chron job
      # window.activ_window = true
    'onCleanup' : ->
      #Clear the entire comment section when leaving fancybox.
      jQuery('#fancybox-comments').remove()
      # window.activ_window = false
      
rating = (attribute,value) ->
  star_s = ''
  if attribute=='my_rating'
    if value==-1
      star_s += 'Rate this image :'
      star_s += '<select id="rate_select" name="relation[name]">'
      star_s += '<option value=""> Rate... </option>'
      for i in [0..4]
        star_s += '<option value="'+i+'">'+i+'</option>'
      star_s += '</select>'
    else
      star_s += 'My Rating : '
      star_s += rating_string(value)
  else if attribute=='rating'
      star_s += 'Average Rating : '
      star_s += rating_string(value)
  return star_s


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
      window.pictureId = parseInt(metainf['_id'])
      star_s = rating('rating',metainf['rating'])
      my_star_s = rating('my_rating',metainf['my_rating'])
      return '<div id="fancybox-title-inside" class="fancybox-title"><table><tr>'+
      '<td style=""><strong id="image-title" style="font-style:italic">'+capitalizeFirstLetter(metainf['title'])+'</strong></td>'+
      '<td style="text-align:right">On '+metainf['date']+'</td></tr>'+
      '<tr><td style="">By <strong>'+metainf['owner']+'</strong>, in <strong id="image-location">'+String(metainf['location'])+'</strong></td>'+
      '<td style="text-align:right"><span id="my_rating_box">'+my_star_s+'</span></td></tr>'+
      '<tr><td><form action="/pictures/'+metainf['id']+'/images" method="LINK" style="text-align:left"><input type="submit" value="Download image" class="download"></form>'+
      '</td><td style="text-align:right"><span id="avg_rating_box">'+star_s+'</span></td></tr>'+
      '</table><div id="fancybox-errors" class="box-errors error"></div></div>'
    'onComplete' : ->
      jQuery('#fancybox-wrap').css
        'position' : 'fixed'
        'left' : '100px'
        'top' : '100px'
        
      jQuery('#fancybox-wrap').draggable
        'handle' : '#fancybox-content' 
      
      #Setup rating interaction
      jQuery('#rate_select').change ->
        changeRating(idPicture,value)
      
      jQuery('#fancybox-outer').after('<div id="fancybox-comments"><div id="fancybox-comment-wrapper"></div>'+
      '<textarea id="add-comment-box" placeholder="Type a comment here"></textarea></div>') #TODO show greetings content when empty
      
      jQuery('#add-comment-box').keypress ( (keypressed) ->
        if keypressed.keyCode == 13
          text = jQuery('#add-comment-box').val()
          addComment(window.pictureId,text) #Add a comment with text entered up to now.
          jQuery('#add-comment-box').val('') #Clear the comment line
      )
      
      #window.activ_window = true
    'onCleanup' : ->
      #Clear the entire comment section when leaving fancybox.
      jQuery('#fancybox-comments').remove()
      #window.activ_window = false

jQuery(document).ready ->
  jQuery fancybox_func
  jQuery('#wepicbox-wrap').draggable()
  #Setup the wepic buttons
  jQuery('#my_pictures_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="my_pictures_menu" class="popUpMenu">'
      html += '<a type="submit" id="my_pictures_menu_close" class="button-close"></a><ul>'
      html += '<li><div style="color : #666;cursor : text;">Upload New Picture...</li><ul>'
      html += '<li><a type="submit" id="upload_from_file" class="active_action">from file</a></li>'
      html += '<li><a type="submit" id="upload_from_url" class="active_action" >from URL</a></li>'
      html += '</ul>'
      html += '<li><a type="submit" id="sort_by">Sort By...</a></li>'
      html += '</ul></div>'
      jQuery('#my_pictures_button').html(html)
      menu_open = true
      jQuery('#my_pictures_menu_close').click ->
        console.log('close menu')
        jQuery('#my_pictures_button').html('+')
        menu_open = false
      jQuery('#upload_from_file').click ->
        # unless active_form
          console.log('upload new pic')
          jQuery('#my_pictures_button').html('+')
          jQuery('.box_wrapper').css 
            'display' : 'block'
          jQuery('#upload_file').css
            'display' : 'block'
          menu_open = false
          # active_form = true
      jQuery('#upload_from_url').click ->
        # unless active_form
          console.log('upload new pic')
          jQuery('#my_pictures_button').html('+')
          jQuery('.box_wrapper').css 
            'display' : 'block'
          jQuery('#upload_url').css
            'display' : 'block'
          menu_open = false
          # active_form = true
      jQuery('#sort_by').click ->
        # unless active_form
          console.log('edit')
          jQuery('.box_wrapper').css 
            'display' : 'block'
          jQuery('#sort').css
            'display' : 'block'
          jQuery('#my_pictures_button').html('+')
          menu_open = false
          # active_form = true
                
  jQuery('#contact_pictures_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="contact_pictures_menu" class="popUpMenu">'
      html += '<a type="submit" id="contact_pictures_menu_close" class="button-close"></a><ul>'
      html += '<li><a type="submit" id="sort_by">Sort By...</a></li>'
      html += '</ul></div>'
      jQuery('#contact_pictures_button').html(html)
      menu_open = true
      jQuery('#contact_pictures_menu_close').click ->
        jQuery('#contact_pictures_button').html('+')
        menu_open = false
      jQuery('#sort_by').click ->
        # unless active_form
          jQuery('.box_wrapper').css 
            'display' : 'block'
          jQuery('#contact-sort').css
            'display' : 'block'
          jQuery('#contact_pictures_button').html('+')
          menu_open = false
          # active_form = true
  
  closeBoxWrapper = ->
    active_form = false
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
    _sort = jQuery('#contact-sort div.field select#sort option:selected').html()
    _order = jQuery('#contact-sort div.field select#order option:selected').html()
    _id = getPicturesForContact(contact,'#contact_pictures',true,_order,_sort)
    console.log 'sort contact : [sort='+String(_sort)+',order='+String(_order)+',id='+String(id)+']'
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