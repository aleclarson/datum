
emptyFunction = require "emptyFunction"
sliceArray = require "sliceArray"
isType = require "isType"
Type = require "Type"

type = Type "Action"

type.defineArgs [String, Function]

type.defineValues (name, action) ->

  _name: name

  _action: action

  _resolve: action.resolve

type.defineMethods

  apply: (node, args) ->
    assertType node, Node.Kind

    args = if args.length then sliceArray args else null
    action = node._startAction @_name, args
    result = @_action.apply node, args

    if isType result, Promise
      action.name += ":pending"
      result = @_async node, args, result

    node._finishAction action
    return result

  _async: (node, args, promise) ->
    name = @_name + ":resolve"
    resolve = @_resolve or emptyFunction.thatReturnsArgument

    promise.then (result) ->
      action = node._startAction name, [result]
      result = resolve.call node, result
      node._finishAction action
      return result

    # TODO: Track rejected promises somewhere.
    # .fail (error) ->

module.exports = type.build()
