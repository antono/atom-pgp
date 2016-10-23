"use babel";

require('jasmine-expect');

const KeymapManager = require('atom-keymap');
const AtomPgpCredentialsDialog = require('../lib/atom-pgp-credentials-dialog-view');

describe("AtomPgpCredentialsDialog", function() {

  beforeEach(function() {
    this.view = new AtomPgpCredentialsDialog;
  });

  it("is prepared", function() {
    expect(this.view instanceof AtomPgpCredentialsDialog).toBe(true);
  });

  describe("markup", function() {
    beforeEach(function() {
      this.element = this.view.getElement();
    });

    it("exist", function() {
      expect(this.element instanceof HTMLElement).toBe(true);
    });

    it("has input[type=password]", function() {
      expect(this.element.querySelector('input[type=password]')).not.toBe(null);
    });

    return it("has label", function() {
      expect(this.element.querySelector('label')).not.toBe(null);
    });
  });

  describe("handlePassword", function() {
    it("sets password if saved password is blank", function() {
      expect(this.view.password).toBe(null);
      this.view.handlePassword('123456');
      expect(this.view.password).toBe('123456');
    });

    it("shows error password length is <= 5", function() {
      expect(this.view.error.textContent).toBe('');
      this.view.handlePassword('123');
      expect(this.view.error.textContent).toBe('Please provide password of 6+ chars');
    });

    it("shows error if different passwords handled twice", function() {
      this.view.handlePassword('123456');
      expect(this.view.error.textContent).toBe('');
      this.view.handlePassword('1234567');
      expect(this.view.error.textContent).toBe('nope. try again!');
    });

    it("emits password-provided if same password handled twice", function() {
      var spy;
      spy = jasmine.createSpy('passwordProvided');
      this.view.emitter.on('password-provided', spy);
      this.view.password = '123456';
      this.view.handlePassword('123456');
      waitsFor(() => spy.callCount > 0);
      runs(() => expect(spy).toHaveBeenCalledWith('123456'));
    });
  });

  describe("@input events", function() {

    beforeEach(function() {
      this.keymapManager = new KeymapManager;
      this.input = this.view.getElement().querySelector('input');
    });

    const enterPassword = function(input, pwd) {
      input.value = 'password';
      const event = KeymapManager.buildKeydownEvent('x', {
        target: input,
        keyCode: 13
      });
      input.dispatchEvent(event);
    };

    it("handles password when enter key pressed", function() {
      const pwdSpy = jasmine.createSpy('handler');

      this.view.handlePassword = pwdSpy;
      enterPassword(this.input, 'password');
      waitsFor(() => {
        return pwdSpy.callCount > 0;
      }, 'handlePassword(cb)', 100);

      runs(() => {
        return expect(pwdSpy).toHaveBeenCalledWith('password');
      });
    });

    it("handles password confirmation", function() {
      const providedSpy = jasmine.createSpy('passwordProvidedSpy');
      this.view.onPasswordProvided(providedSpy);

      ['pwd', 'confirmation'].forEach((step) => {
        enterPassword(this.input, 'password');
      });

      waitsFor(() => {
        return providedSpy.callCount === 1;
      }, 'onPasswordProvided(cb)', 100);

      runs(() => {
        expect(providedSpy).toHaveBeenCalledWith('password');
      });
    });
  });
});
