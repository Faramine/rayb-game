extends AnimationTree

func idle():
	self["parameters/conditions/bullet_end"] = true
	self["parameters/conditions/laser_end"] = true
	self["parameters/conditions/sw_end"] = true
	self["parameters/conditions/take_hit"] = false
	self["parameters/conditions/laser_shoot"] = false
	self["parameters/conditions/laser"] = false
	self["parameters/conditions/bullet"] = false
	self["parameters/conditions/sw_start"] = false

func bullet():
	self["parameters/conditions/bullet"] = true
	self["parameters/conditions/bullet_end"] = false
	
func laser():
	self["parameters/conditions/laser"] = true
	self["parameters/conditions/laser_shoot"] = false

func laser_shoot():
	self["parameters/conditions/laser_shoot"] = true
	self["parameters/conditions/laser_end"] = false

func shockwave():
	self["parameters/conditions/sw_start"] = true
	self["parameters/conditions/sw_end"] = false

func take_hit():
	self["parameters/conditions/take_hit"] = true
