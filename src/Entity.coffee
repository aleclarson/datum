
Type = require "Type"

ActionHistory = require "./ActionHistory"
Node = require "./Node"

type = Type "Entity"

type.inherits Node

type.defineValues ->

  _actions: ActionHistory()

type.defineGetters

  action: -> @_actions._current

  actions: -> @_actions._finished

type.defineStatics

  Type: lazy: ->
    require "./EntityType"

module.exports = type.build()
