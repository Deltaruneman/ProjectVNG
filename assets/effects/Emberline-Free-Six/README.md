# Emberline — Combat VFX / Free Six

Six editable 2D combat effects for **Godot 4.7.2, Compatibility renderer**.
Version 1.0.0 · Free sample · Windows verification.

Open the included project, replay the effects, and try the projectile → trail → impact example. Change the palette, size, speed, intensity, and background in the showcase. All six effects are usable in your own game.

## Included

| Scene in emberline/effects/ | Behavior | Default duration |
| --- | --- | --- |
| impact_spark.tscn | Ten short outward fragments and small embers | 0.65 s, one shot |
| impact_ring.tscn | Expanding, fading shockwave | 0.85 s, one shot |
| projectile_orb.tscn | Animated orb with a directional tail, facing local +X | Continuous |
| projectile_trail.tscn | World-space ribbon behind a moving emitter | Continuous; 0.32 s trail memory |
| slash_arc.tscn | A tapered sweeping crescent | 0.60 s, one shot |
| area_burst.tscn | A ground ring and rising energy sparks | 0.95 s, one shot |

Three demo palettes are settings for these six effects, not additional assets. The package contains GDScript, a canvas shader, reusable scenes, an interactive showcase, this guide, a Korean quick start, provenance, and the MIT license. These are procedural Godot effects; rendered PNG sprite sheets, sound, enemy AI, collision detection, and a complete combat system are not included.

## Try the sample

1. Extract the ZIP into a new folder.
2. In Godot **4.7.2**, choose **Import**, select **project.godot**, and open it.
3. Press **F6** with **emberline/demo/showcase.tscn** open, or **F5** to run the project.
4. Click Replay or press **1–6**. Click **Fire** or press **Space** for the travel/impact example.
5. Try the three palettes and sliders. **Light / Dark** changes the six preview cards and applies the matching contrast setting; the combat panel stays dark.

The showcase automatically replays the six previews. Its Size slider is limited to fit the cards; an effect's effect_scale can be set independently in your game. You need Godot to run the source project. No addon, API key, paid dependency, or network connection is needed while it runs.

## Put an effect in your game

Copy the **entire emberline folder** into your project's root, so its path is **res://emberline/**. Do not replace your own project.godot. Keep the folder name and internal paths. The demo subfolder is optional for game builds; keep all of effects.

Instance a scene in the editor and run your game, or create it from code:

~~~gdscript
const HitSpark = preload("res://emberline/effects/impact_spark.tscn")

func show_hit(world_position: Vector2) -> void:
    var fx = HitSpark.instantiate()
    fx.tint = Color("#ff8f47")
    fx.accent = Color("#ffe7a3")
    fx.effect_scale = 0.8
    fx.playback_speed = 1.2
    get_tree().current_scene.add_child(fx)
    fx.global_position = world_position
~~~

Effects autoplay by default. One-shot scenes emit **finished**, hide, and free themselves. To pool a node, set **free_on_finish = false** before it finishes and call **play()** whenever it is needed. To start manually, set **autoplay = false** before adding it, then call play().

## Settings

| Property / method | Use |
| --- | --- |
| tint, accent | Main and secondary colors; tint alpha controls visibility |
| effect_scale | Visual size, including trail width; positive values |
| playback_speed | Local effect time multiplier; positive values |
| intensity | 0 hides the effect; 1 is the default; up to 2 brightens it |
| light_surface | Enable for pale backgrounds to use a darker, readable core |
| rotation | Forward direction is local +X; use a direction vector's angle |
| duration | One-shot lifetime in effect time; positive seconds |
| trail_width, trail_lifetime | Ribbon width and sample lifetime; positive values |
| play() | Restart the effect, clearing old trail samples |
| stop() | Stop emission and fade out, then finish/free |
| stop(false) | Finish immediately |
| finished | Signal emitted at completion |

Settings update during playback. **set_preview_progress(0.0…1.0)** pauses a still frame for inspection; call play() to return to normal playback. A looping effect does not stop on its own. Its shader uses continuous time, avoiding a forced reset on each duration.

The origin of an impact or orb is its center. The origin of area_burst is the ground contact. Rotation and effect_scale preserve these anchors. Move the orb with your own game logic and set **rotation = velocity.angle()** to face its travel direction.

## A trail that survives its projectile

Add the trail to the same stable world parent as the projectile, rather than as a child that is destroyed with it. Update the trail's global_position after moving the projectile each frame. On impact, call **trail.stop()**, spawn the impact at the collision position, and free the projectile. The trail's old samples remain behind and fade automatically.

The included **emberline/demo/showcase.gd** demonstrates this sequence with a fixed target and a timed arrival. Connect the same spawn/stop pattern to your own collision event. The demo does not detect collisions for your game.

Use effect_scale and trail_width to change ribbon width. Trail samples are stored in world space, so changing an ancestor's transform does not drag previous samples along with it. Avoid reparenting an active trail between unrelated CanvasLayers/cameras.

## Verified scope

Godot **4.7.2 stable**, **Compatibility / OpenGL 3.3**, Windows, AMD Radeon(TM) Graphics. The release was checked for clean import, all six lifecycles, settings, mouse/keyboard input, anchor positions, and 100 spawn/finish cycles per effect with no accumulated nodes. Dark/light backgrounds, three palettes, multiple sizes, rotation, and a six-second animation were visually reviewed.

Other Godot versions, Forward+/Mobile renderers, web exports, mobile devices, and other operating systems have not been verified. No performance target is promised.

## License and provenance

The included source and documentation use the **MIT license** in LICENSE.txt. You may use them in free or commercial games, modify them, and redistribute the source with the required notice. This permissive sample also allows source redistribution; no exclusive rights are promised. Keep the license with redistributed substantial source or in your game's third-party notices.

The code, procedural visual design, and documentation were produced with AI assistance. See PROVENANCE.md for the exact scope. No third-party textures, sounds, or competitor source files are included.
