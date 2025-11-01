extends AnimationTree

var bullet : bool = false
var shockwave : bool = false
var laser : bool = false
var hit : bool = false

func shoot_bullet():
	bullet = true

func stop_bullet():
	bullet = false

func shoot_shockwave():
	shockwave = true

func stop_shockwave():
	shockwave = false

func shoot_laser():
	laser = true

func stop_laser():
	laser = false

func trigger_hit():
	hit = true

func stop_hit():
	hit = false
