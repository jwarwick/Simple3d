# Simple3d

Sample [Processing](http://processing.org) code to demonstrate how 3d authoring might work.

There are two concepts
* `Sources` - things that generate color values
* `Fixtures` - things that sum color values for display

The basic idea is that each `Fixture` sums the color inputs from every `Source`. A `Source` is free to change its location and/or color every frame. Several example `Source`s are provided.

This code relies on the [PeasyCam](http://mrfeinberg.com/peasycam/) library.

Several shortcuts are defined:
* `s` hides `Source` objects
* `f` hides `Fixture` objects
* `r` paints the `Source`s as spheres at with their range as the radius (which obscures all `Fixture`s they interact with)

