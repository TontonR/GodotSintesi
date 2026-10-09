class_name Skills
extends Items

enum EquipSlot {}

@export_group("Configuración de Equipamiento")
@export var slot: EquipSlot = EquipSlot
@export var armor_bonus: float = 0
@export var attack_bonus: float = 0
@export var attack_speed_bonus: float = 0
@export var crit_chance_bonus: float = 0
@export var crit_dmg_bonus: float = 0
@export var status_effect: String = ""
@export var special_effect: bool = false
@export var cooldown: float = 0
func use(target: Node = null) -> void:
	super.use(target)
	
	if target and target.has_method("equip"):
		target.equip(self)
		print("Equipando ", item_name, " en la ranura ", EquipSlot.keys()[slot])
