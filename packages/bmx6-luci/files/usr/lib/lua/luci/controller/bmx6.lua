local bmx6json = require("luci.model.bmx6json")

module("luci.controller.bmx6", package.seeall)
 
function index()
       
	local ucim = require "luci.model.uci"
	local uci = ucim.cursor()
 	local place = {}
	-- checking if ignore is on
	if uci:get("luci-bmx6","luci","ignore") == "1" then
		return nil
	end
	
	-- getting value from uci database
	local uci_place = uci:get("luci-bmx6","luci","place")
	
	-- default values
	if uci_place == nil then 
		place = {"bmx6"} 
	else 
		local util = require "luci.util"
		place = util.split(uci_place," ")
	end
	---------------------------
	-- Starting with the pages
	---------------------------
   
	--- status (this is default one)
	entry(place,call("action_status"),place[#place])	

	--- neighbours
	table.insert(place,"Neighbours")
	entry(place,call("action_neighbours"),"Neighbours") 
	table.remove(place)
 
	--- links
	table.insert(place,"Links")
	entry(place,call("action_links"),"Links") 
	table.remove(place)

	--- configuration (CBI)
	table.insert(place,"Configuration")
	entry(place, cbi("bmx6/main"), "Configuration").dependent=false

	table.insert(place,"Advanced")	
	entry(place, cbi("bmx6/advanced"), "Advanced")
	table.remove(place)
	
	table.insert(place,"Interfaces")	
	entry(place, cbi("bmx6/interfaces"), "Interfaces")
	table.remove(place)

	table.insert(place,"Plugins")	
	entry(place, cbi("bmx6/plugins"), "Plugins")
	table.remove(place)

	table.insert(place,"HNA")	
	entry(place, cbi("bmx6/hna"), "HNA")
	table.remove(place)
	
	table.remove(place)	

end
 
function action_status()
		local status = bmx6json.get("status").status or nil
		local interfaces = bmx6json.get("interfaces").interfaces or nil

		if status == nil or interfaces == nil then
			luci.template.render("bmx6/error", {txt="Cannot fetch data from bmx6 json"})	
		else
        	luci.template.render("bmx6/status", {status=status,interfaces=interfaces})
		end
end
 
function action_neighbours()
		local orig = bmx6json.get("originators").originators or nil

		if orig == nil then
			luci.template.render("bmx6/error", {txt="Cannot fetch data from bmx6 json"})
			return nil
		end

		local neighbours = {}
		local nb = nil
		local nd = nil
		for _,o in ipairs(orig) do
			nb = bmx6json.get("originators/"..o.name).originators or {}
			nd = bmx6json.get("descriptions/"..o.name).descriptions or {}
			table.insert(neighbours,{orig=nb,desc=nd})
		end

        luci.template.render("bmx6/neighbours", {neighbours=neighbours})
end
 
function action_links()
	local links = bmx6json.get("links")
	local devlinks = {}
	
	if links ~= nil then
		links = links.links
		for _,l in ipairs(links) do
			devlinks[l.viaDev] = {}
		end
		for _,l in ipairs(links) do
			table.insert(devlinks[l.viaDev],l)	
		end
	end

	luci.template.render("bmx6/links", {links=devlinks}) 
end

