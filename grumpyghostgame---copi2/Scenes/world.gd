extends Node2D

var wind_gust: Node2D
var reposition_timer: Timer

func _ready():
	print("_ready function called")
	
	# Get the reference to the existing WindGust node
	wind_gust = get_node("WindGust")
	if not wind_gust:
		print("Error: WindGust node not found!")
		return
	
	# Create and configure the timer
	reposition_timer = Timer.new()
	reposition_timer.set_wait_time(2.0)  # Reposition every 2 seconds
	reposition_timer.set_one_shot(false)  # Make it repeat
	reposition_timer.connect("timeout", Callable(self, "reposition_wind_gust"))
	add_child(reposition_timer)
	
	# Start the timer
	reposition_timer.start()
	print("Timer started")
	
	# Position the gust immediately
	reposition_wind_gust()

func reposition_wind_gust():
	if not wind_gust:
		print("Error: WindGust node not available!")
		return
	
	print("Repositioning wind gust")
	
	# Get the viewport size
	var viewport_rect = get_viewport_rect()
	
	# Generate random position within the viewport
	var random_x = randf_range(viewport_rect.position.x, viewport_rect.end.x)
	var random_y = randf_range(viewport_rect.position.y, viewport_rect.end.y)
	
	# Set the new position of the WindGust
	wind_gust.position = Vector2(200, 200)
	
	print("Wind gust repositioned to")
	
	# If you need to "reload" or reset the gust in some way, do it here
	# For example, if it has a custom method to reset its state:
	# wind_gust.reset()
