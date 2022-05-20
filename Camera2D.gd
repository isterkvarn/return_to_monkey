# Camera which is tightly clamped to some node which moves during the
# _process() function. Normally cameras do not seem to update their
# position when the node they are following moves in the _process()
# function--this camera will follow the movements of such a node
# exactly, provided that the drag margins are set to 0.

extends Camera2D


# copy pasted stuff from https://github.com/robrtsql/gamedev-projects/blob/master/stablejump/TightCamera.gd
# fixes the camera lagging behind
# found at https://www.reddit.com/r/godot/comments/7i9uma/slight_delay_on_2d_camera/
func _ready():
	set_process(true)

func _process(delta):
	align()
