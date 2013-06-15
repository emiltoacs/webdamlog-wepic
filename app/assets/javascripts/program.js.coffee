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
        html += '<div class="statement"><span class="rule_id">'+id+'</span>:'+rule.split("_at_").join("@")+' </div>'
      jQuery('#rules_content').html(html)

window.get = ->
  get_program()

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
  
  jQuery('#program_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="program_menu" class="popUpMenu">'
      html += '<a type="submit" id="program_menu_close" class="button-close"></a><ul>'
      html += '<li><a type="submit" id="refresh_button" class="active_action">Refresh</a></li>'
      html += '<li><a type="submit" id="add_rule_button" class="active_action">Add Rule...</a></li>'
      html += '</ul></div>'
      jQuery('#program_button').html(html)
      menu_open = true
      jQuery('#program_menu_close').click ->
        jQuery('#program_button').html('+')
        menu_open = false
      jQuery('#refresh_button').click ->
        jQuery('#program_button').html('+')
        window.get()
        menu_open = false
      jQuery('#add_rule_button').click ->
        jQuery('#program_button').html('+')
        menu_open = false
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#add_rule').css
          'display' : 'block'
        