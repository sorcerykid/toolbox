--------------------------------------------------------
-- Minetest :: Admin Toolbox Mod (toolbox)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2016-2020, Leslie E. Krause
--------------------------------------------------------

local function to_signed( val )
	return val < 2048 and val or val - 2 * 2048
end

local function decode_block_pos( idx )
	local x = to_signed( idx % 4096 )
	idx = math.floor( ( idx - x ) / 4096 )
	local y = to_signed( idx % 4096 )
	idx = math.floor( ( idx - y ) / 4096 )
	local z = to_signed( idx % 4096 )
	return { x = x, y = y, z = z }
end

local function encode_block_pos( fpos )
	return fpos.x + fpos.y * 4096 + fpos.z * 16777216
end

local function decode_node_pos( node_idx, fpos )
        local npos = { }

        node_idx = node_idx - 1  -- correct for one-based indexing of node_list

        npos.x = ( node_idx % 16 ) + fpos.x * 16
        node_idx = math.floor( node_idx / 16 )
        npos.y = ( node_idx % 16 ) + fpos.y * 16
        node_idx = math.floor( node_idx / 16 )
        npos.z = ( node_idx % 16 ) + fpos.z * 16

        return npos
end

local function encode_chunk_pos( pos )
	return pos.z * 773 * 773 + pos.y * 773 + pos.x
end

local function get_mapblock_bounds( fpos )
	return vector.apply( fpos, function( c ) return c * 16 end ), vector.apply( fpos, function( c ) return c * 16 + 15 end )
end

local function get_mapblock_center( fpos )
	return vector.apply( fpos, function( c ) return c * 16 + 8 end )
end

local function get_mapblock_from_npos( npos )
	return vector.apply( npos, function( c ) return math.floor( c / 16 ) end )
end

local function get_mapchunk_from_npos( npos )
	return vector.apply( npos, function( c ) return math.floor( ( math.floor( c / 16 ) + 2 ) / 5 ) + 386 end )
end

local function from_npos( npos )
	return vector.offset_y( npos, -1.5 )
end

local function to_npos( ppos )
 	return vector.round( vector.offset_y( ppos, 1.5 ) )
end

minetest.register_chatcommand( "block", {
	description = "Teleport to a specific mapblock by ID or position.",
	privs = { server = true },
	func = function( name, param )
		local player = minetest.get_player_by_name( name )
		local fpos

		if string.find( param, "^-?[0-9]+$" ) then
			local index = tonumber( param ) 
			fpos = decode_block_pos( index )
		elseif string.find( param, "^-?[0-9]+,%s*-?[0-9]+,%s*-?[0-9]+" ) then
			local x, y, z = string.match( param, "^(-?%d+),%s*(-?%d+),%s*(-?%d+)$" )
			fpos = { x = tonumber( x ), y = tonumber( y ), z = tonumber( z ) }
		end

		if fpos then
			local npos = get_mapblock_center( fpos )

			player:setpos( from_npos( npos ) )
			minetest.add_entity( npos, "toolbox:mapblock" )
			return true, "Mapblock " .. minetest.pos_to_string( fpos ) .. " displayed."
		else
			return false, "Invalid mapblock specified."
		end
	end,
} )

minetest.register_chatcommand( "node", {
	description = "Teleport to a specific node by index within the current mapblock.",
	privs = { server = true },
	func = function( name, param )
		local player = minetest.get_player_by_name( name )
		local fpos, npos

		if string.find( param, "^[0-9]+$" ) then
			local node_idx = tonumber( param )
			fpos = get_mapblock_from_npos( to_npos( player:get_pos( ) ) )
			npos = decode_node_pos( node_idx, fpos )
		end

		if fpos and npos then
			local npos2 = get_mapblock_center( fpos )

			player:setpos( from_npos( npos ) )
			minetest.add_entity( npos2, "toolbox:mapblock" )
			return true, "Teleported to node " .. minetest.pos_to_string( npos ) .. " within mapblock " .. minetest.pos_to_string( fpos ) .. "."
		else
			return false, "Invalid node specified."
		end
	end,
} )

minetest.register_chatcommand( "fpos", {
	description = "Show the posititon and ID of the current mapblock.",
	privs = { server = true },
	func = function( name, param )
		local player = minetest.get_player_by_name( name )
		local fpos = get_mapblock_from_npos( to_npos( player:get_pos( ) ) )
		local block_id = encode_block_pos( fpos )

		return true, string.format( "Mapblock: id=%d, pos=%s", block_id, minetest.pos_to_string( fpos ) )
	end
} )

minetest.register_chatcommand( "pos", {
	description = "Show the posititon and ID of the current mapchunk.",
	privs = { server = true },
	func = function( name, param )
		local player = minetest.get_player_by_name( name )
		local pos = get_mapchunk_from_npos( to_npos( player:get_pos( ) ) )
		local chunk_id = encode_chunk_pos( pos )

		return true, string.format( "Mapchunk: id=%d, pos=%s", chunk_id, minetest.pos_to_string( pos ) )
	end
} )

default.register_admintool( "toolbox:pick_ruby", {
	description = "Ruby Pickaxe (Delete Mapblock)",
	range = 5,
	inventory_image = "toolbox_rubypick.png",
	groups = { not_in_creative_inventory = 1 },
	on_use = function( itemstack, player, pointed_thing )
		local fpos = get_mapblock_from_npos( pointed_thing.under or to_npos( player:getpos( ) ) )
		local npos1, npos2 = get_mapblock_bounds( fpos )
		local player_name = player:get_player_name( )

		minetest.delete_area( npos1, npos2 )
		minetest.log( "action", player_name .. " deletes mapblock area " .. minetest.pos_to_string( npos1 ) .. " " .. minetest.pos_to_string( npos2 ) )
		minetest.chat_send_player( player_name, "Mapblock " .. minetest.pos_to_string( fpos ) .. " deleted." )
	end,
} )

default.register_admintool( "toolbox:pick_aikerum", {
	description = "Aikerum Pickaxe (Display Mapblock)",
	range = 5,
	inventory_image = "toolbox_aikerumpick.png",
	groups = { not_in_creative_inventory = 1 },
	on_use = function( itemstack, player, pointed_thing )
		local fpos = get_mapblock_from_npos( pointed_thing.under or to_npos( player:getpos( ) ) )
		local npos = get_mapblock_center( fpos )
		local player_name = player:get_player_name( )

		minetest.add_entity( npos, "toolbox:mapblock" )
		minetest.chat_send_player( player_name, "Mapblock " .. minetest.pos_to_string( fpos ) .. " displayed." )
	end,
} )

default.register_admintool( "toolbox:pick_emerald", {
	description = "Emerald Pickaxe (Update Mapblock)",
	range = 5,
	inventory_image = "toolbox_emeraldpick.png",
	groups = { not_in_creative_inventory = 1 },
	on_use = function( itemstack, player, pointed_thing )
		local fpos = get_mapblock_from_npos( pointed_thing.under or to_npos( player:getpos( ) ) )		
		local npos1, npos2 = get_mapblock_bounds( fpos )
		local player_name = player:get_player_name( )
		local vm = minetest.get_voxel_manip( )

		vm:read_from_map( npos1, npos2 )
		vm:calc_lighting( )
		vm:update_liquids( )
		vm:write_to_map( )
		vm:update_map( )

		minetest.log( "action", player_name .. " updates mapblock area " .. minetest.pos_to_string( npos1 ) .. " to " .. minetest.pos_to_string( npos2 ) )
		minetest.chat_send_player( player_name, "Mapblock " .. minetest.pos_to_string( fpos ) .. " updated." )
	end,
} )

minetest.register_entity( "toolbox:mapblock", {
	hp_max = 1,
	visual = "wielditem",
	visual_size = { x = 1 / 1.5, y = 1 / 1.5 },
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	physical = false,
	textures = { "toolbox:mapblock_display" },
	timeout = 7,

	on_step = function( self, dtime )
		self.timeout = self.timeout - dtime
		
		if self.timeout < 0 then
			self.object:remove( )
		end
	end,
} )

minetest.register_node( "toolbox:mapblock_display", {
	tiles = { "protector_display.png" },
	use_texture_alpha = true,
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- west face
			{ -8.5, -8.5, -8.5, -8.5, 7.5, 7.5 },
			-- north face
			{ -8.5, -8.5, 7.5, 7.5, 7.5, 7.5 },
			-- east face
			{ 7.5, -8.5, -8.5, 7.5, 7.5, 7.5 },
			-- south face
			{ -8.5, -8.5, -8.5, 7.5, 7.5, -8.5 },
			-- top face
			{ -8.5, 7.5, -8.5, 7.5, 7.5, 7.5 },
			-- bottom face
			{ -8.5, -8.5, -8.5, 7.5, -8.5, 7.5 },
		},
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = "",
} )
