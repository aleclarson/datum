
# jar v1.1.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

One-way, serializable state trees made easy. Time-traveling and hot-reloading included.

## synopsis

[**Node**](#node):
- Nodes are encapsulated objects.
- Nodes can be targeted by actions.
- Nodes track all changes to their values.

[**MapNode**](#mapnode):
- Supports nesting other nodes.

[**ArrayNode**](#arraynode):
- Cannot contain other nodes (yet?).

[**ModelNode**](#modelnode):
- Provides a getter & setter for each serialized key.
- Supports ephemeral properties.

[**NodeTree**](#nodetree):
- Keeps a map to every node in the tree.
- Keeps a history of all performed actions.

---

## api reference

### MapNode

The `MapNode` class encapsulates a plain object.

### ArrayNode

The `ArrayNode` class encapsulates an array.

#### `length`

The number of values in the array.

#### `get(index)`

Returns the value for the given `index`.

Returns `undefined` if the `index` does not exist.

#### `set(index, value)`

Sets the value for the given `index`.

Sparse arrays are supported.

#### `delete(index)`

Removes a value from the array by its `index`.

#### `insert(index, value)`

Adds a value to the array at the given `index`.

#### `push(value)`

Adds a value to the end of the array.

#### `unshift(value)`

Adds a value to the start of the array.

#### `insertAll(index, values)`

Splices an array into the array at the given `index`.

#### `pushAll(values)`

Concatenates an array to the end of the array.

#### `unshiftAll(values)`

Concatenates an array to the start of the array.

#### `slice(index, length)`

Creates a new array using the given `index` and `length`.

#### `forEach(iterator)`

Calls the `iterator` for each key/value pair in the array.

The `iterator` function signature is `(value, key)`.

#### `filter(iterator)`

Calls the `iterator` for each key/value pair in the array.

The `iterator` function signature is `(value, key)`.

Whenever `true` is returned by the `iterator`, the current key/value pair is skipped.

A new array of the unfiltered values is returned.

#### `map(iterator)`

Calls the `iterator` for each key/value pair in the array.

The `iterator` function signature is `(value, key)`.

The value returned by the `iterator` is added to the results.

A new array of mapped values is returned.

### ModelNode

### NodeTree

### Node

The `Node` class is the starting point for all node types.

#### `tree`

The `NodeTree` that this node is attached to.

#### `on(action, callback)`

Listen for actions with a specific name.

Use the `once` method for one-time listeners.

#### `__onAttach()`

A hook called when attached to a `NodeTree`.

#### `__onDetach()`

A hook called when detached from a `NodeTree`.

---

## roadmap

- Support `ModelNode` instances nested within other `ModelNode` instances.
- Support `ModelNode` instances within arrays.

