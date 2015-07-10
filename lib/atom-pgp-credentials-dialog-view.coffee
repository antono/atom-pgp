{Emitter} = require 'event-kit'

module.exports =
class AtomPgpCredentialsDialog

  constructor: (serializedState) ->
    @emitter = new Emitter
    @buildDom()
    @bindEvents()

  buildDom: ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('atom-pgp')

    @error = document.createElement('div')
    @error.classList.add('error')

    @label = document.createElement('label')
    @label.setAttribute('for', 'pgp-password')

    @input = document.createElement('input')
    @input.setAttribute('type', 'password')

    @element.appendChild(@label)
    @element.appendChild(@input)
    @element.appendChild(@error)
    @initPasswordPrompt()

  initPasswordPrompt: ->
    @clear()
    @label.textContent = 'Encryption password: '

  initConfirmationPrompt: ->
    @clearError()
    @input.value = ''
    @label.textContent = 'Confirm password: '

  bindEvents: ->
    @input.addEventListener 'keydown', (ev) =>
      if ev.keyCode is 13
        @handlePassword(@input.value)
      return true

  handlePassword: (password) ->
    switch
      when password.length <= 5
        @initPasswordPrompt()
        @showError('Please provide password of 6+ chars')
      when !@password # provided first time
        @password = password
        @initConfirmationPrompt()
      when !!@password and (@password is password)
        @emitter.emit('password-provided', password)
        @clearError()
      when !!@password and (@password isnt password)
        @initPasswordPrompt()
        @showError('nope. try again!')
      else
        console.error('WTF?')

  showError: (message) ->
    @error.textContent = message

  clearError: ->
    @error.textContent = ''

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  focus: -> @input.focus()
  clear: ->
    @clearError()
    @password = null
    @input.value = ''

  onPasswordProvided: (handlePassword) ->
    disposable = @emitter.on 'password-provided', (password) =>
      handlePassword(password)
      disposable.dispose()

  # Tear down any state and detach
  destroy: ->
    @emitter.dispose()
    @element.remove()

  getElement: ->
    @element
