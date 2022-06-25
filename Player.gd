extends KinematicBody

var subtitle_fade_tween

func set_subtitle(text):
	$SubtitleView/Center/Subtitles.text = text
	$Camera/SubtitleUI/Timeout.stop()
	$Camera/SubtitleUI/Tween.stop_all()
	$Camera/SubtitleUI.opacity = 1.0
	var subtitle_time = len(text)/12.0
	$Camera/SubtitleUI/Timeout.start(subtitle_time)

func _on_SubtitleTimeout_timeout():
	var tween = $Camera/SubtitleUI/Tween
	tween.interpolate_property($Camera/SubtitleUI, "opacity", 1.0, 0.0, 1.0)
	tween.start()
