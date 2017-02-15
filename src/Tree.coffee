
emptyFunction = require "emptyFunction"
assertType = require "assertType"
isType = require "isType"
isDev = require "isDev"
steal = require "steal"
Event = require "eve"
Type = require "Type"

ArrayNode = require "./ArrayNode"
MapNode = require "./MapNode"

type = Type "Tree"

type.defineValues ->

  # The base level. All data lives here.
  _root: MapNode()

  # Fast access to any node in the entire tree (using absolute paths).
  _nodes: Object.create null

  # The current action being performed.
  _currentAction: null

  # Whenever a nested action is performed, its parent action is marked "pending".
  _pendingActions: []

  # The history of actions performed anywhere in the tree.
  _finishedActions: []

type.initInstance ->
  root = @_root
  root._tree = this
  root._resolve = emptyFunction.thatReturnsArgument
  return

type.defineGetters

  actions: -> @_finishedActions

  # Used for testing & debugging.
  _values: -> @_root._values

type.defineMethods

  get: (key) ->
    assertType key, String

    return node if node = @_nodes[key]
    return unless node = @_getParent key

    if isType node, ArrayNode
      throw Error "Cannot use array indexes with dot-notation!"

    if node._key
    then node._get key.slice node._key.length + 1
    else node._get key

  call: (action) ->
    @_root.call.apply @_root, arguments

  set: (key, value) ->
    @_root.set key, value

  delete: (key) ->
    @_root.delete key

  merge: (values) ->
    @_root.merge values

  forEach: (iterator) ->
    @_root.forEach iterator

  filter: (iterator) ->
    @_root.filter iterator

  map: (iterator) ->
    @_root.map iterator

  on: (event, callback) ->
    @_root.on event, callback

  once: (event, callback) ->
    @_root.once event, callback

  load: (key) ->
    @_root.load key

  toString: ->
    @_root.toString()

  fromString: (json) ->
    @_root.fromString json

  convert: (modelTypes) ->
    @_root.convert modelTypes

  transform: (transformer) ->
    @_root.transform transformer

  _get: (key) ->
    @_root._values[key]

  # Supports dot-notation.
  _getParent: (key) ->
    if 0 < dot = key.lastIndexOf "."
    then @_nodes[key.slice 0, dot] or null
    else @_root

  _attachNode: (key, node) ->

    if isDev and @_nodes[key]
      throw Error "A node named '#{key}' already exists!"

    node._key = key
    node._tree = this

    @_nodes[key] = node
    return node

  _detachNode: (node) ->
    delete @_nodes[node._key]
    node._onDetach()
    node._tree = null
    node._key = null
    return

  _performAction: (node, action) ->
    assertType action, Object

    parents = @_pendingActions
    parents.push parent if parent = @_currentAction
    @_currentAction = action

    action.target = node._key
    result = node._performAction action, changes = []
    action.changes = changes if changes.length

    if parent
    then parent.changes.push action
    else @_finishedActions.push action

    @_currentAction = parents.pop() or null
    return result

  _revertAction: (action) ->
    assertType action, Object

    unless action.revertable
      if changes = action.changes
        @_revertChange change for change in changes
      return

    node =
      if action.target
      then @_nodes[action.target]
      else @_root

    if node is undefined
      throw Error "Missing node for key: '#{action.target}'"

    node.__revertAction action.name, action.args
    return

  _replayAction: (action) ->
    assertType action, Object

    node =
      if action.target
      then @_nodes[action.target]
      else @_root

    if node is undefined
      throw Error "Missing node for key: '#{action.target}'"

    delete action.changes
    @_performAction node, action
    return

module.exports = type.build()
