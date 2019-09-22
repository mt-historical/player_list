local playerlist = {}

local update_interval = tonumber(minetest.settings:get("player_list_update_interval")) or 2

local function display_formspec(name)

    local players = minetest.get_connected_players()
    local max_players = minetest.settings:get("max_users") or 15
    local playernames = "Name,Ping,"
    local total_players = 0

    for _,v in pairs(players) do
        if minetest.is_player(v) then
            local ping = math.floor((minetest.get_player_information(v:get_player_name()).avg_rtt/2)*1000)
            playernames = playernames .. v:get_player_name() .. "," .. tostring(ping) .. ","
            total_players = total_players + 1
        end
    end

    local formspec = "size[2,5]" .. default.gui_bg .. default.gui_bg_img ..
    "textarea[0.25,0;3,1;;Players: " .. total_players .. "/" .. max_players .. ";]" ..
    "tablecolumns[text,align=left,width=4.5,padding=0.5;text,align=right,width=3,padding=0.5]" ..
    "tableoptions[background=#000000A0;highlight=#00000000;border=true]" ..
    "table[0,0.5;1.8,3.5;playerlist;" .. playernames .. "]" ..
    "button_exit[0,4.55;2,0.3;accept;Accept]"

    for _,v in pairs(playerlist) do
        if v == name then
            minetest.show_formspec(name, "player_list", formspec)
            minetest.after(update_interval, display_formspec, name)
            break
        end
    end
end

local function playerlist_action(name)

    local user = ""
    if type(name) ~= "string" and name:is_player() then
        user = name:get_player_name()
    else
        user = name
    end

    table.insert(playerlist, user)
    display_formspec(user)
end

minetest.register_chatcommand("playerlist",{
    params = "",
    description = "Shows the list of players",
    privs = {shout = true},
    func = playerlist_action
})

if minetest.get_modpath("sfinv_buttons") then
    sfinv_buttons.register_button("show_player_list",
    {
        title = "Player List",
        action = playerlist_action,
        tooltip = "Show list of players",
        image = "player_list_sfinv_icon.png",
    })
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "player_list" then return end
    local name = player:get_player_name()
    if fields.accept or fields.quit then
        for k,v in pairs(playerlist) do
            if v == name then
                table.remove(playerlist, k)
                break
            end
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    for k,v in pairs(playerlist) do
        if v == name then
            table.remove(playerlist, k)
            break
        end
    end
end)