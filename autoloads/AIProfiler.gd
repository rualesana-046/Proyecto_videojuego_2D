extends Node

var traits: Dictionary = {
	"nostalgia": 0,
	"curiosity": 0,
	"pragmatism": 0
}


func add_points(trait_name: String, amount: int) -> void:
	if traits.has(trait_name):
		traits[trait_name] = int(traits[trait_name]) + amount
	else:
		push_warning("Unknown trait in AIProfiler: " + trait_name)


func get_dominant_profile() -> String:
	var dominant_trait: String = "nostalgia"
	var max_score: int = -1
	var is_tie: bool = false

	for trait_key: Variant in traits.keys():
		var key_name: String = str(trait_key)
		var score: int = int(traits[key_name])

		if score > max_score:
			max_score = score
			dominant_trait = key_name
			is_tie = false
		elif score == max_score:
			is_tie = true

	if is_tie:
		return "nostalgia"

	return dominant_trait
