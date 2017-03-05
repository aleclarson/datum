
assertType = require "assertType"
inArray = require "in-array"
isType = require "isType"
Event = require "eve"
Type = require "Type"
has = require "has"

ArrayNode = require "./ArrayNode"
MapNode = require "./MapNode"
Node = require "./Node"

lastActionId = 0

type = Type "NodeTree"

type.defineArgs [MapNode.Maybe]

type.defineValues ->

  # The bottom-most node in the tree.
  _root: null

  # A map of nodes by their keys. Includes nested nodes.
  _nodes: Object.create null

  # Each key is the absolute path to a model node.
  # Each value is the model type's name.
  _modelNodes: Object.create null

  # Each key is a model type's name.
  # Each value is the model type.
  _modelTypes: Object.create null

  # The history of performed actions.
  _actions: []

  # The action being performed now.
  _currentAction: null

  # The stack of actions where a nested action took over as `current`.
  _parentActions: []

  # Emits when any action in the tree is finished.
  _didFinishAction: Event()

type.initInstance (root) ->
  @_root =
    if isType root, MapNode
    then root
    else MapNode null, this
  return

type.defineGetters

  root: -> @_root

  currentAction: -> @_currentAction

  actions: -> @_actions

type.defineMethods

  toString: ->
    JSON.stringify
      values: @_root._values
      models: @_modelNodes

  convert: (models) ->

    for model of models

      if has @_modelTypes, model
        throw Error "Model named '#{model}' already exists!"

      @_modelTypes[model] = models[model]

    for nodePath, model of @_modelNodes
      continue unless createNode = models[model]

      # Detach the map node from the tree.
      @detach @_nodes[nodePath]

      # Get the basename of `nodePath`.
      parent = @getParent nodePath
      key =
        if parent._key
        then nodePath.slice parent._key.length + 1
        else nodePath

      # Create the model node with the old values.
      parent._nodes[key] = node = createNode parent._values[key]
      parent._values[key] = node._values

      # Attach the model node to the tree.
      @attach nodePath, node
    return

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
    @_didFinishAction (action) ->

      {key} = node
      if key is null
        callback action
        return

      {target} = action
      return if target is null

      if key is target
        callback action
        return

      if target.startsWith key + "."
        callback action
        return

  attach: (key, node) ->
    assertType key, String
    assertType node, Node.Kind

    if isDev and @_nodes[key]
      throw Error "A node named '#{key}' already exists!"

    node._key = key
    node._tree = this
    node.__onAttach()

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
