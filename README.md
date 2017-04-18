
# jar v1.1.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

Preservable state trees for Javascript.

- **Coming soon:** time traveling & hot reloading

### Node

An atom of data which can be serialized.

- Referenced within the state tree using a key path.
- May be targeted by actions (which can be reverted & replayed).
- Keeps a history of all mutations to its internal data.

**Methods:**
- `on(action, callback)`
- `once(action, callback)`
- `observe(key, callback)`
- `toString()`

### MapNode

A map of atoms.

- Subclass of `Node`

**Methods:**
- `get(key)`
- `set(key, value)`
- `merge(values)`
- `delete(key)`
- `forEach(iterator)`
- `filter(iterator)`
- `map(iterator)`

### Entity

A group of atoms with specialized actions and temporal data.

- Subclass of `Node`
- Must be created within an action.
- Provides a getter and setter for each serialized atom.
- May provide keys which can be loaded asynchronously.
- Defined using an `Entity.Type` instance.

**Methods:**
- `load(key, options)`

### NodeList

An ordered set of atoms.

- Subclass of `Node`

**Properties:**
- `length: Number`

**Methods:**
- `get(index)`
- `append(node)`
- `prepend(node)`
- `remove(node)`
- `move(node, index)`
- `forEach(iterator)`
- `toArray()`

### NodeTree

A branch of atoms which can be serialized.

- Keeps a history of all actions performed on atoms attached to it.

**Properties:**
- `actions: Array`
