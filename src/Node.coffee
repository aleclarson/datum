
emptyFunction = require "emptyFunction"
assertType = require "assertType"
LazyVar = require "LazyVar"
Event = require "eve"
Type = require "Type"

NodeTree = LazyVar -> require "./NodeTree"

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

type.defineValues (values) ->

  # The absolute path to this node.
  _key: null

  # The data associated with this node.
  _values: values

  # The event map for any changes.
  _events: Event.Map()

  # The history of mutations to this node.
  _changes: []

  # The tree this node belongs to.
  _tree: NodeTree.call this

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

    key = @_resolve key
    dot = key.lastIndexOf "."
    return @_tree._root if dot < 0

    key = key.slice 0, dot
    key = ref if ref = @_tree._refs[key]
    return node if node = @_tree._nodes[key]

    throw Error "Invalid key has no parent: '#{key}'"

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

  __onDetach: emptyFunction

module.exports = type.build()
