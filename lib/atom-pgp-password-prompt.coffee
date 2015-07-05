{Emitter} = require 'event-kit'

module.exports =
class AtomPgpPasswordPrompt

  constructor: (serializedState) ->
    @emitter = new Emitter
    @buildDom()
    @bindEvents()

  buildDom: ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('atom-pgp')

    @label = document.createElement('label')
    @label.setAttribute('for', 'pgp-password')

    @input = document.createElement('input')
    @input.setAttribute('type', 'password')

    @element.appendChild(@label)
    @element.appendChild(@input)
    @initPasswordPrompt()

  initPasswordPrompt: ->
    @password = null
    @input.value = ''
    @label.textContent = 'Encryption password: '

  initConfirmationPrompt: ->
    @input.value = ''
    @label.textContent = 'Confirm password: '

  bindEvents: ->
    @input.addEventListener 'keydown', (ev) =>
      @emitter.emit('password-provided', @input.value) if ev.keyCode is 13
      return true

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  focus: -> @input.focus()
  clear: ->
    @password = null
    @passwordConfirmation = null
    @input.value = ''

  onPasswordProvided: (handlePassword) ->
    disposable = @emitter.on 'password-provided', (password) =>
      switch
        when [null, undefined, ''].indexOf(password) > 0
          alert('Please provide password')
          @initPasswordPrompt()
        when !!@password and (@password is password)
          handlePassword(password)
          disposable.dispose()
        when !!@password and !!password
          @password = password
          @initConfirmationPrompt()


  # Tear down any state and detach
  destroy: ->
    @emitter.dispose()
    @element.remove()

  getElement: ->
    @element
