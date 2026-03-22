-- LazyHub - Game Detector

local GAMES = {
	[124622974349108] = "https://raw.githubusercontent.com/pettirossoo/LazyHub-Scripts/main/games/RollABrainrot.lua",
}

local url = GAMES[game.PlaceId]
if url then
	loadstring(game:HttpGet(url))()
else
	warn("LazyHub: Game not supported - PlaceId: " .. tostring(game.PlaceId))
end
