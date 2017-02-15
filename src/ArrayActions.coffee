
actions = Object.create null

actions.set = (index, value) ->
  @_values[index] = value
  return

actions.delete = (index) ->
  @_values.splice index, 1
  return

actions.push = (value) ->
  @_values.push value
  return

actions.unshift = (value) ->
  @_values.unshift value
  return

actions.insert = (index, value) ->
  @_values.splice index, 0, value
  return

actions.pushAll = (values) ->
  for value in values
    @push value
  return

actions.unshiftAll = (values) ->
  index = values.length
  while --index > 0
    @unshift values[index]
  return

actions.insertAll = (index, values) ->
  for value, offset in values
    @insert index + offset, value
  return

module.exports = actions
