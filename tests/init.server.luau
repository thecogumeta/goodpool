local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Specium = require(ReplicatedStorage.DevPackages.Specium)
local GoodPool = require(ReplicatedStorage.GoodPool)

local suite = Specium.suite("GoodPool", function(ctx)
	ctx.describe("GoodPool.new", function(ctx)
		ctx.it("should create a pool", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			Specium.expect(pool).never.toBeNil()
		end)

		ctx.it("should get an object", function()
			local pool = GoodPool.new(function()
				return { value = 10 }
			end, function(obj)
				obj.value = 10
			end)

			local obj = pool:Get()

			Specium.expect(obj).never.toBeNil()
			Specium.expect(obj.value).withMessage("value").toBe(10)
		end)

		ctx.it("should reset object on Get via initFn", function()
			local pool = GoodPool.new(function()
				return { value = 10 }
			end, function(obj)
				obj.value = 10
			end)

			local obj = pool:Get()
			obj.value = 99
			pool:Return(obj)

			local obj2 = pool:Get()
			Specium.expect(obj2.value).withMessage("value after reset").toBe(10)
		end)

		ctx.it("should reuse returned objects", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			local obj = pool:Get()
			pool:Return(obj)

			local obj2 = pool:Get()
			Specium.expect(obj2).withMessage("should be same object").toBe(obj)
		end)

		ctx.it("should call destroyFn on Clean", function()
			local destroyed = 0

			local pool = GoodPool.new(function()
				return {}
			end, function() end, function()
				destroyed += 1
			end)

			pool:Preload(3)
			pool:Clean()

			Specium.expect(destroyed).withMessage("destroyed count").toBe(3)
		end)

		ctx.it("should reset size after Clean", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(5)
			pool:Clean()

			Specium.expect(pool:GetSize()).withMessage("size after clean").toBe(0)
		end)
	end)

	ctx.describe("Preload", function(ctx)
		ctx.it("should preload objects into the pool", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(5)

			Specium.expect(pool:GetSize()).withMessage("size after preload").toBe(5)
		end)

		ctx.it("should do nothing if amount is <= 0", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(0)
			pool:Preload(-1)

			Specium.expect(pool:GetSize()).withMessage("size").toBe(0)
		end)
	end)

	ctx.describe("GetSize", function(ctx)
		ctx.it("should return 0 initially", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			Specium.expect(pool:GetSize()).withMessage("initial size").toBe(0)
		end)

		ctx.it("should increase after Return", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			local obj = pool:Get()
			pool:Return(obj)

			Specium.expect(pool:GetSize()).withMessage("size after return").toBe(1)
		end)

		ctx.it("should decrease after Get", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(3)
			pool:Get()

			Specium.expect(pool:GetSize()).withMessage("size after get").toBe(2)
		end)
	end)

	ctx.describe("IsEmpty", function(ctx)
		ctx.it("should return true when pool is empty", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			Specium.expect(pool:IsEmpty()).withMessage("should be empty").toBe(true)
		end)

		ctx.it("should return false when pool has objects", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(1)

			Specium.expect(pool:IsEmpty()).withMessage("should not be empty").toBe(false)
		end)

		ctx.it("should return true after Clean", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(3)
			pool:Clean()

			Specium.expect(pool:IsEmpty()).withMessage("should be empty after clean").toBe(true)
		end)
	end)

	ctx.describe("ReturnList", function(ctx)
		ctx.it("should return multiple objects at once", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			local a = pool:Get()
			local b = pool:Get()
			local c = pool:Get()

			pool:ReturnList({ a, b, c })

			Specium.expect(pool:GetSize()).withMessage("size after ReturnList").toBe(3)
		end)

		ctx.it("should make objects reusable after ReturnList", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			local a = pool:Get()
			local b = pool:Get()

			pool:ReturnList({ a, b })

			local obj1 = pool:Get()
			local obj2 = pool:Get()

			Specium.expect(obj1).never.toBeNil()
			Specium.expect(obj2).never.toBeNil()
		end)
	end)

	ctx.describe("Resize", function(ctx)
		ctx.it("should grow the pool", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Resize(5)

			Specium.expect(pool:GetSize()).withMessage("size after resize up").toBe(5)
		end)

		ctx.it("should shrink the pool", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(5)
			pool:Resize(2)

			Specium.expect(pool:GetSize()).withMessage("size after resize down").toBe(2)
		end)

		ctx.it("should do nothing if size is the same", function()
			local destroyed = 0

			local pool = GoodPool.new(function()
				return {}
			end, function() end, function()
				destroyed += 1
			end)

			pool:Preload(3)
			pool:Resize(3)

			Specium.expect(pool:GetSize()).withMessage("size unchanged").toBe(3)
			Specium.expect(destroyed).withMessage("nothing destroyed").toBe(0)
		end)

		ctx.it("should call destroyFn when shrinking", function()
			local destroyed = 0

			local pool = GoodPool.new(function()
				return {}
			end, function() end, function()
				destroyed += 1
			end)

			pool:Preload(5)
			pool:Resize(2)

			Specium.expect(destroyed).withMessage("destroyed count").toBe(3)
		end)
	end)

	ctx.describe("Clean with amount", function(ctx)
		ctx.it("should partially clean the pool", function()
			local pool = GoodPool.new(function()
				return {}
			end, function() end)

			pool:Preload(5)
			pool:Clean(2)

			Specium.expect(pool:GetSize()).withMessage("size after partial clean").toBe(3)
		end)

		ctx.it("should destroy only the given amount", function()
			local destroyed = 0

			local pool = GoodPool.new(function()
				return {}
			end, function() end, function()
				destroyed += 1
			end)

			pool:Preload(5)
			pool:Clean(3)

			Specium.expect(destroyed).withMessage("destroyed count").toBe(3)
		end)
	end)

	ctx.describe("GoodPool.forInstance", function(ctx)
		ctx.it("should return a pool and a template", function()
			local pool, template = GoodPool.forInstance("Part", function() end)

			Specium.expect(pool).never.toBeNil()
			Specium.expect(template).never.toBeNil()
		end)

		ctx.it("should clone the template on Get", function()
			local pool, template = GoodPool.forInstance("Part", function() end)

			local part = pool:Get()

			Specium.expect(part).never.toBe(template)
			Specium.expect(part.ClassName).withMessage("class name").toBe("Part")
		end)

		ctx.it("should call setupFn on Get", function()
			local called = false

			local pool = GoodPool.forInstance("Part", function()
				called = true
			end)

			pool:Get()

			Specium.expect(called).withMessage("setupFn called").toBe(true)
		end)

		ctx.it("should return template when passing an Instance", function()
			local template = Instance.new("Part")
			local _, returnedTemplate = GoodPool.forInstance(template, function() end)

			Specium.expect(returnedTemplate).withMessage("template").toBe(template)
		end)

		ctx.it("should destroy instances on Clean", function()
			local pool = GoodPool.forInstance("Part", function() end)

			pool:Preload(2)
			pool:Clean()

			Specium.expect(pool:GetSize()).withMessage("size after clean").toBe(0)
		end)
	end)
end)

local output = Specium.run(suite)

print(output)
