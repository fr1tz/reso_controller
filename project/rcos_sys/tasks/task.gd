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

var properties = {}

func _init():
	add_user_signal("properties_changed")

func get_id():
	return int(get_name())

func get_parent_task_id():
	var parent_task = get_parent()
	if parent_task == rcos_tasks:
		return 0
	return parent_task.get_id()

func change_properties(new_properties):
	for key in new_properties.keys():
		properties[key] = new_properties[key]
	emit_signal("properties_changed", new_properties)
	rcos_tasks.emit_signal("task_changed", self)