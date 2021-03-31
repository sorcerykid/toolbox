--------------------------------------------------------
-- Minetest :: Admin Toolbox Mod (toolbox)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2016-2021, Leslie E. Krause
--------------------------------------------------------

default.register_admintool = function ( name, fields )
	fields.item_privs = { server = true }
	fields.on_use_old = fields.on_use
	fields.on_use = function( itemstack, player, pointed_thing )
		local player_name = player:get_player_name( )
		if not minetest.is_poweruser( player_name ) then
			minetest.chat_send_player( player_name, "Your privileges are insufficient to use this tool." )
			player:set_hp( 0 )
			return ItemStack( nil )
		end
		fields.on_use_old( itemstack, player, pointed_thing )	-- maybe call fields.on_grant?
	end
	
	minetest.register_tool( name, fields )
end

minetest.include( "explorer.lua" )
