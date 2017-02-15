
assertType = require "assertType"
isType = require "isType"
OneOf = require "OneOf"
Type = require "Type"

Node = require "./Node"

type = Type "ArrayNode"

type.inherits Node

type.defineGetters

  length: -> @_values.length

type.definePrototype

  _actions: require "./ArrayActions"

type.defineMethods

  get: (index) ->
    assertType index, Number
    return @_values[index]

  set: (index, value) ->
    assertType index, Number
    @_tree._performAction this,
      name: "set"
      args: [index, value]
      revertable: yes

  delete: (index) ->
    assertType index, Number
    @_tree._performAction this,
      name: "delete"
      args: [index]
      revertable: yes

  insert: (index, value) ->
    assertType index, Number
    @_tree._performAction this,
      name: "insert"
      args: [index, value]
      revertable: yes

  push: (value) ->
    @_tree._performAction this,
      name: "push"
      args: [value]
      revertable: yes

  unshift: (value) ->
    @_tree._performAction this,
      name: "unshift"
      args: [value]
      revertable: yes

  insertAll: (index, values) ->
    assertType index, Number
    assertType values, Array
    @_tree._performAction this,
      name: "insertAll"
      args: [index, values]

  pushAll: (values) ->
    assertType values, Array
    @_tree._performAction this,
      name: "pushAll"
      args: [values]

  unshiftAll: (values) ->
    assertType values, Array
    @_tree._performAction this,
      name: "unshiftAll"
      args: [values]

  slice: (index, length) ->
    @_values.slice index, length

  sort: -> # TODO: Implement?

  sortBy: (key) -> # TODO: Implement?

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

  __getInitialValue: -> []

  __attachValues: (values) -> @pushAll values

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
