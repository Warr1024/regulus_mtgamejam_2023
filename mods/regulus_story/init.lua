--todo

local mod_storage=minetest.get_mod_storage()

regulus_story={}

regulus_story.dialogues={
    intro={
        {file="todo",text="Greetings, young one!",length=2},
        {file="todo",text="Thank you for coming when we called",length=3},
        {file="todo",text="You are the strongest wizard of the guild",length=3},
        {file="todo",text="But alas, now that the crystal is gone, this guild may not remain for long.",length=5},
        {file="todo",text="The darkness will soon swallow our world unless we get it back.",length=5},
        {file="todo",text="You are our only hope of recovering the crystal",length=5},
        {file="todo",text="Along your way, make sure to pick up your new wand at the library.",length=5},
        {file="todo",text="Good luck",length=1},
    },
    intro_idle={
        {file="todo",text="Go to the library to pick up your wand",length=4},
    },
    library1={
        {file="todo",text="Ah, hello there!",length=2},
        {file="todo",text="I apologize for not noticing you when you came in. ",length=4},
        {file="todo",text="I was very busy thinking over our strategies to retrieve the crystal.",length=6},
        {file="todo",text="I believe you were sent to pick up your new wand, yes? ",length=4},
        {file="todo",text="I left it somewhere in this library, I believe",length=3},
        {file="todo",text="But I am very busy at the moment,",length=1.5},
        {file="todo",text="perhaps you could go find it for me?",length=2},
    },
    library2={
        {file="todo",text="You found it? Oh, excellent.",length=3},
        {file="todo",text="The defense obstacles in the base have been active ever since the crystal was stolen",length=6},
        {file="todo",text="You will need your wand to get past them to where the crystal was hidden",length=4},
        {file="todo",text="Good luck on your mission!",length=3},
    },
    library_idle={
        {file="todo",text="Use your wand to fly out of the library",length=4},
    },
    second_meeting1={
        {file="todo",text="Why, long time no see!",length=3},
        {file="todo",text="I wasn't expecting you to get here so fast.",length=3},
        {file="todo",text="The crystal is just after this room.",length=3},
        {file="todo",text="Is your new wand working okay?",length=3},
    },
    second_meeting2={
        {file="todo",text="",length=1},--pause
        {file="todo",text="Oh, dear, that is not right. You are so tiny!",length=3},
        {file="todo",text="You wand appears to be malfunctioning",length=3},
        {file="todo",text="I suppose you will have to take a detour through that small hole in the wall behind me.",length=5},
        {file="todo",text="You'll still make it to the crystal, but it will take a bit longer.",length=3},
    },
    second_meeting_idle={
        {file="todo",text="Go through the hole in the wall to get to the next room",length=3},
        {file="todo",text="Your wand is malfunctioning. That's is why you become tiny when you use it.",length=3},
    },
    bossfight1={
        {file="todo",text="How did you get here so quickly? I wasn't finished--",length=3},
        {file="todo",text="No matter.",length=2},
        {file="todo",text="I think it is time that I tell you the truth",length=3},
        {file="todo",text="I am not on your side",length=3},
        {file="todo",text="You see that crystal behind me? I am the one who stole it.",length=4},
    },
    bossfight2={
        {file="todo",text="For I am a master wizard",length=3},
        {file="todo",text="None can compare to me",length=3},
        {file="todo",text="You shall die, but I will live forever with the energy of this crystal.",length=4},
    },
    bossfight_try_dig_crystal={
        {file="todo",text="",length=2},
        {file="todo",text="I have set a spell over the crystal",length=3},
        {file="todo",text="No one cannot remove it until I am dead",length=3},
    },
    you_won={
        {file="todo",text="",length=2},
        {file="todo",text="At last!",length=3},
        {file="todo",text="The crystal has been returned safely!",length=3},
        {file="todo",text="Thank you, young wizard, for your excellent service.",length=3},
        {file="todo",text="The sun shall never again be blotted out by the darkness",length=3},
    }
}


regulus_story.win=function(player)
    if player:get_meta():get_int("finished")==0 then
        player:get_meta():set_int("finished",1)
        local total_time=(minetest.get_us_time()-player:get_meta():get_float("start_time"))/10^6
        local minutes=math.floor(total_time/60)
        local seconds=total_time % 60
        minetest.chat_send_all("You completed the game in "..minutes..":"..seconds)
        --regulus_mapgen.load_level(player,"you_won")

        minetest.after(0.3,function()
            player:set_sky({
                base_color="#FFFFFF",
                type="regular",
                sky_color={
                    day_sky="#61b5f5",
                    day_horizon="#b4bafa",
                    
                }
            })
            player:set_sun({
                visible=true,
                sunrise_visible=false,
            })
            player:override_day_night_ratio(nil)
            minetest.set_timeofday(0.5)
            regulus_story.trigger_dialogue(player, "you_won")
        end)
    end
end

minetest.register_on_newplayer(function(player)
    --minetest.chat_send_player(player:get_player_name(),"Game starts now, at "..tostring(minetest.get_us_time()))
    player:get_meta():set_float("start_time",minetest.get_us_time())
end)

regulus_story.is_dialogue_playing=false

regulus_story.voiceline_length_pause_inbetween=0.4

regulus_story.trigger_voiceline=function(player,voiceline,predelay)
    if predelay then
        minetest.after(predelay,function()
        --regulus_story.after_beat(predelay, function()
            regulus_gui.show_subtitles(player,voiceline.text,voiceline.length)
        end)
    else
        regulus_gui.show_subtitles(player,voiceline.text,voiceline.length)
    end
end

regulus_story.trigger_dialogue=function(player,dialogue_id,do_after)
    if regulus_story.is_dialogue_playing then
        return
    end
    regulus_story.is_dialogue_playing=true
    local total_delay=0
    for _,voiceline in ipairs(regulus_story.dialogues[dialogue_id]) do
        regulus_story.trigger_voiceline(player,voiceline,total_delay)
        --minetest.chat_send_all(dump(voiceline))
        total_delay=total_delay+voiceline.length+regulus_story.voiceline_length_pause_inbetween
    end
    minetest.after(total_delay,function()
        regulus_story.is_dialogue_playing=false
        player:get_meta():set_int("dialogue_"..dialogue_id,1)
        if do_after then
            do_after()
        end
    end)
end

minetest.register_node("regulus_story:crystal",{
    description="Crystal",
    drawtype="mesh",
    mesh="regulus_crystal.obj",
    tiles={"regulus_crystal.png"},
    collision_box={
        type="fixed",
        fixed={
            {-0.7,-0.2,-0.2,0.7,0.2,0.2},
            {-0.2,-0.2,-0.7,0.2,0.2,0.7},
            {-0.2,-0.7,-0.2,0.2,0.7,0.2},
            {-0.5,-0.5,-0.5,0.5,0.5,0.5},
        },
    },
    after_dig_node=function(pos,oldnode,oldmeta,digger)
        mod_storage:set_int("crystal_taken",1)
        digger:get_meta():set_int("crystal_taken",1)
        --minetest.chat_send_all(dump({"Yelloooo",digger:get_meta():get_int("crystal_taken")}))
        minetest.add_particlespawner({
            amount=20,
            time=1,
            pos=pos,
            texture={
                name="regulus_crystal_sparkle1.png",
                scale=5,
                alpha_tween={1,0},
            },
            vel={
                min=vector.new(-10,-1,-10),
                max=vector.new(10,1,10),
            }
        })
    end,
    sounds={dig="default_dig_crystal"},
    groups={diggable=1,crystal=1},
})


minetest.register_node("regulus_story:unbreakable_crystal",{
    description="Unbreakable Crystal",
    drawtype="mesh",
    mesh="regulus_crystal.obj",
    tiles={"regulus_crystal.png"},
    collision_box={
        type="fixed",
        fixed={
            {-0.7,-0.2,-0.2,0.7,0.2,0.2},
            {-0.2,-0.2,-0.7,0.2,0.2,0.7},
            {-0.2,-0.7,-0.2,0.2,0.7,0.2},
            {-0.5,-0.5,-0.5,0.5,0.5,0.5},
        },
    },
    on_punch=function(pos,node,puncher)
        if puncher:get_meta():get_int("dialogue_bossfight_try_dig_crystal")~=1 then
            regulus_story.trigger_dialogue(puncher,"bossfight_try_dig_crystal")
        end
    end,
    groups={undiggable=1,crystal=1},
})

minetest.register_node("regulus_story:crystal_pedistal_original",{
    description="crystal pedistal original full",
    tiles={"regulus_pedistal.png"},
    drawtype="mesh",
    mesh="regulus_pedistal.obj",
    on_rightclick=function(pos,node,clicker,itemstack,pointed_thing)
    end,
    on_construct=function(pos)
        minetest.set_node(pos+vector.new(0,1,0),{name="regulus_story:crystal"})
    end,
    groups={undiggable=1},
    use_texture_alpha=true,
    paramtype="light",
    light_source=14,
})

minetest.register_node("regulus_story:crystal_pedistal_original_empty",{
    description="crystal pedistal original empty",
    tiles={"regulus_pedistal.png"},
    drawtype="mesh",
    mesh="regulus_pedistal.obj",
    on_rightclick=function(pos,node,clicker,itemstack,pointed_thing)
    end,
    groups={undiggable=1,not_in_creative_inventory=1},
    paramtype="light",
    light_source=14,
})


minetest.register_node("regulus_story:crystal_pedistal_finish_empty",{
    description="crystal pedistal finish empty",
    tiles={"regulus_pedistal.png"},
    drawtype="mesh",
    mesh="regulus_pedistal.obj",
    on_rightclick=function(pos,node,clicker,itemstack,pointed_thing)
        --minetest.chat_send_all(dump(itemstack:to_string()))
        if itemstack:get_name()=="regulus_story:crystal" then
            --minetest.chat_send_all("Well done, player! you won!")
            minetest.set_node(pos+vector.new(0,1,0),{name="regulus_story:unbreakable_crystal"})
            minetest.set_node(pos,{name="regulus_story:crystal_pedistal_finish_full"})
            itemstack:clear()
            regulus_story.win(clicker)

            minetest.add_entity(pos,"regulus_story:crystal_laser")
            minetest.add_entity(pos,"regulus_story:crystal_laser_backward")
            
            minetest.add_particlespawner({
                amount=20,
                time=1,
                pos=pos,
                texture={
                    name="regulus_crystal_sparkle1.png",
                    scale=5,
                    alpha_tween={1,0},
                },
                vel={
                    min=vector.new(-10,-1,-10),
                    max=vector.new(10,1,10),
                }
            })
        end
    end,
    groups={undiggable=1},
    paramtype="light",
    light_source=14,
})

minetest.register_node("regulus_story:crystal_pedistal_finish_full",{
    description="crystal pedistal finish full",
    tiles={"regulus_pedistal.png"},
    drawtype="mesh",
    mesh="regulus_pedistal.obj",
    on_rightclick=function(pos,node,clicker,itemstack,pointed_thing)
    end,
    groups={undiggable=1,not_in_creative_inventory=1},
    paramtype="light",
    light_source=14,
})


minetest.register_node("regulus_story:wand_on_ground",{
    description="wand stand finish full",
    tiles={"regulus_wood2.png"},
    drawtype="nodebox",
    node_box={
        type="fixed",
        fixed={
            {-0.7,-0.5,-0.05,0.7,-0.4,0.05},
        }
    },
    on_punch=function(pos,node,clicker)
        clicker:get_inventory():add_item("main",ItemStack("regulus_tools:test"))
        minetest.set_node(pos,{name="air"})
        if minetest.get_node(pos-vector.new(0,1,0)).name=="regulus_story:wand_stand_full" then
            minetest.set_node(pos-vector.new(0,1,0),{name="regulus_story:wand_stand_empty"})
        end
        clicker:get_meta():set_int("has_wand",1)
    end,
    groups={undiggable=1},
    paramtype="light",
    paramtype2="facedir",
    light_source=14,
})
minetest.register_node("regulus_story:wand_stand_full",{
    description="wand stand finish full",
    tiles={"regulus_wand_stand.png"},
    groups={undiggable=1},
    paramtype="facedir",
    paramtype="light",
    light_source=14,
})
minetest.register_node("regulus_story:wand_stand_empty",{
    description="wand stand finish empty",
    tiles={"regulus_stone2.png"},
    groups={undiggable=1,not_in_creative_inventory=1},
    paramtype="facedir",
})


minetest.register_entity("regulus_story:crystal_laser",{
    visual="mesh",
    mesh="crystal_laser.obj",
    textures={"regulus_crystal_laser.png"},
    use_texture_alpha=true,
    backface_culling=false,
    automatic_rotate=1,
    shaded=false,
    on_activate=function(self)
        --self.object:set_velocity(vector.new(0,-20,0))
        minetest.after(1.0,function()
            self.object:remove()
        end)
    end,
})

minetest.register_entity("regulus_story:crystal_laser_backward",{
    visual="mesh",
    mesh="crystal_laser.obj",
    textures={"regulus_crystal_laser.png"},
    use_texture_alpha=true,
    backface_culling=false,
    automatic_rotate=-1,
    shaded=false,
    on_activate=function(self)
        --self.object:set_velocity(vector.new(0,-20,0))
        minetest.after(1.0,function()
            self.object:remove()
        end)
    end,
})


regulus_story.current_music=nil
regulus_story.current_music_beat_start=nil
regulus_story.current_music_spb=60/140*4--seconds per beat (bpm of my music is 140)

regulus_story.play_music=function(music_name)
    if not regulus_story.current_music_beat_start then
        regulus_story.current_music_beat_start=minetest.get_us_time()
    end
    if regulus_story.current_music then
        minetest.sound_fade(regulus_story.current_music,1,0)
        local delay_until_beat=regulus_story.current_music_spb-((minetest.get_us_time()-regulus_story.current_music_beat_start)/10^6 % (regulus_story.current_music_spb))
        --minetest.chat_send_all(dump(delay_until_beat))
        minetest.after(delay_until_beat,function()
            --minetest.sound_stop(regulus_story.current_music)
            regulus_story.current_music=minetest.sound_play(music_name,{loop=true})
            regulus_story.current_music_beat_start=minetest.get_us_time()
        end)
        --minetest.chat_send_all(dump(delay_until_beat))
    else
        regulus_story.current_music=minetest.sound_play(music_name,{loop=true})
    end
end

regulus_story.after_beat=function(delay,func)
    if regulus_story.current_music and regulus_story.current_music_beat_start then
        local at_that_time=minetest.get_us_time()+delay*10^6
        local delay_until_beat=regulus_story.current_music_spb-((at_that_time-regulus_story.current_music_beat_start)/10^6 % (regulus_story.current_music_spb))
        return minetest.after(delay+delay_until_beat,func)
    else
        return minetest.after(delay,func)
    end
end

regulus_story.do_functions_on_beat=function(list_of_funcs,beats_per_execution,predelay_beats)
    for i,func in ipairs(list_of_funcs) do
        regulus_story.after_beat((i-1)*regulus_story.current_music_spb*beats_per_execution+regulus_story.current_music_spb*predelay_beats,func)
    end
end


minetest.register_chatcommand("play_music",{
    description="test playing music",
    func=function(name,param)
        regulus_story.play_music("mtgj_song2")
    end
})
minetest.register_chatcommand("on_beat",{
    description="test playing music",
    func=function(name,param)
        regulus_story.after_beat(1,function()regulus_story.trigger_voiceline(minetest.get_player_by_name(name),{text="Hello",length=1})end)
        regulus_story.after_beat(2,function()regulus_story.trigger_voiceline(minetest.get_player_by_name(name),{text="How are you",length=1})end)
        regulus_story.after_beat(3,function()regulus_story.trigger_voiceline(minetest.get_player_by_name(name),{text="I am good",length=1})end)
    end
})

regulus_story.show_intro=function(player)
    local blackscreen={
        hud_elem_type="image",
        text="regulus_blackscreen.png",
        position={x=0.5,y=0.5},
        scale={x=2,y=2},
        alignment={x=0,y=0},
    }
    local id=player:hud_add(blackscreen)
    local bar=regulus_story.current_music_spb
    regulus_story.do_functions_on_beat({
        function()regulus_story.trigger_voiceline(player,{text="Long ago, the world was peaceful and bright",length=bar*2})end,
        function()regulus_story.trigger_voiceline(player,{text="The guild of wizards kept the world in balance with the power of the velvet crystal",length=bar*3})end,
        function()regulus_story.trigger_voiceline(player,{text="But one day, a mysterious monster appeared",length=bar*3})end,
        function()regulus_story.trigger_voiceline(player,{text="It tried to steal the crystal, but the guilders fought it off",length=bar*3})end,
        function()regulus_story.trigger_voiceline(player,{text="Many believed that the monster was gone forever",length=bar*3})end,
        function()regulus_story.trigger_voiceline(player,{text="But they were all wrong; for just this past night, it struck again",length=bar*3})end,
        function()regulus_story.trigger_voiceline(player,{text="It stealthily stole the crystal and flew off with it to its lair",length=bar*3})end,
        function()regulus_story.trigger_voiceline(player,{text="Darkness enveloped the land, and the sun disappeared from the sky",length=bar*3})end,
        function()regulus_story.trigger_voiceline(player,{text="It is up to you, young wizard, to retrieve the crystal and save the land",length=bar*3})end,
        function()player:hud_remove(id)end,
    },4,-1)

end