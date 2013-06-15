# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery.noConflict()
current_url = location.protocol + '//' + location.host + location.pathname

Object.size = (obj) ->
    size = 0
    for key of obj
        if (obj.hasOwnProperty(key))
          size++
    size

display_error = (error_msg) ->
  "The following error has been encountered :\n" + error_msg

add_described_rule = (rule) ->
  description = 'Added through program page.'
  jQuery.ajax
    'url' : current_url + '/described_rule/add'
    'data' :
      'rule' : rule
      'description' : description
      'role' : role
    'datatype' : 'json'
    'success' : (data) ->
      if data.saved
        window.program_refresh()
      else
        alert(display_error(data.errors.wdlrule[0]))


get_delegations = ->
  jQuery.ajax
    type: "POST"
    'url' : current_url + '/delegations/get'
    'data': null
    'datatype' : 'json'
    'success' : (data) ->
      if data.saved
        html = '<div class="drule">'
        html += '<a class="close" onclick="window.close_rule('+data.id+');">x</a>'
        html += '<div class="description">' + description+ '</div>'
        html += '<div class="id">'+data.id+'</div>'
        html += '<div class="rule">' + rule + '</div>'
        html += '</div>'
        jQuery('.'+role+'_examples').append(html)



window.program_refresh = (type)->
  relation = jQuery('#relation_'+type+' option:selected').html()
  getRelationContents(relation,type)

jQuery(document).ready ->
  
  jQuery('#update_examples_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="update_examples_menu" class="popUpMenu">'
      html += '<a type="submit" id="update_examples_menu_close" class="button-close"></a><ul>'
      html += '<li><a type="submit" id="create_relation_button" class="active_action">Create Relation...</a></li>'
      html += '<li><a type="submit" id="insert_tuple_button" class="active_action" >Insert Fact...</a></li>'
      html += '</ul></div>'
      jQuery('#update_examples_button').html(html)
      menu_open = true
      jQuery('#update_examples_menu_close').click ->
        jQuery('#update_examples_button').html('+')
        menu_open = false
      jQuery('#create_relation_button').click ->
        jQuery('#update_examples_button').html('+')
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#create_relation').css
          'display' : 'block'
        menu_open = false
      jQuery('#insert_tuple_button').click ->
        jQuery('#update_examples_button').html('+')
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#insert_tuple').css
          'display' : 'block'
        menu_open = false