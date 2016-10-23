"use babel";

const {Emitter} = require('event-kit');

class AtomPgpCredentialsDialog {

  constructor(serializedState) {
    this.emitter = new Emitter;
    this.buildDom();
    this.bindEvents();
  }

  buildDom() {
    this.element = document.createElement('div');
    this.element.classList.add('atom-pgp');
    this.error = document.createElement('div');
    this.error.classList.add('error');
    this.label = document.createElement('label');
    this.label.setAttribute('for', 'pgp-password');
    this.input = document.createElement('input');
    this.input.setAttribute('type', 'password');
    this.element.appendChild(this.label);
    this.element.appendChild(this.input);
    this.element.appendChild(this.error);

    this.initPasswordPrompt();
  }

  initPasswordPrompt() {
    this.clear();
    return this.label.textContent = 'Encryption password: ';
  }

  initConfirmationPrompt() {
    this.clearError();
    this.input.value = '';
    return this.label.textContent = 'Confirm password: ';
  }

  bindEvents() {
    return this.input.addEventListener('keydown', (ev) => {
      if (ev.keyCode === 13) this.handlePassword(this.input.value);
      return true;
    });
  }

  handlePassword(password) {
    switch (false) {
      case !(password.length <= 5):
        this.initPasswordPrompt();
        return this.showError('Please provide password of 6+ chars');
      case !!this.password:
        this.password = password;
        return this.initConfirmationPrompt();
      case !(!!this.password && (this.password === password)):
        this.emitter.emit('password-provided', password);
        return this.clearError();
      case !(!!this.password && (this.password !== password)):
        this.initPasswordPrompt();
        return this.showError('nope. try again!');
      default:
        return console.error('WTF?');
    }
  }

  showError(message) {
    this.error.textContent = message;
  }

  clearError() {
    this.error.textContent = '';
  }

  serialize() {}

  focus() {
    return this.input.focus();
  }

  clear() {
    this.clearError();
    this.password = null;
    return this.input.value = '';
  }

  onPasswordProvided(handlePassword) {
    const disposable = this.emitter.on('password-provided', (password) => {
      handlePassword(password);
      disposable.dispose();
    });
  }

  destroy() {
    this.emitter.dispose();
    this.element.remove();
  }

  getElement() {
    return this.element;
  }
}

module.exports = AtomPgpCredentialsDialog;
