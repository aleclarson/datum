
emptyFunction = require "emptyFunction"
assertType = require "assertType"
Event = require "eve"
Type = require "Type"

type = Type "Node"

type.inherits null

type.defineMethods

  toString: ->
    JSON.stringify @_values

  on: (event, callback) ->
    @_events.on event, callback

  once: (event, callback) ->
    @_events.once event, callback

  observe: (key, callback) ->
    @_getParent key
    .on "set", (event) ->
      if key is event.args[0]
        callback event.args[1]
        return

#
# Internal
#

type.defineValues (values, tree) ->

  # The absolute path to this node.
  _key: null

  # The data associated with this node.
  _values: values

  # The event map for any changes.
  _events: Event.Map()

  # The history of mutations to this node.
  _changes: []

  # The tree this node belongs to.
  _tree: tree or null

type.definePrototype

  # The default registry of performable actions. Never mutate this!
  _actions: Object.create null

  # The default list of revertable actions. Never mutate this!
  _revertable: Object.create null

type.defineMethods

  _resolve: (key) ->
    assertType key, String
    return key unless @_key
    return @_key + "." + key

  _getParent: (key) ->
    @_tree.getParent @_resolve(key)

  _startAction: (name, args) ->
    @_tree.startAction @_key, name, args

  _finishAction: ->
    action = @_tree.finishAction()

    # Only revertable actions are tracked per-node.
    if @_revertable[action.name]
      @_changes.push action

    @_events.emit action.name, action
    @_events.emit "all", action
    return

type.defineHooks

  __initialize: null

  __revertAction: emptyFunction

  __replayAction: emptyFunction

  __onAttach: emptyFunction

  __onDetach: emptyFunction

module.exports = type.build()
