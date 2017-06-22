Provider = require './provider'

module.exports =

  config:
    useEnhancedFirmware:
      type: 'boolean'
      default: false
    allowOtherAutocompleationProvidors:
      type: 'boolean'
      default: true
    showReturnTypeInAutocompleation:
      type: 'boolean'
      default: false

  getProvider: -> Provider

  activate: ->
    Provider.updateDocs()
    atom.commands.add 'atom-workspace',
      'nxc:compile': => @compile()
      'nxc:upload': => @upload()
      'nxc:run': => @run()

  compile: ->
    @nbc 'compile'
  upload: ->
    @nbc 'upload'
  run: ->
    @nbc 'run'

  nbc: (type) ->

    if process.platform == 'win32'
      userHome = process.env.USERPROFILE
    else
      userHome = process.env.HOME

    activeItem = atom.workspace.getActivePaneItem()

    # save current file
    potentialPromise = activeItem.buffer.save().then ->
      args = []

      # generate the command to run
      switch process.platform
        when 'linux'
          command = "#{userHome}/.atom/packages/language-nxc/nbc-linux"
        when 'darwin'
          command = "#{userHome}/.atom/packages/language-nxc/nbc-osx"
        when 'win32'
          command = "#{userHome}\\.atom\\packages\\language-nxc\\nbc-windows.exe"

      args.push '-T=NXT'
      args.push '-S=usb'
      switch type
        when 'upload'
          args.push '-d'
        when 'run'
          args.push '-r'

      if atom.config.get 'language-nxc.useEnhancedFirmware'
        args.push '-EF'

      args.push activeItem.buffer.file.path
      console.debug "language-nxc: executing command `#{command}` with args `#{args}"

      filename = activeItem.buffer.file.path.split('.');
      if filename[filename.length-1] != 'nxc'
        atom.notifications.addWarning "not working on an nxc file!"
        return

      require('child_process').execFile command, args, (error, stdout, stderr) ->
        # do we have an error?
        if error?
          if stdout == "" && stderr == ""
            atom.notifications.addFatalError(error, {detail: "stdout:\n#{stdout}\nstderr:\n#{stderr}"})
          if stderr != ""
            atom.notifications.addError "You got a bug!",
              icon: 'bug'
              detail: stderr
              dismissable: true
          else
            atom.notifications.addWarning "Robot not connected!",
              detail: "If the robot is connected, please view the trobble " +
                      "shooting tips at https://goo.gl/lWWy0s"
              dismissable: true
        else
            atom.notifications.addSuccess "Succesfull!"
