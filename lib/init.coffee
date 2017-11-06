VirtualenvView = require './virtualenv-view'
VirtualenvListView = require './virtualenv-list-view'
VirtualenvManger = require './virtualenv-manager'
VirtualenvStatusView = require './virtualenv-status-view'
MakeDialog = require './virtualenv-dialog'

module.exports =
  manager: new VirtualenvManger()

  config:

    getVirtualEnvsFromHome:
      type: 'boolean'
      default: true
      title: 'Get virtualenvs from the home folder?'
      order: 1

    getVirtualEnvsFromWrapper:
      type: 'boolean'
      default: true
      title: 'Get virtualenvs from the virtualenvwrapper folder?'
      order: 2

    getWorkOnHome:
      type: 'string'
      default: ''
      title: 'WORKON_HOME (virtualenvwrapper must be enabled)'
      description: 'By default the WORKON_HOME variable will be obtained
      automatically. But, if this does not work, you can force the WORKON_HOME
      here.
      <br>
      Example: $HOME/.virtualenvs;
      <br>
      <br>
      The $HOME variable points to the user home folder.'
      order: 3

    additionalVirtualEnvPaths:
      type: 'string'
      default: ''
      title: 'Additional virtualenvs'
      description: 'Configure additional projects with virtualenvs separated by semicolon.
      You should add the path of the project, without the virtualenv (/env or /venv).
      <br>
      Example: $HOME/projects/p1;$HOME/projects/p2;
      <br>
      <br>
      The $HOME variable points to the user home folder.'
      order: 4

  activate: (state) ->

    manager = @manager
    atom.project.onDidChangePaths ->
      manager.initEnvs()

    atom.config.onDidChange 'atom-python-virtualenv.additionalVirtualEnvPaths', ({newValue, oldValue}) ->
      manager.initEnvs()

    atom.config.onDidChange 'atom-python-virtualenv.getVirtualEnvsFromHome', ({newValue, oldValue}) ->
      manager.initEnvs()

    atom.config.onDidChange 'atom-python-virtualenv.getVirtualEnvsFromWrapper', ({newValue, oldValue}) ->
      manager.initEnvs()

    atom.config.onDidChange 'atom-python-virtualenv.getWorkOnHome', ({newValue, oldValue}) ->
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

    # Create the view for the status bar and change the status string according
    # to the changed environement
    @virtualenvStatusView = new VirtualenvStatusView()
    @manager.on 'virtualenv:changed', =>
      if @manager.env?
        @virtualenvStatusView.setStatus(@manager.env.name)
      else
        @virtualenvStatusView.clearStatus()

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addLeftTile(item: @virtualenvStatusView.getStatus(), priority: 100);

  deactivate: ->
    @statusBarTile?.destroy()
    @statusBarTile = null
