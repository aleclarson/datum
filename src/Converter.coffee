
assertType = require "assertType"
Type = require "Type"

type = Type "Converter"

type.defineValues ->

  _types: []

  _converters: []

type.defineMethods

  add: (type, converter) ->
    @_types.push type
    @_converters.push converter
    return

type.defineBoundMethods

  convertValue: (value) ->
    return value unless value?
    index = @_types.indexOf value.constructor
    return value if index is -1
    return @_converters[index] value

  convertArray: (array) ->
    assertType array, Array
    for value, key in array
      continue unless value?
      index = @_types.indexOf value.constructor
      continue if index is -1
      array[key] = @_converters[index] value
    return

  convertState: (state) ->
    assertType state, Object
    for key, value of state
      continue unless value?
      index = @_types.indexOf value.constructor
      continue if index is -1
      state[key] = @_converters[index] value
    return

module.exports = type.construct()
