
// Inedible Produce

/obj/item/plant/
	name = "plant"
	desc = "You shouldn't be able to see this item ingame!"
	icon = 'icons/obj/hydroponics/hydromisc.dmi'
	var/brewable = 0 // will hitting a still with it do anything?
	var/brew_result = null // what will it make if it's brewable?
	rand_pos = 1

	New()
		..()
		unpooled()

	proc/make_reagents()
		if (!src.reagents)
			var/datum/reagents/R = new/datum/reagents(100)
			reagents = R
			R.my_atom = src
		..()

	unpooled()
		if(src.reagents)
			src.reagents.clear_reagents()
		..()
		make_reagents()

	pooled()
		..()
		if (src.reagents)
			src.reagents.clear_reagents()

/obj/item/plant/herb
	name = "herb base"
	burn_point = 330
	burn_output = 800
	burn_possible = 2

	attackby(obj/item/W as obj, mob/user as mob)
		if (!src.reagents)
			src.make_reagents()

		if (istype(W, /obj/item/spacecash) || istype(W, /obj/item/paper))
			boutput(user, "<span style=\"color:red\">You roll up [W] into a cigarette.</span>")
			var/obj/item/clothing/mask/cigarette/custom/P = new(user.loc)
			
			P.name = build_name(W)
			P.reagents.maximum_volume = src.reagents.total_volume
			src.reagents.trans_to(P, src.reagents.total_volume)
			W.force_drop(user)
			src.force_drop(user)
			pool (W)
			pool (src)

	combust_ended()
		smoke_reaction(src.reagents, 1, get_turf(src), do_sfx = 0)
		..()

	proc/build_name(obj/item/W)
		return "[istype(W, /obj/item/spacecash) ? "[W.amount]-credit " : ""][pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")]"

/obj/item/plant/herb/cannabis/
	name = "cannabis leaf"
	desc = "Leafs for reefin'!"
	icon = 'icons/obj/hydroponics/hydromisc.dmi'
	icon_state = "cannabisleaf"
	brewable = 1
	brew_result = "THC"
	module_research = list("vice" = 10)
	module_research_type = /obj/item/plant/herb/cannabis
	contraband = 1
	w_class = 1

/obj/item/plant/herb/cannabis/spawnable
	make_reagents()
		var/datum/reagents/R = new/datum/reagents(85)
		reagents = R
		R.my_atom = src
		R.add_reagent("THC", 80)

/obj/item/plant/herb/cannabis/mega
	name = "cannabis leaf"
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megaweedleaf"
	brew_result = list("THC", "LSD")

/obj/item/plant/herb/cannabis/mega/spawnable
	make_reagents()
		var/datum/reagents/R = new/datum/reagents(85)
		reagents = R
		R.my_atom = src
		R.add_reagent("THC", 40)
		R.add_reagent("LSD", 40)

/obj/item/plant/herb/cannabis/black
	name = "cannabis leaf"
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackweedleaf"
	brew_result = list("THC", "cyanide")

/obj/item/plant/herb/cannabis/black/spawnable
	make_reagents()
		var/datum/reagents/R = new/datum/reagents(85)
		reagents = R
		R.my_atom = src
		R.add_reagent("THC", 40)
		R.add_reagent("cyanide", 40)

/obj/item/plant/herb/cannabis/white
	name = "cannabis leaf"
	desc = "It feels smooth and nice to the touch."
	icon_state = "whiteweedleaf"
	brew_result = list("THC", "omnizine")

/obj/item/plant/herb/cannabis/white/spawnable
	make_reagents()
		var/datum/reagents/R = new/datum/reagents(85)
		reagents = R
		R.my_atom = src
		R.add_reagent("THC", 40)
		R.add_reagent("omnizine", 40)

/obj/item/plant/herb/cannabis/omega
	name = "glowing cannabis leaf"
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "Oweedleaf"
	brew_result = list("THC", "LSD", "suicider", "space_drugs", "mercury", "lithium", "atropine", "haloperidol", "methamphetamine",\
	"capsaicin", "psilocybin", "hairgrownium", "ectoplasm", "bathsalts", "itching", "crank", "krokodil", "catdrugs", "histamine")

/obj/item/plant/herb/cannabis/omega/spawnable
	make_reagents()
		var/datum/reagents/R = new/datum/reagents(800)
		reagents = R
		R.my_atom = src
		R.add_reagent("THC", 40)
		R.add_reagent("LSD", 40)
		R.add_reagent("suicider", 40)
		R.add_reagent("space_drugs", 40)
		R.add_reagent("mercury", 40)
		R.add_reagent("lithium", 40)
		R.add_reagent("atropine", 40)
		R.add_reagent("haloperidol", 40)
		R.add_reagent("methamphetamine", 40)
		R.add_reagent("THC", 40)
		R.add_reagent("capsaicin", 40)
		R.add_reagent("psilocybin", 40)
		R.add_reagent("hairgrownium", 40)
		R.add_reagent("ectoplasm", 40)
		R.add_reagent("bathsalts", 40)
		R.add_reagent("itching", 40)
		R.add_reagent("crank", 40)
		R.add_reagent("krokodil", 40)
		R.add_reagent("catdrugs", 40)
		R.add_reagent("histamine", 40)

/obj/item/plant/herb/tobacco
	name = "tobacco leaf"
	desc = "A leaf from a tobacco plant. This could probably be smoked..."
	icon_state = "tobacco"
	brewable = 1
	brew_result = list("nicotine")

	build_name(obj/item/W)
		return "[istype(W, /obj/item/spacecash) ? "[W.amount]-credit " : ""]rolled cigarette"

/obj/item/plant/herb/tobacco/twobacco
	name = "twobacco leaf"
	desc = "A leaf from the twobacco plant. This could probably be smoked- wait, is it already smoking?"
	icon_state = "twobacco"
	brewable = 1
	brew_result = list("nicotine2")

/obj/item/plant/wheat
	name = "wheat"
	desc = "Never eat shredded wheat."
	icon_state = "wheat"
	brewable = 1
	brew_result = "beer"

/obj/item/plant/wheat/durum
	name = "durum wheat"
	desc = "A harder wheat for a harder palate."
	icon_state = "wheat"
	brewable = 1
	brew_result = "beer"

/obj/item/plant/wheat/metal
	name = "steelwheat"
	desc = "Never eat iron filings."
	icon_state = "metalwheat"
	brew_result = list("beer", "iron")

	make_reagents()
		..()
		src.setMaterial(getMaterial("steel"))

/obj/item/plant/oat
	name = "oat"
	desc = "A bland but healthy cereal crop. Good source of fiber."
	icon_state = "oat"

/obj/item/plant/sugar/
	name = "sugar cane"
	desc = "Grown lovingly in our space plantations."
	icon_state = "sugarcane"
	brewable = 1
	brew_result = "rum"

/obj/item/plant/herb/contusine
	name = "contusine leaves"
	desc = "Dry, bitter leaves known for their wound-mending properties."
	icon_state = "contusine"

/obj/item/plant/herb/nureous
	name = "nureous leaves"
	desc = "Chewy leaves often manufactured for use in radiation treatment medicine."
	icon_state = "nureous"

/obj/item/plant/herb/asomna
	name = "asomna bark"
	desc = "Often regarded as a delicacy when used for tea, Asomna also has stimulant properties."
	icon_state = "asomna"
	brewable = 1
	brew_result = "tea"

/obj/item/plant/herb/commol
	name = "commol root"
	desc = "A tough and waxy root. It is well-regarded as an ingredient in burn salve."
	icon_state = "commol"

/obj/item/plant/herb/venne
	name = "venne fibers"
	desc = "Fibers from the stem of a Venne vine. Though tasting foul, it has remarkable anti-toxic properties."
	icon_state = "venne"
	
/obj/item/plant/herb/sassafras
	name = "sassafras root"
	desc = "Roots from a Sassafras tree. Can be fermented into delicious sarsaparilla."
	icon_state = "sassafras"
	brewable = 1
	brew_result = "sarsaparilla"

/obj/item/plant/herb/venne/toxic
	name = "black venne fibers"
	desc = "It's black and greasy. Kinda gross."
	icon_state = "venneT"

/obj/item/plant/herb/venne/curative
	name = "dawning venne fibers"
	desc = "It has a lovely sunrise coloration to it."
	icon_state = "venneC"

/obj/item/plant/herb/mint
	name = "mint leaves"
	desc = "Aromatic leaves with a clean flavor."
	icon_state = "mint"
	brewable = 1
	brew_result = "menthol"

/obj/item/plant/herb/catnip
	name = "nepeta cataria"
	desc = "Otherwise known as catnip or catswort.  Cat drugs."
	icon_state = "catnip"
	brewable = 1
	brew_result = "catdrugs"
	module_research = list("vice" = 3)
	module_research_type = /obj/item/plant/herb/cannabis

/obj/item/plant/herb/poppy
	name = "poppy"
	desc = "A distinctive red flower."
	icon_state = "poppy"
	module_research = list("vice" = 4)
	module_research_type = /obj/item/plant/herb/cannabis

/obj/item/plant/herb/aconite
	name = "aconite"
	desc = "A professor once asked, \"What is the difference, Mr. Potter, between monkshood and wolfsbane?\"\n  \"Aconite\", answered Hermione. And all was well."
	icon_state = "aconite"
	module_research = list("vice" = 3)
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER
	// module_research_type = /obj/item/plant/herb/cannabis
	attack_hand(var/mob/user as mob)
		if (iswerewolf(user))
			user.changeStatus("weakened",80)
			user.take_toxin_damage(-10)
			boutput(user, "<span style=\"color:red\">You try to pick up [src], but it hurts and you fall over!</span>")
			return
		else ..()
	//stolen from glass shard
	HasEntered(AM as mob|obj)
		var/mob/M = AM
		if(iswerewolf(M))
			M.changeStatus("weakened",30)
			M.force_laydown_standup()
			M.take_toxin_damage(-10)
			M.visible_message("<span style=\"color:red\">The [M] steps too close to [src] and falls down!</span>")
			return
		..()
	attack(mob/M as mob, mob/user as mob)
		//if a wolf attacks with this, which they shouldn't be able to, they'll just drop it
		if (iswerewolf(user))
			user.u_equip(src)
			user.drop_item()
			boutput(user, "<span style=\"color:red\">You drop the aconite, you don't think it's a good idea to hold it!</span>")
			return
		if (iswerewolf(M))
			M.take_toxin_damage(rand(5,10))
			user.visible_message("[user] attacks [M] with [src]! It's super effective!")
			if (prob(50))
				//Wraith does stamina damage this way, there is probably a better way, but I can't find it
				M:stamina -= 40
			return
		..()
		return
	//stolen from dagger, not much too it
	throw_impact(atom/A)
		if(iswerewolf(A))
			if (istype(usr, /mob))
				A:lastattacker = usr
				A:lastattackertime = world.time
			A:weakened += 15
	pull()
		set src in oview(1)
		set category = "Local"
		var/mob/living/user = usr
		if (!istype(user))
			return
		if (!iswerewolf(user))
			return ..()
		else
			boutput(user, "<span style=\"color:red\">You can't drag that aconite! It burns!</span>")
			user.take_toxin_damage(-10)
			return