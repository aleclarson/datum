
emptyFunction = require "emptyFunction"
assertType = require "assertType"
hasKeys = require "hasKeys"
isDev = require "isDev"
Type = require "Type"

Converter = require "./Converter"
Node = require "./Node"

{convertValue, convertState} = Converter

type = Type "MapNode"

type.inherits Node

type.defineArgs [Object.Maybe]

type.defineMethods

  has: (key) ->
    assertType key, String
    return @_state.hasOwnProperty key

  get: (key) ->
    assertType key, String
    return @_state[key]

  set: (key, value) ->
    assertType key, String

    @_state[key] = value
    @_events.emit "set", key, value
    return value

  add: (node) ->
    assertType node, Node.Kind

    if isDev and node.id is undefined
      throw Error "Nodes passed to `add` must have an 'id' property!"

    unless has @_state, node.id
      @_state[node.id] = node
      @_events.emit "set", node.id, node
    return

  merge: (values) ->
    assertType values, Object
    return unless hasKeys values
    for key, value of values
      @set key, value
    return

  delete: (key) ->
    assertType key, String
    if has @_state, key
      delete @_state[key]
      @_events.emit "delete", key
    return

  reset: (values) ->
    assertType values, Object
    @_state = values or {}
    @_events.emit "reset"
    return

  observe: (key, callback) ->
    @_events.on "set", ->
      if key is arguments[0]
        callback arguments[1]
        return

  forEach: (iterator) ->
    assertType iterator, Function
    for key, value of @_state
      iterator value, key
    return

  filter: (iterator) ->
    assertType iterator, Function
    values = {}

    for key, value of @_state
      if iterator value, key
        values[key] = value

    return values

  map: (iterator) ->
    assertType iterator, Function
    values = {}

    for key, value of @_state
      values[key] = iterator value, key

    return values

#
# Internal
#

type.defineValues (values) ->

  convertState values if values

  _state: values or {}

type.defineMethods

  _getState: -> @_state

type.overrideMethods

  __createOptions: emptyFunction.thatReturnsArgument

module.exports = type.build()
