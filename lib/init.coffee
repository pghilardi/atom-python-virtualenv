VirtualenvView = require './virtualenv-view'
VirtualenvListView = require './virtualenv-list-view'
VirtualenvManger = require './virtualenv-manager'
MakeDialog = require './virtualenv-dialog'

module.exports =
  manager: new VirtualenvManger()

  config:
    workOnHome:
      type: 'boolean'
      default: false
      title: 'Use this configuration if all your virtual envs are in the HOME
      folder and you are not using virtualenvwrapper. With this configuration
      your virtual envs will be obtained from /home/<user>/ folder'

  activate: (state) ->

    if process.platform == 'win32'
      atom.notifications.addWarning('The **atom-python-virtual** plug-in does not work in Windows. It only works in UNIX systems')
      return

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
