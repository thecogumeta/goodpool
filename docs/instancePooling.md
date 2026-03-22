---
sidebar_position: 4
---

# Instance Pooling

GoodPool can be used to pool Roblox Instances, such as Parts, Models, and UI elements.

## Creating an Instance Pool

```lua
local GoodPool = require(path.to.GoodPool)

-- Note: forInstance return the same as GoodPool.new
local pool = GoodPool.forInstance("Part", function(part)
        part.Parent = nil
        part.Anchored = true
		part.Size = Vector3.new(1, 1, 1)
		part.CFrame = CFrame.new(0, 100, 0)
		part.Transparency = 0
		part.CanCollide = true
	end
)
```

## Getting and Returning Instances

```lua
local part = pool:Get()
part.CFrame = CFrame.new(0, 0, 0)

-- When done
pool:Return(part)
```

## Cleaning the Pool

```lua
pool:Clean()
```

This will :Destroy all pooled instances.
