extends Node

signal randomize
func emit_randomize():
	emit_signal('randomize')

signal mask_mode
func emit_mask_mode():
	emit_signal('mask_mode')
	
signal base_mode
func emit_base_mode():
	emit_signal('base_mode')
