
emptyFunction = require "emptyFunction"
assertType = require "assertType"
Event = require "eve"
Type = require "Type"

nextId = 1

type = Type "Node"

type.inherits null

type.defineMethods

  on: (event, callback) ->
    @_events.on event, callback

  once: (event, callback) ->
    @_events.once event, callback

#
# Internal
#

type.defineFrozenValues ->

  _id: nextId++

  _events: Event.Map()

type.defineHooks

  __createOptions: emptyFunction

  __createValues: emptyFunction

  __revertAction: emptyFunction.thatReturnsFalse

module.exports = type.build()
