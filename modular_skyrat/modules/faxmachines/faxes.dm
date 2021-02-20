// Fax datum - holds all faxes sent during the round
GLOBAL_LIST_EMPTY(faxes)
GLOBAL_LIST_EMPTY(adminfaxes)

/datum/fax
	var/name = "fax"
	var/from_department = null
	var/to_department = null
	var/origin = null
	var/message = null
	var/sent_by = null
	var/sent_at = null

/datum/fax/New()
	GLOB.faxes += src

/datum/fax/admin
	var/list/reply_to = null

/datum/fax/admin/New()
	GLOB.adminfaxes += src

// Fax panel - lets admins check all faxes sent during the round
/client/proc/fax_panel()
	set name = "Fax Panel"
	set category = "Admin.Fun"
	if(holder)
		holder.fax_panel(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Fax Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/fax_panel(var/mob/living/user)
	var/dat = "<A align='right' href='?src=[REF()];[HrefToken(TRUE)];refreshfaxpanel=1'>Refresh</A>"
	dat += "<A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxCreate=1;faxtype=Custom'>Create Fax</A>"

	dat += "<div class='block'>"
	dat += "<h2>Admin Faxes</h2>"
	dat += "<table>"
	dat += "<tr style='font-weight:bold;'><td width='150px'>Name</td><td width='150px'>From Department</td><td width='150px'>To Department</td><td width='75px'>Sent At</td><td width='150px'>Sent By</td><td width='50px'>View</td><td width='50px'>Reply</td><td width='75px'>Replied To</td></td></tr>"
	for(var/thing in GLOB.adminfaxes)
		var/datum/fax/admin/rcvdfax = thing
		dat += "<tr>"
		dat += "<td>[rcvdfax.name]</td>"
		dat += "<td>[rcvdfax.from_department]</td>"
		dat += "<td>[rcvdfax.to_department]</td>"
		dat += "<td>[worldtime2text(rcvdfax.sent_at)]</td>"
		if(rcvdfax.sent_by)
			var/mob/living/sender = rcvdfax.sent_by
			dat += "<td><A HREF='?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(rcvdfax.sent_by)]'>[sender.name]</A></td>"
		else
			dat += "<td>Unknown</td>"
		//dat += "<td><A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxView=[REF(rcvdfax.message)]'>View</A></td>"		ORIGINAL
		dat += "<td><A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxView=[REF(rcvdfax)]'>View</A></td>"
		if(!rcvdfax.reply_to)
			if(rcvdfax.from_department == "Administrator")
				dat += "<td>N/A</td>"
			else
				dat += "<td><A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxCreate=[REF(rcvdfax.sent_by)];originfax=[REF(rcvdfax.origin)];faxtype=[rcvdfax.to_department];replyto=[REF(rcvdfax.message)]'>Reply</A></td>"
			dat += "<td>N/A</td>"
		else
			dat += "<td>N/A</td>"
			//dat += "<td><A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxView=[REF(rcvdfax.reply_to)]'>Original</A></td>"		ORIGINAL
			dat += "<td><A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxView=[REF(rcvdfax)]'>Original</A></td>"
		dat += "</tr>"
	dat += "</table>"
	dat += "</div>"

	dat += "<div class='block'>"
	dat += "<h2>Departmental Faxes</h2>"
	dat += "<table>"
	dat += "<tr style='font-weight:bold;'><td width='150px'>Name</td><td width='150px'>From Department</td><td width='150px'>To Department</td><td width='75px'>Sent At</td><td width='150px'>Sent By</td><td width='175px'>View</td></td></tr>"
	for(var/thing in GLOB.faxes)
		var/datum/fax/rcvdfax = thing
		dat += "<tr>"
		dat += "<td>[rcvdfax.name]</td>"
		dat += "<td>[rcvdfax.from_department]</td>"
		dat += "<td>[rcvdfax.to_department]</td>"
		dat += "<td>[worldtime2text(rcvdfax.sent_at)]</td>"
		if(rcvdfax.sent_by)
			var/mob/living/sender = rcvdfax.sent_by
			dat += "<td><A HREF='?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(rcvdfax.sent_by)]'>[sender.name]</A></td>"
		else
			dat += "<td>Unknown</td>"
		//dat += "<td><A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxView=[REF(rcvdfax.message)]'>View</A></td>"		ORIGINAL
		dat += "<td><A align='right' href='?src=[REF()];[HrefToken(TRUE)];AdminFaxView=[REF(rcvdfax)]'>View</A></td>"
		dat += "</tr>"
	dat += "</table>"
	dat += "</div>"

	var/datum/browser/popup = new(user, "fax_panel", "Fax Panel", 950, 450)
	popup.set_content(dat)
	popup.open()
