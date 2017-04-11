VirtualenvView = require './virtualenv-view'
VirtualenvListView = require './virtualenv-list-view'
VirtualenvManger = require './virtualenv-manager'
MakeDialog = require './virtualenv-dialog'

module.exports =
  manager: new VirtualenvManger()

  config:

    getVirtualEnvsFromWrapper:
      type: 'boolean'
      default: true
      title: 'Get virtualenvs from virtualenvwrapper?'

    getVirtualEnvsFromHome:
      type: 'boolean'
      default: true
      title: 'Get virtualenvs from the $HOME folder?'

    additionalVirtualEnvPaths:
      type: 'string'
      default: ''
      title: 'Configure additional projects with virtualenvs separated by semicolon.
      You should add the path of the project, without the virtualenv (/env or /venv).
      The $HOME variable points to the user home folder.
      Example: $HOME/projects/p1;$HOME/projects/p2;'

  activate: (state) ->

    if process.platform == 'win32'
      atom.notifications.addWarning('The **atom-python-virtual** plug-in does not work in Windows. It only works in UNIX systems')
      return

    manager = @manager
    atom.project.onDidChangePaths ->
      manager.initEnvs()

    atom.config.onDidChange 'atom-python-virtualenv.additionalVirtualEnvPaths', ({newValue, oldValue}) ->
      manager.initEnvs()

    atom.config.onDidChange 'atom-python-virtualenv.getVirtualEnvsFromHome', ({newValue, oldValue}) ->
      manager.initEnvs()

    atom.config.onDidChange 'atom-python-virtualenv.getVirtualEnvsFromWrapper', ({newValue, oldValue}) ->
      manager.initEnvs()

    atom.commands.add 'atom-workspace', 'virtualenv:make': ->
      (new MakeDialog(manager)).attach()

    atom.commands.add 'atom-workspace', 'virtualenv:select': ->
      manager.emit('selector:show')

    atom.commands.add 'atom-workspace', 'virtualenv:deactivate': ->
      manager.deactivate()

    @manager.on 'selector:show', =>
      view = new VirtualenvListView(@manager)
      view.attach()
