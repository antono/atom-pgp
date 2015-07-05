require 'jasmine-expect'
AtomPgpPasswordPrompt = require '../lib/atom-pgp-password-prompt'

describe "AtomPgpPasswordPrompt", ->
  beforeEach ->
    @view = new AtomPgpPasswordPrompt

  it "is prepared", ->
    expect(@view instanceof AtomPgpPasswordPrompt).toBe true

  describe "markup", ->
    beforeEach ->
      @element = @view.getElement()

    it "exist", ->
      expect(@element instanceof HTMLElement).toBe true

    it "has input[type=password]", ->
      expect(@element.querySelector('input[type=password]')).not.toBe null

    it "has label", ->
      expect(@element.querySelector('label')).not.toBe null

  describe "input events", ->
    beforeEach ->
      @input = @view.getElement().querySelector('input')

    it "handles enter key", ->
      input = @input
      callbackSpy = jasmine.createSpy('passwordProvidedCallback')
      @view.emitter.on 'password-provided', callbackSpy

      waitsFor ->
        callbackSpy.callCount > 0
      runs ->
        input.value = 'secret'
        event = buildKeydownEvent('keydown')
        keymapManager.handleKeyboardEvent(event)
        expect(callbackSpy).toHaveBeenCalledWith(null, ['secret'])



    it "handles password confirmation", ->
