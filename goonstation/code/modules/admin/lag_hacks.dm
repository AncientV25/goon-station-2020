

client/proc/show_admin_lag_hacks()
	set name = "Lag Reduction"
	set desc = "A few janky commands that can smooth the game during an Emergency."
	set category="Debug"
	admin_only
	src.holder.show_laghacks(src.mob)

/datum/admins/proc/show_laghacks(mob/user)


	var/HTML = "<html><head><title>Admin Lag Reductions</title></head><body>"
	HTML += "<b><a href='?src=\ref[src];action=lightweight_doors'>Remove Light+Cam processing when doors open or close (May jank up lights slightly)</a></b><br>"
	HTML += "<b><a href='?src=\ref[src];action=lightweight_lights'>Slow down the light queue drastically (May jank up lights slightly)</a></b><br>"
	HTML += "<b><a href='?src=\ref[src];action=slow_atmos'>Slow atmos processing (May jank up the TEG/Hellburns)</a></b><br>"
	HTML += "<b><a href='?src=\ref[src];action=slow_fluids'>Slow fluid processing (Safe, just feels weird)</a></b><br>"
	HTML += "<b><a href='?src=\ref[src];action=special_sea_fullbright'>Stop Sea Light processing on Z1 (Safe, makes the Z1 ocean a little ugly)</a></b><br>"
	HTML += "<b><a href='?src=\ref[src];action=slow_ticklag'>Adjust ticklag bounds (Manually adjust ticklag dilation upper and lower bounds! Compensate for lag, or go super smooth at lowpop!)</a></b><br>"

	HTML += "</body></html>"

	user.Browse(HTML,"window=alaghacks")


//fluid_commands.dm
//client/proc/special_fullbright()


client/proc/lightweight_doors()
	set name = "Force Doors Ignore Cameras and Lighting"
	set desc = "Helps when server load is heavy. Might jank up the lighting system a bit, but its mostly OK."
	set category="Debug"
	set hidden = 1
	admin_only

	message_admins("[key_name(src)] is removing light/camera interactions from doors...")
	SPAWN_DBG(0)
		for(var/obj/machinery/door/D in doors)
			D.ignore_light_or_cam_opacity = 1
			LAGCHECK(LAG_REALTIME)
		message_admins("Doors are now less expensive.")


client/proc/lightweight_lights()
	set name = "Kneecap Light Queue"
	set desc = "Helps when server load is heavy."
	set category="Debug"
	set hidden = 1
	admin_only

	if (processScheduler.hasProcess("Lighting"))
		var/datum/controller/process/lighting/L = processScheduler.nameToProcessMap["Lighting"]
		L.max_chunk_size = 5

		message_admins("[key_name(src)] kneecapped the light queue processing speed for less lag.")

client/proc/slow_fluids()
	set name = "Slow Fluid Processing"
	set desc = "Higher schedulde interval."
	set category="Debug"
	set hidden = 1
	admin_only

	if (processScheduler.hasProcess("Fluid_Groups"))
		var/datum/controller/process/fluid_group/P = processScheduler.nameToProcessMap["Fluid_Groups"]
		P.max_schedule_interval = 90

	if (processScheduler.hasProcess("Fluid_Turfs"))
		var/datum/controller/process/P = processScheduler.nameToProcessMap["Fluid_Turfs"]
		P.schedule_interval = 100

	message_admins("[key_name(src)] slowed the schedule interval of Fluids.")

client/proc/slow_atmos()
	set name = "Slow Atmos Processing"
	set desc = "Higher schedulde interval. May fuck the TEG."
	set category="Debug"
	set hidden = 1
	admin_only

	if (processScheduler.hasProcess("Atmos"))
		var/datum/controller/process/P = processScheduler.nameToProcessMap["Atmos"]
		P.schedule_interval = 50

	message_admins("[key_name(src)] slowed the schedule interval of Atmos.")

client/proc/slow_ticklag()
	set name = "Change Ticklag Bounds"
	set desc = "Change max/min ticklag bounds for smoother experience during LagTimes."
	set category="Debug"
	set hidden = 1
	admin_only

	//var/prev = world.tick_lag
	//world.tick_lag = OVERLOADED_WORLD_TICKLAG

	ticker.timeDilationLowerBound = input("Enter lower bound:","Num", MIN_TICKLAG) as num
	ticker.timeDilationUpperBound = input("Enter upper bound:","Num", OVERLOADED_WORLD_TICKLAG) as num

	message_admins("[key_name(src)] changed world Tick Lag bounds to MIN:[ticker.timeDilationLowerBound]  MAX:[ticker.timeDilationUpperBound]")