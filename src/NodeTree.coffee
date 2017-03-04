
assertType = require "assertType"
inArray = require "in-array"
isType = require "isType"
Event = require "eve"
Type = require "Type"

ArrayNode = require "./ArrayNode"
Node = require "./Node"

lastActionId = 0

type = Type "NodeTree"

type.defineValues (root) ->

  # The bottom-most node in the tree.
  _root: root

  # A map of nodes by their keys. Includes nested nodes.
  _nodes: Object.create null

  # The history of performed actions.
  _actions: []

  # The action being performed now.
  _currentAction: null

  # The stack of actions where a nested action took over as `current`.
  _parentActions: []

  # Emits when any action in the tree is finished.
  _didFinishAction: Event()

type.defineGetters

  root: -> @_root

  currentAction: -> @_currentAction

  actions: -> @_actions

type.defineMethods

  get: (key) ->
    assertType key, String

    return node if node = @_nodes[key]
    return unless node = @getParent key

    if isType node, ArrayNode
      throw Error "Cannot use array indexes with dot-notation!"

    if node._key
    then node._get key.slice node._key.length + 1
    else node._get key

  getParent: (key) ->
    assertType key, String
    if 0 < dot = key.lastIndexOf "."
    then @_nodes[key.slice 0, dot] or null
    else @_root

  observe: (node, callback) ->
    @_didFinishAction.on (action) ->

      # Observing the root node captures all actions.
      if node.key is null
        callback action
        return

      # Otherwise, only actions within the node are captured.
      return if action.target is null
      if action.target.startsWith node.key
        callback action
        return

  attach: (key, node) ->
    assertType key, String
    assertType node, Node.Kind

    if isDev and @_nodes[key]
      throw Error "A node named '#{key}' already exists!"

    node._key = key
    node._tree = this

    @_nodes[key] = node
    return node

  detach: (node) ->
    delete @_nodes[node._key]
    node.__onDetach()
    node._tree = null
    node._key = null
    return

  startAction: (action) ->
    assertType action, Object

    if parent = @_currentAction
      @_parentActions.push parent

    @_currentAction = action
    action.id = ++lastActionId
    action.changes = []
    return action

  finishAction: (action) ->
    assertType action, Object

    if action isnt @_currentAction
      throw Error "Must finish the current action first!"

    unless action.changes.length
      delete action.changes

    if @_currentAction = @_parentActions.pop() or null
    then @_currentAction.changes.push action
    else @_actions.push action

    @_didFinishAction.emit action
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
  _mergeTree: (key, root) ->
    assertType key, String
    assertType root, Node.Kind

    if this is tree = root._tree
      throw Error "That node is already attached to this tree!"

    nodes = @_nodes
    sync.each tree._nodes, (node, path) ->
      node._key = key + "." + path
      nodes[node._key] = node

    root._key = key
    root._tree = this
    return

module.exports = type.build()
