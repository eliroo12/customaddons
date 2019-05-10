_addon.author = 'Skittylove'
_addon.command = 'ring'
_addon.name = 'RingUse'
_addon.version = '1.0'


require('strings')
require('GUI')
require('tables')
require('Modes')
res = require('resources')
extdata = require('extdata')
packets = require('packets')
config = require('config')

settings = config.load({gearswap=false,x=500,y=500})

sendcom = 'send @all '
gearswapdisable='gs disable ring1;'
gearswapenable='gs enable ring1;'
target = ' <me>'
send = M(false, 'Send Command')

usingring = false
goingtoenter = false
enterarea = false
running = false
proceed = false
tp = false
currentsender = false
useringat = 0
ringcommand = ''
ringbeingused=''
attempts = 0


Rings = M{['description']='AllRings', 'Warp Ring', 'Teleport Ring', 'EXP Ring', 'CP Ring', 'Emporox'}
Ringlist = M{['description']='AllRings','None', 'Warp Ring', 'Teleport Ring', 'EXP Ring', 'CP Ring', 'Emporox'}
RingGroups = {
['Warp Ring'] = M{['description']='Warp Rings', 'Warp Ring'},
['EXP Ring'] = M{['description']='EXP Rings', 'Echad Ring','Caliber Ring','Emperor Band', 'Empress Band', 'Chariot Band', 'Resolution Ring', 'Allied Ring', 'Kupofried\'s Ring'},
['CP Ring'] = M{['description']='CP Rings','Trizek Ring','Endorsement Ring','Facility Ring','Capacity Ring','Vocation Ring',},
['Teleport Ring'] = M{['description']='TeleportRings', 'Dim. Ring (Holla)', 'Dim. Ring (Dem)', 'Dim. Ring (Mea)'},
['Emporox'] = M{['description']='Emporox Rings', 'Emporox\'s Ring'},
}


RingImages = {
  ['None'] = {img='None.png'},
  ['Warp Ring'] ={img='WarpRing.png'},
  ['Teleport Ring'] = {img='Holla.png', act = 8},
  ['EXP Ring'] = {img='Dem.png', act = 8},
  ['CP Ring'] = {img='Mea.png', act = 8}, 
  ['Emporox'] = {img='Trizek.png'},
  }
  
RingDetails = {
  ['None'] = {act = 10},
  ['Warp Ring'] ={act = 8},
  ['Dim. Ring (Holla)'] = {act = 8},
  ['Dim. Ring (Dem)'] = {act = 8},
  ['Dim. Ring (Mea)'] = {act = 8},
  ['Capactiy Ring'] ={act = 5},
  ['Trizek Ring'] ={act = 5},
  ['Echad Ring'] ={act = 5},
  ['Emperor Band'] ={act = 8},
  ['Caliber Ring'] ={act = 8},
  ['Emporox\'s Ring'] = {act = 5},
  
  }

function use(ringlist, sent)
	
	local echotext = 'input /echo '
	if send.value then -- Send command to all
		currentsender = true
		windower.send_command(sendcom..'ring sentuse '..ringlist)
		echotext = sendcom..'input /echo '..windower.ffxi.get_mob_by_target('me').name..': '
	end
	
	if sent then 
		echotext = sendcom..'input /echo '..windower.ffxi.get_mob_by_target('me').name..': '
	end

	if ringlist == 'None' then reset() return end
	
	local bestring = determinebestring(ringlist)
	
	if not bestring[1] then	--Check inventory for ring
		if bestring[2] == 2 then
			windower.send_command(echotext..ringlist..' is either not in your inventory or hasn\'t been loaded')
			reset()
		else
			windower.send_command(echotext..ringlist..' is still on cooldown')
			reset()
		end
		return
	end
	ring = bestring[1]
	if RingDetails[ring] then
		ringtimer =  RingDetails[ring].act + 2
	else
		ringtimer = 10
	end

	
	if settings.gearswap then -- Disable slot
	windower.send_command('gs disable ring1')
	end
	

	
	windower.send_command('input /equip ring1 "'..ring..'"')
	if ringlist == 'Teleport Ring' then goingtoenter = true else goingtoenter = false end
	usingring = true -- set value for prender to check
	useringat = os.clock() + ringtimer --set time to trigger
	ringcommand = 'input /item "'..ring..'"'..target --command for using the ring
	ringbeingused = ring
end

function useit()

	if enterarea then
		attempts = attempts + 1
		local info = windower.ffxi.get_info()
		local zone = res.zones[info.zone].name
		if zone == 'La Theine Plateau' or zone == 'Konschtat Highlands' or zone == 'Tahrongi Canyon' then
			movetozone()
		elseif attempts > 3000 then 
			enterarea = false
			attempts = 0
		end		
	end
	
	if not usingring then 
		return 
	elseif os.clock() <= useringat then
		return
	else
		windower.send_command(ringcommand)
		if goingtoenter then enterarea = true goingtoenter = false end
		reset()
		if settings.gearswap then windower.send_command('gs enable ring1') end
	end
	
end

function checkinventory(ring)
	-- 0, 8 , 10, 11, 12
	local inventory = windower.ffxi.get_items(0)
	local wardrobe1 = windower.ffxi.get_items(8)
	local wardrobe2 = windower.ffxi.get_items(10)
	local wardrobe3 = windower.ffxi.get_items(11)
	local wardrobe4 = windower.ffxi.get_items(12)
	for i, v in ipairs(inventory) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {0, i}
			end
		end
	end
	
	for i, v in ipairs(wardrobe1) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {8, i, v.id}
			end
		end
	end
	
	for i, v in ipairs(wardrobe2) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {10, i, v.id}
			end
		end
	end
	
	for i, v in ipairs(wardrobe3) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {11, i, v.id}
			end
		end
	end
	
	for i, v in ipairs(wardrobe4) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {12, i, v.id}
			end
		end
	end
	
	return false
end

function checkcooldown(ring)
	local bagval = checkinventory(ring)
	if not bagval then return {false, 2} end
	local itemtable = windower.ffxi.get_items(bagval[1], bagval[2])
	e = extdata.decode(itemtable)
	local t = e.type
	local recast = t and e.charges_remaining > 0 and math.max(e.next_use_time+18000-os.time(),0)
	if not recast then return {false, 1} end

	if recast > 0 then 
		return {false, 1}
	else
		return {true, 1}
	end
end

function determinebestring(ringlist)
	
	if not RingGroups[ringlist] then print('Verify Ring Groups') return end
	local checkrecast = {}
	
	for i, v in ipairs(RingGroups[ringlist]) do
		checkrecast = checkcooldown(v)
		if checkrecast[1] then return {v, checkrecast[1], checkrecast[2]} end
	end
	
	return {checkrecast[1],checkrecast[2]}
	
end

function reset()

	Ringlist:set('None')
	useringat=0
	usingring=false
	ringbeingused=''

end

function buildUI()

	local ri = {}
	for i,v in ipairs(Ringlist) do
		ri[i] = {img=RingImages[v].img, value=v}
	end
	
	RingSelect = IconButton{
		x = settings.x + 0,
		y = settings.y + 54,
		var = Ringlist,
		icons = ri,
		direction = 'north',
		command = function() use(Ringlist.value) end		
	}
	RingSelect:draw()
	
	SendToggle= ToggleButton{
		x = settings.x + 50,
		y = settings.y + 54,
		var = send,
		iconUp = 'SendOff.png',
		iconDown = 'SendOn.png',
		command = function() windower.send_command('input /echo Send '..tostring(send.value)) end
		}		
	SendToggle:draw()
	
	end

function redrawUI()
	RingSelect:undraw()
	SendToggle:undraw()
	buildUI()
end

function movetozone()
	local me = windower.ffxi.get_mob_by_target('me')
	tp = windower.ffxi.get_mob_by_name('Dimensional Portal')
	if tp and math.sqrt(tp.distance) > 3 and not running then
		windower.ffxi.run(tp.x - me.x, tp.y - me.y)
		running = true
	elseif tp and math.sqrt(tp.distance) == 0 and not running then return
	elseif tp and math.sqrt(tp.distance) <= 3 then
		windower.ffxi.run(false)
		running = false
		local p = packets.new('outgoing', 0x01A, {
            ['Target'] = tp.id,
            ['Target Index'] = tp.index,
        })
        packets.inject(p)
		enterarea = false
		proceed = true
	end
	
end

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

windower.register_event('prerender', useit)

windower.register_event('zone change', function(new, old)
	if enterarea then
		local zone = res.zones[new].name
		if not (zone == 'La Theine Plateau' or zone == 'Konschtat Highlands' or zone == 'Tahrongi Canyon') then enterarea = false end
	end	
end)

windower.register_event('addon command', function(...)
	local args = T{...}
	local cmd = args[1]:lower()
	args:remove(1)
	if cmd == 'sentuse' then
		local argsend = ''
		for i, v in ipairs(args) do
			argsend = argsend..v..' '
		end
			argsend = trim(argsend)
		if not currentsender then
			use(argsend, true)
		else
			currentsender = false
		end
	elseif cmd == 'gs' then
		settings.gearswap = not settings.gearswap
		windower.send_command('input /echo settings.gearswap set to '..tostring(settings.gearswap))
		config.save(settings,windower.ffxi.get_mob_by_target('me').name)
	elseif cmd == 'pos' then
	
		if not tonumber(args[1]) or not tonumber(args[2]) then
			print('Invalid arguments') 
			return 
		end
		settings.x = tonumber(args[1])
		settings.y = tonumber(args[2])
		redrawUI()

		config.save(settings,windower.ffxi.get_mob_by_target('me').name)		
	end
	
	end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	local player = windower.ffxi.get_player()
	local me = windower.ffxi.get_mob_by_target('me')
	local zone_id = windower.ffxi.get_info().zone
	local zone_name = res.zones[zone_id].name
	local menu_id = 0
	if id == 0x034 or id == 0x032 then
		if proceed == true then
			local parse = packets.parse('incoming', data)
			local npc_id = parse['NPC']
			if tp and npc_id == tp.id then		--Dimensional Portal
				if zone_name == 'La Theine Plateau' then
					menu_id = 222
				elseif zone_name == 'Konschtat Highlands' or zone_name == 'Tahrongi Canyon' then
					menu_id = 926
				end
				local port = packets.new('outgoing', 0x05B, {
					["Target"] = tp.id,
					["Option Index"] = 0,
					["_unknown1"] = 0,
					["Target Index"] = tp.index,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = zone_id,
					["Menu ID"] = menu_id
				})
				packets.inject(port)
				
				local port = packets.new('outgoing', 0x05B, {
					["Target"] = tp.id,
					["Option Index"] = 2,
					["_unknown1"] = 0,
					["Target Index"] = tp.index,
					["Automated Message"] = false,
					["_unknown2"] = 0,
					["Zone"] = zone_id,
					["Menu ID"] = menu_id
				})
				packets.inject(port)
				delay = 10
				proceed = false
			end
		end
	end
end)
buildUI()


