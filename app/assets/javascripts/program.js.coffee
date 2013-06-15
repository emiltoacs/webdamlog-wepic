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
    'url' : current_url + '/delegations/get'
    'data': null
    'datatype' : 'json'
    'success' : (data) ->
      if data.saved
        for delegation of data.delegations
          html = '<div class="delegtion">'
          html += '<a class="refuse" onclick="window.refuse_rule('+delegation.rule+','+delegation.id+');">x</a>'
          html += '<a class="accept" onclick="window.accept_rule('+delegation.rule+','+delegation.id+');">&#10003;</a>'
          html += '<div class="id">'+delegation.id+'</div>'
          html += '<div class="rule">' + delegation.rule.split(";").join(";<br/>") + '</div>'
          html += '</div>'
          jQuery('#display_delegation').append(html)

get_program = ->
  jQuery.ajax
    'url' : current_url + '/get'
    'data' : null
    'datatype' : 'json'
    'success' : (data) ->
      html = ""
      for peer in data.peers
        html += '<div class="statement">'+peer+'</div>'
      jQuery('#peers_content').html(html)
      html = ""
      for collection in data.collections
        html += '<div class="statement">'+collection+'</div>'
      jQuery('#collections_content').html(html)
      html = ""
      for id,rule of data.rules
        html += '<div class="statement"><span class="rule_id">'+id+'</span>:'+rule+' </div>'
      jQuery('#rules_content').html(html)

window.get = ->
  

window.program_refresh = (type)->
  relation = jQuery('#relation_'+type+' option:selected').html()
  getRelationContents(relation,type)

window.refuse_rule = (rule,id) ->
  jQuery('.id:contains("'+String(id)+'")').parent().remove()

window.accept_rule = (rule,id) ->
  jQuery('.id:contains("'+String(id)+'")').parent().remove()
  add_described_rule(rule)

jQuery(document).ready ->
  get_delegations()
  
  get_program()
  
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