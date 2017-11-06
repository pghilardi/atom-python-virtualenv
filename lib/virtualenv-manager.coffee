EventEmitter = (require 'events').EventEmitter
exec = (require 'child_process').exec
fs = require 'fs'
path = require 'path'

compare = (a,b) ->
  if a.name < b.name
    return -1
  if a.name > b.name
    return 1
  return 0

module.exports =

  class VirtualenvManager extends EventEmitter

    constructor: () ->
      @initEnvs()

    initEnvs: () ->
      @options = []
      @path = process.env.VIRTUAL_ENV

      # Get all envs from opened projects
      filePaths = atom.project.getPaths()

      # Add home folder on search of virtualenvs
      getVirtualEnvsFromHome = atom.config.get('atom-python-virtualenv.getVirtualEnvsFromHome')
      if not getVirtualEnvsFromHome? || getVirtualEnvsFromHome
        @getVirtualEnvs([process.env.HOME])

      getVirtualEnvsFromWrapper = atom.config.get('atom-python-virtualenv.getVirtualEnvsFromWrapper')
      if not getVirtualEnvsFromWrapper? || getVirtualEnvsFromWrapper
        # Get all envs from wrapper (using the WORKON_HOME path)
        wrapper = process.env.WORKON_HOME
        if wrapper and fs.existsSync wrapper
          @getVirtualEnvs([wrapper])
        else
          customWorkOnHome = atom.config.get('atom-python-virtualenv.getWorkOnHome')

          if customWorkOnHome?
            customWorkOnHome = customWorkOnHome.replace('$HOME', process.env.HOME)
            if fs.existsSync customWorkOnHome
              @getVirtualEnvs([customWorkOnHome])

      # Get all envs from configured paths
      additionalPaths = atom.config.get('atom-python-virtualenv.additionalVirtualEnvPaths')

      if additionalPaths
        additionalPaths = additionalPaths.split(';')
        for additionalPath in additionalPaths
          filePaths.push(additionalPath.replace('$HOME', process.env.HOME))

        @getVirtualEnvs(filePaths)

    hasVirtualEnv: (env) ->
      for venv in @options
        if env.name == venv.name
          return true
      return false

    getVirtualEnvs: (filePaths) ->
      @options = []
      for filePath, index in filePaths
        do (filePath) =>

          if process.platform == 'win32'
            cmd = ' dir /s /b activate'
          else
            cmd = 'find "$(pwd - P)" -follow -maxdepth 3 -name "activate"'

          exec cmd, {'cwd' : filePath}, (error, stdout, stderr) =>
            if stdout
              pathsFound = stdout.split('\n')
              for venvPath in pathsFound
                venvPath = path.normalize(venvPath)
                filePath = path.normalize(filePath)
                if venvPath and !!venvPath
                  splittedPaths = venvPath.trim().split(path.sep)
                  # Only get venv name from path
                  venvName = splittedPaths[splittedPaths.length - 3]
                  if venvName
                    # Ignore /activate on path
                    venvPath = splittedPaths[..splittedPaths.length - 2].join(path.sep) + path.delimiter
                    info = {'name': venvName, 'path': venvPath}
                    if not @hasVirtualEnv(info)
                      @options.push(info)

                @options.sort(compare)
                if @options.length > 1
                  @emit('options', @options)

    getPathForEnv: (env) ->
      return env.path

    change: (env) ->
      if @env?
        # Remove current virtual env from path
        process.env.PATH = process.env.PATH.replace(@getPathForEnv(@env), '')

      process.env.PATH = @getPathForEnv(env) + process.env.PATH
      if env?
        @env = env
        @emit('virtualenv:changed')
        atom.notifications.addSuccess('Virtualenv changed with success!')

    deactivate: () ->
      if @env?
        process.env.PATH = process.env.PATH.replace(@getPathForEnv(@env), '')
        @env = null
        @emit('virtualenv:changed')
        atom.notifications.addSuccess('Virtualenv deactivated with success!')

    make: (name) ->
      cmd = 'virtualenv ' + name

      customWorkOnHome = atom.config.get('atom-python-virtualenv.getWorkOnHome')
      if customWorkOnHome
        customWorkOnHome = customWorkOnHome.replace('$HOME', process.env.HOME)
        if fs.existsSync customWorkOnHome
          wrapper = customWorkOnHome
          message = 'Created virtualenv using custom work on home.'
      else
        workOnHome = process.env.WORKON_HOME

        if workOnHome and fs.existsSync workOnHome
          wrapper  = workOnHome
          message = 'Created virtualenv inside the default work on home'
        else
          wrapper = process.env.HOME
          message = 'Created virtualenv inside the $HOME folder'

      exec cmd, {'cwd' : wrapper}, (error, stdout, stderr) =>
        if error?
          @emit('error', error, stderr)
        else
          path = require 'path'
          option = {name: name, path : path.join(wrapper, name)}
          @options.push(option)
          @options.sort(compare)
          @emit('options', @options)
          @change(option)

          atom.notifications.addSuccess(message)
