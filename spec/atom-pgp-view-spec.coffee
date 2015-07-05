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

  describe "handlePassword", ->
    it "sets password if saved password is blank", ->
      expect(@view.password).toBe null
      @view.handlePassword('123456')
      expect(@view.password).toBe '123456'

    it "shows error password length is <= 5", ->
      expect(@view.error.textContent).toBe ''
      @view.handlePassword('123')
      expect(@view.error.textContent).toBe 'Please provide password of 6+ chars'

    it "shows error if different passwords handled twice", ->
      @view.handlePassword('123456')
      expect(@view.error.textContent).toBe ''
      @view.handlePassword('1234567')
      expect(@view.error.textContent).toBe 'nope. try again!'

    it "emits password-provided if same password handled twice", ->
      spy = jasmine.createSpy('passwordProvided')

      @view.emitter.on 'password-provided', spy
      @view.password = '123456'
      @view.handlePassword('123456')

      waitsFor ->
        spy.callCount > 0
      runs ->
        expect(spy).toHaveBeenCalledWith('123456')


  describe "input events", ->
    beforeEach ->
      @input = @view.getElement().querySelector('input')

    fit "handles password when enter key pressed", ->
      @input.value = 'verysecret'
      spy = jasmine.createSpy('handler')
      @view.handlePassowrd = spy

      ev = new KeyboardEvent('keydown')
      ev.keyCode = 13

      @input.dispatchEvent(ev)

      waitsFor ->
        spy.callCount > 0
      runs ->
        expect(spy).toHaveBeenCalledWith(null, ['verysecret'])

    it "handles password confirmation", ->
