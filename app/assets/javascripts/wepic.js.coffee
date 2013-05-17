jQuery.noConflict()
capitalizeFirstLetter = (string) ->
  string.charAt(0).toUpperCase()+string.slice(1)
jQuery ->
  jQuery('a.fancybox').fancybox
  	'hideOnContentClick' : true
  	'hideOnOverlayClick' : true
  	'padding': 10
  	'titlePosition' : 'over'
  	'overayColor' : '#333'
  	'titleFormat' : (title, currentArray, currentIndex, currentOpts) ->
  	  location = 'Jules Testard\'s house'
  	  console.log("Title : " + title)
  	  console.log("Array : " + currentArray)
  	  console.log("Index : " + currentIndex)
  	  console.log("Opts : " + currentOpts)
  	  '<div id="fancybox-title-over"><div><strong style="font-style:italic">'+capitalizeFirstLetter(title)+'</strong></div><div>At <strong>'+location+'</strong></div></div>'
  	'onComplete' : -> 
  		# #jQuery('#fancybox-title-over').style()
  		# jQuery('#fancybox-title-over').append('<div id="wepic-fancybox-location"> At Jules\' Place </div>')
  		jQuery('#fancybox-wrap').hover ( -> jQuery("#fancybox-title").show()),( -> jQuery("#fancybox-title").hide())
