module.exports =
class AtomPgpPasswordPrompt

  constructor: (serializedState) ->
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

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  focus: -> @input.focus()
  clear: -> @input.value = ''

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
