AtomPgp = require '../lib/atom-pgp'

describe "AtomPgp", ->
  [workspaceElement, activationPromise, textEditor] = []

  getEditorElement = (callback) ->
    waitsForPromise ->
      atom.workspace.open('hello.txt').then (e) ->
        textEditor = e
    runs ->
      element = document.createElement("atom-text-editor")
      element.setModel(textEditor)
      callback(element.getModel())

  activate = (command) ->
    waitsForPromise -> activationPromise
    atom.commands.dispatch workspaceElement, command

  expectVisiblePanel = ->
    expect(workspaceElement.querySelector('.atom-pgp')).toExist()

    atomPgpElement = workspaceElement.querySelector('.atom-pgp')
    atomPgpPanel = atom.workspace.panelForItem(atomPgpElement)
    expect(atomPgpPanel.isVisible()).toBe true

  expectVisiblePasswordDialog = ->
    atomPgpElement = workspaceElement.querySelector('.atom-pgp')
    expect(atomPgpElement).toExist()

  expectNoPasswordDialog = ->
    atomPgpElement = workspaceElement.querySelector('.atom-pgp')
    expect(atomPgpElement).not.toExist()

  beforeEach ->
    workspaceElement  = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('atom-pgp')

  for event in ['atom-pgp:encode', 'atom-pgp:decode']
    describe "when the #{event} event is triggered", ->
      it "shows panel", ->
        expectNoPasswordDialog()
        activate(event)
        runs ->
          expectVisiblePanel()

      it "shows the password dialog", ->
        jasmine.attachToDOM(workspaceElement)

        expectNoPasswordDialog()
        activate(event)
        runs ->
          expectVisiblePasswordDialog()

  describe "._replaceBufferOrSelection(text)", ->
    it "when selection is not empty it will be replaced with given text", ->
      getEditorElement (editor) ->
        editor.setText("hello world\nmore text\none more line")
        editor.addSelectionForBufferRange([[1,0], [1,9]])
        AtomPgp._replaceBufferOrSelection('xxx')
        expect(editor.lineTextForBufferRow(1)).toBe('xxx')

    it "when selection empty it will replace all text", ->
      getEditorElement (editor) ->
        editor.setText("hello world\nmore text\none more line")
        AtomPgp._replaceBufferOrSelection('XXX')
        expect(editor.lineTextForBufferRow(0)).toBe('XXX')
        expect(editor.lineTextForBufferRow(1)).toBe(undefined)

  describe "._withBufferOrSelection(cb(text))", ->
    it "when selection is not empty it will pass selection to cb", ->
      getEditorElement (editor) ->
        editor.setText("hello world\nmore text\none more line")
        editor.addSelectionForBufferRange([[1,0], [1,9]])

        cbSpy = jasmine.createSpy('callback')
        AtomPgp._withBufferOrSelection(cbSpy)

        waitsFor ->
          cbSpy.callCount > 0
        runs ->
          expect(cbSpy).toHaveBeenCalledWith('more text')

    it "when selection empty it will pass full text to cb", ->
      getEditorElement (editor) ->
        editor.setText("all text\n")

        cbSpy = jasmine.createSpy('callback')
        AtomPgp._withBufferOrSelection(cbSpy)

        waitsFor ->
          cbSpy.callCount > 0
        runs ->
          expect(cbSpy).toHaveBeenCalledWith('all text\n')
