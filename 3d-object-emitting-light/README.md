# 3d Obejct Emitting Light

By default, if you create a 3d object in Godot and put a light source inside of it, the outside of the object won't be affected by it, becoming completely black.

This prevents users from creating moving objects that emit light AND glow on the outside.
You can create moving unshaded objcts that emit light but don't glow, objects that emit light and glow but don't move (using baked lights) or moving objects that glow but don't emit light.

But you can create an object that moves and glows and then put a light source inside of it but in another layer, and then make the light not affect the layer of the object.
