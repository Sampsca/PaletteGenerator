# PaletteGenerator
Generate and mix palettes for Infinity Engine BAMs.

This project is inspired by [Erephine](http://www.shsforums.net/user/2954-erephine/)’s [Palette Generator V1](http://www.shsforums.net/files/file/552-developer-files-v2/) and [Palette Generator V2](http://www.shsforums.net/files/file/819-1ppv3-extended-palette-entries/).  While this project is visually a bit of a cross between the two, the underlying code is completely different:  I would estimate a code similarity of ~1%.  This iteration of the Palette Generator is considerably more dynamic than its predecessors, and the UI is designed to be significantly more ergonomic and responsive (have fun with the mouse scroll wheel).

Note that when generating the mixed gradients from the seven primary ones, this Palette Generator produces slightly different results than the palette in the vanilla paletted BAMs using those special gradients as reference.  The same appears to be true for its predecessors.  This may indicate that the mixing algorithm used by this Palette Generator varies slightly from the one used by the original developers, or it may simply indicate that the original palette used for “paletted BAMs” was not created in such a structured way.  In either case, the difference is so small as to be visually indistinguishable.
