# Place all th0 behaviorules and hooks related  descrto the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#TODO remove need for description


jQuery.noConflict()
current_url = location.protocol + '//' + location.host + location.pathname
window.username = null

print_hash = (data) ->
  str = ""
  for key,val of data
    if typeof(value)=='object'
      str += key + ' => ' + "\n\t" + print_hash(val) + "\n"
    else
      str += key + ' => ' + val + "\n"

Object.size = (obj) ->
    size = 0
    for key of obj
        if (obj.hasOwnProperty(key))
          size++
    size

display_error = (error_msg) ->
  "The following error has been encountered :\n" + error_msg


getRelationFields = (relation) ->
  jQuery.ajax
    'url' : current_url + '/relation'
    'data' :
      'relation' : relation
      'content' : false
    'datatype' : 'json'
    'success' : (data) -> 
      if data[0]
        data = data[0]
        columns = data.columns
        html = '' 
        for col in columns
          input = '<input type="text" size="30" name="values['+String(col)+']">'
          html += '<div class="field">'+String(col)+':'+input+'</div>'
        jQuery('#new_fact_columns').html(html)

getRelationContents = (relation,type)->
  jQuery('#display_relation_'+type).html('')
  jQuery.ajax
    'url' : current_url + '/relation'
    'data' :
      'relation' : relation
      'content' : true
    'datatype' : 'json'
    'success' : (data) -> 
      if data[0]
        data = data[0]
        columns = data.columns
        num = Object.size(columns)
        width =  Math.round(document.getElementById("display_relation_"+type).offsetWidth / num) - 17 + num
        html = '<tr class="record">' 
        for col in columns
          html += '<td class="attribute" style="width:'+String(width)+'px;border-bottom:1px solid #fff;font-weight:bold;">'+String(col)+'</td>'
        html += '</tr>'        
        for tuple in data.content
          html += '<tr class="record">' 
          for col,field of tuple
            html += '<td class="attribute" style="width:'+String(width)+'px;">'+String(field)+'</td>'
          html += '</tr>'
        jQuery('#display_relation_'+type).append('<table>'+html+'</table>')
        true

add_described_rule = (rule,description,type) ->
  role = rule.split(' ')[0] 
  jQuery.ajax
    'url' : current_url + '/described_rule/add'
    'data' :
      'rule' : rule
      'description' : description
      'role' : role
    'datatype' : 'json'
    'success' : (data) ->
      if data.saved
        html = '<div class="drule">'
        relation = rule.split(" ")[1].split("(")[0]
        if local(relation)
          html += '<div class="local">local</div>'
        else
          html += '<div class="non-local">non local</div>'
        html += '<div class="description">' + description+ '</div>'
        html += '<div class="id">'+data.id+'</div>'
        html += '<div class="rule">' + rule + '</div>'
        html += '</div>'
        jQuery('.'+type+'_examples').append(html)
        elem = jQuery('.id:contains("'+String(data.id)+'")').parent()
        window.drule_click(elem)
        jQuery('#description_edit_'+type).val('')
        jQuery('#rule_edit_'+type).val('')
      else
        alert(display_error(print_hash(data.errors)))
     'error' : (error,why) ->
        alert(String(error.statusText))


remove_described_rule = (id) ->
  jQuery.ajax
    'url' : current_url + '/described_rule/remove'
    'data' :
      'id' : id
    'datatype' : 'json'
    'success' : (data) ->
      if data.saved
        jQuery('.id:contains("'+String(id)+'")').parent().remove()

local = (relation,username) ->
    if relation
      name = window.capitalizeFirstLetter(relation.split('@')[0])
      location = relation.split('@')[1]
      if location=='local' or location==username or location==window.username #if head is local 
        true
      else
        false

window.drule_click = (elem) ->
  jQuery(elem).click ->
    relation = jQuery.trim(jQuery(this).find('div.rule').html()).split(" ")[1].split("(")[0]
    name = window.capitalizeFirstLetter(relation.split('@')[0])
    if local(relation,window.username)
      jQuery('#relation_extensional').val(name).attr('selected',true).change()
    else
      alert(display_error('You should only click on local rules'))

#Manage local non local determination
window.setup_query = ->
  jQuery.ajax
    'url' : current_url + '/username'
    'data' : null
    'datatype' : 'json'
    'success' : (data) ->
      username = data.username
      window.username = data.username
      jQuery('.drule').each ->
        relation = jQuery.trim(jQuery(this).find('div.rule').html()).split(" ")[1].split("(")[0]
        if local(relation,username)
          html = '<div class="local">local</div>'
          jQuery(this).append(html)
        else
          html = '<div class="non-local">non local</div>'
          jQuery(this).append(html)
        window.drule_click(this)


window.relation_refresh = (type)->
  relation = jQuery('#relation_'+type+' option:selected').html()
  getRelationContents(relation,type)

jQuery(document).ready ->
  jQuery('#relation_select').change ->
    relation = jQuery('#relation_select option:selected').html()
    if relation!='Select Relation'
      getRelationFields(relation)
    
  jQuery('#relation_extensional').change ->
    relation = jQuery('#relation_extensional option:selected').html()
    getRelationContents(relation,'extensional')
  jQuery('#relation_intentional').change ->
    relation = jQuery('#relation_intentional option:selected').html()
    getRelationContents(relation,'intentional')
  window.custom_query = ->
    rule = jQuery('#rule_edit_query').val()
    desc = jQuery('#description_edit_query').val()
    add_described_rule(rule,desc,'query')
  window.custom_update = ->
    rule = jQuery('#rule_edit_update').val()
    rule = jQuery.trim(rule)
    desc = jQuery('#description_edit_update').val()
    add_described_rule(rule,desc,'update')
  window.close_rule = (id) ->
    remove_described_rule(id)
      
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