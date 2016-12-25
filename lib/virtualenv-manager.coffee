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
      @path = process.env.VIRTUAL_ENV
      confHome = atom.config.get "virtualenv.workonHome"
      if confHome != "autodetect" and fs.existsSync(confHome)
        @home = confHome
        @setup()
      else if process.env.WORKON_HOME
        @home = process.env.WORKON_HOME
        @setup()
      else
        wrapper = path.join(process.env.HOME, '.virtualenvs')
        fs.exists wrapper, (exists) =>
          @home = if exists then wrapper else process.env.PWD
          @setup()

    setup: () ->
      @wrapper = Boolean(process.env.WORKON_HOME)

      if @path?
        @env = @path.replace(@home + '/', '')
      else
        @env = '<None>'

      try
        fs.watch @home, (event, filename) =>
          if event != "change"
            setTimeout =>
              @get_options()
            , 2000
      catch error
        console.info("Failed to setup file system watch, home = {#{@home}}")
        console.error(error)

      @get_options()

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

      console.log process.env.PATH

      @path = null
      @env = '<None>'
      @emit('virtualenv:changed')

    get_options: () ->
      cmd = 'find . -maxdepth 3 -name activate'
      @options = []
      exec cmd, {'cwd' : @home}, (error, stdout, stderr) =>
        for opt in (path.trim().split('/')[1] for path in stdout.split('\n'))
          if opt
            @options.push({'name': opt})
        @options.sort(compare)
        if @wrapper or @options.length > 1
          @emit('options', @options)
        if @options.length == 1 and not @wrapper
          @change(@options[0])

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
