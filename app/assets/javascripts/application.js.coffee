# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require vue
#= require jquery
#= require jquery_ujs
#  require turbolinks
#= require flatly/loader
#= require follow_or_unfollow_button
#= require message_form
#= require message_dialog
#= require i18n
#= require i18n/translations

window.appVM = new Vue
  el: '#app'

  data:
    following: null
    followers: null

  created: ->
    $d = $('#profile-user-data')
    if $d.size() > 0
      @following = $d.data('following-count')
      @followers = $d.data('followers-count')

    @$on 'follow-or-unfollow-button.update-stats', (event, following, followers) ->
      @following = following if following?
      @followers = followers if followers?

  ready: ->
    window.rendered = true

  methods:
    onClickNewMessageButton: (event) ->
      @$broadcast('modal-dialog.open-new', event)

    onClickReplyToMessageButton: (event) ->
      d = $(event.target).closest('.message-data')
      screen_name = d.data('screen-name')

      message = $(event.target).closest('.message').clone()
      message.find('.message-foot').empty()
      html = message.wrapAll("<div>").parent().html()

      @$broadcast('modal-dialog.open-message-reply', event, html, screen_name)

    onClickReplyToUserButton: (event) ->
      d = $(event.target).closest('.user-data')
      screen_name = d.data('screen-name')
      @$broadcast('modal-dialog.open-user-reply', event, screen_name)