local ts = require "typesystem"

local animal = {
	_ctor = function(self, name, a)
		self.name = name
		self.a = a or false
		self.data = {1, 2, 3, 4}

		print('_ctor, name=', name)
	end,

	_dtor = function(self)
		print("_dtor", self, ' name=', self.name, ' a=', self.a, 'data[3]=', self.data[3])
	end,

	update = function(self)
		self.a = 1000
		self.data[3] = 3000
	end,

	name = 'animal',
	a = false,
}

local metaAnimal = {__index=animal}

local dog = {
	_ctor = function(self, name, a)
		setmetatable(self, metaAnimal)

		self.super = animal

		self.super._ctor(self, name, a)
	end,

	_dtor = function(self)
		self.super._dtor(self)
	end,

	f = ts.dog,
	weak_g = ts.dog,
	
	--[备注]
	--特别地，要定义 table 类型的值，则该 table 的 metatable 必须是 typesystem 内部的 typeclass
}

-- ts.animal(animal)
ts.dog(dog)

local dogs = {}
for i = 1, 3 do
	table.insert(dogs, ts.dog:new('dog'..i, 100+i))
	--在外部是无法访问 dogs 中对象里的当前属性(得到的都是“原型”里的默认值),
	--如果需要访问，则必须在类型定义中提供 get 函数
end
for _, v in ipairs(dogs) do
	v:update()
	ts.delete(v)
end
dogs = nil

ts.collectgarbage()

local godDogs = {}
--其中3个对象是重用了上面创建的对象
for i = 1, 5 do
	table.insert(godDogs, ts.dog:new('godDog'..i, 100+i, 200+i))
end
for _, v in ipairs(godDogs) do
	ts.delete(v)
end

ts.collectgarbage()

--在修复缓存对象中 _mark 标志未重置之前存在BUG：
--有执行多一次和没执行多一次垃圾收集结果不一样！——产生这种情况的原因是上面重用了缓存的对象
-- ts.collectgarbage()
