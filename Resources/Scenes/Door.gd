extends StaticBody

var players = []

func registerPlayer(p: Object) -> void:
	players.push_back(p)

func areAllPlayersReady() -> bool:
	for p in players:
		if !p.isReadyToExit():
			return false
	return true
