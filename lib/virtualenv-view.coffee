{View} = require 'atom-space-pen-views'

module.exports =
class VirtualenvView extends View

  @content: ->
    @a href: '#', class: 'inline-block virtualenv'

  initialize: (@statusBar, @manager) ->
    @subscribe @statusBar, 'active-buffer-changed', @update

    @subscribe atom.workspace.eachEditor (editor) =>
      @subscribe editor, 'grammar-changed', =>
        @update() if editor is atom.workspace.getActiveEditor()

    @subscribe this, 'click', =>
      @manager.emit('selector:show')
      false

    @manager.on 'virtualenv:changed', @update

  afterAttach: ->
    @update()

  update: =>
    grammar = atom.workspace.getActiveEditor()?.getGrammar?()

    if grammar? and grammar.name == 'Python'
      @text(@manager.env).show()
    else
      @hide()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()
