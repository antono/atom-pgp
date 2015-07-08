AtomPgp = require '../lib/atom-pgp'

describe "AtomPgp", ->
  [workspaceElement, activationPromise] = []

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
