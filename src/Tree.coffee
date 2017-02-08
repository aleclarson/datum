
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

  # Contains all data (flat or nested).
  _root: MapNode()

  # Quick access to any nested node (eg: "a.b.c").
  _nodes: Object.create null

  # Contains changes to all nested data.
  _changes: []

type.initInstance ->
  @_root._tree = this
  @_root._resolve = emptyFunction.thatReturnsArgument

type.defineGetters

  changes: -> @_changes

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

  set: (key, value) ->
    assertType key, String
    return @_root.set key, value

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

  undo: (key, count) ->

    if arguments.length is 1
      count = key
      key = null

    assertType key, String.Maybe
    assertType count, Number

    if key isnt null

      if node = @_nodes[key]
        key = null

      else if 0 < dot = key.lastIndexOf "."
        node = @_getParent
        key = key.slice dot + 1

    changes = @_changes

    if node?
      changes = changes.filter (event) ->
        event.key is node._key

    if key isnt null
      changes = changes.filter (event) ->
        event.change.key is key

    index = changes.length
    lastIndex = Math.max 0, index - count

    # while --index >= lastIndex
    #   change = changes[index]
    #   if change.event is "delete"
    #     # TODO: Look up last change/add event for the specific key.
    #   else if change.event is "add"
    #     newChange = {event: "delete"}
    #     newChange.key = change.key
    #     Object.assign {}, change, {event: "delete"}
    #   else

    # TODO: Splice reversed changes out of `this._changes` and `node._changes`.
    return

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

  _pushChange: (key, change) ->
    assertType key, String.Maybe
    assertType change, Object
    event = if key then {key, change} else {change}
    @_changes.push event
    @_root._events.emit change.event, event
    @_root._events.emit "all", event
    return

  _performChange: (key, change) ->

    if node = @_getParent key
      key = key.slice node._key.length + 1
      node._performChange key, change
      return

    throw Error "Invalid key has no parent: '#{key}'"

module.exports = type.build()
