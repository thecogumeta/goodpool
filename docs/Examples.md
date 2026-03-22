---
sidebar_position: 5
---

# Examples

## Basic Table Pool

Pooling tables can reduce allocations when frequently creating temporary objects.

```lua
local GoodPool = require(path.to.GoodPool)

local tablePool = GoodPool.new(
	function()
		return {}
	end,
	function(tbl)
		table.clear(tbl)
	end
)

local obj = tablePool:Get()
obj.value = 42

print(obj.value) -- 42

tablePool:Return(obj)
```

## Pooling Roblox Instances

GoodPool can also be used to reuse Roblox instances instead of constantly cloning and destroying them.

```lua
local GoodPool = require(path.to.GoodPool)

local partPool, template = GoodPool.forInstance(
	"Part",
	function(part)
        part.Parent = nil
        part.Position = Vector3.zero
		part.Anchored = true
		part.Transparency = 0
	end
)

local part = partPool:Get()
part.Position = Vector3.new(0, 10, 0)
part.Parent = workspace

-- later
partPool:Return(part)
```

## Projectile Pool Example

Pooling is especially useful for frequently spawned objects like bullets.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GoodPool = require(path.to.GoodPool)

local bulletTemplate = ReplicatedStorage:WaitForChild("Bullet")

local bulletPool = GoodPool.forInstance(
	bulletTemplate,
	function(bullet)
        bullet.Parent = nil
        bullet.CFrame = CFrame.new()
		bullet.Anchored = true
		bullet.Transparency = 0
	end
)

local function fireBullet(position: Vector3, direction: Vector3)
	local bullet = bulletPool:Get()

	bullet.CFrame = CFrame.new(position, position + direction)
	bullet.Parent = workspace

    task.spawn(function()
        while bullet.Parent do
            bullet.CFrame += direction * 50 * task.wait()
        end
    end)

	task.delay(2, function()
		bulletPool:Return(bullet)
	end)
end

for i = 1, 100 do
    fireBullet(Vector3.new(0, 5, 0), Vector3.new(0, 0, -1))
    task.wait(0.05)
end
```
