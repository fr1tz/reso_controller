# Copyright © 2017, 2018 Michael Goldener <mg@wasted.ch>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

extends Panel

const ORIENTATION_N = 0
const ORIENTATION_E = 1
const ORIENTATION_S = 2
const ORIENTATION_W = 3

var mWidgetHostApi = null
var mWidget = null
var mWidgetName = -1
var mWidgetOrientation = ORIENTATION_N
var mWidgetProductId = ""
var mWidgetConfigString = ""

onready var mWidgetFrame = get_node("widget_frame")

func _ready():
	connect("resized", self, "_resized")

func _resized():
	var pos = Vector2(0, 0)
	var size = get_size()
	var rot
	var rot_deg
	if mWidgetOrientation == ORIENTATION_E:
		rot = PI+PI/2
		rot_deg = 270
		pos = Vector2(size.x, 0)
		size = Vector2(size.y, size.x)
	elif mWidgetOrientation == ORIENTATION_S:
		rot = PI
		rot_deg = 180
		pos = Vector2(size.x, size.y)
	elif mWidgetOrientation == ORIENTATION_W:
		rot = PI/2
		rot_deg = 90
		pos = Vector2(0, size.y)
		size = Vector2(size.y, size.x)
	else:
		rot = 0
		rot_deg = 0
		pos = Vector2(0, 0)
	mWidgetFrame.set_rotation_deg(rot_deg)
	mWidgetFrame.set_pos(pos)
	mWidgetFrame.set_size(size)

func init(widget_host_api, widget_name, widget_product_id = "", widget_orientation = ORIENTATION_N, widget_config_string = ""):
	mWidgetHostApi = widget_host_api
	mWidgetName = widget_name
	mWidgetProductId = widget_product_id
	mWidgetOrientation = widget_orientation
	mWidgetConfigString = widget_config_string
	set_name(mWidgetName+"_container")
	get_node("widget_product_id_label").set_text(mWidgetProductId)

func add_widget(widget, io_ports_path_prefix):
	if widget == null:
		return
	mWidget = widget
	var config_canvas = null
	var config_canvas_size = Vector2(40, 40)
	var main_canvas_placeholder = mWidget.get_node("main_canvas")
	#main_canvas_size.x = main_canvas_placeholder.get_margin(MARGIN_RIGHT)
	#main_canvas_size.y = main_canvas_placeholder.get_margin(MARGIN_BOTTOM)
	#main_canvas_min_size = main_canvas_placeholder.get_custom_minimum_size()
	if mWidget.has_node("config_canvas"):
		var config_canvas_placeholder = mWidget.get_node("config_canvas")
		config_canvas_size.x = config_canvas_placeholder.get_margin(MARGIN_RIGHT)
		config_canvas_size.y = config_canvas_placeholder.get_margin(MARGIN_BOTTOM)
		config_canvas = rlib.instance_scene("res://rcos/lib/canvas.tscn")
		config_canvas_placeholder.replace_by(config_canvas)
		config_canvas_placeholder.free()
		config_canvas.resizable = false
		config_canvas.set_rect(Rect2(Vector2(0, 0), config_canvas_size))
		config_canvas.set_name("config_canvas")
	rlib.set_meta_recursive(mWidget, "io_ports_path_prefix", io_ports_path_prefix)
	rlib.set_meta_recursive(mWidget, "widget_host_api", mWidgetHostApi)
	rlib.set_meta_recursive(mWidget, "widget_root_node", mWidget)
	mWidgetFrame.add_child(mWidget)
	if mWidgetConfigString != "" && mWidget.has_method("load_widget_config_string"):
		mWidget.load_widget_config_string(mWidgetConfigString)
	if config_canvas:
		config_canvas.set_rect(Rect2(Vector2(0, 0), config_canvas.get_child(0).get_size()))
	var size = get_size()
	mWidgetFrame.set_size(size)
	get_node("widget_product_id_label").set_hidden(true)

func get_widget():
	return mWidget

func get_widget_name():
	return mWidgetName

func get_widget_product_id():
	return mWidgetProductId

func get_widget_config_string():
	if mWidget != null && mWidget.has_method("create_widget_config_string"):
		mWidgetConfigString = mWidget.create_widget_config_string()
	return mWidgetConfigString

func get_widget_orientation():
	return mWidgetOrientation

func get_widget_frame():
	return mWidgetFrame

func get_config_canvas():
	return mWidget.get_node("config_canvas")

func get_widget_rotation():
	return mWidgetFrame.get_rotation()

func rotate():
	mWidgetOrientation += 1
	if mWidgetOrientation == 4:
		mWidgetOrientation = 0
	_resized()

func set_widget_margin(margin):
	return
#	var canvas = get_widget_canvas()
#	if canvas == null: 
#		return
#	canvas.resize(get_size() - Vector2(margin*2, margin*2))
