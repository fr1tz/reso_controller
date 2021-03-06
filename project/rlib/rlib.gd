# Copyright © 2017, 2018 Michael Goldener <mg@wasted.ch>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node

#-------------------------------------------------------------------------------
# Function Descriptions
#-------------------------------------------------------------------------------

func encode_uint16(val):
	return _encode_uint16(val)

func instance_scene(scene_path):
	return _instance_scene(scene_path)

func join_array(array, spacer = ""):
	return _join_array(array, spacer)

func join_array_tree(array, field_separator_list, escape_fields = false,  depth = 0):
	return _join_array_tree(array, field_separator_list, escape_fields, depth)

func ws(char):
	# *** Returns whether char is whitespace
	return _ws(char)

func hd(string):
	# *** Return first word in string
	return _hd(string)

func tl(string): 
	# *** Return remains of string starting with 2nd word
	return _tl(string)

func extract_numbers(string):
	return _extract_numbers(string)

func base64_decode(input_string):
	return _base64_decode(input_string)

func find_files(dir_path, match_expr):
	return _find_files(dir_path, match_expr)

func set_meta_recursive(node, name, value):
	_set_meta_recursive(node, name, value)

#-------------------------------------------------------------------------------
# Function Implementations
#-------------------------------------------------------------------------------

func _encode_uint16(val):
	var bytes = RawArray()
	var b1 = (val & 0xFF00) >> 8
	var b2 = (val & 0x00FF)
	bytes.append(b1)
	bytes.append(b2)
	return bytes

func _instance_scene(scene_path):
	var packed_scene = load(scene_path)
	if packed_scene == null:
		print("instance_scene() Error loading ", scene_path)
		return null
	var scene_instance = packed_scene.instance()
	if scene_instance == null:
		print("instance_scene() Error instancing ", scene_path)
		return null
	return scene_instance

func _join_array(array, spacer = ""):
	var ret = ""
	for i in range(0, array.size()):
		ret = ret + str(array[i])
		if i < array.size()-1:
			ret = ret + spacer
	return ret

func _join_array_tree(array, fsl, ef = false, depth = 0):
	var s = ""
	var fs
	if depth < fsl.size():
		fs = fsl[depth]
	else:
		fs = fsl.back()
	for i in range(0, array.size()):
		var e = array[i]
		if typeof(e) == TYPE_ARRAY:
			s += join_array_tree(e, fsl, ef, depth+1)
		elif typeof(e) == TYPE_STRING:
			if ef:
				e = e.xml_escape()
			s += e
		else:
			continue
		if i < array.size()-1:
			s += fs
	return s

#
# Base64 encoding / decoding 
#
# Adapted from http://web.mit.edu/freebsd/head/contrib/wpa/src/utils/base64.c
#
# Original copyright notice:
#
#   /*
#    * Base64 encoding/decoding (RFC1341)
#    * Copyright (c) 2005-2011, Jouni Malinen <j@w1.fi>
#    *
#    * This software may be distributed under the terms of the BSD license.
#    * See README for more details.
#    */
#

const _base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

func _base64_decode(input_string):
	var base64_table = _base64_chars.to_ascii()
	var src = input_string.to_ascii()
	var len = src.size()
	var out = RawArray()
	var block = RawArray()
	var dtable = RawArray()
	var olen
	var pos
	var pad
	dtable.resize(256)
	for i in range(0, 256):
		dtable[i] = 0x80
	for i in range(0, base64_table.size()):
		dtable[base64_table[i]] = i
	dtable["=".to_ascii()[0]] = 0
	var count = 0
	for i in range(0, len):
		if dtable[src[i]] != 0x80:
			count += 1
	if count == 0 || count % 4 != 0:
		return RawArray([""])
	olen = count / 4 * 3
	out.resize(olen)
	block.resize(4)
	pos = 0
	pad = 0
	count = 0
	for i in range(0, len):
		var tmp = dtable[src[i]]
		if tmp == 0x80:
			continue
		if input_string[i] == "=":
			pad += 1
		block[count] = tmp
		count += 1
		if count == 4:
			out[pos] = (block[0] << 2) | (block[1] >> 4); pos += 1
			out[pos] = (block[1] << 4) | (block[2] >> 2); pos += 1
			out[pos] = (block[2] << 6) | block[3]; pos += 1
			count = 0
			if pad > 0:
				if pad == 1:
					pos -= 1
				elif pad == 2:
					pos -= 2
				else:
					# Invalid padding
					return null
				break
	return out

func _ws(char):
	if char == " " || char == "\t":
		return true
	return false

func _hd(string):
	if string == null || string.empty():
		return ""
	var len = string.length()
	var start = 0
	var find_start = true
	for i in range(0, len):
		var c = string[i]
		if find_start:
			if !rlib.ws(c):
				start = i
				find_start = false
		elif rlib.ws(c):
			return string.substr(start, i-start)
	if find_start == false:
		return string.right(start)
	return ""

func _tl(string): 
	if string == null || string.empty():
		return ""
	var len = string.length()
	var start = 0
	# Find beginning of first word
	if rlib.ws(string[start]):
		for i in range(start, len):
			var c = string[i]
			if i == len-1:
				return ""
			elif !rlib.ws(c):
				start = i
				break
	# Find end of first word
	for i in range(start, len):
		var c = string[i]
		if i == len-1:
			return ""
		elif rlib.ws(c):
			start = i
			break
	# Find beginning of second word
	for i in range(start, len):
		var c = string[i]
		if !rlib.ws(c):
			return string.right(i)
		elif i == len-1:
			return ""
	return ""

func _extract_numbers(string):
	var NUMBER_CHARS = "1234567890."
	var numbers = []
	var nbegin = -1
	var nend = -1
	var nfloat = false
	var len = string.length()
	for i in range(0, len):
		var c = string[i]
		var nchars = NUMBER_CHARS
		if nbegin == -1:
			nchars += "+-"
		if nchars.find(c) >= 0:
			if c == ".":
				nfloat = true
			if nbegin == -1:
				nbegin = i
				nend = i
			else:
				nend = i
		elif nbegin != -1 && nend != -1:
			var nstring = string.substr(nbegin, nend-nbegin+1)
			if nfloat:
				numbers.push_back(float(nstring))
			else:
				numbers.push_back(int(nstring))
			if c == "+" || c == "-":
				nbegin = i
			else:
				nbegin = -1
			nend = -1
			nfloat = false
	if nbegin != -1 && nend != -1:
		var nstring = string.substr(nbegin, nend-nbegin+1)
		if nfloat:
			numbers.push_back(float(nstring))
		else:
			numbers.push_back(int(nstring))
	return numbers

func _find_files(dir_path, match_expr):
	if !dir_path.ends_with("/"):
		dir_path += "/"
	var dir = Directory.new()
	if dir.open(dir_path) != OK:
		return []
	var files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var file_path = dir_path + file_name
		if dir.current_is_dir():
			var files2 = _find_files(file_path, match_expr)
			if !files2.empty():
				files += files2
		else:
			if file_name.match(match_expr):
				files.push_back(file_path)
		file_name = dir.get_next()
	return files

func _set_meta_recursive(node, name, value):
	node.set_meta(name, value)
	for c in node.get_children():
		_set_meta_recursive(c, name, value)
