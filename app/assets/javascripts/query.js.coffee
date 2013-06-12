# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#function addColumnFields(index) {
#  document.getElementById("column_fields").innerHTML += 
#     "Column Name : <input id=\"col" + index + "\" name=\"col" + index + "\" type=\"text\"/><br/>" +
#     "Column Type : <input id=\"type" + index + "\" name=\"type" + index + "\" type=\"text\"/>";
#}
jQuery.noConflict()
current_url = location.protocol + '//' + location.host + location.pathname

getRelationContents = (relation)->
  jQuery.ajax
    'url' : current_url + '/relation'
    'data' :
      'relation' : relation
    'datatype' : 'json'
    'success' : (data) -> 
      console.log(data)

jQuery(document).ready ->
  jQuery('#relation').change ->
    relation = jQuery('#relation option:selected').html()
    getRelationContents(relation)
