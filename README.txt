Admin Toolbox Mod v1.0
By Leslie E. Krause

Admin Toolbox provides a set of tools for basic manipulation of mapblocks, in addition to
chat commands for easily navigating by mapblocks and mapchunks.

The following non-craftable tools are available:

* Aikerum Pickaxe (toolbox:pick_aikerum)
  Display the boundaries of the current mapblock

* Emerald Pickaxe (toolbox:pick_emerald)
  Recalculate lighting and flowing-liquids within the current mapblock

* Ruby Pickax (toolbox:pick_ruby)
  Delete the current mapblock (this operation cannot be undone!)

The server administrator also has use of the following chat commands:

  /block
  Teleport to a specific mapblock by ID or position (positions are expressed as X,Y,Z)

* /node
  Teleport to a specific node by index within the current mapblock (indices range from 1 
  to 4096)

* /fpos
  Show the position and ID of the current mapblock.

* /pos
  Show the position and ID of the current mapchunk.

Note that current mapblock is determined by the position of the player's eyes, not the
base position of the player object, for simplicity.


Repository 
----------------------

Browse source code...
  https://bitbucket.org/sorcerykid/toolbox

Download archive...
  https://bitbucket.org/sorcerykid/toolbox/get/master.zip
  https://bitbucket.org/sorcerykid/toolbox/get/master.tar.gz

Compatability
----------------------

Minetest 0.4.14+ required

Installation
----------------------

  1) Unzip the archive into the mods directory of your game
  2) Rename the toolbox-master directory to "toolbox"

License of source code
----------------------------------------------------------

GNU Lesser General Public License v3 (LGPL-3.0)

Copyright (c) 2018-2021, Leslie E. Krause

This program is free software; you can redistribute it and/or modify it under the terms of
the GNU Lesser General Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

http://www.gnu.org/licenses/lgpl-2.1.html
