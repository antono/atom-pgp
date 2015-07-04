{Emitter} = require 'event-kit'

module.exports =
class AtomPgpPasswordPrompt

  constructor: (serializedState) ->
    @emitter = new Emitter
    @buildDom()
    @bindEvents()

  buildDom: =>
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('atom-pgp')

    @label = document.createElement('label')
    @label.setAttribute('for', 'pgp-password')
    @label.textContent = 'Enter Password: '

    @input = document.createElement('input')
    @input.setAttribute('type', 'password')

    @label.appendChild(@input)
    @element.appendChild(@label)

  bindEvents: =>
    @input.addEventListener 'keydown', (ev) =>
      if ev.keyCode is 13
        @emitter.emit 'password-provided', @input.value

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  focus: -> @input.focus()
  clear: -> @input.value = ''

  onPasswordProvided: (cb) =>
    @emitter.on 'password-provided', cb

  # Tear down any state and detach
  destroy: ->
    @emitter.dispose()
    @element.remove()

  getElement: ->
    @element
