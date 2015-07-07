AtomPgpPasswordPrompt = require './atom-pgp-password-prompt'
{CompositeDisposable} = require 'atom'

gpg = require './gpg'

module.exports = AtomPgp =
  atomPgpView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomPgpPasswordPrompt = new AtomPgpPasswordPrompt(state.atomPgpViewState)

    @modalPanel = atom.workspace.addModalPanel(
      item: @atomPgpPasswordPrompt.getElement()
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
    @atomPgpPasswordPrompt.destroy()

  serialize: ->
    atomPgpViewState: @atomPgpPasswordPrompt.serialize()

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
    @atomPgpPasswordPrompt.focus()
    @atomPgpPasswordPrompt.onPasswordProvided (password) =>
      @closePasswordPrompt()
      cb(password)

  closePasswordPrompt: ->
    @modalPanel.hide()
    @atomPgpPasswordPrompt.clear()
    atom.workspace.getActivePane().activate()
