extends Control


var inv_data = {"Wire": 1}





# These below functions are there to let all the entirety of the toolbox 
# be a drop of point and deletion point for items
func can_drop_data(_pos, data):
	# Check if we can drop an item in this slot
	return true
	# Whatever you are dragging you are allowed to drop in in the inventory
	

func drop_data(_pos, data):
	#What happens when we drop an item here
	if data["origin_panel"] == "CircuitSheet":
			#remove the original
			data["origin_node"]._Clear_tile()
	return true
