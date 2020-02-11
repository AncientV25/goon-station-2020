//code\lists\jobs.dm

var/list/xpRewards = list() //Assoc. List of NAME OF XP REWARD : INSTANCE OF XP REWARD DATUM . Contains all rewards.
var/list/xpRewardButtons = list() //Assoc, datum:button obj

mob/verb/checkrewards()
	set name = "Check Job Rewards"
	set category = "Commands"
	var/txt = input(usr, "Which job? (Case sensitive)","Check Job Rewards", src.job)
	if(txt == null || lentext(txt) == 0) txt = src.job
	showJobRewards(txt)
	return

/proc/showJobRewards(var/job) //Pass in job instead
	var/mob/M = usr
	if(job)
		if(!winexists(M, "winjobrewards_[M.ckey]"))
			winclone(M, "winJobRewards", "winjobrewards_[M.ckey]")

		var/list/valid = list()
		for(var/datum/jobXpReward/J in xpRewardButtons) //This could be cached later.
			if(J.required_levels.Find(job))
				valid.Add(J)
				valid[J] = xpRewardButtons[J]

		if(valid.len)
			winset(M, "winjobrewards_[M.ckey].grdJobRewards", "cells=\"1x[valid.len]\"")
			var/count = 0
			for(var/S in valid)
				winset(M, "winjobrewards_[M.ckey].grdJobRewards", "current-cell=1,[++count]")
				M << output(valid[S], "winjobrewards_[M.ckey].grdJobRewards")
			winset(M, "winjobrewards_[M.ckey].lblJobName", "text=\"Job rewards for '[job]', Lvl [get_level(M.key, job)]\"")
		else
			winset(M, "winjobrewards_[M.ckey].grdJobRewards", "cells=\"1x0\"")
			winset(M, "winjobrewards_[M.ckey].lblrewarddesc", "text=\"Sorry nothing.\"")
			winset(M, "winjobrewards_[M.ckey].lblJobName", "text=\"Sorry there's no rewards for the [job] yet :(\"")
		winshow(M, "winjobrewards_[M.ckey]")
	else
		boutput(M, "<span style=\"color:red\">Woops! That's not a valid job, sorry!</span>")

//Once again im forced to make fucking objects to properly use byond skin stuff.
/obj/jobxprewardbutton
	icon = 'icons/ui/jobxp.dmi'
	icon_state = "?"
	var/datum/jobXpReward/rewardDatum = null

	Click(location,control,params)
		if(control && rewardDatum)
			if(control == "winjobrewards_[usr.ckey].grdJobRewards")
				if(rewardDatum.claimable && (usr.job in rewardDatum.required_levels) && rewardDatum.qualifies(usr.key)) //Check for number of claims.
					var/claimsLeft = 1
					if(rewardDatum.claimPerRound > 0)
						if(rewardDatum.claimedNumbers.Find(usr.key) && rewardDatum.claimedNumbers[usr.key] >= rewardDatum.claimPerRound)
							claimsLeft = 0
					if(claimsLeft)
						if(alert("Would you like to claim this reward?",,"Yes","No") == "Yes")
							if(rewardDatum.claimPerRound > 0)
								if(rewardDatum.claimedNumbers.Find(usr.key) && rewardDatum.claimedNumbers[usr.key] >= rewardDatum.claimPerRound)
									return
							if(rewardDatum.qualifies(usr.key))
								rewardDatum.activate(usr.client)
								if(rewardDatum.claimedNumbers.Find(usr.key))
									rewardDatum.claimedNumbers[usr.key] = (rewardDatum.claimedNumbers[usr.key] + 1)
								else
									rewardDatum.claimedNumbers[usr.key] = 1
							else
								boutput(usr, "<span style=\"color:red\">Looks like you haven't earned this yet, sorry!</span>")
					else
						boutput(usr, "<span style=\"color:red\">Sorry, you can not claim any more of this reward, this round.</span>")
		return

	MouseEntered(location,control,params)
		if(winexists(usr, "winjobrewards_[usr.ckey]"))
			var/str = ""
			for(var/X in rewardDatum.required_levels)
				str += "[X] [rewardDatum.required_levels[X]],"
			str = copytext(str,1,lentext(str))
			winset(usr, "winjobrewards_[usr.ckey].lblrewarddesc", "text=\"[rewardDatum.desc] | Required levels: [str]\"")
		return

/proc/qualifiesXpByName(var/key, var/name)
	if(xpRewards.Find(name))
		var/datum/jobXpReward/R = xpRewards[name]
		if(R.qualifies(key))
			return 1
	return 0

/datum/jobXpReward
	//TBI: Icons, XP reward tree overview.
	var/name = "" //Also used in the trait unlock checks. Make sure theres no duplicate names.
	var/desc = ""
	var/list/required_levels = list("Clown"=999) //Associated List of JOB:REQUIRED LEVEL. Affects visibility in jobxp rewards screen
	var/icon_state = "?"
	var/claimPerRound = -1 //How often can this be used per round. <0 = infinite
	var/claimable = 0 //Can this actively be claimed? (1) or is it a passive thing that is checked elsewhere (0)
	var/list/claimedNumbers = list() //Assoc list, key:numclaimed

	proc/qualifies(var/key)
		var/pass = 1
		for(var/X in required_levels)
			var/level = get_level(key, X)
			if(level < required_levels[X])
				pass = 0
		return pass

	proc/activate(var/client/C)
		return

//JANITOR

/datum/jobXpReward/janitor10
	name = "Holographic signs (WIP)"
	desc = "Gives access to a hologram emitter loaded with various signs."
	required_levels = list("Janitor"=10)
	icon_state = "holo"
	claimable = 1
	claimPerRound = 5

	activate(var/client/C)
		var/obj/item/holoemitter/T = new/obj/item/holoemitter(get_turf(C.mob))
		T.ownerKey = C.key
		T.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(T)
		return

/datum/jobXpReward/janitor15
	name = "Tsunami-P3"
	desc = "Gain access to the Tsunami-P3 spray bottle."
	required_levels = list("Janitor"=15)
	icon_state = "tsunami"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		var/obj/item/spraybottle/cleaner/tsunami/T = new/obj/item/spraybottle/cleaner/tsunami()
		T.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(T)
		return

/datum/jobXpReward/janitor20
	name = "Antique Mop"
	desc = "Gain access to an ancient mop."
	required_levels = list("Janitor"=20)
	icon_state = "tsunami"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		var/obj/item/mop/old/T = new/obj/item/mop/old()
		T.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(T)
		return

/datum/jobXpReward/janitor20
	name = "(TBI)"
	desc = "(TBI)"
	required_levels = list("Janitor"=20)
	icon_state = "?"

//JANITOR END

/datum/jobXpReward/head_of_security_LG
	name = "The Lawgiver"
	desc = "Gain access to a voice activated weapon of the future-past by sacrificing your egun."
	required_levels = list("Head of Security"=0)
	claimable = 1
	claimPerRound = 1
	icon_state = "?"
	var/sacrifice_path = /obj/item/gun/energy/egun 		//Don't go lower than obj/item/gun/energy
	var/reward_path = /obj/item/gun/energy/lawgiver
	var/sacrifice_name = "E-Gun"

	activate(var/client/C)
		var/charge = 0
		var/found = 0
		for (var/O in C.mob.contents)
			if (istype(O, sacrifice_path))
				var/obj/item/gun/energy/E = O
				if (!E.cell)
					continue
				charge = E.cell.charge
				C.mob.remove_item(E)
				found = 1
				qdel(E)
				break

		if (!found)
			boutput(C.mob, "You need to be holding a [sacrifice_name] in order to claim this reward.")
			//Remove used from list of claimed. I'll make this more elegant once I understand it all. No time for it now. -Kyle
			src.claimedNumbers[usr.key] --
			return

		var/obj/item/gun/energy/lawgiver/LG = new reward_path()
		if (!istype(LG))
			boutput(C.mob, "Something terribly went wrong. The reward path got screwed up somehow. call 1-800-CODER. But you're an HoS! You don't need no stinkin' guns anyway!")
			src.claimedNumbers[usr.key] --
			return
		//Don't let em get get a charged power cell for a spent one
		if (charge < 200)
			LG.cell.charge = charge

		LG.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(LG)
		boutput(C.mob, "Your E-Gun vanishes and is replaced with [LG]!")
		return

/datum/jobXpReward/head_of_security_LG/old
	name = "The Antique Lawgiver"
	desc = "Gain access to a voice activated weapon of the past-future-past by sacrificing your gun of the future-past. I.E. The Lawgiver."
	sacrifice_path = /obj/item/gun/energy/lawgiver
	reward_path = /obj/item/gun/energy/lawgiver/old
	sacrifice_name = "Lawgiver"
	required_levels = list("Head of Security"=5)

/datum/jobXpReward/security2
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security5
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security10
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security15
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security20
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"