# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

period = 10000 #ms

check_people = ->
  $.ajax
    url: "/on_now"
    success: (data)->
      $(".person_button").removeClass "on"
      for person in data
        $("##{person["code"]}").addClass "on"
    complete: (data)->
      window.setTimeout check_people, period

update_person = (code, is_on)->
  url = "/person?code=#{code}"
  url += "&off" unless is_on
  $.ajax
    url: url

$ ->

  $(".person_button").click ->
    $(this).toggleClass "on"
    update_person $(this).attr("id"), $(this).hasClass("on")

  check_people()


