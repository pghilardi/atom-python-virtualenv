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
        @getVirtualEnvs([process.env.HOME], true)

      getVirtualEnvsFromWrapper = atom.config.get('atom-python-virtualenv.getVirtualEnvsFromWrapper')
      if not getVirtualEnvsFromWrapper? || getVirtualEnvsFromWrapper
        # Get all envs from wrapper (using the WORKON_HOME path)
        wrapper = process.env.WORKON_HOME
        if wrapper and fs.existsSync wrapper
          @getVirtualEnvs([wrapper], true)
        else
          customWorkOnHome = atom.config.get('atom-python-virtualenv.getWorkOnHome')

          if customWorkOnHome?
            customWorkOnHome = customWorkOnHome.replace('$HOME', process.env.HOME)
            if fs.existsSync customWorkOnHome
              @getVirtualEnvs([customWorkOnHome], true)

      # Get all envs from configured paths
      additionalPaths = atom.config.get('atom-python-virtualenv.additionalVirtualEnvPaths')

      if additionalPaths
        additionalPaths = additionalPaths.split(';')
        for additionalPath in additionalPaths
          filePaths.push(additionalPath.replace('$HOME', process.env.HOME))

        @getVirtualEnvs(filePaths, false)

    hasVirtualEnv: (env) ->
      for venv in @options
        if env.name == venv.name
          return true
      return false

    getVirtualEnvs: (filePaths, isUsingBaseFolder) ->
      @options = []
      for filePath, index in filePaths
        do (filePath) =>
          cmd = 'find . -maxdepth 3 -name activate'
          exec cmd, {'cwd' : filePath}, (error, stdout, stderr) =>
            if stdout
              pathsFound = stdout.split('\n')
              for venvPath in pathsFound

                splittedPaths = venvPath.trim().split('/')
                if isUsingBaseFolder
                  opt = splittedPaths[1]
                else
                  splittedFilePaths = filePath.trim().split('/')
                  opt = splittedFilePaths[splittedFilePaths.length - 1]

                if opt
                    path = require 'path'
                    venvPath = path.join(filePath, opt)
                    info = {'name': opt, 'path': venvPath}
                    if not @hasVirtualEnv(info)
                      @options.push(info)

                @options.sort(compare)
                if @options.length > 1
                  @emit('options', @options)

    getPathForEnv: (env) ->
      currentPath = env.path
      return currentPath + "/bin:"

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
        @emit('virtualenv:changed')
        atom.notifications.addSuccess('Virtualenv deactivated with success!')
      @env = null

    make: (name) ->
      cmd = 'virtualenv ' + name
      wrapper = process.env.WORKON_HOME
      if wrapper and fs.existsSync wrapper
        root = wrapper
        message = 'Created virtualenv inside the virtualenvwrapper folder.'
      else
        root = process.env.HOME
        message = 'Created virtualenv inside the $HOME folder.'

      exec cmd, {'cwd' : root}, (error, stdout, stderr) =>
        if error?
          @emit('error', error, stderr)
        else
          path = require 'path'
          option = {name: name, path : path.join(root, name)}
          @options.push(option)
          @options.sort(compare)
          @emit('options', @options)
          @change(option)

          atom.notifications.addSuccess(message)
