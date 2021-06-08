/**
 * # N-spect scanner
 *
 * Creates reports for area inspection bounties.
 */
/obj/item/inspector
	name = "\improper N-spect scanner"
	desc = "Central Command-issued inspection device. Performs inspections according to Nanotrasen protocols when activated, then \
			prints an encrypted report regarding the maintenance of the station. Hard to replace."
	icon = 'icons/obj/device.dmi'
	icon_state = "inspector"
	worn_icon_state = "salestagger"
	inhand_icon_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	power_use_amount = POWER_CELL_USE_NORMAL
	///How long it takes to print on time each mode, ordered NORMAL, FAST, HONK
	var/list/time_list = list(5 SECONDS, 1 SECONDS, 0.1 SECONDS)
	///Which print time mode we're on.
	var/time_mode = INSPECTOR_TIME_MODE_SLOW
	///determines the sound that plays when printing a report
	var/print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL

/obj/item/inspector/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/cell)

/obj/item/inspector/attack_self(mob/user)
	. = ..()
	if(do_after(user, time_list[time_mode], target = user, progress=TRUE))
		print_report(user)

/**
 * Create our report
 *
 * Arguments:
 */
/obj/item/inspector/proc/create_slip()

	var/obj/item/paper/report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))

/**
 * Prints out a report for bounty purposes, and plays a short audio blip.
 *
 * Arguments:
*/
/obj/item/inspector/proc/print_report(mob/user)

	if(!(item_use_power(power_use_amount, user, FALSE) & COMPONENT_POWER_SUCCESS))
		return

	create_slip()
	switch(print_sound_mode)
		if(INSPECTOR_PRINT_SOUND_MODE_NORMAL)
			playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)
		if(INSPECTOR_PRINT_SOUND_MODE_CLASSIC)
			playsound(src, 'sound/items/biddledeep.ogg', 50, FALSE)
		if(INSPECTOR_PRINT_SOUND_MODE_HONK)
			playsound(src, 'sound/items/bikehorn.ogg', 50, FALSE)
		if(INSPECTOR_PRINT_SOUND_MODE_FAFAFOGGY)
			playsound(src, pick(list('sound/items/robofafafoggy.ogg', 'sound/items/robofafafoggy2.ogg')), 50, FALSE)

/obj/item/paper/report
	name = "encrypted station inspection"
	desc = "Contains no information about the station's current status."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "slip"
	///What area the inspector scanned when the report was made. Used to verify the security bounty.
	var/area/scanned_area
	show_written_words = FALSE

/obj/item/paper/report/proc/generate_report(area/scan_area)
	scanned_area = scan_area
	icon_state = "slipfull"
	desc = "Contains detailed information about the station's current status."

	var/list/characters = list()
	characters += GLOB.alphabet
	characters += GLOB.alphabet_upper
	characters += GLOB.numerals

	info = random_string(rand(180,220), characters)
	info += "[prob(50) ? "=" : "=="]" //Based64 encoding

/obj/item/paper/report/examine(mob/user)
	. = ..()
	if(scanned_area?.name)
		. += "<span class='notice'>\The [src] contains data on [scanned_area.name].</span>"
	else if(scanned_area)
		. += "<span class='notice'>\The [src] contains data on a vague area on station, you should throw it away.</span>"
	else if(info)
		icon_state = "slipfull"
		. += "<span class='notice'>Wait a minute, this isn't an encrypted inspection report! You should throw it away.</span>"
	else
		. += "<span class='notice'>Wait a minute, this thing's blank! You should throw it away.</span>"

/**
 * # Fake N-spect scanner
 *
 * A clown variant of the N-spect scanner
 *
 * This prints fake reports with garbage in them,
 * can be set to print them instantly with a screwdriver.
 * By default it plays the old "woody" scanning sound, scanning sounds can be cycled by clicking with a multitool.
 * Can be crafted into a bananium HONK-spect scanner
 */
/obj/item/inspector/clown
	///will only cycle through modes with numbers lower than this
	var/max_mode = CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST
	///names of modes, ordered first to last
	var/list/mode_names = list("normal", "classic", "honk", "fafafoggy")

/obj/item/inspector/clown/attack(mob/living/M, mob/living/user)
	. = ..()
	print_report(user)

/obj/item/inspector/clown/screwdriver_act(mob/living/user, obj/item/tool)
	cycle_print_time(user)
	return TRUE

/obj/item/inspector/clown/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/fork))
		cycle_sound(user)
		return
	return ..()

/obj/item/inspector/clown/examine(mob/user)
	. = ..()
	. += "Two weird settings dials are visible within the battery compartment."

/obj/item/inspector/clown/examine_more(mob/user)
	. = list("<span class='notice'>Both setting dials are flush with the surface of the battery compartment, and seem to be impossible to move with bare hands.</span>")
	. += "\t<span class='info'>The first dial is labeled \"SPEED\" and looks a bit like a <strong>screw</strong> head.</span>"
	. += "\t<span class='info'>The second dial is labeled \"SOUND\". It has four small holes in it. Perhaps it can be turned with a fork?</span>"
	. += "\t<span class='info'>A small bananium part labeled \"ADVANCED WATER CHIP 23000000\" is visible within the battery compartment. It looks completely unlike normal modern electronics, disturbing it would be rather unwise.</span>"

/obj/item/inspector/clown/proc/cycle_print_time(mob/user)
	var/message
	if(time_mode == INSPECTOR_TIME_MODE_FAST)
		time_mode = INSPECTOR_TIME_MODE_SLOW
		message = "SLOW."
	else
		time_mode = INSPECTOR_TIME_MODE_FAST
		message = "LIGHTNING FAST."

	balloon_alert(user, "You turn the screw-like dial, setting the device's scanning speed to [message]")

/obj/item/inspector/clown/proc/cycle_sound(mob/user)
	print_sound_mode++
	if(print_sound_mode > max_mode)
		print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
	balloon_alert(user, "You turn the dial with holes in it, setting the device's bleep setting to [mode_names[print_sound_mode]] mode.")

/obj/item/inspector/clown/create_slip()
	var/obj/item/paper/fake_report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))

/**
 * # Bananium HONK-spect scanner
 *
 * An upgraded version of the fake N-spect scanner
 *
 * Can print things way faster, at full power the reports printed by this will destroy
 * themselves and leave water behind when folding is attempted by someone who isn't an
 * origami master. Printing at full power costs POWER_CELL_USE_HIGH cell units
 * instead of POWER_CELL_USE_NORMAL cell units.
 */
/obj/item/inspector/clown/bananium
	name = "\improper Bananium HONK-spect scanner"
	desc = "Honkmother-blessed inspection device. Performs inspections according to Clown protocols when activated, then \
			prints a clowncrypted report regarding the maintenance of the station. Hard to replace."
	icon = 'icons/obj/tools.dmi'
	icon_state = "bananium_inspector"
	w_class = WEIGHT_CLASS_SMALL
	max_mode = BANANIUM_CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST
	///How many more times can we print?
	var/paper_charges = 32
	///Max value of paper_charges
	var/max_paper_charges = 32
	///How much charges are restored per paper consumed
	var/charges_per_paper = 1

/obj/item/inspector/clown/bananium/proc/check_settings_legality()
	if(print_sound_mode == INSPECTOR_PRINT_SOUND_MODE_NORMAL && time_mode == INSPECTOR_TIME_MODE_HONK)
		say("Setting combination forbidden by Geneva convention revision CCXXIII selected, reverting to defaults")
		time_mode = INSPECTOR_TIME_MODE_SLOW
		print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
		power_use_amount = POWER_CELL_USE_NORMAL

/obj/item/inspector/clown/bananium/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	check_settings_legality()
	return TRUE

/obj/item/inspector/clown/bananium/attackby(obj/item/I, mob/user, params)
	. = ..()
	check_settings_legality()
	if(istype(I, /obj/item/paper/fake_report) || paper_charges >= max_paper_charges)
		to_chat(user, "<span class='info'>\The [src] refuses to consume \the [I]!</span>")
		return
	if(istype(I, /obj/item/paper))
		to_chat(user, "<span class='info'>\The [src] consumes \the [I]!</span>")
		paper_charges = min(paper_charges + charges_per_paper, max_paper_charges)
		qdel(I)

/obj/item/inspector/clown/bananium/Initialize()
	. = ..()
	playsound(src, 'sound/effects/angryboat.ogg', 150, FALSE)

/obj/item/inspector/clown/bananium/create_slip()
	if(time_mode == INSPECTOR_TIME_MODE_HONK)
		var/obj/item/paper/fake_report/water/slip = new(get_turf(src))
		slip.generate_report(get_area(src))
		return
	return ..()

/obj/item/inspector/clown/bananium/print_report(mob/user)
	if(time_mode != INSPECTOR_TIME_MODE_HONK)
		return ..()
	if(paper_charges == 0)
		say("ERROR! OUT OF PAPER! MAXIMUM PRINTING SPEED UNAVAIBLE! SWITCH TO A SLOWER SPEED TO OR PROVIDE PAPER!")
		return
	paper_charges--
	return ..()

/obj/item/inspector/clown/bananium/cycle_print_time(mob/user)
	var/message
	switch(time_mode)
		if(INSPECTOR_TIME_MODE_HONK)
			time_mode = INSPECTOR_TIME_MODE_SLOW
			power_use_amount = POWER_CELL_USE_NORMAL
			message = "SLOW."
		if(INSPECTOR_TIME_MODE_SLOW)
			time_mode = INSPECTOR_TIME_MODE_FAST
			message = "LIGHTNING FAST."
		else
			time_mode = INSPECTOR_TIME_MODE_HONK
			power_use_amount = POWER_CELL_USE_HIGH
			message = "HONK!"
	balloon_alert(user, "You turn the screw-like dial, setting the device's scanning speed to [message]")
