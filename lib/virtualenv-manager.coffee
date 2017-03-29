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

    listenVirtualEnvsChange: () ->
      try
        fs.watch @home, (event, filename) =>
          if event != "change"
            setTimeout =>
              @getVirtualEnvs()
            , 2000
      catch error
        console.info("Failed to setup file system watch, home = {#{@home}}")

    getVirtualEnvs: () ->
      filePaths = atom.project.getPaths()
      filePaths.push(@home)

      @options = []
      for filePath in filePaths
        cmd = 'find . -maxdepth 3 -name activate'
        exec cmd, {'cwd' : filePath}, (error, stdout, stderr) =>
          for opt in (venvPath.trim().split('/')[1] for venvPath in stdout.split('\n'))
            if opt and opt not in @options
                @options.push({'name': opt})

            @options.sort(compare)
            if @wrapper or @options.length > 1
              @emit('options', @options)

    initEnvs: () ->
      @path = process.env.VIRTUAL_ENV
      wrapper = path.join(process.env.HOME, '.virtualenvs')
      fs.exists wrapper, (exists) =>
        @home = if exists then wrapper else process.env.PWD
        @getVirtualEnvs()

        if exists
          @listenVirtualEnvsChange()

    change: (env) ->
      if @path?
        newPath = @path.replace(@env, env.name)
        process.env.PATH = process.env.PATH.replace(@path, newPath)
        @path = newPath
      else
        @path = @home + '/' + env.name
        process.env.PATH = @path + '/bin:' + process.env.PATH

      @env = env.name

      @emit('virtualenv:changed')

    deactivate: () ->
      process.env.PATH = process.env.PATH.replace(@path + '/bin:', '')
      @path = null
      @env = '<None>'
      @emit('virtualenv:changed')

    ignore: (path) ->
      if @wrapper
        return
      cmd = "echo #{path} >> .gitignore"
      exec cmd, {'cwd' : @home}, (error, stdout, stderr) ->
        if error?
          console.warn("Error adding #{path} to ignore list")

    make: (path) ->
      cmd = 'virtualenv ' + path
      exec cmd, {'cwd' : @home}, (error, stdout, stderr) =>
        if error?
          console.log 'error applying virtual env'
          @emit('error', error, stderr)
        else
          console.log 'success!'
          option = {name: path}
          @options.push(option)
          @options.sort(compare)
          @emit('options', @options)
          @change(option)
          @ignore(path)
