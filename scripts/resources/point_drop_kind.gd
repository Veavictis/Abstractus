class_name PointDropKind
extends Resource
## One kind of point dot an enemy can drop. Each kind is a .tres file in resources/drops/.

@export var points := 1
## Relative drop weight. Within one enemy's drop table, 75 / 20 / 5 means 75%, 20%, 5%.
@export var weight := 1.0
@export_file("*.png") var art_path: String
## Color of the placeholder dot shown until `art_path` exists.
@export var placeholder_color := Color.WHITE
