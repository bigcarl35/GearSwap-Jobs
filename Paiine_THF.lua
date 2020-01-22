-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

--[[
    Custom commands:
    gs c cycle treasuremode (set on ctrl-= by default): Cycles through the available treasure hunter modes.
    
    Treasure hunter modes:
        None - Will never equip TH gear
        Tag - Will equip TH gear sufficient for initial contact with a mob (either melee, ranged hit, or Aeolian Edge AOE)
        SATA - Will equip TH gear sufficient for initial contact with a mob, and when using SATA
        Fulltime - Will keep TH gear equipped fulltime
		
	Supported sub jobs: DNC, NIN, WAR
--]]

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    
    include('Mote-TreasureHunter')

    -- For th_action_check():
    -- JA IDs for actions that always have TH: Provoke, Animated Flourish
    info.default_ja_ids = S{35, 204}
    -- Unblinkable JA IDs for actions that always have TH: Quick/Box/Stutter Step, Desperate/Violent Flourish
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal', 'Acc', 'Mod')
    state.HybridMode:options('Normal', 'Evasion', 'PDT')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
    state.PhysicalDefenseMode:options('Evasion', 'PDT')


    gear.default.weaponskill_neck = "Pentalagus Charm"
    gear.default.weaponskill_waist = "Cetl Belt"
    -- gear.AugQuiahuiz = {name="Quiahuiz Trousers", augments={'Haste+2','"Snapshot"+2','STR+8'}}

    -- Additional local binds
    send_command('bind ^` input /ja "Flee" <me>')
    send_command('bind ^= gs c cycle treasuremode')
    send_command('bind !- gs c cycle targetmode')

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
	send_command('unbind ^=')
    send_command('unbind !-')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    -------------------------------------
	-- Define items that are augmented --
	--------------------------------------
	Toutatis = {}
    --Toutatis.STP = { name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Phys. dmg. taken-10%'}}
    Toutatis.WSD = { name="Toutatis's Cape", augments={'Accuracy+11 Attack+11'}}
	
    --------------------------------------
    -- Special sets (required by rules)
    --------------------------------------

    sets.TreasureHunter = {}
    sets.ExtraRegen = {ring2="Meghanada Ring"}
    sets.Kiting = {}

	-- Sneak Attack is about DEX, takes advantage of elemental neck/waist
    sets.buff['Sneak Attack'] = {
		head="Meghanada Visor +1",
		neck=gear.ElementalGorget,
		ear1="Suppanomimi",
		ear2="Mache Earring",
        body="Mummu Jacket +1",
		hands="Meghanada gloves +1",
		ring1="Mummu Ring",
		ring2="Enlivened Ring",
        back=Toutatis.WSD,
		waist="Panthalassa sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada jambeaux +1"}

	-- Trick Attack is about AGI, takes advantage of elemental neck/waist
    sets.buff['Trick Attack'] = {
		head="Meghanada visor +1",
		neck=gear.ElementalGorget,
		ear1="Allegro Earring",
		ear2="Mache Earring",
        body="Mummu Jacket +1",
		hands="Mummu Wrists +1",
		ring1="Mummu Ring",
		ring2="Meghanada Ring",
        back="Meanagh Cape +1",
		waist="Cetl Belt",
		legs="Meghanada chausses +1",
		feet="Meghanada jambeaux +1"}

    -- Actions we want to use to tag TH.
    sets.precast.Step = sets.TreasureHunter
    sets.precast.Flourish1 = sets.TreasureHunter
    sets.precast.JA.Provoke = sets.TreasureHunter


    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs
    sets.precast.JA['Collaborator'] = {} -- {head="Raider's Bonnet +2"}
    sets.precast.JA['Accomplice'] = {} -- {head="Raider's Bonnet +2"}
    sets.precast.JA['Flee'] = {feet="Rogue's Poulaines"}
    sets.precast.JA['Hide'] = {body="Rogue's Vest"}
    sets.precast.JA['Conspirator'] = {} -- {body="Raider's Vest +2"}
    sets.precast.JA['Steal'] = {head="Rogue's Bonnet",
		neck="Pentalagus charm",
		legs="Rogue's Culottes",
		feet="Rogue's Poulaines"}
    sets.precast.JA['Despoil'] = {} -- {legs="Raider's Culottes +2",feet="Raider's Poulaines +2"}
    sets.precast.JA['Perfect Dodge'] = {} -- {hands="Plunderer's Armlets +1"}
    sets.precast.JA['Feint'] = {} -- {legs="Assassin's Culottes +2"}
	sets.precast.JA['Mug'] = {} -- {head="Assassin's bonnet"}
	sets.precast.JA["Assassin's Charge"] = {back=Toutatis.WSD}

    sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
    sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']
	
	-- /WAR job abilities
	sets.precast.JA['Warcry'] = {}
	sets.precast.JA['Berserk'] = {}
	sets.precast.JA['Aggressor'] = {}

	-- /DNC job abilities
    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
		head="Meghanada Visor +1",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		waist="Royal Knight's Belt",
		legs="Mummu Kecks +1",
		feet="Meghanada Jambeaux +1"}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

	-- tends to be for /NIN
    -- Fast cast sets for spells
    sets.precast.FC = {}
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})

    -- Ranged snapshot gear
    sets.precast.RA = {
		head="Meghanada Visor +1",
		hands="Meghanada Gloves +1",
		waist="Royal Knight's Belt",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}

    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		head="Meghanada Visor +1",
		neck=gear.ElementalGorget,
		ear1="Suppanomimi",
		ear2="Mache Earring",
        body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Meghanada Ring",
        back=Toutatis.WSD,
		waist="Cetl Belt",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {ear1="Kemas Earring"})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	-- Exenterator is about AGI, Fragmentation/Scission (Lightning/Wind, Soil), Light if under Aeonic Aftermath, 73~85% AGI
    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
		ear1="Allegro Earring",
		back="Meanagh Cape +1"})
    sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'], {})
    sets.precast.WS['Exenterator'].Mod = set_combine(sets.precast.WS['Exenterator'], {waist=gear.ElementalBelt})
    sets.precast.WS['Exenterator'].SA = set_combine(sets.precast.WS['Exenterator'].Mod, {})
    sets.precast.WS['Exenterator'].TA = set_combine(sets.precast.WS['Exenterator'].Mod, {})
    sets.precast.WS['Exenterator'].SATA = set_combine(sets.precast.WS['Exenterator'].Mod, {})
	
	-- Dancing Edge is about DEX/CHR, Scission/Detonation (Soil, Wind), 40% DEX/40% CHR
    sets.precast.WS['Dancing Edge'] = set_combine(sets.precast.WS, {
		ring2="Enlivened Ring",
		back="Meanagh Cape +1"})
    sets.precast.WS['Dancing Edge'].Acc = set_combine(sets.precast.WS['Dancing Edge'], {})
    sets.precast.WS['Dancing Edge'].Mod = set_combine(sets.precast.WS['Dancing Edge'], {waist=gear.ElementalBelt})
    sets.precast.WS['Dancing Edge'].SA = set_combine(sets.precast.WS['Dancing Edge'].Mod, {})
    sets.precast.WS['Dancing Edge'].TA = set_combine(sets.precast.WS['Dancing Edge'].Mod, {})
    sets.precast.WS['Dancing Edge'].SATA = set_combine(sets.precast.WS['Dancing Edge'].Mod, {})

	-- Evisceration is about DEX, Gravitation/Transfixion (Soil/Dark, Light), 50% DEX
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
		ring2="Enlivened Ring",
		back="Meanagh Cape +1"})
    sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {})
	sets.precast.WS['Evisceration'].Mod = set_combine(sets.precast.WS['Evisceration'], {waist=gear.ElementalBelt})
    sets.precast.WS['Evisceration'].SA = set_combine(sets.precast.WS['Evisceration'].Mod, {})
    sets.precast.WS['Evisceration'].TA = set_combine(sets.precast.WS['Evisceration'].Mod, {})
    sets.precast.WS['Evisceration'].SATA = set_combine(sets.precast.WS['Evisceration'].Mod, {})
	
	--[[
	-- Rudra's Storm is about DEX, Darkness/Distortion (Ice/Soil/Water/Dark, Ice/Water)
    sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {ring2="Enlivened Ring",back="Meanagh Cape +1"})
    sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {})
    --sets.precast.WS["Rudra's Storm"].Mod = set_combine(sets.precast.WS["Rudra's Storm"], {waist=gear.ElementalBelt})
    sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"].Mod, {body="Mummu Jacket +1",
		legs="Meghanada Chausses +1"})
    sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"].Mod, {body="Mummu Jacket +1",
		legs="Meghanada Chausses +1"})
    sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"].Mod, {body="Mummu Jacket +1",
		legs="Meghanada Chausses +1"})
]]--

	-- Shark Bite is about DEX/AGI, Fragmentation (Lightening/Wind), 40% DEX/40% AGI
    sets.precast.WS["Shark Bite"] = set_combine(sets.precast.WS, {
		body="Mummu Jacket +1",
		ear1="Allegro Earring",
		ring2="Enlivened Ring",
		back="Meanagh Cape +1"})
    sets.precast.WS['Shark Bite'].Acc = set_combine(sets.precast.WS['Shark Bite'], {})
    sets.precast.WS['Shark Bite'].Mod = set_combine(sets.precast.WS['Shark Bite'], {waist=gear.ElementalBelt})
    sets.precast.WS['Shark Bite'].SA = set_combine(sets.precast.WS['Shark Bite'].Mod, {
		body="Mummu Jacket +1",
		legs="Meghanada Chausses +1"})
    sets.precast.WS['Shark Bite'].TA = set_combine(sets.precast.WS['Shark Bite'].Mod, {
		body="Mummu Jacket +1",
		legs="Meghanada Chausses +1"})
    sets.precast.WS['Shark Bite'].SATA = set_combine(sets.precast.WS['Shark Bite'].Mod, {
		body="Mummu Jacket +1",
		legs="Meghanada Chausses +1"})

--[[
	-- Mandalic Stab is about DEX, Fusion/Compression (Fire/Light, Dark)
	sets.precast.WS['Mandalic Stab'] = set_combine(sets.precast.WS, {ring2="Enlivened Ring",back="Meanagh Cape +1"})
    sets.precast.WS['Mandalic Stab'].Acc = set_combine(sets.precast.WS['Mandalic Stab'], {})
    --sets.precast.WS['Mandalic Stab'].Mod = set_combine(sets.precast.WS['Mandalic Stab'], {waist=gear.ElementalBelt})
    sets.precast.WS['Mandalic Stab'].SA = set_combine(sets.precast.WS['Mandalic Stab'].Mod, {})
    sets.precast.WS['Mandalic Stab'].TA = set_combine(sets.precast.WS['Mandalic Stab'].Mod, {})
    sets.precast.WS['Mandalic Stab'].SATA = set_combine(sets.precast.WS['Mandalic Stab'].Mod, {})
]]--

	-- Aeolian Edge is about DEX/INT, Impaction/Scission/Detonation, 40% DEX/40% INT
    sets.precast.WS['Aeolian Edge'] = {
		head="Mummu Bonnet +1",
		ring2="Enlivened Ring",
        back="Meanagh Cape +1",
		waist="Royal Knight Belt",
		legs="Mummu Kecks +1"}

    sets.precast.WS['Aeolian Edge'].TH = set_combine(sets.precast.WS['Aeolian Edge'], sets.TreasureHunter)

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {}

    -- Specific spells
    sets.midcast.Utsusemi = {		
		head="Mummu Bonnet +1",
		body="Mummu Jacket +1",
		hands="Mummu Wrists +1",
		waist="Panthalassa Sash",
		legs="Mummu Kecks +1",
		feet="Mummu Gamashes +1"}	-- Haste and Fast Cast gear

    -- Ranged gear
    sets.midcast.RA = {
		head= "Meghanada Visor +1",
		neck="Pentalagus Charm",
		ear1="Suppanomimi",
		ear2="Mache Earring",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Meghanada Ring",
		back=Toutatis.WSD,
		waist="Panthalassa Sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}

	-- Ranged gear emphasizing Accuracy
    sets.midcast.RA.Acc = {
		head="Meghanada Visor +1",
		neck="Pentalagus Charm",
	    ear1="Suppanomimi",
		ear2="Mache Earring",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Meghanada Ring",
        back=Toutatis.WSD,
		waist="Panthalassa Sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}

    --------------------------------------
    -- Idle/resting/defense sets
    --------------------------------------

    -- Resting sets --
    sets.resting = {ring2="Meghanada Ring"}

    -- Idle sets -- 

    sets.idle = {
		head="Espial Cap",
		neck="Pentalagus Charm",
		ear1="Suppanomimi",
		ear2="Mache Earring",
        body="Rogue's Vest",
		hands="Rogue's Armlets",
		ring1="Mummu Ring",
		ring2="Warp Ring",
        back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Rogue's Culottes",
		feet="Rogue's Poulaines"}

	-- Idle in Town
    sets.idle.Town = {
		head="Espial Cap",
		neck="Pentalagus Charm",
		ear1="Suppanomimi",
		ear2="Mache Earring",
        body="Rogue's Vest",
		hands="Rogue's Armlets",
		ring1="Mummu Ring",
		ring2="Warp Ring",
        back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Rogue's Culottes",
		feet="Rogue's Poulaines"}

	-- Idled Weakened
    sets.idle.Weak = {
		head="Meghanada Visor +1",
		neck="Pentalagus Charm",
		ear1="Allegro Earring",
		ear2="Mache Earring",
        body="Mummu Jacket +1",
		hands="Mummu Wrists +1",
		ring1="Mummu Ring",
		ring2="Meghanada Ring",
        back="Meanagh Cape +1",
		waist="Cetl Belt",
		legs="Mummu Kecks +1",
		feet="Mummu Gamashes +1"}


    -- Defense sets --
	-- Evasion Defense
    sets.defense.Evasion = {
		head="Mummu Bonnet +1",
		neck="Pentalagus Charm",
		ear1="Allegro Earring",
		ear2="Mache Earring",
        body="Mummu Jacket +1",
		hands="Mummu Wrists +1",
		ring1="Mummu Ring",
		ring2="Meghanada Ring",
        back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Mummu Kecks +1",
		feet="Mummu Gamashes +1"}
		
	-- Physical Damage Defense - Physical Damage Mitigation
    sets.defense.PDT = {
		head="Meghanada Visor +1",
		neck="Pentalagus Charm",
		ear1="Allegro Earring",
		ear2="Mache Earring",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Enlivened Ring",
		back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}

	-- Magical Damage defense - Magical Damage Mitigation, Magical Defense bonus, Magical Evasion
    sets.defense.MDT = {
		head="Mummu Bonnet +1",
		neck="Pentalagus Charm",
		ear1="Allegro Earring",
		ear2="Mache Earring",
		body="Mummu Jacket +1",
		hands="Mummu Wrists +1",
		ring1="Mummu Ring",
		ring2="Enlivened Ring",
		back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Mummu Kecks +1",
		feet="Mummu Gamashes +1"}

    --------------------------------------
    -- Melee sets
    --------------------------------------

    -- Normal melee group
    sets.engaged = {
		head="Mummu Bonnet +1",
		neck="Pentalagus Charm",
		ear1="Suppanomimi",
		ear2="Mache Earring",
        body="Mummu Jacket +1",
		hands="Mummu Wrists +1",
		ring1="Mummu Ring",
		ring2="Meghanada Ring",
        back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Mummu Kecks +1",
		feet="Mummu Gamashes +1"}
		
	-- Engaged with Accuracy
    sets.engaged.Acc = {
		head="Meghanada Visor +1",
		neck="Pentalagus Charm",
		ear1="Kemas Earring",
		ear2="Mache Earring",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Enlivened Ring",
        back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}
        
    -- Mod set for trivial mobs (Skadi+1)
    sets.engaged.Mod = {}

    -- Mod set for trivial mobs (Thaumas)
    sets.engaged.Mod2 = {}

	-- Engaged with Evasion emphasis
    sets.engaged.Evasion = set_combine(sets.engaged, {ear1="Allegro Earring"})
	
	-- Engaged with Accuracy and Evasion emphasis
    sets.engaged.Acc.Evasion = {
		head="Meghanada Visor +1",
		neck="Pentalagus Charm",
		ear1="Allegro Earring",
		ear2="Mache Earring",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Enlivened Ring",
        back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}

	-- Engaged with Physical Damage Reduction
    sets.engaged.PDT = {
		head="Meghanada Visor +1",
		neck="Pentalagus Charm",
		ear1="Allegro Earring",
		ear2="Mache Earring",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Enlivened Ring",
		back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}

	-- Engaged with Accuracy and Physical Damage Reduction
    sets.engaged.Acc.PDT = {
		head="Meghanada Visor +1",
		neck="Pentalagus Charm",
		ear1="Allegro Earring",
		ear2="Mache Earring",
		body="Meghanada Cuirie +1",
		hands="Meghanada Gloves +1",
		ring1="Mummu Ring",
		ring2="Enlivened Ring",
		back="Meanagh Cape +1",
		waist="Panthalassa Sash",
		legs="Meghanada Chausses +1",
		feet="Meghanada Jambeaux +1"}

end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.type == 'Trust' then
		-- Summoning a trust. Equip gear that adds levels to trusts here
	else
		if spell.english == 'Aeolian Edge' and state.TreasureMode.value ~= 'None' then
			equip(sets.TreasureHunter)
		elseif spell.english=='Sneak Attack' or spell.english=='Trick Attack' or spell.type == 'WeaponSkill' then
			if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
				equip(sets.TreasureHunter)
			end
        end
    end
	
end

-- Run after the general midcast() set is constructed.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.TreasureHunter)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Weaponskills wipe SATA/Feint.  Turn those state vars off before default gearing is attempted.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end
end

-- Called after the default aftercast handling is complete.
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- If Feint is active, put that gear set on on top of regular gear.
    -- This includes overlaying SATA gear.
    check_buff('Feint', eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    if state.Buff[buff] ~= nil then
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function get_custom_wsmode(spell, spellMap, defaut_wsmode)
    local wsmode

    if state.Buff['Sneak Attack'] then
        wsmode = 'SA'
    end
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA'
    end

    return wsmode
end


-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Check that ranged slot is locked, if necessary
    check_range_lock()

    -- Check for SATA when equipping gear.  If either is active, equip
    -- that gear specifically, and block equipping default gear.
    check_buff('Sneak Attack', eventArgs)
    check_buff('Trick Attack', eventArgs)
end


function customize_idle_set(idleSet)
    if player.hpp < 80 then
        idleSet = set_combine(idleSet, sets.ExtraRegen)
    end

    return idleSet
end


function customize_melee_set(meleeSet)
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end

    return meleeSet
end


-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    th_update(cmdParams, eventArgs)
end

-- Function to display the current relevant user state when doing an update.
-- Return true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
    local msg = 'Melee'
    
    if state.CombatForm.has_value then
        msg = msg .. ' (' .. state.CombatForm.value .. ')'
    end
    
    msg = msg .. ': '
    
    msg = msg .. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ', WS: ' .. state.WeaponskillMode.value
    
    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end
    
    if state.Kiting.value == true then
        msg = msg .. ', Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end
    
    msg = msg .. ', TH: ' .. state.TreasureMode.value

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
        equip(sets.buff[buff_name] or {})
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
        eventArgs.handled = true
    end
end


-- Check for various actions that we've specified in user code as being used with TH gear.
-- This will only ever be called if TreasureMode is not 'None'.
-- Category and Param are as specified in the action event packet.
function th_action_check(category, param)
    if category == 2 or -- any ranged attack
        --category == 4 or -- any magic action
        (category == 3 and param == 30) or -- Aeolian Edge
        (category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
        (category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
        then return true
    end
end


-- Function to lock the ranged slot if we have a ranged weapon equipped.
function check_range_lock()
    if player.equipment.range ~= 'empty' then
        disable('range', 'ammo')
    else
        enable('range', 'ammo')
    end
end


-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(1, 4)
    elseif player.sub_job == 'NIN' then
        set_macro_page(2, 4)
	elseif player.sub_job == 'WAR' then	
		set_macro_page(3, 4)
    else
        set_macro_page(1, 4)
    end
end