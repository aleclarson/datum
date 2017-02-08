
emptyFunction = require "emptyFunction"
assertType = require "assertType"
isType = require "isType"
OneOf = require "OneOf"
Event = require "eve"
isDev = require "isDev"
steal = require "steal"
Type = require "Type"

ArrayNode = require "./ArrayNode"

MapEvent = OneOf "add change delete loading loaded"

type = Type "MapNode"

type.defineValues ->

  _tree: null

  # The full tree path.
  _key: null

  # A reference to the nested tree data.
  _values: {}

  # Does *not* contain nested nodes.
  _nodes: Object.create null

  # Custom loaders for specific keys.
  _loaders: Object.create null

  # Resolves keys to absolute paths.
  _resolve: @_defaultResolve

  _events: Event.Map()

type.defineGetters

  key: -> @_key

  _initialValue: -> {}

type.defineMethods

  get: (key) ->
    assertType key, String
    if 1 > key.lastIndexOf "."
    then @_nodes[key] or @_values[key]
    else @_tree.get @_key + "." + key

  set: (key, value) ->
    assertType key, String

    if arguments.length < 2
      throw Error "Must provide 2 arguments!"

    if 1 > dot = key.lastIndexOf "."
      return @_set key, value

    if node = @_getParent key
      return node._set key.slice(dot + 1), value

    throw Error "Invalid key has no parent: '#{key}'"

  delete: (key) ->
    assertType key, String

    if 1 > dot = key.lastIndexOf "."
      return @_delete key

    if node = @_getParent key
      return node._delete key.slice(dot + 1)

    throw Error "Invalid key has no parent: '#{key}'"

  merge: (values) ->
    assertType values, Object
    for key, value of values
      @_set key, value
    return

  forEach: (iterator) -> # TODO: Implement?

  filter: (iterator) -> # TODO: Implement?

  map: (iterator) -> # TODO: Implement?

  # Possible events:
  #  - add
  #  - change
  #  - delete
  #  - loading
  #  - loaded

  on: (event, callback) ->
    @_events.on event, callback

  once: (event, callback) ->
    @_events.once event, callback

  load: (key) ->
    # TODO: Implement field loading.

  toString: ->
    JSON.stringify @_values

  fromString: (json) ->
    @merge JSON.parse json

  reset: ->
    @_onDetach()
    @_nodes = Object.create null
    @_values = {}
    return

  _defaultResolve: (key) ->
    return @_key + "." + key

  _getParent: (key) ->
    @_tree._getParent @_resolve key

  _get: (key) ->
    return @_nodes[key] or @_values[key]

  _set: (key, value) ->

    oldValue = @_values[key]
    return value if value is oldValue

    event =
      if oldValue is undefined
      then "add"
      else "change"

    if node = @_nodes[key]
      @_tree._detachNode node
      unless node._canAttachValue value
        delete @_nodes[key]
        node = null

    if node or node = @_createNode value
      @_attachNode key, node
      @_values[key] = node._values
      @_pushChange {event, key, value: node._initialValue}
      node._attachValues value
      return node

    @_values[key] = value
    @_pushChange {event, key, value}
    return value

  _delete: (key) ->

    delete @_values[key]

    if node = @_nodes[key]
      @_tree._detachNode node
      delete @_nodes[key]

    @_pushChange {event: "delete", key}
    return

  _canAttachValue: (value) -> isType value, Object

  _attachValues: (values) -> @merge values

  _createNode: (value) ->
    return ArrayNode() if isType value, Array
    return MapNode() if isType value, Object
    return null

  _attachNode: (key, node) ->
    @_nodes[key] = node
    @_tree._attachNode @_resolve(key), node
    return

  _onDetach: ->
    for key, node of @_nodes
      @_tree._detachNode node
    return

  _pushChange: (change) ->
    if @_key isnt null
      @_events.emit change.event, change
      @_events.emit "all", change
    @_tree._pushChange @_key, change
    return

  _performChange: (key, change) ->
    if change.event is "delete"
    then @_delete key
    else @_set key, change.value

module.exports = MapNode = type.build()
