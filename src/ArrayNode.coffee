
emptyFunction = require "emptyFunction"
assertType = require "assertType"
Type = require "Type"

Converter = require "./Converter"
Node = require "./Node"

{convertValue, convertArray} = Converter

type = Type "ArrayNode"

type.inherits Node

type.defineArgs [Array.Maybe]

type.defineGetters

  length: -> @_state.length

type.defineMethods

  get: (index) ->
    assertType index, Number
    return @_state[index]

  indexOf: (value) ->
    return @_state.indexOf value

  contains: (value) ->
    return 0 <= @_state.indexOf value

  set: (index, value) ->
    assertType index, Number
    value = convertValue value
    @_state[index] = value
    @_events.emit "set", index, value
    return

  push: (value) ->
    value = convertValue value
    length = @_state.push value
    @_events.emit "set", length - 1, value
    return

  unshift: (value) ->
    value = convertValue value
    @_state.unshift value
    @_events.emit "insert", 0, value
    return

  insert: (index, value) ->
    value = convertValue value
    @_state.splice index, 0, value
    @_events.emit "insert", index, value
    return

  remove: (value) ->
    index = @_state.indexOf value
    if index >= 0
      @_state.splice index, 1
      @_events.emit "delete", index
    return

  delete: (index) ->
    assertType index, Number

    length = @_state.length
    index += length if index < 0

    if index >= 0 and index < length
      @_state.splice index, 1
      @_events.emit "delete", index
    return

  forEach: (iterator) ->
    assertType iterator, Function
    return @_state.forEach iterator

  map: (iterator) ->
    assertType iterator, Function
    return @_state.map iterator

  filter: (iterator) ->
    assertType iterator, Function
    return @_state.filter iterator

  toArray: ->
    return @_state.slice()

#
# Internal
#

type.defineValues (values) ->

  convertArray values if values

  _state: values or []

type.defineMethods

  _getState: -> @_state

type.overrideMethods

  __createOptions: (values) ->
    return values._array

module.exports = type.build()
