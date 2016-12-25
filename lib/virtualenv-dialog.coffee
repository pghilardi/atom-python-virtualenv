{$, TextEditorView, View} = require 'atom-space-pen-views'
path = require 'path'
exec = (require 'child_process').exec

module.exports =
class MakeDialog extends View
  @content: ->
    @div class: 'tree-view-dialog overlay from-top', =>
      @label 'Virtualenv name', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: (manager) ->
    console.log(manager)

    @panel = atom.workspace.addModalPanel(item: this)

    panel = @panel
    panel.hide()

    atom.commands.add 'atom-workspace', 'core:confirm': ->
      path = panel.item.miniEditor.getText()
      manager.make(path)
      panel.hide()

    atom.commands.add 'atom-workspace', 'core:cancel': ->
      panel.hide()

  attach: ->
    @panel.show()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
