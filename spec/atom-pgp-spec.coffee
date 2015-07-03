AtomPgp = require '../lib/atom-pgp'

describe "AtomPgp", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('atom-pgp')

  activate = (command) ->
    atom.commands.dispatch workspaceElement, command
    waitsForPromise ->
      activationPromise


  describe "when the atom-pgp:encode event is triggered", ->

    it "shows modal password prompt", ->
      expect(workspaceElement.querySelector('.atom-pgp')).not.toExist()

      activate('atom-pgp:encode')

      runs ->
        expect(workspaceElement.querySelector('.atom-pgp')).toExist()

        atomPgpElement = workspaceElement.querySelector('.atom-pgp')
        atomPgpPanel = atom.workspace.panelForItem(atomPgpElement)
        expect(atomPgpPanel.isVisible()).toBe true

        atomPgpElement = workspaceElement.querySelector('.atom-pgp')
        expect(atomPgpElement).toExist()


    it "shows the view", ->
      jasmine.attachToDOM(workspaceElement)
      expect(workspaceElement.querySelector('.atom-pgp')).not.toExist()

      activate('atom-pgp:encode')

      runs ->
        console.log('hello2')
        expect(workspaceElement.querySelector('.atom-pgp')).toBeVisible()
