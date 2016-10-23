"use babel";

const AtomPgpCredentialsDialog = require('./atom-pgp-credentials-dialog-view');
const {CompositeDisposable} = require('atom');
const openpgp = require('openpgp');

module.exports = {
  atomPgpView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.credentialsDialog = new AtomPgpCredentialsDialog(state.atomPgpViewState);

    this.modalPanel = atom.workspace.addModalPanel({
      item: this.credentialsDialog.getElement(),
      visible: false
    });

    this.subscriptions = new CompositeDisposable;

    return this.subscriptions.add(atom.commands.add('atom-workspace', {
      'atom-pgp:encode': () => this.encode(),
      'atom-pgp:decode': () => this.decode(),
      'atom-pgp:paste': () => this.paste(),
      'core:cancel': () => this._closePasswordPrompt(),
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    return this.credentialsDialog.destroy();
  },

  serialize() {
    return { atomPgpViewState: this.credentialsDialog.serialize() };
  },

  encode() {
    this._requestPassword((password) => {
      this._withBufferOrSelection((data) => {
        const options = { data, passwords: [password] };

        openpgp.encrypt(options)
          .then((result) => {
            this._replaceBufferOrSelection(result.data);
          })
          .catch(err => console.error(err));
      });
    })
  },

  decode() {
    this._requestPassword((password) => {
      this._withBufferOrSelection((data) => {
        const options = {
          password,
          message: openpgp.message.readArmored(data)
        };

        openpgp.decrypt(options)
          .then((result) => {
            console.log('Decoded:', result);
            this._replaceBufferOrSelection(result.data);
          })
          .catch(err => console.error(err));
      });
    });
  },

  paste() {
    const tinput = this.credentialsDialog.element.querySelector('input:focus');
    input.value = atom.clipboard.read();
  },

  _requestPassword(cb) {
    this.modalPanel.show();
    this.credentialsDialog.focus();

    this.credentialsDialog.onPasswordProvided((password) => {
      this._closePasswordPrompt();
      return cb(password);
    });
  },

  _closePasswordPrompt() {
    this.modalPanel.hide();
    this.credentialsDialog.clear();
    atom.workspace.getActivePane().activate();
  },

  _replaceBufferOrSelection(text) {
    const editor = atom.workspace.getActiveTextEditor();
    const selection = editor.getLastSelection();
    editor.createCheckpoint();
    if (selection.getText() === '') {
      return editor.setText(text);
    } else {
      return selection.insertText(text);
    }
  },

  _withBufferOrSelection: function(cb) {
    const editor = atom.workspace.getActiveTextEditor();
    const selection = editor.getLastSelection().getText();
    if (selection === '') {
      return cb(editor.getText());
    } else {
      return cb(selection);
    }
  }
};
