
isDev = require "isDev"
Type = require "Type"

Action = require "./Action"

type = Type "ActionHistory"

type.defineMethods

  start: (action) ->
    assertType action, Action
    @_current and @_started.push @_current
    @_current = action
    return

  finish: (action) ->
    assertType action, Action

    if isDev and @_current is null
      throw Error "No current action exists!"

    if isDev and action isnt @_current
      throw Error "Must finish the current action first!"

    if action._tracked
      @_finished.push action

    @_current = @_started.pop() or null
    return

  remove: (action) ->
    assertType action, Action

    index = @_finished.indexOf action
    if isDev and index < 0
      throw Error "That action is not being tracked!"

    @_finished.splice index, 1
    return

#
# Internal
#

type.defineValues ->

  _current: null

  _started: []

  _finished: []

module.exports = type.build()
