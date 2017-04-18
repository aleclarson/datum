
assertType = require "assertType"
LazyVar = require "LazyVar"
inArray = require "in-array"
isDev = require "isDev"
Event = require "eve"
Type = require "Type"
sync = require "sync"
has = require "has"

ActionStack = require "./ActionStack"
MapNode = require "./MapNode"
Node = require "./Node"

lastActionId = 0

type = Type "NodeTree"

type.defineArgs [Node.Kind]

type.defineValues ->

  actions: []

type.defineGetters

  root: -> @_root

  currentAction: -> @_currentAction

type.defineMethods

  get: (key) ->
    assertType key, String

    return node if node = @_nodes[key]
    return unless node = @getParent key

    if node._key
    then node._get key.slice node._key.length + 1
    else node._get key

  getParent: (key) ->
    assertType key, String
    if 0 < dot = key.lastIndexOf "."
    then @_nodes[key.slice 0, dot] or null
    else @_root

  resolve: (node, key) ->
    return @_nodes[node._resolve key]

  attach: (key, node) ->
    assertType key, String

    if isDev and @_nodes[key]
      throw Error "A node named '#{key}' already exists!"

    if isDev and node._tree isnt this
      throw Error "Node already belongs to another tree!"

    node._key = key
    node._tree = this
    node.__onAttach()

    @_nodes[key] = node
    return node

  detach: (node) ->
    assertType node, Node.Kind

    node.__onDetach()
    node._tree = null
    node._key = null

    delete @_nodes[node._key]
    return

  startAction: (target, name, args) ->

    assertType target, String.Maybe
    assertType name, String
    assertType args, Array.Maybe

    id = ++lastActionId
    action = {id, target, name}
    action.args = args if args
    action.changes = []
    action.tree = this

    ActionStack.push action
    return action

  finishAction: ->

    action = ActionStack.pop()

    if parent = ActionStack.current
    then parent.changes.push action
    else @actions.push action

    unless action.changes.length
      delete action.changes

    delete action.tree
    return action

  revertAction: (action) ->
    assertType action, Object

    unless inArray node._revertable, action.name
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

#
# Internal
#

type.defineValues (root) ->

  _root: root

  _nodes: Object.create null

type.defineMethods

  _replayAction: (action) ->
    assertType action, Object

    node =
      if action.target
      then @_nodes[action.target]
      else @_root

    if node is undefined
      throw Error "Missing node for key: '#{action.target}'"

    node.__replayAction action.name, action.args
    return

module.exports = type.build()
