--[=[
	@class GoodPool
	A flexible and lightweight generic object pool.

	GoodPool allows you to reuse objects instead of repeatedly creating
	and destroying them. You provide a function to create the object,
	another to initialize it when acquired, and an optional one to
	destroy it when the pool is cleaned.
	```lua
	local tblPool = GoodPool.new(
		function()
			return { value = 10 }
		end,
		function(tbl)
			tbl.value = 10
		end
	)

	local obj = tblPool:Get()
	obj.value += 10
	print(obj.value) -- 20

	tblPool:Return(obj)
	print(tblPool:Get().value) -- 10
	```
]=]
local GoodPool = {}
GoodPool.__index = GoodPool

export type GoodPool<T> = {
	Get: (self: GoodPool<T>) -> T,
	Preload: (self: GoodPool<T>, amount: number) -> (),
	Return: (self: GoodPool<T>, T) -> (),
	Clean: (self: GoodPool<T>) -> (),
	GetSize: (self: GoodPool<T>) -> number,
}

type InternalGoodPool<T> = GoodPool<T> & {
	pool: { T },
	createFn: () -> T,
	initFn: (T) -> (),
	destroyFn: (T) -> (),
	size: number,
}

--[=[
	@within GoodPool
	@param createFn () -> T -- Called when the pool is empty and a new object is needed.
	@param initFn (T) -> () -- Called every time an object is acquired. Use this to reset its state.
	@param destroyFn ((T) -> ())? -- Called on each object when `Clean` is invoked. Use this to free resources.
	@return GoodPool<T>

	Creates a new GoodPool.
]=]
function GoodPool.new<T>(createFn: () -> T, initFn: (T) -> (), destroyFn: ((T) -> ())?): GoodPool<T>
	local self: InternalGoodPool<T> = {} :: any

	self.pool = {}
	self.createFn = createFn
	self.initFn = initFn
	self.destroyFn = destroyFn or function() end
	self.size = 0

	return setmetatable(self, GoodPool) :: any
end

--[=[
	@within GoodPool
	@param templateOrClassName Instance | string -- An existing Instance to clone, or a class name string to create one from.
	@param setupFn (Instance) -> () -- Called every time an Instance is acquired. Use this to reset its state.
	@return GoodPool<Instance>, Instance

	Creates a GoodPool that clones Instances from a template.

	If a class name string is provided, a new Instance of that class is created
	and used as the template. The template is returned alongside the pool so you
	can reference it later regardless of how it was created.
	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local partPool, template = GoodPool.forInstance(
		ReplicatedStorage.Part,
		function(part)
			part.Transparency = 0
			part.Position = Vector3.new(0, 0, 0)
		end
	)

	print(template == ReplicatedStorage.Part) -- true

	local part = partPool:Get()
	part.Parent = workspace

	partPool:Return(part)
	```
]=]
function GoodPool.forInstance(
	templateOrClassName: Instance | string,
	setupFn: (Instance) -> ()
): (GoodPool<Instance>, Instance)
	if typeof(templateOrClassName) == "string" then
		templateOrClassName = Instance.new(templateOrClassName)
	end
	local template: Instance = templateOrClassName :: any

	return GoodPool.new(
		function()
			return template:Clone()
		end,
		setupFn,
		function(item)
			item:Destroy()
		end
	),
		template
end

local function _GetPure<T>(self: InternalGoodPool<T>): T
	if self.size > 0 then
		local item = self.pool[self.size]
		self.pool[self.size] = nil
		self.size -= 1
		return item
	end

	return self.createFn()
end

--[=[
	@within GoodPool
	@return T

	Retrieves an object from the pool, passing it through `initFn` before returning.

	If the pool is empty, a new object is created via `createFn`.
]=]
function GoodPool:Get<T>(): T
	local item = _GetPure(self)
	self.initFn(item)
	return item
end

--[=[
	@within GoodPool
	@param amount number -- Number of objects to pre-fill the pool with.

	Pre-fills the pool with a given number of objects created via `createFn`.

	Useful for avoiding lag spikes on first use. Does nothing if `amount` is <= 0.
]=]
function GoodPool:Preload(amount: number)
	if amount <= 0 then
		return
	end

	for i = 1, amount do
		self.size += 1
		self.pool[self.size] = self.createFn()
	end
end

--[=[
	@within GoodPool
	@param newAmount number -- The desired pool size.

	Resizes the pool to the given amount.

	If `newAmount` is greater than the current size, new objects are created via `Preload`.
	If `newAmount` is less, excess objects are destroyed via `Clean`.
	Does nothing if `newAmount` equals the current size.
]=]
function GoodPool:Resize(newAmount: number)
	if newAmount == self.size then
		return
	end

	local diff = math.abs(newAmount - self.size)

	if newAmount < self.size then
		self:Clean(diff)
	elseif newAmount > self.size then
		self:Preload(diff)
	end
end

--[=[
	@within GoodPool
	@param amount number? -- Number of objects to destroy. Defaults to all objects in the pool.

	Destroys objects in the pool via `destroyFn`.

	If `amount` is provided, only that many objects are destroyed.
	Otherwise, the entire pool is cleared.

	Objects that are currently in use (i.e. not yet returned) are not affected.
]=]
function GoodPool:Clean(amount: number?)
	local count = amount or self.size
	for i = self.size, self.size - count + 1, -1 do
		local item = self.pool[i]
		self.pool[i] = nil
		self.destroyFn(item)
	end
	self.size -= count
end

--[=[
	@within GoodPool
	@return number

	Returns the number of objects currently sitting idle in the pool.
]=]
function GoodPool:GetSize(): number
	return self.size
end

--[=[
	@within GoodPool
	@return boolean

	Returns `true` if the pool has no objects available, `false` otherwise.
]=]
function GoodPool:IsEmpty(): boolean
	return self.size == 0
end

--[=[
	@within GoodPool
	@param item T -- The object to return.

	Returns an object back to the pool so it can be reused later.

	:::caution
	This does not reset the object's state. State reset is handled by
	`initFn` the next time the object is acquired via `Get`.
	:::
]=]
function GoodPool:Return<T>(item: T)
	self.size += 1
	self.pool[self.size] = item
end

--[=[
	@within GoodPool
	@param list {T} -- The objects to return to the pool.

	Returns a list of objects back to the pool so they can be reused later.

	:::caution
	This does not reset the objects' state. State reset is handled by
	`initFn` the next time each object is acquired via `Get`.
	:::
]=]
function GoodPool:ReturnList<T>(list: { T })
	for _, element in list do
		self:Return(element)
	end
end

return GoodPool
