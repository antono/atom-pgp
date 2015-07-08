AtomPgpCredentialsDialog = require './atom-pgp-credentials-dialog'
{CompositeDisposable} = require 'atom'

gpg = require './gpg'

module.exports = AtomPgp =
  atomPgpView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @credentialsDialog = new AtomPgpCredentialsDialog(state.atomPgpViewState)

    @modalPanel = atom.workspace.addModalPanel(
      item: @credentialsDialog.getElement()
      visible: false
    )

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', {
      'atom-pgp:encode': => @encode()
      'atom-pgp:decode': => @decode()
      'atom-pgp:clearsign': => @clearsign()
      'atom-pgp:close-password-prompt': => @closePasswordPrompt()
      'core:cancel': => @closePasswordPrompt()
    }


  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @credentialsDialog.destroy()

  serialize: ->
    atomPgpViewState: @credentialsDialog.serialize()

  encode: ->
    @requestPassword (password) =>
      editor = atom.workspace.getActiveTextEditor()
      gpg.encrypt editor.getText(), password, (err, text) =>
        if err
          alert(err)
        else
          editor.createCheckpoint()
          editor.setText(text)

  decode: ->
    @requestPassword (password) =>
      editor = atom.workspace.getActiveTextEditor()
      gpg.decrypt editor.getText(), password, (err, text) =>
        if err
          alert(err)
        else
          editor.createCheckpoint()
          editor.setText(text)

  clearsign: ->
    @requestPassword (password) =>
      editor = atom.workspace.getActiveTextEditor()
      gpg.clearsign editor.getText(), password, (err, text) =>
        if err
          alert(err)
        else
          editor.createCheckpoint()
          editor.setText(text)

  requestPassword: (cb) ->
    @modalPanel.show()
    @credentialsDialog.focus()
    @credentialsDialog.onPasswordProvided (password) =>
      @closePasswordPrompt()
      cb(password)

  closePasswordPrompt: ->
    @modalPanel.hide()
    @credentialsDialog.clear()
    atom.workspace.getActivePane().activate()
