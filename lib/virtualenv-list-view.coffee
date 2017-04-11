{SelectListView} = require 'atom-space-pen-views'

module.exports =
  class VirtualenvListView extends SelectListView
    initialize: (@manager) ->
      super

      @addClass('virtualenv-selector from-top overlay')
      @list.addClass('mark-active')

      @setItems(@manager.options)

    getFilterKey: ->
      'name'

    viewForItem: (env) ->
      element = document.createElement('li')
      if @manager.env
        element.classList.add('active') if env.name is @manager.env.name
      element.textContent = env.name
      element

    confirmed: (env) ->
      @manager.change(env)
      @panel.hide()
      @cancel()

    cancelled: ->
      @panel.hide()

    attach: ->
      @storeFocusedElement()
      @panel = atom.workspace.addModalPanel(item: this)
      @focusFilterEditor()
