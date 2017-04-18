
assertType = require "assertType"
Type = require "Type"

type = Type "ActionStack"

type.defineValues ->

  _current: null

  _stack: []

type.defineGetters

  current: -> @_current

type.defineMethods

  push: (action) ->
    assertType action, Object
    @_stack.push @_current
    @_current = action
    return

  pop: ->
    action = @_current
    if @_stack.length
      @_current = @_stack.pop()
    return action

module.exports = type.construct()
