
emptyFunction = require "emptyFunction"
assertType = require "assertType"
isType = require "isType"
OneOf = require "OneOf"
Event = require "eve"
Type = require "Type"

ArrayEvent = OneOf "add change delete"

type = Type "ArrayNode"

type.defineValues ->

  _tree: null

  _key: null

  _values: []

  _events: Event.Map()

type.defineGetters

  key: -> @_key

  length: -> @_values.length

  _initialValue: -> []

type.defineMethods

  get: (index) ->
    assertType index, Number
    return @_values[index]

  set: (index, value) ->
    assertType index, Number
    if index >= 0 and index < @length
      @_values[index] = value
      @_pushChange {event: "change", index, value}
    return value

  delete: (index) ->
    assertType index, Number
    if index >= 0 and index < @length
      [oldValue] = @_values.splice index, 1
      @_pushChange {event: "delete", index}
    return

  push: (value) ->
    index = -1 + @_values.push value
    @_pushChange {event: "add", index, value}
    return

  unshift: (value) ->
    @_values.unshift value
    @_pushChange {event: "add", index: 0, value}
    return

  pushAll: (values) ->
    assertType values, Array
    @push value for value in values
    return

  unshiftAll: (values) ->
    assertType values, Array
    @_values = values.concat @_values
    for value, index in values
      @_pushChange {event: "add", index, value}
    return

  insert: (index, value) -> # TODO: Implement?

  insertAll: (index, value) -> # TODO: Implement?

  slice: (index, length) ->
    @_values.slice index, length

  sort: -> # TODO: Implement?

  sortBy: (key) -> # TODO: Implement?

  forEach: (iterator) -> # TODO: Implement?

  filter: (iterator) -> # TODO: Implement?

  map: (iterator) -> # TODO: Implement?

  on: (event, callback) ->
    assertType event, ArrayEvent
    @_events.on event, callback

  once: (event, callback) ->
    assertType event, ArrayEvent
    @_events.once event, callback

  reset: ->
    @_values = []
    return

  _canAttachValue: (value) -> isType value, Array

  _attachValues: (values) -> @pushAll values

  _onDetach: emptyFunction

  _pushChange: (change) ->
    @_events.emit change.event, change
    @_events.emit "all", change
    @_tree._pushChange @_key, change
    return

  _performChange: (key, change) ->
    # TODO: Implement

module.exports = type.build()
