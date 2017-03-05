
emptyFunction = require "emptyFunction"
assertType = require "assertType"
sliceArray = require "sliceArray"
LazyVar = require "LazyVar"
inArray = require "in-array"
OneOf = require "OneOf"
Event = require "eve"
Type = require "Type"

NodeTree = LazyVar -> require "./NodeTree"

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

type.definePrototype

  tree: get: -> @_tree

  # The default registry of performable actions. Never mutate this!
  _actions: Object.create null

  # The default list of revertable actions. Never mutate this!
  _revertable: []

type.defineMethods

  on: (event, callback) ->
    @_events.on event, callback

  once: (event, callback) ->
    @_events.once event, callback

  _startAction: (name, args) ->
    assertType name, String
    assertType args, Array.Maybe

    action = {target: @_key, name}
    action.args = args if args

    @_tree ?= NodeTree.call this
    return @_tree.startAction action

  _finishAction: (action) ->

    # Only revertable actions are tracked per-node.
    if inArray @_revertable, action.name
      @_changes.push action

    @_events.emit action.name, action
    @_tree.finishAction action
    return

  # _findPreviousValue: (key, event) ->
  #   index = @_changes.indexOf event
  #   while --index > 0
  #     event = @_changes[index]
  #     if event.args
  #   return

type.defineHooks

  __revertAction: ->
    throw Error "Failed to revert action!"

  __replayAction: ->
    throw Error "Failed to replay action!"

  __onAttach: emptyFunction

  __onDetach: emptyFunction

module.exports = type.build()
