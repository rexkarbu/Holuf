class_name DialogueChoice
extends Resource

## Data untuk satu pilihan dialog.
## action: aksi opsional yang dijalankan saat pilihan ini dipilih (misal: "start_quest")
## action_data: parameter untuk aksi tersebut (misal: "whispers_beneath_forest")

@export var text: String = ""
@export var next_id: String = ""
@export var action: String = ""
@export var action_data: String = ""
