
emptyFunction = require "emptyFunction"
assertType = require "assertType"
sliceArray = require "sliceArray"
OneOf = require "OneOf"
Event = require "eve"
Type = require "Type"

type = Type "Node"

type.inherits null

type.defineValues (values) ->

  # The absolute path to this node.
  _key: null

  # The tree this node belongs to.
  _tree: null

  # The data associated with this node.
  _values: values

  # The event map for any changes.
  _events: Event.Map()

  # The history of mutations to this node.
  _changes: []

type.defineGetters

  key: -> @_key

  _initialValue: -> @__getInitialValue()

type.definePrototype

  # The registry of available actions.
  _actions: Object.create null

type.defineMethods

  call: (name) ->

    unless @_actions[name]
      throw Error "Invalid action: '#{name}'"

    action = {name}

    if arguments.length > 1
      action.args = sliceArray arguments, 1

    return @_performAction action

  on: (event, callback) ->
    @_events.on event, callback

  once: (event, callback) ->
    @_events.once event, callback

  _performAction: (action, changes) ->
    assertType action, Object
    assertType changes, Array

    # Perform the action.
    result = @_actions[action.name].apply this, action.args

    # Only revertable actions are tracked per-node.
    if action.revertable
      @_changes.push action
      @_events.emit action.name, action

    return result

  # _findPreviousValue: (key, event) ->
  #   index = @_changes.indexOf event
  #   while --index > 0
  #     event = @_changes[index]
  #     if event.args
  #   return

type.defineHooks

  __getInitialValue: -> {}

  __attachValues: emptyFunction

  __revertAction: emptyFunction

  __onDetach: emptyFunction

module.exports = type.build()
