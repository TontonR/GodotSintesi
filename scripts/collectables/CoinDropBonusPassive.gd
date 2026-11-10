class_name CoinDropBonusPassive
extends PassiveItems

@export_group("Loot")
## Extra chance (0-1) that an enemy drops a coin on death (0.05 = +5%).
@export_range(0.0, 1.0, 0.01) var extra_coin_chance: float = 0.05

## `EnemyBase` reads it when rolling loot: it adds this chance to the coin.
func get_coin_drop_bonus() -> float:
	return extra_coin_chance
