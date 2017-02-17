
assertType = require "assertType"
isType = require "isType"
OneOf = require "OneOf"
Type = require "Type"

Node = require "./Node"

type = Type "ArrayNode"

type.inherits Node

type.defineArgs [Array]

type.defineGetters

  key: -> @_key

  length: -> @_values.length

  _initialValue: -> @_values.slice()

type.definePrototype

  _revertable: ["set", "insert", "push", "unshift", "delete"]

type.defineMethods

  get: (index) ->
    assertType index, Number
    return @_values[index]

  set: (index, value) ->
    assertType index, Number
    action = @_startAction "set", [index, value]
    @_values[index] = value
    @_finishAction action
    return value

  delete: (index) ->
    assertType index, Number
    action = @_startAction "delete", [index]
    @_values.splice index, 1
    @_finishAction action
    return

  insert: (index, value) ->
    assertType index, Number
    action = @_startAction "insert", [index, value]
    @_values.splice index, 0, value
    @_finishAction action
    return

  push: (value) ->
    action = @_startAction "push", [value]
    @_values.push value
    @_finishAction action
    return

  unshift: (value) ->
    action = @_startAction "unshift", [value]
    @_values.unshift value
    @_finishAction action
    return

  insertAll: (index, values) ->
    assertType index, Number
    assertType values, Array
    action = @_startAction "insertAll", [index, values]
    for value, offset in values
      @insert index + offset, value
    @_finishAction action
    return

  pushAll: (values) ->
    assertType values, Array
    action = @_startAction "pushAll", [values]
    @push value for value in values
    @_finishAction action
    return

  unshiftAll: (values) ->
    assertType values, Array
    action = @_startAction "unshiftAll", [values]
    index = values.length
    @unshift values[index] while --index > 0
    @_finishAction action
    return

  slice: (index, length) ->
    @_values.slice index, length

  # sort: -> # TODO: Implement?

  # sortBy: (key) -> # TODO: Implement?

  forEach: (iterator) ->
    for value, index in @_values
      iterator value, index
    return

  filter: (iterator) ->
    values = []
    for value, index in @_values
      values.push value if iterator value, index
    return values

  map: (iterator) ->
    values = new Array @length
    for value, index in @_values
      values[index] = iterator value, index
    return values

type.overrideMethods

  __revertAction: (name, args) ->

    if name is "set"
      throw Error "not implemented"
      return

    if name is "delete"
      throw Error "not implemented"
      return

    if name is "insert"
      throw Error "not implemented"
      return

    if name is "push"
      throw Error "not implemented"
      return

    if name is "unshift"
      throw Error "not implemented"
      return

module.exports = type.build()
