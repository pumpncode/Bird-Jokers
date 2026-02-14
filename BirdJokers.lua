--- STEAMODDED HEADER
--- MOD_NAME: Bird Jokers
--- MOD_ID: BirdJokers
--- PREFIX: bird_jokers
--- MOD_AUTHOR: [Justin]
--- MOD_DESCRIPTION: Adds a couple of custom bird Jokers
--- BADGE_COLOR: 00CCFF
--- LOADER_VERSION_GEQ: 1.0.0
----------------------------------------------
------------MOD CODE -------------------------
--- localization ---
SMODS.Atlas({
key = "BirdStickers",
path = "BirdStickers.png",
px = 71,
py = 95
})
to_big = to_big or function(x) return x end
function SMODS.current_mod.process_loc_text()
    G.localization.descriptions.Other['crow_key'] = {
        name = 'Unfortunate bird',
        text = {
            'gains {X:mult,C:white}X#1#{} Mult when',
            'Wheel of Fortune',
            'says "'..localize("k_nope_ex")..'"'
        }
    }
    G.localization.descriptions.Other['swallow_key'] = {
        name = 'Fortunate bird',
        text = {
            'gains {X:mult,C:white}X#1#{} Mult when',
            'Wheel of Fortune',
            'gives an edition'
        }
    }
    G.localization.descriptions.Other['forgiveness'] = {
        name = 'Seeker of forgiveness',
        text = {
            'Returns all scoring',
            'Sacred Geometry cards'
        }
    }
    G.localization.descriptions.Other['bird_sacred'] = {
        name = 'Sacred Geometry',
        text = {
            'This card was marked',
            'by a crow person',
            'to be "returned"'
        }
    }
    G.localization.descriptions.Other['bird_returned_sacred'] = {
        name = 'Returned Sacred Geometry',
        text = {
            'This card was scored',
            'after being marked',
            'by a crow person.',
        }
    }
    G.localization.descriptions.Other['april_fools'] = {
        name='April fools!',
        text = {
            'spawns a negative',
            'copy of itself if {C:attention}sold'
        }
    }
    G.localization.descriptions.Other['eternal_negative'] = {
        name='Immortal',
        text = {
            'If this joker is eternal',
            'it becomes negative at the',
            'end of the round'
        }
    }
    G.localization.descriptions.Other['showdowns'] = {
        name='Final Ante Showdown',
        text = {
            'the {C:attention}Ante #1# boss blind{}',
            'counts as a {C:attention}Showdown blind{}'
        }
    }
    G.localization.misc.dictionary.ph_mr_bones = "Done gambling"
    G.localization.misc.labels['bird_sacred']='Sacred Geometry'
    G.localization.misc.labels['bird_returned_sacred']='Returned Sacred Geometry'
    G.bird_jokers_global_modifiers = {
    "sacred_geometry",
    "returned"
    }
    if SMODS.Mods["JokerDisplay"] and _G["JokerDisplay"] then
        JokerDisplay.Definitions["j_bird_jokers_house_sparrow"]={
            text ={{ text = " +",colour = G.C.MULT },
                { ref_table = "card.ability", ref_value = "mult",  colour = G.C.MULT }},
            reminder_text = {
                { text = "(", colour = G.C.UI.TEXT_INACTIVE},
                { ref_table = "card.joker_display_values", ref_value = "active_text", colour = G.C.UI.TEXT_INACTIVE},
                { text = ")", colour = G.C.UI.TEXT_INACTIVE},
            },
            calc_function = function(card)
                local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and (G.GAME.blind:get_type() == 'Boss') 
                local next_showdown = (G.GAME.round_resets.ante and (G.GAME.win_ante + math.max(0, math.floor(G.GAME.round_resets.ante / G.GAME.win_ante) * G.GAME.win_ante))) or 8 
                local showdown_enabled = G.GAME.round_resets.ante and G.GAME.round_resets.ante%G.GAME.win_ante == 0
                card.joker_display_values.active = disableable and showdown_enabled
                card.joker_display_values.maybe_active = disableable
                card.joker_display_values.active_text = (showdown_enabled or not disableable) and localize(disableable and 'k_active' or 'ph_no_boss_active') or "May be active"
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.active and G.C.GREEN or card.joker_display_values.maybe_active and G.C.YELLOW or
                        G.C.RED
                    reminder_text.children[2].config.scale = card.joker_display_values.active and 0.35 or 0.3
                    return true
                end
                return false
            end
        }        
        JokerDisplay.Definitions["j_bird_jokers_unlucky_crow"]={
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.ability", ref_value = "x_mult" }
                    }
                }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREEN},
                { ref_table = "card.joker_display_values", ref_value = "odds", colour = G.C.GREEN},
                { text = " in ", colour = G.C.GREEN},
                { ref_table = "card.ability.extra", ref_value = "odds", colour = G.C.GREEN},
                { text = ")", colour = G.C.GREEN},
            },
            calc_function = function(card)
                card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
            end
        }
        JokerDisplay.Definitions["j_bird_jokers_lucky_swallow"]={
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.ability", ref_value = "x_mult" }
                    }
                }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREEN},
                { ref_table = "card.joker_display_values", ref_value = "odds_n", colour = G.C.GREEN},
                { text = " in ", colour = G.C.GREEN},
                { ref_table = "card.ability.extra", ref_value = "odds", colour = G.C.GREEN},
                { text = ")", colour = G.C.GREEN},
            },
            calc_function = function(card)
                card.joker_display_values.odds_n = (G.GAME and G.GAME.probabilities.normal or 1) * card.ability.extra.odds_numer
                card.joker_display_values.odds_d = card.ability.extra.odds or 8
            end
        }
        if not JokerDisplay.calculate_rightmost_card then
            JokerDisplay.calculate_rightmost_card = function(cards)
                if not cards or type(cards) ~= "table" then
                    return nil
                end
                local rightmost = cards[#cards]
                for i = 1, #cards do
                    if cards[i].T.x > rightmost.T.x then
                        rightmost = cards[i]
                    end
                end
                return rightmost
            end
        end
        JokerDisplay.Definitions["j_bird_jokers_manzai"]={
            text = {
                { ref_table = "card.joker_display_values", ref_value = "count"},
                { text = "x",                              scale = 0.35 },
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.ability.extra", ref_value = "x_mult" }
                    }
                }
            },
            reminder_text = {
                { text = "(Last scored)",colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
            },
            extra = {
                {
                    { text = "(", colour = G.C.GREEN},
                    { ref_table = "card.joker_display_values", ref_value = "odds", colour = G.C.GREEN},
                    { text = " in ", colour = G.C.GREEN},
                    { ref_table = "card.ability.extra", ref_value = "odds", colour = G.C.GREEN},
                    { text = ")", colour = G.C.GREEN},
                }
            },
            calc_function = function(card)
                local mult_count = 0
                local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
                local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
                local last_card = JokerDisplay.calculate_rightmost_card(scoring_hand)
                    for k, v in pairs(scoring_hand) do
                        if v == last_card and v.facing and not (v.facing == 'back') and not v.debuff then
                            mult_count = mult_count + JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                        end
                    end
                card.joker_display_values.count = mult_count
                card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
            end,
            retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
                local last_card = scoring_hand and JokerDisplay.calculate_rightmost_card(scoring_hand) or nil
                return last_card and playing_card == last_card and 1 or 0
            end
        }
        JokerDisplay.Definitions["j_bird_jokers_crow_person"]={
        text={                { text = "(", colour = G.C.GREEN},
            { ref_table = "card.joker_display_values", ref_value = "odds", colour = G.C.GREEN},
            { text = " in ", colour = G.C.GREEN},
            { ref_table = "card.ability.extra", ref_value = "odds", colour = G.C.GREEN},
            { text = ")", colour = G.C.GREEN},
            { text = " (marking)", colour = G.C.UI.TEXT_INACTIVE}
        },
        reminder_text={
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { ref_table = "card.joker_display_values", ref_value = "count",         colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
        },
        calc_function = function(card)
            card.joker_display_values.count = (card.ability.extra.returned_geometries .. "/" .. 10)
            card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
        end
        }
        JokerDisplay.Definitions["j_bird_jokers_crow_person_true"]={
            text = {
                { ref_table = "card.joker_display_values", ref_value = "count" },
                { text = "x",                              scale = 0.35 },
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.ability.extra", ref_value = "x_mult" }
                    }
                }
            },
            reminder_text = {
                { text = "(Returned Geometries)",colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
            },
            extra = {
                {
                    { text = "(",colour = G.C.GREEN},
                    { ref_table = "card.joker_display_values", ref_value = "odds",colour = G.C.GREEN},
                    { text = " in ",colour = G.C.GREEN},
                    { ref_table = "card.ability.extra", ref_value = "odds",colour = G.C.GREEN},
                    { text = ")",colour = G.C.GREEN},
                    { text = " (marking)", colour = G.C.UI.TEXT_INACTIVE}
                }
            },
            extra_config = {scale = 0.3 },
        calc_function = function(card)
            local mult_count = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
                for k, v in pairs(scoring_hand) do
                    if v.facing and not (v.facing == 'back') and not v.debuff and v.ability.returned then
                        mult_count = mult_count  + JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                    end
                end
            card.joker_display_values.count = mult_count
            card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
        end
        }
        JokerDisplay.Definitions["j_bird_jokers_phoenix"]={
            reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "active",         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.active = (to_big(G.GAME.chips) / to_big(G.GAME.blind.chips) >= to_big(0.8)) and localize("k_active_ex") or "Inactive"
        end
        }
        JokerDisplay.Definitions["j_bird_jokers_hummingbird_nerd"]={
            reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "active",         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.active = (to_big(G.GAME.chips) / to_big(G.GAME.blind.chips) >= to_big(0.01*card.ability.extra.percentage)) and localize("k_active_ex") or "Inactive"
        end
        }
        JokerDisplay.Definitions["j_bird_jokers_wren"]={
            retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
                local first_card = scoring_hand and JokerDisplay.calculate_leftmost_card(scoring_hand) or nil
                local last_card = scoring_hand and JokerDisplay.calculate_rightmost_card(scoring_hand) or nil
                local _, _, scoring_hand = JokerDisplay.evaluate_hand()
                return ((last_card and playing_card == last_card) or (first_card and playing_card == first_card)) and ((#scoring_hand>=4 or #scoring_hand==1) and 2 or 1) * JokerDisplay.calculate_joker_triggers(joker_card) or 0
            end
        }
        JokerDisplay.Definitions["j_bird_jokers_canary"]={
            text ={{ text = " +",colour = G.C.MULT },
                { ref_table = "card.joker_display_values", ref_value = "mult",  colour = G.C.MULT }},
            calc_function = function(card)
                local mult_count = 0
                local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
                local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
                local last_card = JokerDisplay.calculate_rightmost_card(scoring_hand)
                    for k, v in pairs(scoring_hand) do
                        if v == last_card and v.facing and not (v.facing == 'back') and not v.debuff then
                            mult_count = mult_count + JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                        end
                    end
                card.joker_display_values.mult = mult_count*((#scoring_hand>=4) and 8 or 4)
            end
        }    
    end
end
SMODS.Atlas({
   key = "modicon",
   path = "bird_jokers_tag.png",
   px = 32,
   py = 32
 })
SMODS.Atlas{
    key = "unlucky_crow",
    path = "j_bird_jokers_unlucky_crow.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "lucky_swallow",
    path = "j_bird_jokers_lucky_swallow.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "manzai",
    path = "j_bird_jokers_manzai.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "crow_person",
    path = "j_bird_jokers_crow_person.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "crow_person_true",
    path = "j_bird_jokers_crow_person_true.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "phoenix",
    path = "j_bird_jokers_phoenix.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "house_sparrow",
    path = "j_bird_jokers_house_sparrow.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "hummingbird_nerd",
    path = "hummingbird_nerd.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "wren",
    path = "j_bird_jokers_wren.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "canary",
    path = "j_bird_jokers_canary.png",
    px = 71,
    py = 95
}
local donaiyanen = SMODS.Sound({
    key = "manzai_donaiyanen",
    path = "donaiyanen_hit.ogg"
})
local aw_dang = SMODS.Sound({
    key = "unlucky_dangit",
    path = "gamblecore_aw_dangit.wav"
})
local winning = SMODS.Sound({
    key = "lucky_winnning",
    path = "gamblecore_winning.wav"
})
local done_gambling = SMODS.Sound({
    key = "hummingbird_done",
    path = "gamblecore_done.wav"
})
local hai_hai = SMODS.Sound({
    key = "manzai_hai_hai",
    path = "hai_hai.ogg"
})
if SMODS.DrawStep then
    
    SMODS.DrawStep{
        key = "bird_sacred",
        order = 50,
        func = function (card, layer)
            for _, v in ipairs(G.bird_jokers_global_modifiers or {}) do
                if card.ability[v] then
                    G.bird_jokers_shared_modifiers[v].role.draw_major = card
                    G.bird_jokers_shared_modifiers[v]:draw_shader('dissolve', nil, nil, nil, card.children.center)
                    G.bird_jokers_shared_modifiers[v]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center)
                end
            end
        end,
        conditions = { vortex = false, facing = 'front' },
    }
end
local config = SMODS.current_mod.config
--- Function redefinitions ---
local get_badge_colourref = get_badge_colour
function get_badge_colour(key)
    if key == 'bird_sacred' then return HEX("00CCCC") end
    if key == 'bird_returned_sacred' then return HEX("00FFFF") end
    return get_badge_colourref(key);
end
    --Keep markings when card is enhanced
local set_abilityref = Card.set_ability
function Card.set_ability(self, center, initial, delay_sprites)
    local bird_abilities = {}

    if self.ability and self.playing_card then
        for _, v in ipairs(G.bird_jokers_global_modifiers) do
            if self.ability[v] then
                bird_abilities[v] = true
            end
        end
    end

    set_abilityref(self, center, initial, delay_sprites)

    if self.ability and self.playing_card then
        for k, v in pairs(bird_abilities) do
            if v then
                self.ability[k] = true
            end
        end
    end
end
local dissolve_ref = Card.start_dissolve
local todays_date = os.date("*t",os.time())
function Card.start_dissolve(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
    dissolve_ref(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
    if self.ability.name == "Phoenix" and (self.ability.extra.destroy_disolve or (todays_date.month==4 and todays_date.day==1))then
           G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            local new_card = create_card_alt('Joker', G.jokers, nil, nil, nil, nil, 'j_bird_jokers_phoenix', nil, true, {negative = true})
            new_card:add_to_deck()
            G.jokers:emplace(new_card)
            new_card:start_materialize()
            G.GAME.joker_buffer = 0
            return true;
        end}))
    end
end
SMODS.current_mod.config_tab = function()
return {n = G.UIT.ROOT, config = {r = 0.1, align = "t", padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6}, nodes = {
        {n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 0.85, w = 0, shadow = true, ref_table = config, ref_value = "custom_sounds" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = "custom sound effects", scale = 0.35, colour = G.C.UI.TEXT_LIGHT }},
            }}
        }},
    }}
end
SMODS.current_mod.credits_tab = function()
return {n = G.UIT.ROOT, config = {r = 0.1, align = "cm", padding = 0.1, colour = G.C.BLACK, minw = 10, minh = 6}, nodes = {
    {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
            {n = G.UIT.T, config = { text = "Character credits:", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}},
        }},
        {n = G.UIT.R, config = {align = "cl", padding = 0.05}, nodes = {
            {n = G.UIT.T, config = { text = "Crow People: Monmuent Valley, made by Ustwo Games", scale = 0.35, colour = G.C.UI.TEXT_LIGHT}},
        }},{n = G.UIT.R, config = {align = "cl", padding = 0.05}, nodes = {
            {n = G.UIT.T, config = { text = "Manzai Birds: Rhythm Heaven (JP), made by Nintendo", scale = 0.35, colour = G.C.UI.TEXT_LIGHT}},
        }},{n = G.UIT.R, config = {align = "cl", padding = 0.05}, nodes = {
            {n = G.UIT.T, config = { text = "Wren and Canary: Bits and Bops, made by Tempo Lab Games", scale = 0.35, colour = G.C.UI.TEXT_LIGHT}},
        }},{n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
            {n = G.UIT.T, config = { text = "SFX credits:", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}},
        }},{n = G.UIT.R, config = {align = "cl", padding = 0.05}, nodes = {
            {n = G.UIT.T, config = { text = "Unlucky Crow, Lucky Swallow, Hummingbird Nerd: gamblecore by raxdflipnote", scale = 0.35, colour = G.C.UI.TEXT_LIGHT}},
        }},}}

end
--- Jokers ---
local house_sparrow = SMODS.Joker{key="house_sparrow",
    atlas="house_sparrow", 
    name="House Sparrow", 
    rarity=1, 
    unlocked=true, 
    discovered=true, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=2,
    config={mult = 4},
    loc_txt={
        ['en-us']={
            name="House Sparrow",
            text={
                '{C:mult}+#1# mult{},',
                'Disables the effect of',
                'all {C:attention}Showdown blinds'
        }},
        ['default']={
            name="House Sparrow",
            text={
                '{C:mult}+#1# mult{},',
                'Disables the effect of',
                'all {C:attention}Showdown blinds'
    }},},
    loc_vars = function(self, info_queue, card)
        local showdown = (G.GAME.round_resets.ante and (G.GAME.win_ante + math.max(0, math.floor((G.GAME.round_resets.ante-1) / G.GAME.win_ante) * G.GAME.win_ante))) or 8 
        info_queue[#info_queue+1] = {set = 'Other', key = 'showdowns', vars = {showdown}}
        return {vars = {card.ability.mult}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not card.getting_sliced and not context.blueprint and context.blind.boss then
            if (G.GAME.round_resets.ante and  G.GAME.round_resets.ante%G.GAME.win_ante == 0) or context.blind.boss.showdown then
                G.E_MANAGER:add_event(Event({func = function()
                    G.E_MANAGER:add_event(Event({func = function()
                        G.GAME.blind:disable()
                        play_sound('timpani')
                        delay(0.4)
                        return true end }))
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = localize('ph_boss_disabled')})
                    if SMODS.Mods["LobotomyCorp"] and (context.blind.name == "WhiteNight" or (context.blind.passives and context.blind.passives["psv_lobc_fixed_encounter"])) then
                        card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = ('Grr...')})
                    end
                return true end }))
            -- else
            --      card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, 
            --         {message = ((G.GAME.round_resets.ante~=nil) and G.GAME.round_resets.ante..'/'..G.GAME.win_ante) or "nil"})
            end
        elseif context.cardarea == G.jokers and context.joker_main then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.mult}},
                mult_mod = card.ability.mult,
            }
        end
    end
    }
local unlucky_crow = SMODS.Joker{
    key="unlucky_crow",
    atlas="unlucky_crow",  
    name="Unlucky Crow", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=false, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={ x_mult = 1 ,extra = {odds = 4, x_mult=0.25}},
    loc_txt={
        ['en-us']={
            name="Unlucky Crow",
            text={
                'This Joker has a',
                '{C:green} #3# in #4#{} chance',
                'to gain {X:mult,C:white}X#2#{} Mult',
                'every hand',
            '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
            }},
        ['default']={
            name="Unlucky Crow",
            text={
                'This Joker has a',
                '{C:green} #3# in #4#{} chance',
                'to gain {X:mult,C:white}X#2#{} Mult',
                'every hand',
            '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
            }},
    },
    -- This Joker has a 1 in 4 chance
    -- to gain X0.25 Mult every hand
    --
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'crow_key', vars = {card.ability.extra.x_mult}}
        return {vars = {card.ability.x_mult,card.ability.extra.x_mult,G.GAME.probabilities.normal,card.ability.extra.odds}}
    end,
    calculate = function(self,card, context)
        if not context.blueprint then
            if context.consumeable then
                if context.consumeable.ability.name =='The Wheel of Fortune' and not(context.consumeable.yep) then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                    return true
                end
            elseif context.cardarea == G.jokers and context.before then
                if (pseudorandom('unlucky_crow') < G.GAME.probabilities.normal/card.ability.extra.odds) then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'),colour = G.C.MULT})
                else
                    -- card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}}})
                    if config.custom_sounds then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                aw_dang:play(1, (G.SETTINGS.SOUND.volume/100.0) * (G.SETTINGS.SOUND.game_sounds_volume/100.0),true)
                                card:juice_up()
                                return true
                            end
                        }))
                        delay(1)
                    end
                end
            end
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.x_mult>1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                Xmult_mod = card.ability.x_mult,
            }
        end
    end
}
local lucky_swallow = SMODS.Joker{
    key="lucky_swallow",
    atlas="lucky_swallow", 
    name="Lucky Swallow", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=false, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={ x_mult = 1 ,extra = {odds = 8,odds_numer = 1, x_mult=0.25}},
    loc_txt={
        ['en-us']={
            name="Lucky Swallow",
            text={
                'This Joker has a {C:green}#3# in #4#{} chance',
                'to gain {X:mult,C:white}X#2#{} Mult every hand,',
                'odds increase per consecutive hand',
                'played without succeeding',
                '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
        }},
        ['default']={
             name="Lucky Swallow",
        text={
            'This Joker has a {C:green}#3# in #4#{} chance',
            'to gain {X:mult,C:white}X#2#{} Mult every hand,',
            'odds increase per consecutive hand',
            'played without succeeding',
            '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
        }},},
    -- This Joker has a 
    -- 1 in 8 chance
    -- to gain X0.25 Mult
    -- every hand,
    -- Odds increase per
    -- consecutive hand
    -- played without
    -- succeeding
    -- (Currently X1.00 Mult)
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'swallow_key', vars = {card.ability.extra.x_mult}}
        return {vars = {card.ability.x_mult,card.ability.extra.x_mult,G.GAME.probabilities.normal*card.ability.extra.odds_numer,card.ability.extra.odds}}
    end,
    calculate = function(self,card, context)
        if not context.blueprint then
            if context.consumeable then
                if context.consumeable.ability.name =='The Wheel of Fortune' and context.consumeable.yep then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                    return true
                end
            elseif context.cardarea == G.jokers and context.before then
                if (pseudorandom('lucky_swallow') < G.GAME.probabilities.normal*card.ability.extra.odds_numer/card.ability.extra.odds) then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            winning:play(1, (G.SETTINGS.SOUND.volume/100.0) * (G.SETTINGS.SOUND.game_sounds_volume/100.0),true);
                            return true
                        end
                    }))
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'),colour = G.C.MULT})
                    if (card.ability.extra.odds_numer > 1) then
                        card.ability.extra.odds_numer = 1
                        card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = ((G.GAME.probabilities.normal*card.ability.extra.odds_numer)..' in '..card.ability.extra.odds),colour = G.C.GREEN}) 
                    end
                else
                    card.ability.extra.odds_numer = card.ability.extra.odds_numer + 1
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = ((G.GAME.probabilities.normal*card.ability.extra.odds_numer)..' in '..card.ability.extra.odds),colour =  G.C.GREEN})
                end
            end
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.x_mult>1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                Xmult_mod = card.ability.x_mult,
            }
        end
    end
}
local manzai_birds = SMODS.Joker{
    key="manzai", 
    atlas="manzai", 
    name="Manzai birds", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={extra = {odds = 4, x_mult=2}},
    loc_txt={
        ['en-us'] = {
            name="Manzai Birds",
            text={
                'Retrigger the last played',
                'card used in scoring once,',
                '{C:green}#1# in #2#{} chance for retriggered',
                'card to gain {X:mult,C:white}X#3#{} mult'
        }},
        ['default']={
            name="Manzai Birds",
            text={
                'Retrigger the last played',
                'card used in scoring once,',
                '{C:green}#1# in #2#{} chance for retriggered',
                'card to gain {X:mult,C:white}X#3#{} mult'
        }}
    },
    -- Retrigger the last played
    -- card used in scoring once,
    -- 1 in 4 chance for Retriggered
    -- card to gain x2 Mult
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,card.ability.extra.odds,card.ability.extra.x_mult}}
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play
            and context.other_card == context.scoring_hand[#(context.scoring_hand)] then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
        end
        if context.individual
            and context.cardarea == G.play
            and context.other_card == context.scoring_hand[#(context.scoring_hand)] then
            local donaiyanen_trigger = pseudorandom('manzai') < G.GAME.probabilities.normal/card.ability.extra.odds 
            if config.custom_sounds then
                if donaiyanen_trigger then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            donaiyanen:play(1, (G.SETTINGS.SOUND.volume/100.0) * (G.SETTINGS.SOUND.game_sounds_volume/100.0),true);
                            return true
                        end
                    }))
                else
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            hai_hai:play(1, (G.SETTINGS.SOUND.volume/100.0) * (G.SETTINGS.SOUND.game_sounds_volume/100.0),true);
                            return true
                        end
                    }))
                end
            end
            if donaiyanen_trigger then
                return {
                        x_mult = card.ability.extra.x_mult,
                        colour = G.C.RED,
                        card = card
                }
            end
        end
    end
}
local crow_person = SMODS.Joker{
    key="crow_person",
    atlas="crow_person",
    name="Crow Person",
    rarity=1,
    unlocked=true, 
    discovered=false, 
    blueprint_compat=false, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=2,
    config={extra={odds=2 , returned_geometries=0}},
    loc_txt={
        ['en-us'] = {
            name="Crow Person",
            text={
                'Has a {C:green}#1# in #2#{} chance',
                'to mark all scored cards',
                'as sacred geometry cards,',
                'Transforms into its true form',
                'if 10 or more sacred geometry',
                'cards score',
                '{C:inactive}(Currently #3#/10)'
            }},
        ['default'] = {
            name="Crow Person",
            text={
                'Has a {C:green}#1# in #2#{} chance',
                'to mark all scored cards',
                'as sacred geometry cards,',
                'Transforms into its true form',
                'if 10 or more sacred geometry',
                'cards score',
                '{C:inactive}(Currently #3#/10)'
            }}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'forgiveness'}
        return {vars = {G.GAME.probabilities.normal,card.ability.extra.odds,card.ability.extra.returned_geometries}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local returning = false;
            for k, v in ipairs(context.scoring_hand) do
                if v.ability and v.ability.sacred_geometry and not v.ability.returned then
                    returning = true;
                    card.ability.extra.returned_geometries = card.ability.extra.returned_geometries + 1;
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = function()
                            v:juice_up()
                            v.ability.returned = true
                        return true
                        end
                    }))
                end
            end
            if returning then
                card:juice_up()
                if card.ability.extra.returned_geometries < 10 then
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = (card.ability.extra.returned_geometries..'/'..10)})
                else
                    local transfer_edition = card.edition or nil
                    G.E_MANAGER:add_event(Event({
                            func = function()
                                play_sound('tarot1')
                                card.T.r = -0.2
                                card:juice_up(0.3, 0.4)
                                card.states.drag.is = true
                                card.children.center.pinch.x = true
                                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                    func = function()
                                            G.jokers:remove_card(card)
                                            card:remove()
                                            card = nil
                                        return true; end})) 
                                return true
                            end
                        })) 
                    G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
                        local new_card = nil
                        -- create_card_alt(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, edition_append, forced_edition)
                        if transfer_edition then
                            new_card = create_card_alt('Joker', G.jokers, nil, nil, nil, nil, 'j_bird_jokers_crow_person_true', nil, true, card.edition)
                        else
                            new_card = create_card_alt('Joker', G.jokers, nil, nil, nil, nil, 'j_bird_jokers_crow_person_true')
                        end
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                        new_card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true;
                    end}))
                    G.GAME.pool_flags["crow_person_transformed"] = true;
                    return  {
                    message = ('Transformed!')
                    }
                end
            end
            if pseudorandom('crow_person') < G.GAME.probabilities.normal/card.ability.extra.odds then
                local marking = false
                for k, v in ipairs(context.scoring_hand) do
                    if v.ability and not v.ability.sacred_geometry then
                        marking = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = function()
                                v:juice_up()
                                v.ability.sacred_geometry = true
                            return true
                            end
                        }))
                    end
                end
                if marking then
                    card:juice_up()
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = ("Marked!")})
                end
            end
        end
    end
}
local true_crow = SMODS.Joker{
    key="crow_person_true",
    atlas="crow_person_true",
    name="Crow Person (True form)",
    yes_pool_flag="crow_person_transformed",
    rarity=3,
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={extra={odds=2,x_mult=2}},
    loc_txt={
        ['en-us'] = {
            name="Crow Person (True Form)",
            text={
                'Has a {C:green}#1# in #2#{} chance',
                'to mark all scored cards',
                'as sacred geometry cards,',
                'Scoring returned sacred geometry',
                'cards give {X:mult,C:white}X#3#{} mult'
            }},
            ['default'] = {
            name="Crow Person (True Form)",
            text={
                'Has a {C:green}#1# in #2#{} chance',
                'to mark all scored cards',
                'as sacred geometry cards,',
                'Scoring returned sacred geometry',
                'cards give {X:mult,C:white}X#3#{} mult'
            }},
        },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'forgiveness'}
        return {vars = {G.GAME.probabilities.normal,card.ability.extra.odds,card.ability.extra.x_mult}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local returning = false
            for k, v in ipairs(context.scoring_hand) do
                if v.ability and v.ability.sacred_geometry and not v.ability.returned then
                    returning = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = function()
                            v:juice_up()
                            v.ability.returned = true
                        return true
                        end
                    }))
                end
            end
            if returning then
                card:juice_up()
                card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = ("returned!")})
            end
            if pseudorandom('crow_person') < G.GAME.probabilities.normal/card.ability.extra.odds then
                local marking = false
                for k, v in ipairs(context.scoring_hand) do
                    if v.ability and not v.ability.sacred_geometry then
                        marking = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = function()
                                v:juice_up()
                                v.ability.sacred_geometry = true
                            return true
                            end
                        }))
                    end
                end
                if marking then
                    card:juice_up()
                    card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = ("Marked!")})
                end
            end
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.ability.returned then
                return {
                            x_mult = card.ability.extra.x_mult,
                            colour = G.C.RED,
                            card = card
                        }
            end
        end
    end
}
local phoenix = SMODS.Joker{
    key="phoenix",
    atlas="phoenix", 
    name="Phoenix", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=4,
    config={extra = {destroy_disolve = true}},
    loc_txt={
        ['en-us'] = {
        name="Phoenix",
        text={
            'Prevents death',
            'if chips scored',
            'are at least {C:attention}80%{}',
            'of required chips',
            'spawns a negative copy',
            'of itself if {C:red}destroyed'
        }},
        ['default'] = {
        name="Phoenix",
        text={
            'Prevents death',
            'if chips scored',
            'are at least {C:attention}80%{}',
            'of required chips',
            'spawns a negative copy',
            'of itself if {C:red}destroyed'
        }}
    },
    -- Prevents death if chips scored are at least 80% of required chips, spawns a negative copy of itself if destroyed
    loc_vars = function(self, info_queue, card)
        if config.april_fools_test or (todays_date.month==4 and todays_date.day==1) then
            info_queue[#info_queue+1] = {set = 'Other', key = 'april_fools'}
        end
        info_queue[#info_queue+1] = {set = 'Other', key = 'eternal_negative'}
        return {vars = nil}
    end,
    calculate = function(self,card, context)
        local scored = to_big(G.GAME.chips)
        local required = to_big(G.GAME.blind.chips)
        local save_factor = to_big(0.8)
        if context.end_of_round then
            if context.game_over and 
            scored/required >= save_factor then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        return true
                    end
                })) 
                return {
                    message = localize('k_saved_ex'),
                    saved = true,
                    colour = G.C.RED
                }
            end
            if card.ability.eternal then
                if not card.edition or (card.edition and not card.edition.negative) then
                    card:set_edition("e_negative")
                end
            end
        elseif context.selling_self then
            card.ability.extra.destroy_disolve = false
        end
    end,
}
local humingbird_nerd = SMODS.Joker{
    key="hummingbird_nerd",
    atlas="hummingbird_nerd", 
    name="Hummingbird Nerd", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={extra = {percentage = 25,update_flag = false}},
    loc_txt={
        ['en-us'] = {
        name="Hummingbird Nerd",
        text={
            'Immediately ends',
            'round if chips',
            'scored are at least',
            '{C:attention}#1#%{} of required chips,',
            'percentage increases',
            'by {C:attention}25%{} per hand and',
            'can\'t go over {C:attention}90%{}',
        }},
        ['default'] = {
        name="Hummingbird Nerd",
        text={
            'Immediately ends',
            'round if chips',
            'scored are at least',
            '{C:attention}#1#%{} of required chips,',
            'percentage increases',
            'by {C:attention}25%{} per hand and',
            'can\'t go over {C:attention}90%{}',
        }}
    },
    -- Immediately ends 
    -- round if chips 
    -- scored are at least 
    -- 80% of required chips,
    -- percentage increases
    -- by 25% per hand and
    -- can't go over 90%
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.percentage}}
    end,
    calculate = function(self,card, context)
        local scored = to_big(G.GAME.chips)
        local required = to_big(G.GAME.blind.chips)
        local premature_end = to_big(card.ability.extra.percentage*0.01)
        --G.GAME.current_round.hands_played
        if context.after then
            card.ability.extra.update_flag = true
        end
        if context.end_of_round then
            card.ability.extra.percentage = 25
            if context.game_over and scored/required > premature_end then
                done_gambling:play(1, (G.SETTINGS.SOUND.volume/100.0) * (G.SETTINGS.SOUND.game_sounds_volume/100.0),true)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        return true
                    end
                })) 
                return {
                    message = 'Done!',
                    saved = true,
                    colour = G.C.RED
                }
            end
        end
    end,
    update = function(self, card, dt)
        if card.area == G.jokers and G.STAGE == G.STAGES.RUN and G.STATE == G.STATES.SELECTING_HAND and not card.debuff and card.ability.extra.update_flag then
            local scored = to_big(G.GAME.chips)
            local required = to_big(G.GAME.blind.chips)
            local premature_end = to_big(card.ability.extra.percentage*0.01)
            card.ability.extra.update_flag = false
            if scored/required > premature_end and scored < required then
                G.STATE = G.STATES.HAND_PLAYED
                G.STATE_COMPLETE = true
                if G.GAME.current_round.hands_left <= 0 then 
                    G.GAME.current_round.hands_left = 0
                else
                    end_round()
                end
            elseif scored < required then
                if card.ability.extra.percentage + 25 < 90 then
                    card.ability.extra.percentage = card.ability.extra.percentage + 25
                else
                    card.ability.extra.percentage = 90
                end
            end
        end
    end
} 
local wren = SMODS.Joker{
    key = "wren",
    atlas = "wren",
    name = "Wren (Bits and Bops)",
    rarity=1, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=false,
    pos={ x = 0, y = 0 },
    cost=4,
    config= {extra = 1},
    loc_txt={ 
        ['en-us'] = {
        name="Wren (Bits and Bops)",
        text={
            'retrigger the first and last',
            'cards used in scoring,',
            'retrigger them twice if',
            'scoring hand contains',
            '{C:attention}4 or more{} cards.',
        }},
        ['default'] = {
        name="Wren (Bits and Bops)",
        text={
            'retrigger the first and last',
            'cards used in scoring,',
            'retrigger them twice if',
            'scoring hand contains',
            '{C:attention}4 or more{} cards.',
        }},
    },
    calculate = function(self,card, context)
        if context.repetition and context.cardarea == G.play then
            card.ability.extra = (#context.scoring_hand >=4 or #context.scoring_hand == 1) and 2 or 1
            if (context.other_card == context.scoring_hand[1] or context.other_card == context.scoring_hand[#(context.scoring_hand)] ) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
                    card = card
                }
            end
        end
    end
}
local canary = SMODS.Joker{
    key = "canary",
    atlas = "canary",
    name = "Canary (Bits and Bops)",
    rarity=1, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=false,
    pos={ x = 0, y = 0 },
    cost=4,
    config= {extra = 4},
    loc_txt={
        ['en-us'] = {
        name="Canary (Bits and Bops)",
        text={
            'the last card used in scoring',
            'gives {C:mult}+4 mult{} when scored',
            'gives {C:mult}+8 mult{} instead if scoring',
            'hand contains {C:attention}4 or more{} cards.',
            '{C:inactive}(will give {C:mult}+#1# mult{C:inactive})'
        }},
        ["default"] = {
        name="Canary (Bits and Bops)",
        text={
            'the last card used in scoring',
            'gives {C:mult}+4 mult{} when scored',
            'gives {C:mult}+8 mult{} instead if scoring',
            'hand contains {C:attention}4 or more{} cards.',
            '{C:inactive}(will give {C:mult}+#1# mult{C:inactive})'
        }},
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra}}
    end,
    calculate = function(self,card, context)
        if context.individual and context.cardarea == G.play then
            card.ability.extra = (#context.scoring_hand >=4) and 8 or 4
            if (context.other_card == context.scoring_hand[#(context.scoring_hand)]) then
                return {
                    mult = card.ability.extra,
                    card = card
                }
            end
        end
    end
}
chal_mv = {
    name = 'Monument Valley',
    key = 'mv',

    loc_txt = {
         ['en-us'] = {name = 'Monument Valley'},
         ['default'] = {name = 'Monument Valley'},
    },
    rules = {
        custom = {
            {id = 'no_extra_hand_money'},
        },    
        modifiers = {
        }
    },
    jokers = {
            {id = 'j_bird_jokers_crow_person', eternal = true},
            {id = 'j_bird_jokers_crow_person', eternal = true},
        },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck'
      },
    restrictions = {
        banned_cards = {
        },
        banned_tags = {
        },
        banned_other = {
        }
    }
}
local chal_valley = SMODS.Challenge(chal_mv)

--- create_card_alt (used by some jokers) ---
-- Credit to the creators of Joker Evolution for the code

if not create_card_alt then 
    function create_card_alt(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, edition_append, forced_edition)
        local area = area or G.jokers
        local center = G.P_CENTERS.b_red
            

        --should pool be skipped with a forced key
        if not forced_key and soulable and (not G.GAME.banned_keys['c_soul']) then
            if (_type == 'Tarot' or _type == 'Spectral' or _type == 'Tarot_Planet') and
            not (G.GAME.used_jokers['c_soul'] and not next(find_joker("Showman")))  then
                if pseudorandom('soul_'.._type..G.GAME.round_resets.ante) > 0.997 then
                    forced_key = 'c_soul'
                end
            end
            if (_type == 'Planet' or _type == 'Spectral') and
            not (G.GAME.used_jokers['c_black_hole'] and not next(find_joker("Showman")))  then 
                if pseudorandom('soul_'.._type..G.GAME.round_resets.ante) > 0.997 then
                    forced_key = 'c_black_hole'
                end
            end
        end

        if _type == 'Base' then 
            forced_key = 'c_base'
        end

        if forced_key and not G.GAME.banned_keys[forced_key] then 
            center = G.P_CENTERS[forced_key]
            _type = (center.set ~= 'Default' and center.set or _type)
        else
            local _pool, _pool_key = get_current_pool(_type, _rarity, legendary, key_append)
            center = pseudorandom_element(_pool, pseudoseed(_pool_key))
            local it = 1
            while center == 'UNAVAILABLE' do
                it = it + 1
                center = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
            end

            center = G.P_CENTERS[center]
        end

        local front = ((_type=='Base' or _type == 'Enhanced') and pseudorandom_element(G.P_CARDS, pseudoseed('front'..(key_append or '')..G.GAME.round_resets.ante))) or nil

        local card = Card(area.T.x + area.T.w/2, area.T.y, G.CARD_W, G.CARD_H, front, center,
        {bypass_discovery_center = area==G.shop_jokers or area == G.pack_cards or area == G.shop_vouchers or (G.shop_demo and area==G.shop_demo) or area==G.jokers or area==G.consumeables,
         bypass_discovery_ui = area==G.shop_jokers or area == G.pack_cards or area==G.shop_vouchers or (G.shop_demo and area==G.shop_demo),
         discover = area==G.jokers or area==G.consumeables, 
         bypass_back = G.GAME.selected_back.pos})
        if card.ability.consumeable and not skip_materialize then card:start_materialize() end

        if _type == 'Joker' then
            if G.GAME.modifiers.all_eternal then
                card:set_eternal(true)
            end
            if (area == G.shop_jokers) or (area == G.pack_cards) then 
                local eternal_perishable_poll = pseudorandom((area == G.pack_cards and 'packetper' or 'etperpoll')..G.GAME.round_resets.ante)
                if G.GAME.modifiers.enable_eternals_in_shop and eternal_perishable_poll > 0.7 then
                    card:set_eternal(true)
                elseif G.GAME.modifiers.enable_perishables_in_shop and ((eternal_perishable_poll > 0.4) and (eternal_perishable_poll <= 0.7)) then
                    card:set_perishable(true)
                end
                if G.GAME.modifiers.enable_rentals_in_shop and pseudorandom((area == G.pack_cards and 'packssjr' or 'ssjr')..G.GAME.round_resets.ante) > 0.7 then
                    card:set_rental(true)
                end
            end

            if edition_append then
                if forced_edition == nil then
                    local edition = poll_edition('edi'..(key_append or '')..G.GAME.round_resets.ante)
                    card:set_edition(edition)
                else
                    card:set_edition(forced_edition)
                end
                check_for_unlock({type = 'have_edition'})
            end
        end
        return card
    end
end
----------------------------------------------
------------MOD CODE END----------------------