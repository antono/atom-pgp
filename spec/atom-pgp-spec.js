"use babel";

const AtomPgp = require('../lib/atom-pgp');

describe("AtomPgp", function() {

  let activationPromise, textEditor, workspaceElement;

  const getEditorElement = function(callback) {
    waitsForPromise(() => {
      return atom.workspace
        .open('hello.txt')
        .then(editor => textEditor = editor);
    });

    runs(() => {
      const element = document.createElement("atom-text-editor");
      element.setModel(textEditor);
      callback(element.getModel());
    });
  };

  const activate = function(command) {
    waitsForPromise(() => activationPromise);
    return atom.commands.dispatch(workspaceElement, command);
  };

  function expectVisiblePanel() {
    var atomPgpElement, atomPgpPanel;
    expect(workspaceElement.querySelector('.atom-pgp')).toExist();
    atomPgpElement = workspaceElement.querySelector('.atom-pgp');
    atomPgpPanel = atom.workspace.panelForItem(atomPgpElement);
    expect(atomPgpPanel.isVisible()).toBe(true);
  };
  function expectVisiblePasswordDialog() {
    var atomPgpElement;
    atomPgpElement = workspaceElement.querySelector('.atom-pgp');
    expect(atomPgpElement).toExist();
  };

  function expectNoPasswordDialog() {
    const atomPgpElement = workspaceElement.querySelector('.atom-pgp');
    expect(atomPgpElement).not.toExist();
  };

  beforeEach(function() {
    workspaceElement = atom.views.getView(atom.workspace);
    activationPromise = atom.packages.activatePackage('atom-pgp');
  });

  ['atom-pgp:encode', 'atom-pgp:decode'].forEach((event) => {
    describe("when the " + event + " event is triggered", function() {
      it("shows panel", function() {
        expectNoPasswordDialog();
        activate(event);
        runs(() => expectVisiblePanel());
      });

      it("shows the password dialog", function() {
        jasmine.attachToDOM(workspaceElement);
        expectNoPasswordDialog();
        activate(event);
        runs(() => expectVisiblePasswordDialog());
      });
    });
  });

  describe("._replaceBufferOrSelection(text)", function() {
    it("when selection is not empty it will be replaced with given text", function() {
      getEditorElement(function(editor) {
        editor.setText("hello world\nmore text\none more line");
        editor.addSelectionForBufferRange([[1, 0], [1, 9]]);
        AtomPgp._replaceBufferOrSelection('xxx');
        expect(editor.lineTextForBufferRow(1)).toBe('xxx');
      });
    });

    it("when selection empty it will replace all text", function() {
      getEditorElement(function(editor) {
        editor.setText("hello world\nmore text\none more line");
        AtomPgp._replaceBufferOrSelection('XXX');
        expect(editor.lineTextForBufferRow(0)).toBe('XXX');
        expect(editor.lineTextForBufferRow(1)).toBe(void 0);
      });
    });
  });
  describe("._withBufferOrSelection(cb(text))", function() {
    it("when selection is not empty it will pass selection to cb", function() {
      getEditorElement(function(editor) {
        const cbSpy = jasmine.createSpy('callback');

        editor.setText("hello world\nmore text\none more line");
        editor.addSelectionForBufferRange([[1, 0], [1, 9]]);

        AtomPgp._withBufferOrSelection(cbSpy);

        waitsFor(() => cbSpy.callCount > 0);
        runs(() => {
          expect(cbSpy).toHaveBeenCalledWith('more text');
        });
      });
    });

    it("when selection empty it will pass full text to cb", function() {
      getEditorElement(function(editor) {
        const cbSpy = jasmine.createSpy('callback');

        editor.setText("all text\n");
        AtomPgp._withBufferOrSelection(cbSpy);

        waitsFor(() => cbSpy.callCount > 0);
        runs(() => {
          expect(cbSpy).toHaveBeenCalledWith('all text\n');
        });
      });
    });
  });
});
