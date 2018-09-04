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

extends Node

func _ready():
	rcos.spawn_module("host_clipboard_io_ports")
	rcos.spawn_module("host_sensors_io_ports")
	rcos.spawn_module("host_joysticks_io_ports")
	rcos.spawn_module("pointer_io_ports")
	rcos.spawn_module("ffa_widgets")
	rcos.spawn_module("remote_connector")
	rcos.spawn_module("io_ports_connector")
	rcos.spawn_module("widget_panels")
	rcos.spawn_module("virtual_gamepads")
	rcos.spawn_module("vrchost_ap_detector")
	queue_free()