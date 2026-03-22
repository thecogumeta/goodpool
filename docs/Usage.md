---
sidebar_position: 3
---

# Basic Usage

GoodPool works by reusing objects instead of creating and destroying them repeatedly.

To create a pool, you provide two functions:

- **createFn** – creates a new object when the pool is empty
- **initFn** – resets the object when it is retrieved from the pool

## Creating a Pool

```lua
local GoodPool = require(path.to.GoodPool)

local pool = GoodPool.new(
	function()
		return {
			value = 0
		}
	end,
	function(obj)
		obj.value = 0
	end
)
```

## Getting an Object

Objects are retrieved using `Get()`.

```lua
local obj = pool:Get()

obj.value += 10
print(obj.value) -- 10
```

## Returning an Object

When you are done using the object, return it to the pool so it can be reused.

```lua
pool:Return(obj)
```

The next time the object is retrieved, it will be reset using the `initFn`.

```lua
local obj2 = pool:Get()
print(obj2.value) -- 0
```

## Preloading Objects

You can preload objects into the pool to avoid allocations during gameplay.

```lua
pool:Preload(50)
```

## Cleaning the Pool

To destroy all pooled objects:

```lua
pool:Clean()
```

This calls the `destroyFn` provided when the pool was created.
