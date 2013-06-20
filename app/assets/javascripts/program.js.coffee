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

reject_delegation = (id) ->
  jQuery.ajax
    'url' : current_url + '/delegation/reject'
    'data' :
      'id' : id
    'datatype' : 'json'
    'success' : (data) ->
      if data.success
        #window.program_refresh()
      else
        alert(display_error(data.errors))
  
accept_delegation = (id) ->
  jQuery.ajax
    'url' : current_url + '/delegation/accept'
    'data' :
      'id' : id
    'datatype' : 'json'
    'success' : (data) ->
      if data.success
        #window.program_refresh()
      else
        alert(display_error(data.errors))

get_delegations = ->
  jQuery.ajax
    'url' : current_url + '/delegations/get'
    'data': null
    'datatype' : 'json'
    'success' : (data) ->
      if data.has_new
        html=''
        for id,rule of data.content
            html += '<div class="delegation">'
            html += '<a class="accept" onclick="window.accept('+id+');">&#10003;</a>'
            html += '<a class="refuse" onclick="window.refuse('+id+');">x</a>'
            html += '<div class="id">'+id+'</div>'
            html += '<div class="rule">'+rule.split("\n").join('<br/>')+'</div>'
            html += '</div></div>'
        jQuery('#display_delegations').append(html)

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

window.program_refresh = ->
  get_program()
  
window.delegations = ->
  get_delegations()

window.refuse = (id) ->
  jQuery('.id:contains("'+String(id)+'")').parent().remove()
  reject_delegation(id)

window.accept = (id) ->
  jQuery('.id:contains("'+String(id)+'")').parent().remove()
  accept_delegation(id)

jQuery(document).ready ->
  
  jQuery('#program_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="program_menu" class="popUpMenu">'
      html += '<a type="submit" id="program_menu_close" class="button-close"></a><ul>'
      html += '<li><a type="submit" id="refresh_button" class="active_action">Refresh</a></li>'
      html += '</ul></div>'
      jQuery('#program_button').html(html)
      menu_open = true
      jQuery('#program_menu_close').click ->
        jQuery('#program_button').html('+')
        menu_open = false
      jQuery('#refresh_button').click ->
        jQuery('#program_button').html('+')
        window.program_refresh()
        menu_open = false
        