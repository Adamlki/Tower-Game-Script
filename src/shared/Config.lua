local Config = {}

-- [[ ADMIN & GROUP SETTINGS ]]
Config.OwnerId = 8978185974 -- Ganti dengan UserId owner (kamu)
Config.GroupId = 12345678 -- Ganti dengan GroupId komunitas
Config.MapPlaceId = 12345678 -- Ganti dengan PlaceId game utama

-- [[ CENTRALIZED ASSETS (SOUNDS & IMAGES) ]]
Config.Assets = {
	Sounds = {
		UIHover = "rbxassetid://6895079853",
		UIClick = "rbxassetid://6895079853",
		CheckpointSaved = "rbxassetid://97969485348089",
		TowerFinished = "rbxassetid://115051157912492",
		Jumpscare = "rbxassetid://139162107746216"
	},
	Images = {
		Jumpscare = "rbxthumb://type=Asset&id=1308665113&w=420&h=420"
	}
}

-- [[ UFO SETTINGS ]]
Config.UfoSettings = {
	UFO1 = {
		DropPosition = Vector3.new(22.506, 69.353, 591),
		LiftingTime = 2,
		MovingTime = 3,
		ReturnTime = 3,
		AnimationId = "rbxassetid://112089880074848",
	},
	UFO2 = {
		DropPosition = Vector3.new(56.856, 138.359, 729.014),
		LiftingTime = 2,
		MovingTime = 3,
		ReturnTime = 3,
		AnimationId = "rbxassetid://112089880074848",
	},
	UFO3 = {
		DropPosition = Vector3.new(14.856, 158.664, 784.3),
		LiftingTime = 2,
		MovingTime = 3,
		ReturnTime = 3,
		AnimationId = "rbxassetid://112089880074848",
	},
}

-- [[ DEVELOPER PRODUCTS (Troll, Jump, Checkpoint Skip) ]]
Config.Products = {
	Kill = 100001,
	Fling = 100002,
	Kick = 100003,
	SlowPlayer = 100004,
	Earthquake = 100005,
	Jumpscare = 100006,
	Freeze = 100007,
	SetFire = 100008,
	KillAll = 100009,
	SlowAll = 100010,
	
	DoubleJump = 200002,
	TripleJump = 200003,
	QuadJump = 200004,
	PentaJump = 200005,
	
	SkipCheckpoint = 300001,
	SkipNextStage = 300002,
	SkipToFinish = 300003 
}

-- [[ GAMEPASS SETTINGS (Shop Items) ]]
Config.ShopGamepasses = {
	ItemSatu = 1111111,
	ItemDua = 2222222,
	ItemTiga = 3333333,
	ItemEmpat = 4444444
}

Config.TrollProducts = {
	Kill = Config.Products.Kill,
	Fling = Config.Products.Fling,
	Kick = Config.Products.Kick,
	Slow = Config.Products.SlowPlayer,
	Earthquake = Config.Products.Earthquake,
	Jumpscare = Config.Products.Jumpscare,
	Freeze = Config.Products.Freeze,
	SetFire = Config.Products.SetFire,
	KillAll = Config.Products.KillAll,
	SlowAll = Config.Products.SlowAll
}

Config.JumpProducts = {
	[2] = Config.Products.DoubleJump,
	[3] = Config.Products.TripleJump,
	[4] = Config.Products.QuadJump,
	[5] = Config.Products.PentaJump
}

Config.Tools = {
	ItemSatu = "Speed Coil",
	ItemDua = "Gravity Coil",
	ItemTiga = "Rainbow Coil",
	ItemEmpat = "God Sword"
}

return Config