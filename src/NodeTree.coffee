
assertType = require "assertType"
isDev = require "isDev"
Event = require "eve"
Type = require "Type"
sync = require "sync"

NodeList = require "./NodeList"
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

  attach: (key, node) ->
    assertType key, String
    assertType node, Node.Kind

    if isDev and @_nodes[key]
      throw Error "A node named '#{key}' already exists!"

    if isDev and node._tree is this
      throw Error "Cannot attach a node more than once!"

    if node._tree
      @_mergeTree key, node

    node._key = key
    node._tree = this

    @_nodes[key] = node
    return node

  attachRef: (key, node) ->
    assertType key, String
    assertType node, Node.Kind

    @_refs[key] = node._key
    return

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

    @_pendingActions.push @_currentAction
    @_currentAction = action
    return action

  finishAction: ->

    action = @_currentAction

    unless action.changes.length
      delete action.changes

    if @_currentAction = @_pendingActions.pop()
    then @_currentAction.changes.push action
    else @actions.push action

    return action

  revertAction: (action) ->
    assertType action, Object

    unless node._revertable[action.name]
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

  _refs: Object.create null

  _currentAction: null

  _pendingActions: []

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

  # NOTE: The '_actions' history is not currently copied over.
  _mergeTree: (key, node) ->
    tree = node._tree

    unless node is tree._root
      throw Error "Must call `_mergeTree` with the root node!"

    nodes = @_nodes
    sync.each tree._nodes, (node, path) ->
      node._key = key + "." + path

      if node instanceof NodeList
        node._values = sync.map node._values, (path) ->
          return key + "." + path

      node._tree = this
      nodes[node._key] = node
      return

    refs = @_refs
    sync.each tree._refs, (path, ref) ->
      refs[key + "." + ref] = key + "." + path
      return

    actions = @actions
    sync.each tree.actions, (action) ->

      if action.name is "ref"
        path = action.args[1]
        action.args[1] = key + "." + path

      actions.push action
      action.target =
        if path = action.target
        then key + "." + path
        else key
      return
    return

module.exports = NodeTree = type.build()
