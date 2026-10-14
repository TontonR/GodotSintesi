---
name: godot-escenas
description: Use ONLY when editing or creating Godot scene (.tscn) or resource (.tres) files in this project. Covers file format, node/uid wiring, and the open-editor reserialization trap.
---

# Escenas y recursos de Godot 4 (.tscn / .tres)

## Formato

- Cabecera `[gd_scene load_steps=N format=3 uid="uid://..."]`; las cadenas de recursos llevan comillas.
- `[ext_resource type="Script" path="res://... " id="1_abcd"]` — el `id` es lo que se referencia después como `ExtResource("1_abcd")`.
- Sub-recursos: `[sub_resource type="RectangleShape2D" id="RectangleShape2D_x"]`.
- Nodos: `[node name="X" type="Node2D" parent="."]` (`parent=".."` para el abuelo, `index="N"` si hay hermanos repetidos).
- Orden de nodos = orden de hijos real. Un nodo sin `parent` es la raíz.

## Reglas

- Nunca borres un `ext_resource`/`sub_resource` que aún se use, ni dejes `ExtResource("id")` huérfano.
- Si añades un script a un nodo, añade su `[ext_resource]` y `script = ExtResource("...")`.
- Conserva `unique_id=` y `node_paths=PackedStringArray(...)` de los nodos que los traen; borrarlos rompe conexiones de señales.
- Comillas dobles en todos los valores; sin comentarios salvo `##`.
- Añade 1 a `load_steps` al añadir recursos y restálos al quitarlos (o déjalo: Godot lo recalcula al guardar).

## Trampa del editor abierto

El editor de Godot suele estar **abierto**. Tras cualquier `git checkout/reset/stash`, reescribe las escenas abiertas (añade `unique_id`, reordena, cambia `node_paths`). Si `git status` muestra una escena que no tocaste: es el editor, revierte con `git checkout -- <escena>` solo tras cerrar esa escena en el editor.

## Validación

Nunca ejecutes `godot --headless --check-only` ni tests salvo petición explícita del usuario.
