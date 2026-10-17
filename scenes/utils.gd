class_name Utils

static func clamp_angle(angle: float, from: float, to: float) -> float:
	var width := fposmod(to - from, TAU)
	var offset := fposmod(angle - from, TAU)

	if offset <= width:
		return wrapf(angle, -PI, PI)

	if offset < (width + TAU) * 0.5:
		return wrapf(to, -PI, PI)
	return wrapf(from, -PI, PI)
