local Config = {}

-- [[ ADMIN & GROUP SETTINGS ]]
Config.OwnerId = 8978185974 -- Ganti dengan UserId owner (kamu)
Config.GroupId = 12345678 -- Ganti dengan GroupId komunitas
Config.MapPlaceId = 12345678 -- Ganti dengan PlaceId game utama

-- [[ DEVELOPER PRODUCTS (Troll, Jump, Checkpoint Skip) ]]
-- Ganti angka-angka ini dengan ID Developer Products yang valid di Creator Dashboard
Config.Products = {
	-- Trolls
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
	
	-- Jump Upgrades
	DoubleJump = 200002,
	TripleJump = 200003,
	QuadJump = 200004,
	PentaJump = 200005,
	
	-- Checkpoint
	SkipCheckpoint = 300001,
	SkipNextStage = 300002, -- Placeholder
	SkipToFinish = 300003 -- Placeholder
}

-- [[ GAMEPASS SETTINGS (Shop Items) ]]
Config.ShopGamepasses = {
	ItemSatu = 1111111, -- Placeholder
	ItemDua = 2222222, -- Placeholder
	ItemTiga = 3333333, -- Placeholder
	ItemEmpat = 4444444 -- Placeholder
}

-- Mapping nama product ke ID
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

-- [[ TOOLS SETTINGS ]]
-- Daftar tools yang akan diberikan. (Script akan mencari nama tools ini di ReplicatedStorage atau ServerStorage nantinya jika dibuat sistem tools beneran)
Config.Tools = {
	ItemSatu = "Speed Coil",
	ItemDua = "Gravity Coil",
	ItemTiga = "Rainbow Coil",
	ItemEmpat = "God Sword"
}

return Config
