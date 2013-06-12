# Place all th0 behaviorules and hooks related  descrto the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#function addColumnFields(index) {
#  document.getElementById("column_fields").innerHTML += 
#     "Column Name : <input id=\"col" + index + "\" name=\"col" + index + "\" type=\"text\"/><br/>" +
#     "Column Type : <input id=\"type" + index + "\" name=\"type" + index + "\" type=\"text\"/>";
#}
jQuery.noConflict()
current_url = location.protocol + '//' + location.host + location.pathname

Object.size = (obj) ->
    size = 0
    for key of obj
        if (obj.hasOwnProperty(key))
          size++
    size

display_error = (error_msg) ->
  "The following error has been encountered : " + JSON.stringify(error_msg)

getRelationContents = (relation,type)->
  jQuery('#display_relation_'+type).html('')
  jQuery.ajax
    'url' : current_url + '/relation'
    'data' :
      'relation' : relation
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

add_described_rule = (rule,description,role) ->
  jQuery('#notice').html('rule:' + rule + ",description: " + description + ",role: " + role)
  jQuery('#notice').css
    'display' : 'block'
  jQuery.ajax
    html = location
    jQuery.ajax
      'url' : current_url + '/described_rule/add'
      'data' :
        'rule' : rule
        'description' : description
        'role' : role
      'datatype' : 'json'
      'success' : (data) ->
        if data.saved
          html = capitalizeFirstLetter(data.location)
          jQuery('#image-location').html(html)
          jQuery('#metainf-'+String(idPicture)+' #location').html(html)
        else
          alert(display_error(data.errors))


remove_described_rule = (rule,description,role) ->
  jQuery('#notice').html('rule:' + rule + ",description: " + description + ",role: " + role)
  jQuery('#notice').css
    'display' : 'block'
  console.log('adding rule : ' + '[rule:' + rule + ",description: " + description + ",role: " + role + ']')

window.relation_refresh = (type)->
  relation = jQuery('#relation_'+type+' option:selected').html()
  getRelationContents(relation,type)

jQuery(document).ready ->
  jQuery('#relation_extensional').change ->
    relation = jQuery('#relation_extensional option:selected').html()
    getRelationContents(relation,'extensional')
  jQuery('#relation_intentional').change ->
    relation = jQuery('#relation_intentional option:selected').html()
    getRelationContents(relation,'intentional')
  window.custom_query = ->
    rule = jQuery('#rule_edit_query').val()
    desc = jQuery('#description_edit_query').val()
    jQuery('#description_edit_query').val('')
    jQuery('#rule_edit_query').val('')
    add_described_rule(rule,desc,'query')
  window.custom_update = ->
    rule = jQuery('#rule_edit_update').val()
    desc = jQuery('#description_edit_update').val()
    jQuery('#description_edit_update').val('')
    jQuery('#rule_edit_update').val('')
    add_described_rule(rule,desc,'update')