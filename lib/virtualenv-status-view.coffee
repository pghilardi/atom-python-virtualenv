module.exports =
class VirtualenvStatusView

  # constant string when there is no venv selected
  @NO_ENV_STR: 'no virtualenv'

  # Initialize the status element to show in the status bar
  constructor: ->#(serializedState)->

      # Construct status element and content
      @status = document.createElement('div')
      @status.classList.add('inline-block')
      link = document.createElement('a')
      link.textContent = VirtualenvStatusView.NO_ENV_STR
      @status.appendChild(link)

      # Add a tooltip to the status
      @tooltip = atom.tooltips.add(@status, title: => "Current virtualenv: #{@status.childNodes[0].textContent}")

  # Set the status element string to the no env constant
  clearStatus: ->
    @status.childNodes[0].textContent = VirtualenvStatusView.NO_ENV_STR # 0 index cause only one child: the link

  # Set the status element string as strStatus
  setStatus: (strStatus) ->
    @status.childNodes[0].textContent = strStatus # 0 index cause only one child: the link

  # Get the full status element
  getStatus: ->
    @status

  destroy: ->
    @status.remove()
    @tooltip.dispose()
