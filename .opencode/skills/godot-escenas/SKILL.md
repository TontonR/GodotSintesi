---
name: godot-escenas
description: Use ONLY when editing or creating Godot scene (.tscn) or resource (.tres) files in this project. Covers file format, node/uid wiring, and the open-editor reserialization trap.
---

# Godot 4 scenes and resources (.tscn / .tres)

## Format

- Header `[gd_scene load_steps=N format=3 uid="uid://..."]`; resource strings are quoted.
- `[ext_resource type="Script" path="res://... " id="1_abcd"]` — the `id` is what is referenced later as `ExtResource("1_abcd")`.
- Sub-resources: `[sub_resource type="RectangleShape2D" id="RectangleShape2D_x"]`.
- Nodes: `[node name="X" type="Node2D" parent="."]` (`parent=".."` for the grandparent, `index="N"` when siblings repeat).
- Node order = real child order. A node with no `parent` is the root.

## Rules

- Never delete an `ext_resource`/`sub_resource` that is still in use, and never leave an orphan `ExtResource("id")`.
- If you add a script to a node, add its `[ext_resource]` and `script = ExtResource("...")`.
- Keep `unique_id=` and `node_paths=PackedStringArray(...)` on nodes that have them; deleting them breaks signal connections.
- Double quotes on every value; no comments except `##`.
- Add 1 to `load_steps` when adding resources and subtract when removing (or leave it: Godot recalculates it on save).

## Open-editor trap

The Godot editor is usually **open**. After any `git checkout/reset/stash` it rewrites the open scenes (adds `unique_id`, reorders, changes `node_paths`). If `git status` shows a scene you did not touch: it is the editor, revert it with `git checkout -- <scene>` only after closing that scene in the editor.

## Validation

Never run `godot --headless --check-only` or tests unless the user explicitly asks.
