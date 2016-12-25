VirtualenvView = require './virtualenv-view'
VirtualenvListView = require './virtualenv-list-view'
VirtualenvManger = require './virtualenv-manager'
MakeDialog = require './virtualenv-dialog'

module.exports =
  manager: new VirtualenvManger()

  configDefaults:
    workonHome: 'autodetect'

  activate: (state) ->

    manager = @manager
    atom.commands.add 'atom-workspace', 'virtualenv:make': ->
      (new MakeDialog(manager)).attach()

    atom.commands.add 'atom-workspace', 'virtualenv:select': ->
      manager.emit('selector:show')

    atom.commands.add 'atom-workspace', 'virtualenv:deactivate': ->
      manager.deactivate()

    @manager.on 'selector:show', =>
      console.log 'selector was show'
      view = new VirtualenvListView(@manager)
      view.attach()
