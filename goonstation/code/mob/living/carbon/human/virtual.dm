/mob/living/carbon/human/virtual
	real_name = "Virtual Human"
	var/mob/body = null
	var/isghost = 0 //Should contain a string of the original ghosts real_name
	var/escape_vr = 0


	New()
		..()
		sound_burp = 'sound/voice/virtual_gassy.ogg'
		//sound_malescream = 'sound/voice/virtual_scream.ogg'
		sound_scream = 'sound/voice/virtual_scream.ogg'
		sound_fart = 'sound/voice/virtual_gassy.ogg'
		sound_snap = 'sound/voice/virtual_snap.ogg'
		sound_fingersnap = 'sound/voice/virtual_snap.ogg'
		SPAWN_DBG(0)
			src.set_mutantrace(/datum/mutantrace/virtual)

	Life(datum/controller/process/mobs/parent)
		if (!loc)
			return
		if (..(parent))
			return 1
		var/turf/T = get_turf(src)

		if (!escape_vr)
			var/area/A = get_area(src)
			if ((T && !(T.z == 2 || T.z == 4)) || (A && !A.virtual))
				boutput(src, "<span style=\"color:red\">Is this virtual?  Is this real?? <b>YOUR MIND CANNOT TAKE THIS METAPHYSICAL CALAMITY</b></span>")
				src.gib()
				return

			if(!isghost && src.body)
				if(isdead(src.body) || !src.body:network_device)
					src.gib()
					return
		return

	death(gibbed)
		for (var/atom/movable/a in contents)
			if (a.flags & ISADVENTURE)
				a.set_loc(get_turf(src))

		Station_VNet.Leave_Vspace(src)

		qdel(src)
		return
		..()

	disposing()
		if (isghost && src.client)
			var/mob/dead/observer/O = src.ghostize()
			var/arrival_loc = pick(latejoin)
			O.real_name = src.isghost
			O.name = O.real_name
			O.set_loc(arrival_loc)
		..()

	ex_act(severity)
		src.flash(30)
		if(severity == 1)
			src.death()
		return

	say(var/message) //Handle Virtual Spectres
		if(!isghost)
			return ..()

		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		if (!message)
			return

		if (dd_hasprefix(message, "*"))
			return src.emote(copytext(message, 2),1)

		if (src.client && src.client.ismuted())
			boutput(src, "You are currently muted and may not speak.")
			return

		. = src.say_dead(message, 1)

	emote(var/act, var/voluntary = 0)
		if(isghost)
			if (findtext(act, " ", 1, null))
				var/t1 = findtext(act, " ", 1, null)
				act = copytext(act, 1, t1)
			var/txt = lowertext(act)
			if (txt == "custom" || txt == "customh" || txt == "customv" || txt == "me" || txt == "airquote" || txt == "airquotes")
				boutput(usr, "You may not use that emote as a Virtual Spectre.")
				return
		..()

	whisper(message as text)
		if (isghost)
			boutput(usr, "You may not use that emote as a Virtual Spectre.")
			return
		..()