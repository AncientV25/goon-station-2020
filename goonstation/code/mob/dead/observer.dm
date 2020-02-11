// Observer

/mob/dead/observer
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	event_handler_flags = 0//USE_FLUID_ENTER  //maybe?
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1	//  don't get pushed around
	var/mob/corpse = null	//	observer mode
	var/observe_round = 0
	var/health_shown = 0
	var/delete_on_logout = 1
	var/delete_on_logout_reset = 1
	var/obj/item/clothing/head/wig/wig = null

	var/datum/hud/ghost_observer/hud

	mob_flags = MOB_HEARS_ALL

/mob/dead/observer/disposing()
	corpse = null
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		src.abilityHolder:remove_all_abilities()
		src.abilityHolder.owner = null
	if (hud)
		hud.disposing()

	..()

/mob/dead/observer/Login()
	..()
	if(src.client)
		src.updateOverlaysClient(src.client)
		src.updateButtons()

#define GHOST_LUM	1		// ghost luminosity

/mob/dead/observer/proc/apply_looks_of(var/client/C)
	if (!C.preferences)
		return
	var/datum/preferences/P = C.preferences

	if (!P.AH)
		return

	var/cust_one_state = customization_styles[P.AH.customization_first]
	var/cust_two_state = customization_styles[P.AH.customization_second]
	var/cust_three_state = customization_styles[P.AH.customization_third]

	var/image/hair = image('icons/mob/human_hair.dmi', cust_one_state)
	hair.color = P.AH.customization_first_color
	hair.alpha = 192
	overlays += hair

	wig = new
	wig.mat_changename = 0
	var/datum/material/wigmat = getMaterial("ectofibre")
	wigmat.color = P.AH.customization_first_color
	wig.setMaterial(wigmat)
	wig.name = "ectofibre [name]'s hair"
	wig.icon = 'icons/mob/human_hair.dmi'
	wig.icon_state = cust_one_state
	wig.color = P.AH.customization_first_color
	wig.wear_image_icon = 'icons/mob/human_hair.dmi'
	wig.wear_image = image(wig.wear_image_icon, wig.icon_state)
	wig.wear_image.color = P.AH.customization_first_color


	var/image/beard = image('icons/mob/human_hair.dmi', cust_two_state)
	beard.color = P.AH.customization_second_color
	beard.alpha = 192
	overlays += beard

	var/image/detail = image('icons/mob/human_hair.dmi', cust_three_state)
	detail.color = P.AH.customization_third_color
	detail.alpha = 192
	overlays += detail

	if (!src.bioHolder) //For critter spawns
		var/datum/bioHolder/newbio = new/datum/bioHolder(src)
		newbio.mobAppearance.customization_first_color = hair.color
		newbio.mobAppearance.e_color = P.AH.e_color
		src.bioHolder = newbio


//#ifdef HALLOWEEN
/mob/dead/observer/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (src.icon_state != "doubleghost" && istype(mover, /obj/projectile))
		var/obj/projectile/proj = mover
		if (istype(proj.proj_data, /datum/projectile/energy_bolt_antighost))
			return 0

	return 1

/mob/dead/observer/bullet_act(var/obj/projectile/P)
	if (src.icon_state == "doubleghost")
		return

	src.icon_state = "doubleghost"
	src.visible_message("<span style=\"color:red\"><b>[src] is busted!</b></span>","<span style=\"color:red\">You are demateralized into a state of further death!</span>")

	if (wig)
		wig.loc = src.loc
	new /obj/item/reagent_containers/food/snacks/ectoplasm(get_turf(src))
	overlays.len = 0
	log_shot(P,src)


//#endif

/mob/dead/observer/Life(datum/controller/process/mobs/parent)
#ifdef HALLOWEEN
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
		GH.change_points(1)
		GH.points_since_last_tick = 0
		// src.abilityHolder.getAbility(/datum/targetable/ghost_observer/spooktober_hud).Stat()
#endif
	if (..(parent))
		return 1
	if (src.client && src.client.holder) //ov1
		// overlays
		//src.updateOverlaysClient(src.client)
		src.antagonist_overlay_refresh(0, 0) // Observer Life() only runs for admin ghosts (Convair880).

#ifdef TWITCH_BOT_ALLOWED
	if (IS_TWITCH_CONTROLLED(src))
		var/list/candidates = list()
		for(var/mob/M in mobs)
			if (M.client && isliving(M) && !M.unobservable)
				candidates += M
		if (candidates.len)
			SPAWN_DBG(50)
				src.insert_observer(pick(candidates))
#endif

	return

/mob/dead/observer/proc/updateButtons()
	if (abilityHolder)
		abilityHolder.updateButtons()
	else
		boutput(src, "ability buttons are broken call 1-800-CODER!!!")

/mob/dead/observer/New(mob/corpse)
	. = ..()
	src.invisibility = 10
	src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	src.see_invisible = 16
	src.see_in_dark = SEE_DARK_FULL
	animate_bumble(src) // floaty ghosts  c:

	if(corpse && ismob(corpse))
		src.corpse = corpse
		src.set_loc(get_turf(corpse))
		src.real_name = corpse.real_name
		src.name = corpse.real_name
		src.verbs += /mob/dead/observer/proc/reenter_corpse

	hud = new(src)
	src.attach_hud(hud)

	if (!abilityHolder)
		abilityHolder = new /datum/abilityHolder/ghost_observer(src)
		abilityHolder.owner = src

	updateButtons()

	SPAWN_DBG(5)
		if (src.mind && istype(src.mind.purchased_bank_item, /datum/bank_purchaseable/golden_ghost))
			src.setMaterial(getMaterial("gold"))
//#ifdef HALLOWEEN
//	src.sd_SetLuminosity(GHOST_LUM) // comment all of these back out after hallowe'en
//#endif

/mob/living/verb/become_ghost()
	set src = usr
	set name = "Ghost"
	set category = "Commands"
	set desc = "Leave your lifeless body behind and become a ghost."

	if(!isdead(src))
		if (src.hibernating == 1)
			var/confirm = alert("Are you sure you want to enter long term cryogenic storage and observe? You will not be able to play this round!", "Observe?", "Yes", "No")
			if(confirm)
				src.ghostize()
				qdel(src)
		else if(prob(5))
			src.show_text("You strain really hard. I mean, like, really, REALLY hard but you still can't become a ghost!", "blue")
		else
			src.show_text("You're not dead yet!", "red")
		return
	src.ghostize()



/mob/proc/ghostize()
	if(src.key || src.client)
		if(src.mind && src.mind.damned) // Wow so much sin. Off to hell with you.
			src.hell_respawn(src.mind)
			return null
		var/mob/dead/observer/O = new/mob/dead/observer(src)
		if (isghostrestrictedz(O.z) && !restricted_z_allowed(O, get_turf(O)) && !(src.client && src.client.holder))
			var/OS = observer_start.len ? pick(observer_start) : locate(150, 150, 1)
			if (OS)
				O.set_loc(OS)
			else
				O.z = 1
		if (client) client.color = null  //needed for mesons dont kill me thx - ZeWaka
		if (src.client && src.client.holder && src.stat !=2)
			setalive(O)
		if(src.mind)
			src.mind.transfer_to(O)
		src.ghost = O
		if(istype(get_area(src),/area/afterlife))
			qdel(src)
		O.update_item_abilities()
		return O
	return null


/mob/dead/observer/movement_delay()
	if (src.client && src.client.check_key(KEY_RUN))
		return 0.4 + movement_delay_modifier
	else
		return 0.75 + movement_delay_modifier

/mob/dead/observer/build_keymap(client/C)
	var/datum/keymap/keymap = ..()
	keymap.merge(client.get_keymap("human"))
	return keymap

/mob/dead/observer/is_spacefaring()
	return 1

/mob/living/carbon/human/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	. = O

	if (glasses)
		var/image/glass = image(glasses.wear_image_icon, glasses.icon_state)
		glass.color = glasses.color
		glass.alpha = glasses.alpha * 0.75
		O.overlays += glass

	if (src.bioHolder) //Not necessary for ghost appearance, but this will be useful if the ghost decides to respawn as critter.
		var/image/hair = image('icons/mob/human_hair.dmi', cust_one_state)
		hair.color = src.bioHolder.mobAppearance.customization_first_color
		hair.alpha = 192
		O.overlays += hair

		var/image/beard = image('icons/mob/human_hair.dmi', src.cust_two_state)
		beard.color = src.bioHolder.mobAppearance.customization_second_color
		beard.alpha = 192
		O.overlays += beard

		var/image/detail = image('icons/mob/human_hair.dmi', src.cust_three_state)
		detail.color = src.bioHolder.mobAppearance.customization_third_color
		detail.alpha = 192
		O.overlays += detail

		O.wig = new
		O.wig.mat_changename = 0
		var/datum/material/wigmat = getMaterial("ectofibre")
		wigmat.color = src.bioHolder.mobAppearance.customization_first_color
		O.wig.setMaterial(wigmat)
		O.wig.name = "[O.name]'s hair"
		O.wig.icon = 'icons/mob/human_hair.dmi'
		O.wig.icon_state = cust_one_state
		O.wig.color = src.bioHolder.mobAppearance.customization_first_color
		O.wig.wear_image_icon = 'icons/mob/human_hair.dmi'
		O.wig.wear_image = image(O.wig.wear_image_icon, O.wig.icon_state)
		O.wig.wear_image.color = src.bioHolder.mobAppearance.customization_first_color



		var/datum/bioHolder/newbio = new/datum/bioHolder(O)
		newbio.CopyOther(src.bioHolder)
		O.bioHolder = newbio
		// cirr fix for mutations carrying over to ghosts leading to awful side-effects like ghostly irradiating
		// for now keep glow because it amuses me very much, but we'll take that out if people abuse it
		var/datum/bioEffect/glowy/G = null
		if(O.bioHolder.HasEffect("glowy"))
			G = O.bioHolder.GetEffect("glowy")
		O.bioHolder.RemoveAllEffects()
		// add the glow back if it exists
		if(istype(G))
			O.bioHolder.AddEffect(G)

	return O

/mob/living/silicon/robot/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	O.icon_state = "borghost"
	return O

/mob/dead/observer/verb/show_health()
	set category = "Ghost"
	set name = "Toggle Health"
	client.images.Remove(health_mon_icons)
	if (!health_shown)
		health_shown = 1
		if(client && client.images)
			for(var/image/I in health_mon_icons)
				if (I && src && I.loc != src.loc)
					client.images.Add(I)
	else
		health_shown = 0


/mob/dead/observer/verb/ai_laws()
	set name = "AI Laws"
	set desc = "Displays the current AI laws. You must have DNR on to use this."
	set category = "Ghost"

	if(!mind || !mind.dnr)
		boutput( usr, "<span style='color:red'>You must enable DNR to use this.</span>" )
		return

	if(!ticker || !ticker.centralized_ai_laws)
		boutput( src, "Abort abort abort! No laws! No laws!!" )
		return

	boutput( src, "<b>AI laws:</b>" )
	ticker.centralized_ai_laws.show_laws(usr)


/mob/dead/observer/Logout()
	..()
	if(last_client)
		last_client.images.Remove(health_mon_icons)


	if(!src.key && delete_on_logout)
		qdel(src)
	return

/mob/dead/observer/Move(NewLoc, direct)
	if(!canmove) return

	if (NewLoc && isghostrestrictedz(src.z) && !restricted_z_allowed(src, NewLoc) && !(src.client && src.client.holder && !src.client.holder.tempmin))
		var/OS = observer_start.len ? pick(observer_start) : locate(1, 1, 1)
		if (OS)
			src.set_loc(OS)
		else
			src.z = 1
		return OnMove()

	if (!isturf(src.loc))
		src.set_loc(get_turf(src))
	if (NewLoc)
		dir = get_dir(loc, NewLoc)
		src.set_loc(NewLoc)
		OnMove()
		return

	dir = direct
	if((direct & NORTH) && src.y < world.maxy)
		src.y++
	if((direct & SOUTH) && src.y > 1)
		src.y--
	if((direct & EAST) && src.x < world.maxx)
		src.x++
	if((direct & WEST) && src.x > 1)
		src.x--
	OnMove()

/mob/dead/observer/MouseDrop(atom/A)
	if (usr != src || isnull(A)) return
	if (ismob(A))
		var/mob/M = A
		if (!M.unobservable || isadmin(src))
			if (isadmin(src) || (!isadmin(src) && !isadminghost(M)) )
				src.insert_observer(A)
				return
	if (!istype(A,/turf))
		src.Move(get_turf(A.loc))
		return
	src.Move(A)

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/proc/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!corpse)
		alert("You don't have a corpse!")
		return
	if(src.client && src.client.holder && src.client.holder.state == 2)
		var/rank = src.client.holder.rank
		src.client.clear_admin_verbs()
		src.client.holder.state = 1
		src.client.update_admins(rank)
	if (src.mind)
		src.mind.transfer_to(corpse)
	qdel(src)

/mob/dead/observer/verb/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport"
	if((!isdead(usr)) || !isobserver(usr))
		boutput(usr, "Not when you're not dead!")
		return
	var/A

	A = input("Area to jump to", "BOOYEA", A) in get_teleareas()
	var/area/thearea = get_telearea(A)
	var/list/L = list()
	if (!istype(thearea))
		return

	for(var/turf/T in get_area_turfs(thearea.type))
		if (isghostrestrictedz(T.z)) //fffffuckk you
			continue
		L+=T

	if (L && L.len) //ZeWaka: Fix for pick() from empty list
		usr.set_loc(pick(L))
		OnMove()
	else
		boutput(usr, "Couldn't find anywhere in that area to go to!")

/mob/dead/observer/say_understands(var/other)
	return 1

/* //dont need this anymores
/mob/dead/observer/verb/toggle_wide()
	set name = "Toggle Widescreen"
	set category = "Ghost"

	src.client.set_widescreen(!src.client.widescreen)
*/

//Commented out, not sure if this is safe for the average player (might cause lags?)
/*
/mob/dead/observer/verb/set_view()
	set name = "Set View Size"
	//set category = "Ghost"
	// ooooo its a secret, oooooo!!

	if(!mind || !mind.dnr)
		boutput( usr, "<span style='color:red'>You must enable DNR to use this.</span>" )
		return

	var/x = input("Enter view width in tiles: (Capped at 59)", "Width", 15)
	var/y = input("Enter view height in tiles: (Capped at 30)", "Height", 15)
	src.client.set_view_size(x,y)
	//We don't need to worry about resetting view size when the player is revived or somesuch. The widescreen funcs will do that for us.
*/

/mob/dead/observer/verb/toggle_lighting()
	set name = "Toggle Lighting"
	set category = "Ghost"

	var/atom/plane = client.get_plane(PLANE_LIGHTING)
	if (plane)
		plane.alpha = plane.alpha ? 0 : 255
	else
		boutput( usr, "Well, I want to, but you don't have any lights to fix!" )

/mob/dead/observer/verb/toggle_ability_buttons()
	set name = "Toggle Ability Buttons"
	set category = "Ghost"

	var/datum/abilityHolder/ghost_observer/GAH = src.abilityHolder
	if (istype(GAH))
		GAH.toggle()
		boutput( usr, "[GAH.display_buttons ? "Showing" : "Hiding"] buttons." )


/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	//prefix list with option for alphabetic sorting
	var/const/SORT = "* Sort alphabetically..."
	creatures.Add(SORT)

	for (var/client/C in clients)
		LAGCHECK(LAG_LOW)
		// not sure how this could happen, but be safe about it
		if (!C.mob)
			continue
		var/mob/M = C.mob
		// remove some types you cannot observe
		if (!isliving(M) && !iswraith(M) && !isAI(M))
			continue
		// remove any secret mobs that someone is controlling
		if (M.unobservable)
			continue
		// add to list
		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if (M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if (isliving(M) && isdead(M) && !isAI(M))
			name += " \[dead\]"
		creatures[name] = M

	var/eye_name = null

	eye_name = input("Please, select a target!", "Observe", null, null) as null|anything in creatures

	//sort alphabetically if user so chooses
	if (eye_name == SORT)
		creatures.Remove(SORT)

		creatures = sortList(creatures)

		//redisplay sorted list
		eye_name = input("Please, select a target!", "Observe (Sorted)", null, null) as null|anything in creatures

	if (!eye_name)
		return

	insert_observer(creatures[eye_name])


/mob/dead/observer/verb/observe_object()
	set name = "Observe Objects"
	set category = "Ghost"

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	//prefix list with option for alphabetic sorting
	var/const/SORT = "* Sort alphabetically..."
	creatures.Add(SORT)

	// Same thing you could do with the old auth disk. The bomb is equally important
	// and should appear at the top of any unsorted list  (Convair880).
	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/nuclear))
		var/datum/game_mode/nuclear/N = ticker.mode
		if (N.the_bomb && istype(N.the_bomb, /obj/machinery/nuclearbomb/))
			var/name = "Nuclear bomb"
			if (name in names)
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = N.the_bomb

	for (var/obj/observable/O in world)
		LAGCHECK(LAG_LOW)
		var/name = O.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = O

	for (var/obj/item/ghostboard/GB in world)
		LAGCHECK(LAG_LOW)
		var/name = "Ouija board"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = GB

	for (var/obj/item/gnomechompski/G in world)
		LAGCHECK(LAG_LOW)
		var/name = "Gnome Chompski"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = G

	for (var/obj/cruiser_camera_dummy/CR in world)
		LAGCHECK(LAG_LOW)
		var/name = CR.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = CR

	for (var/obj/item/reagent_containers/food/snacks/prison_loaf/L in world)
		LAGCHECK(LAG_LOW)
		var/name = L.name
		if (name != "strangelet loaf")
			continue
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = L

	for (var/obj/machinery/bot/B in machines)
		LAGCHECK(LAG_LOW)
		if (isghostrestrictedz(B.z)) continue
		var/name = "*[B.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = B

	for (var/obj/item/storage/toolbox/memetic/HG in world)
		LAGCHECK(LAG_LOW)
		var/name = "His Grace"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = HG

	for (var/obj/machinery/portapuke/PP in world)
		var/name = "Port-A-Puke"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = PP

	var/eye_name = null

	for(var/name in creatures)
		var/obj/O = creatures[name]
		if(!istype(O))
			creatures -= name
		else
			var/turf/T = get_turf(O)
			if(!T || isghostrestrictedz(T.z))
				creatures -= name

	eye_name = input("Please, select a target!", "Observe", null, null) as null|anything in creatures

	//sort alphabetically if user so chooses
	if (eye_name == SORT)
		creatures.Remove(SORT)

		for(var/i = 1; i <= creatures.len; i++)
			for(var/j = i+1; j <= creatures.len; j++)
				if(sorttext(creatures[i], creatures[j]) == -1)
					creatures.Swap(i, j)

		//redisplay sorted list
		eye_name = input("Please, select a target!", "Observe (Sorted)", null, null) as null|anything in creatures

	if (!eye_name)
		return

	insert_observer(creatures[eye_name])

mob/dead/observer/proc/insert_observer(var/atom/target)
	var/mob/dead/target_observer/newobs = unpool(/mob/dead/target_observer)
	newobs.set_observe_target(target)
	newobs.name = src.name
	newobs.real_name = src.real_name
	newobs.corpse = src.corpse
	newobs.my_ghost = src
	delete_on_logout_reset = delete_on_logout
	delete_on_logout = 0
	if (target && target.invisibility)
		newobs.see_invisible = target.invisibility
	if (src.corpse)
		corpse.ghost = newobs
	if (src.mind)
		mind.transfer_to(newobs)
	else if (src.client) //Wire: Fix for Cannot modify null.mob.
		src.client.mob = newobs
	set_loc(newobs)
	if (isghostrestrictedz(newobs.z) && !restricted_z_allowed(newobs, get_turf(newobs)) && !(src.client && src.client.holder))
		var/OS = observer_start.len ? pick(observer_start) : locate(150, 150, 1)
		if (OS)
			newobs.set_loc(OS)


// HI IT'S ME CIRR I DON'T KNOW WHERE ELSE TO PUT THIS
var/list/respawn_critter_types = list(/mob/living/critter/small_animal/mouse/weak, /mob/living/critter/small_animal/cockroach/weak, /mob/living/critter/small_animal/butterfly/weak,)
var/list/antag_respawn_critter_types =  list(/mob/living/critter/small_animal/fly/weak, /mob/living/critter/small_animal/mosquito/weak,)
/mob/dead/observer/verb/respawn_as_animal()
	set name = "Respawn as Animal"
	set category = "Ghost"

	// has the game started?
	if(!ticker || !ticker.mode)
		boutput(src, "<span class='text-red'>The game hasn't started yet, silly!</span>")
		return

	// get the mind
	var/datum/mind/mind = src.mind
	if(isnull(src.mind))
		// ok i don't know how this happened but make them a new mind
		if (src.client)
			src.mind = new /datum/mind(src)
			ticker.minds += src.mind
			mind = src.mind
		else
			// why is this happening aaaaa
			return

	// determine if they're allowed to respawn
	var/min_time_passed = 3000 // 5 minutes in byond deciseconds
	if(mind.assigned_role == "Animal")
		// no you get to wait for longer
		min_time_passed = 12000 // 20 minutes
	var/time_elapsed = (world.timeofday + ((world.timeofday < mind.last_death_time) ? 864000 : 0)) - mind.last_death_time // Offset the time of day in case of midnight rollover
	var/time_left = min_time_passed - time_elapsed
	if(time_left > 0)
		var/time_left_message = ""
		var/minutes = round(time_left / 600)
		var/seconds = round((time_left - (minutes * 600))/10)
		if(minutes >= 1)
			time_left_message += "[minutes] minute[minutes == 1 ? "" : "s"] and "
		else
			time_left_message += "[seconds] second[seconds == 1 ? "" : "s"]"
		boutput(src, "<span class='text-red'>You must wait at least [time_left_message] until you can respawn as an animal.</span>")
	else
		if (alert(src, "Are you sure you want to respawn as an animal? You won't be able to come back as a human or cyborg!", "Respawn as Animal", "Yes", "No") != "Yes")
			return
		// you can be an animal
		// get spawnpoints
		var/list/spawns = list()
		for(var/obj/landmark/L in landmarks)
			if (L.name == "peststart")
				spawns.Add(L.loc)
			LAGCHECK(LAG_LOW)
		var/turf/spawnpoint = get_turf(src)
		if(spawns.len >= 1)
			spawnpoint = pick(spawns)
		else
			spawnpoint = latejoin.len ? pick(latejoin) : spawnpoint
		// be critter

		var/mob/living/critter/C
		var/traitor = checktraitor(src)
		if (traitor)
			C = src.make_critter(pick(antag_respawn_critter_types), spawnpoint)
		if (src.mind && istype(src.mind.purchased_bank_item, /datum/bank_purchaseable/critter_respawn))
			var/datum/bank_purchaseable/critter_respawn/critter_respawn = src.mind.purchased_bank_item
			C = src.make_critter(pick(critter_respawn.respawn_critter_types), spawnpoint)
		else
			C = src.make_critter(pick(respawn_critter_types), spawnpoint)

		C.mind.assigned_role = "Animal"
		C.say_language = "animal"
		C.literate = 0
		C.ghost_spawned = 1

		if (traitor)
			C.Browse(grabResource("html/ghostcritter.html"),"window=ghostcritter_antag;size=600x400;title=Ghost Critter Help")
		else
			C.Browse(grabResource("html/ghostcritter.html"),"window=ghostcritter;size=600x400;title=Ghost Critter Help")

		//hacky fix : qdel brain to prevent reviving
		if (C.organHolder)
			var/obj/item/organ/brain/B = C.organHolder.get_organ("brain")
			if (B)
				qdel(B)
