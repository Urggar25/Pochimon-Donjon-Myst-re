extends RefCounted
class_name CombatSystem

func build_turn_queue(team: Array[Dictionary], enemies: Array[Dictionary]) -> Array[Dictionary]:
	var queue: Array[Dictionary] = []
	for i in team.size():
		if team[i].get("hp", 0) > 0:
			queue.append({"side": "team", "index": i, "speed": team[i].get("speed", 5)})
	for i in enemies.size():
		if enemies[i].get("hp", 0) > 0:
			queue.append({"side": "enemy", "index": i, "speed": enemies[i].get("speed", 4)})
	queue.sort_custom(func(a, b): return a["speed"] > b["speed"])
	return queue

func apply_skill(user: Dictionary, target: Dictionary, skill_id: String) -> Dictionary:
	var skill := DataManager.get_skill(skill_id)
	if skill.is_empty():
		return {"log": "%s échoue." % user.get("name", "?")}

	var power: int = skill.get("power", 0)
	var scaling: float = skill.get("attack_scaling", 1.0)
	var damage := maxi(1, int(round(user.get("attack", 1) * scaling + power - target.get("defense", 0))))

	if skill.get("type", "damage") == "heal":
		var heal_value := abs(power) + user.get("attack", 1)
		target["hp"] = mini(target.get("max_hp", 1), target.get("hp", 0) + heal_value)
		return {"log": "%s lance %s et soigne %d PV." % [user.get("name", "?"), skill.get("name", "Compétence"), heal_value]}

	target["hp"] = maxi(0, target.get("hp", 1) - damage)
	return {"log": "%s utilise %s et inflige %d dégâts." % [user.get("name", "?"), skill.get("name", "Compétence"), damage]}

func enemy_choose_action(enemy: Dictionary, team: Array[Dictionary]) -> Dictionary:
	var alive_targets: Array[int] = []
	for i in team.size():
		if team[i].get("hp", 0) > 0:
			alive_targets.append(i)
	if alive_targets.is_empty():
		return {}
	var target_index: int = alive_targets.pick_random()
	var skill_id := enemy.get("skills", ["strike"])[0]
	return {"skill": skill_id, "target": target_index}
