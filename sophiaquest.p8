pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


-- const
left,right,up,down,fire1,fire2,none=0,1,2,3,4,5,6
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
player,bullet,ennemy=0,1,2
immortal_obj = 1000
-- var
dbg=""

animations={
 anim="talk",
 walk={f=1,st=1,sz=2,spd=1/5},
 talk={f=16,st=16,sz=3,spd=1/5}
}

flags={
 item=0,
 inventory=5,
 obst=7
}

ctime={
 m=0,
 s=0,
 ms=0
}

life = {
 player = 25,
 ennemy = 10,
 boss = 150,
}

actors={}
particles={}
explosions={}
items={}

open_inv=false
selected_item=1

-- init
function _init()
 _update = update_menu
 make_game()
end

function init_screen()
 scr = {}
 scr.x = 0
 scr.y = 0
 scr.shake = 0
 scr.intensity = 2
end

-- make

function make_actor(x,y,s,tag,health,direction)
 direction = direction or none
 local actor = {}
 actor.tag = tag
 actor.direction = direction
 actor.bx = x
 actor.by = y
 actor.x = x
 actor.y = y
 actor.s = s
 actor.dx = 0
 actor.dy = 0
 actor.health = health
 actor.box = {x1=0,y1=0,x2=7,y2=7}
 add(actors,actor)
 return actor
end

function make_weapons()
  -- name,spr,sfx,animh,animv,delay,dmg,speed,hb,ox,oy
 make_item("sword",105,4,73,89,15,7,1,8,4,3)
 make_item("wand",106,1,74,90,8,8,3,3,5,1)
 make_item("gun",107,5,75,91,3,3,10,1,5,0)
 make_item("bow",108,3,76,92,6,5,6,3,4,-1)
end

function make_player()
 p = make_actor(48,60,1,player,life.player)
 p.weapon = items[1]
 p.d = up
 p.anim = "talk"
 p.walk = {f=1,st=1,sz=2,spd=1/5}
 p.talk = {f=1+16,st=1+16,sz=3,spd=1/5}
 p.cooldown = 0
 p.box = {x1=0,y1=0,x2=6,y2=7}
end

function make_game()
 init_screen()
 make_weapons()
 make_player()
 make_ennemies(10, {4,7})
end

function make_ennemies(nb, aspr)
 for s in all(aspr) do
  for i=1,nb do
   mstr = make_actor(rnd(248),rnd(248),s,ennemy,life.ennemy)
   mstr.weapon = items[4]
   mstr.anim = "walk"
   mstr.walk = {f=s,st=s,sz=2,spd=1/5}
   mstr.dx = rnd(1)
   mstr.dy = rnd(1)
  end
 end
end

function make_particles(a,n,c)
 c = c or 8
	while (n > 0) do
 	part = {}
 	part.x = a.x+4
 	part.y = a.y+4
 	part.c = flr(rnd(3)+c)
 	part.dx = (rnd(2)-1)*2
 	part.dy = (rnd(2)-1)*2
 	part.f = 0
 	part.maxf = 15
 	add(particles,part)
 	sfx(1)
 	n -= 1
 end
end

function make_explosion(x,y,a)
	while (a > 0) do
		explo = {}
		explo.x = x+(rnd(2)-1)*10
		explo.y = y+(rnd(2)-1)*10
		explo.r = 4 + rnd(4)
		explo.c = 8;
		add(explosions, explo)
		sfx(0)
		a -= 1
	end
end

function make_item(name,spr,sfx,animh,animv,delay,dmg,speed,hb,ox,oy)
 local item = {}
 item.name = name
 item.spr = spr
 item.animh = animh
 item.animv = animv
 item.delay = delay
 item.speed = speed
 item.dmg = dmg
 item.hb = hb
 item.ox = ox
 item.oy = oy
 item.sfx = sfx
 add(items,item)
 return item
end

-- move

function controls_menu()
 if (btnp(up) and selected_item > 1) then
  selected_item -= 1
 end
 if (btnp(down) and selected_item < #items) then
  selected_item += 1
 end
 if (btnp(fire1)) then
  p.weapon = items[selected_item]
  open_inv = false
  p.cooldown = 10
 end
end

function controls()
 p.anim = "walk"
 if (is_moving(left)) move(p,-1,0,0)
 if (is_moving(right)) move(p,1,0,8)
 if (is_moving(up)) move(p,0,-1,0)
 if (is_moving(down)) move(p,0,1,8)
 if (is_not_moving()) p.anim = "talk"
 action()
end

function move_actors()
 for a in all(actors) do
  a.x += a.dx
  a.y += a.dy
  if (a.tag ~= bullet and is_of_limit(a.x,a.y,a.bx,a.by,20)) then
   a.dx *= -1
   a.dy *= -1
  elseif (a.tag == bullet and is_of_limit(a.x,a.y)) then
   del(actors,a)
  end
 end
end

function is_moving(direction)
 if (btn(direction)) then
  p.d = direction
  return true
 end
 return false
end

function is_not_moving()
  if ((btn(left)
 or btn(right)
 or btn(up)
 or btn(down)) == false) then
  return true
 end
 return false
end

function move(a,x,y,o)
 sp = mget((a.x+x+(o*x))/8,(a.y+y+(o*y))/8)
 if (fget(sp,flags.obst) == false) then
  a.x += x
  a.y += y
 end
 if(fget(sp,flags.item)) then
  pick_item((a.x+x+(o*x))/8,(a.y+y+(o*y))/8)
 end
end

-- action

function action()
 if (p.cooldown > 0) p.cooldown -= 1
 if ((p.cooldown == 0) and btn(fire1)) then
  shoot()
  p.cooldown = p.weapon.delay
 end
 if (btnp(fire2)) then
  sp = mget(p.x/8,(p.y-1)/8)
  if (fget(sp,flags.inventory)) then
   open_inv = true
  else
   make_explosion(p.x,p.y,5)
  end
 end
end

function pick_item(x,y)
 sfx(2)
 mset(x,y,32)
end

function wait_inventory_close()
 if (btnp(fire2)) then
  open_inv = false;
 end
end

function anim(a)
	a.f += a.spd
	if(a.f > a.st + a.sz) then
		a.f = a.st
	end
	return flr(a.f)
end

function anim_player(a)
	if(a.anim == "talk") then
		return anim(a.talk)
	else
		return anim(a.walk)
	end
end


-- util

function is_of_limit(x,y,bx,by,r)
 local fpx = gformalisedposition(p.x);
 local fpy = gformalisedposition(p.y);
 bx = bx or x
 by = by or y
 r = r or 1
 if (x < fpx or x >= fpx+128 or
		y < fpy or y >= fpy+128) then
		return true
 end
 if (x < bx-r or x >= bx+r or
  y < by-r or y >= by+r) then
  return true
 end
 return false
end

function shoot()
 local speed = p.weapon.speed
 local center = p.weapon.hb/2
 if(p.d == left) then
  b = make_actor(p.x-6,p.y,p.weapon.animh,bullet,immortal_obj,left)
  b.box = {x1=0,y1=4-center,x2=5,y2=4+center}
  b.dx = -speed
 end
 if(p.d == right) then
  b = make_actor(p.x+6,p.y,p.weapon.animh,bullet,immortal_obj,right)
  b.box = {x1=3,y1=4-center,x2=8,y2=4+center}
  b.dx = speed
 end
 if(p.d == up) then
  b = make_actor(p.x,p.y-6,p.weapon.animv,bullet,immortal_obj,up)
  b.box = {x1=4-center,y1=0,x2=4+center,y2=5}
  b.dy = -speed
 end
 if(p.d == down) then
  b = make_actor(p.x,p.y+6,p.weapon.animv,bullet,immortal_obj,down)
  b.box = {x1=4-center,y1=3,x2=4+center,y2=8}
  b.dy = speed
 end
 b.dmg = p.weapon.dmg
 sfx(p.weapon.sfx)
end

function time_manager()
 ctime.ms += 1/30
 if(ctime.ms >= 1) then
  ctime.ms = 0
  ctime.s += 1
  if (ctime.s >= 60) then
   ctime.s = 0
   ctime.m += 1
  end
 end
end

function gformalisedposition(p)
 return p-64<0 and 0 or p-64
end

function manage_direction(direction)
 direction = direction or none
 local inv = {}
 inv.h = false
 inv.v = false

 if (direction == left) then
  inv.h = true
  inv.v = false
 end

 if (direction == down) then
  inv.h = false
  inv.v = true
 end
 return inv
end

function highlight(f,x,y,c,direction)
 local inv = manage_direction(direction)
	for i=1,16 do
		pal(i,c)
 end
 spr(f,x,y+1,1,1,inv.h,inv.v)
 pal()
 spr(f,x,y,1,1,inv.h,inv.v)
end

-- collisions

function gbox(a)
 local box = {}
 box.x1 = a.x + a.box.x1
 box.y1 = a.y + a.box.y1
 box.x2 = a.x + a.box.x2
 box.y2 = a.y + a.box.y2
 return box
end

function checkcollisions(a,b)
 if(a == b or a.tag == b.tag) return false
 local box_a = gbox(a)
 local box_b = gbox(b)
 if (box_a.x1 > box_b.x2 or
     box_a.y1 > box_b.y2 or
     box_b.x1 > box_a.x2 or
     box_b.y1 > box_a.y2 ) then
  return false
 end
 return true
end

function is_dead(a)
 return a.health <= 0
end

function collisions()
 for a in all(actors) do
  for b in all(actors) do
   if (checkcollisions(a,b)) then
    local damaged_actor = a
    if (a.tag == bullet and b.tag ~= bullet) then
     b.health -= a.dmg
     damaged_actor = b
     make_particles(b,10,5)
     del(actors,a)
    elseif (b.tag == bullet and a.tag ~= bullet) then
     a.health -= b.dmg
     make_particles(a,10,5)
     del(actors,b)
    end
    if (is_dead(damaged_actor)) then
     make_explosion(damaged_actor.x,damaged_actor.y,5)
     screenshake(10)
     del(actors,damaged_actor)
    end
   end
  end
 end
end

-- draw

function _draw()
 cls()
 draw_menu()
end

function draw_particles()
	for part in all(particles) do
		pset(part.x, part.y, part.c)
		part.x += part.dx
		part.y += part.dy
		part.f += 1
		if (part.f > part.maxf or is_of_limit(part.x,part.y)) then
			del(particles, part)
		end
	end
end

function draw_explosions()
	for e in all(explosions) do
  circfill(e.x,e.y,e.r,e.c)
  e.r -= 1
  if (e.r < 4) e.c = 9
  if (e.r < 2) e.c = 10
  if (e.r <= 0) del(explosions, e)
	end
end

function draw_actors()
 for a in all(actors) do
  if (a.tag == player or a.tag == ennemy) then
   draw_weapon(a)
   highlight(anim_player(a),a.x,a.y,5)
  else
   local inv = manage_direction(a.direction)
   spr(a.s,a.x,a.y,1,1,inv.h,inv.v)
  end
 end
end

function draw_weapon(a)
 spr(a.weapon.spr,a.x+a.weapon.ox,a.y-a.weapon.oy)
end

function draw_menu()
 map(0,48,0,0,16,16)
 print("press x+c",50,90,white)
end

function draw_inventory(x,y)
 if (open_inv) then
  rectfill(x,y,x+48,y+128,dark_gray)
  line(x,y,x,y+128,light_gray)
  tx = x+7
  ty = y+10
  for i=1,#items do
   rectfill(tx-1,ty-5,tx+9,ty+5,light_gray)
   spr(items[i].spr,tx,ty-4)
   print(items[i].name,tx+12,ty-2,white)
   if (selected_item == i) then
    spr(58,tx-7,ty-2)
   end
   ty += 12
  end
 end
end

function draw_game()
 cls()
 map(0,0,0,0,48,48)

 scamera()
 draw_particles()
 draw_explosions()
 draw_actors()

 fp = follow_player()

 print(ctime.s,fp.x,fp.y,light_gray)
 highlight(39,fp.x+116,fp.y+5,2)
 draw_inventory(fp.x+80,fp.y)
 debug(fp.x+10,fp.y+10)
end

-- update

function update_menu()
 if (btn(fire1) and btn(fire2)) then
  _update = update_game
  _draw = draw_game
   p.cooldown = 10
 end
end

function update_game()
 if (open_inv == false) then
  move_actors()
  controls()
  collisions()
  time_manager()
 else
  wait_inventory_close()
  controls_menu()
 end
end
-- camera

function follow_player(ofx,ofy)
 ofx = ofx or 0
 ofy = ofy or 0
 local pos = {}
 pos.x = (gformalisedposition(p.x))+ofx
 pos.y = (gformalisedposition(p.y))+ofy
 return pos
end

function scamera()
 scr.x = gformalisedposition(p.x)
 scr.y = gformalisedposition(p.y)
 if (scr.shake > 0) then
  scr.x += (rnd(2)-1)*scr.intensity
  scr.y += (rnd(2)-1)*scr.intensity
  scr.shake -= 1
 end
 camera(scr.x,scr.y)
end

function screenshake(n)
 scr.shake = n
end

-- debug

function debug(x,y)
  print(dbg,x,y,red)
end

__gfx__
00000000088888000888880000000000044444000444440000000000022222000222220000000000333366653333333333333333c71ccccc0000888888800088
00000000888888808888888000000000044444000444440000000000022222000222220000000000333665665666533333333333cccccc7c0008888888880088
007007000f4f4f000f4f4f00000000000f3f3f000f3f3f0000aaaa000f5f5f000f5f5f0000eeee00336667556656666566533333cccccc710088888888888058
000770000fffff000fffff00000990000fffff000fffff0000a33a000fffff000fffff0000e22e00366616656655756666665333cccccccc0088888888888058
000770001111111f1111111f00099000444444404444444f00a33a00222222202222222f00e22e003661cc666666556665776533c71ccccc000ff07f07ff0058
00700700f9989900f998990000000000f44944f0f449440000aaaa00f22322f0f223220000eeee003661ccccccc6666666655653c771cc7c000ff00f00ff0065
0000000001111100011111f00000000004444400044444f00000000002222200022222f0000000003661ccccccccccccc6665653cccccc71000fffffffff0076
000000000f000f00f0000000000000000f000f00f0000000000000000f000f00f000000000000000366661ccccccccccccc66653cccccccc0000fff8fff00057
00000000088888000888880008888800044444000444440004444400022222000222220002222200366661cccccccccccccc6653cccccccc00999999999999ff
00000000888888808888888088888880044444000444440004444400022222000222220002222200366661cccccccccccccc6665ccca91cc09999999999999ff
000000000f4f4f000f4f4f000f4f4f000f3f3f000f3f3f000f3f3f000f5f5f000f5f5f000f5f5f00365561cccccccccccc665565caaaa81c0ff1111b11110055
000000000fffff000ff8ff000fffff000fffff000ff8ff000fffff000fffff000ff8ff000fffff003657561ccccccccccc657565aa990aa10ff1111b111100dd
000000001111111f1111111f1111111f4444444044444440444444402222222022222220222222203657561cccccccccc6667565aa990aa10009999999990000
00000000f9989900f9989900f9989900f44944f0f44944f0f44944f0f22322f0f22322f0f22322f03655661cccccccccc6665565caaaa81c0009990009990000
000000000111110001111100011111000444440004444400044444000222220002222200022222003366661ccccccccccc665653ccca91cc0009900000990000
000000000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f00333661cccccccccccc666653cccccccc0005500000550000
33333333333333333333333333b1b3b13333333333bbb3bbb3333333088088000000000000000000333661ccccccccccccc666330000000000008888888000aa
333333333b333b333338833333bb1bbbbbbb333333bbbbbbbbbb3333878888800000000000000000336661ccccccccccccc665330000000000088888888800aa
333333333b533b53338998333b1bbb1bb1bbb3333bfbbbfbbbbbb3338888888000000000000000003365561ccc6611ccc666653300000000008888888888805a
3333333333333333389aa9833bbb1bbb4bb1b3333bbbbbbb4bbfb33308888800000000000000000033665661c66666666665565300000000008888888888805a
3333333333b33333b89aa98b3bb1bbb44bbbbb333bbbbbb44bbbbb3300888000000000000000000033665576665557566577565300000000000ff70f70ff005a
3333333333b5b3b5bb8998bb3b4bb1b4bb1bbb333b4bbfb4bbbfbb3300080000000000000000000033366556666655566555653300000000000ff00f00ff0065
333333333333b5333bb88bb53b44bbb4b1bb1b333b44bbb4bfbbfb3300000000000000000000000033333666655666666666533300000000000fffffffff0076
3333333333333333333bb55333b4bb44bbb4b33333b4bb44bbb4b333000000000000000000000000333333333333333333333333000000000000fff8fff00057
33333333333333333333333333bb4b4bb444b33333bb4b4bb444b33300000000333ee333333336330c00000000000000000000000000000000999999999999ff
333333333333333332232233333bb44b4bbb3333333bb44b4bbb33330aaaaaa033a22a33355555530cc0000000000000000000000000000009999999999999ff
3333333333b333b332e2e2333331b444bb133333333bb444bbb333330a9999a03a8aa8a3352b2b530ccc00000000000000000000000000000ff1111b11110055
3333333333b533b532eee233333334445533333333333444553333330a9889a0e2a88a2e35b2b2530cccc0000000000000000000000000000ff1111b111100dd
3333333333333333b2eee2b3333334455533333333333445553333330a9889a0e2a88a2e358888530ccc10000000000000000000000000000009999999990000
333333333333b333bb2e2bb3333334455333333333333445533333330a9999a03a8aa8a5355885530cc100000000000000000000000000000009990009990000
333333333333b5333bbbbb53333334453333333333333445333333330aaaaaa033a22a55335885330c1000000000000000000000000000000009900000990000
333333333333333333bbb5333333333333333333333333333333333300000000333ee55335555553010000000000000000000000000000000005500000550000
5555555555555555555555555555555566666666666666663333333b333333b33bbb533300c55100000000000000000000000000000000000000000000000000
5dddd5dddddd5dd555ddd5dddd5ddd55666666666666666633bbbbbbbbbbbbbbbbbbb533000c5510000000000000000000000000000000000000000000000000
5dddd5dddddd5dd55dddd5dddd5dddd56666666666355566bbbbbbbbbbbbbbbbbbbbbb530000c510000000000000000000000000000000000000000000000000
5dddd5dddddd5dd55ddd55555555ddd5665bbb666635b6663bbbbbbbbbbbbbb5bbbbbbb50000c510000880000000000060000050000000000000000000000000
5dddd5dddddd5dd5555555666655555566533b36665566663bbbbbbbbbbb55333bbbbbb50000c510000898000005580006444455000000000000000000000000
5dddd5dddddd5dd55dd5566666655dd566653366656666663bbbbb533333333333bbbbb50000c510000880000000000060000050000000000000000000000000
55555555555555555dd5666666665dd566666566666666663bbbbb5333333333333bbbb5000c5510000000000000000000000000000000000000000000000000
5ddddd5ddd5dddd55dd5666666665dd566666665536666663bbb55333333333333bbbbb500c55100000000000000000000000000000000000000000000000000
5ddddd5ddd5dddd55dd5666666665dd566666553336666663bbbb5333333333333bbbbb500000000000000000000000000050000000000000000000000000000
5ddddd5ddd5dddd555556665bb66555566666655b66666663bbbbb533333333333bbbbb501111110000000000000000000555000000000000000000000000000
5ddddd5ddd5dddd55dd56bb533665dd56655666666655b6633bbbb533333333333bbbbb515555551000800000008000000040000000000000000000000000000
55555555555555555dd566bb33365dd56555566666635bb6bbbbbb533333333333bbbbb555cccc55008980000005000000040000000000000000000000000000
5d5ddddd5dddddd55dd5663bbb365dd5653bb666666355663bbbbb533333333333bbbbb55c0000c5008880000005000000040000000000000000000000000000
5d5ddddd5dddddd55555666333665555663bb666666663363bbbbb533333333333bbbbb5c000000c000000000000000000060000000000000000000000000000
5d5ddddd5dddddd55dd5666666665dd5663666666666666633bbbb533333333333bbbbb500000000000000000000000000606000000000000000000000000000
55555555555555555555666666665555666666666666666633bbb5333333333333bbbbb500000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000003bbbb5333333333333bbbbb500000000000800000000000000004000000000000000000000000000
0000000000000000000000000000000000000000000000003bbbb533333333333bbbbbb5000d00000082800000000000000d0400000000000000000000000000
0000000000000000000000000000000000000000000000003bbbb5333333333bbbbbbbb5000d00000048000000008000000d0040000000000000000000000000
0000000000000000000000000000000000000000000000003bbbbb5333333bbbbbbbbbb5000d00000004000000555590000d0040000000000000000000000000
0000000000000000000000000000000000000000000000003bbbbbbb55bbbbbbbbbbbbb5000d00000040000000dd0000000d0040000000000000000000000000
0000000000000000000000000000000000000000000000003bbbbbbbbbbbbbbbbbbbbb53000d00000004000000d00000000d0400000000000000000000000000
00000000000000000000000000000000000000000000000033bbbbbbbbbbbbbbbbbbb533001c1000000400000000000000004000000000000000000000000000
000000000000000000000000000000000000000000000000333333bbbbbb53333333333300010000000400000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a500000000000000000000000000000000000000000000000000000000b5b5b5b5000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222323222202222323232222232312000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02b1b1b1b1b102b1b1b1b1b1b1b1b102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020222b14212232202b102b13242b102830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
526202b143b102b102b102b13343b122830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
536302b112b1b1b122b112b1b1b1b102830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020202232202122212122302125363000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22021202125262021202023242120202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12233242125363022302023343120223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12023343121202020202020202125262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12220212020202023242020222025363000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020212230202023343022222020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02022202220222235262021212220202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020232421202025363120202220202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02120233432202020222021232422202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020212020202020202021233430202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
000202000000000000008080800000000002020200000000000080008000000000000000000000000000808080000000000000800080000001a000000000000000000000000080808000000000000000000000000000800080000000000000000000000000008080800000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4647474747474747474747474747474747474747474747474747474747474748000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5635363221202025262021322023242020202222222222222020202020232458000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5626203232222235362220202033342020202220202020202020322031333458000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5636212020312220202020203231202020202120232420203232202020202058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5622202324312020202020202031312020202120333420203220222020312058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562020333425260a0b0b0b0b0c20203120202120202039203232322032203158000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562020212135391a1b1b1b1b1c20223120202121202020203232322220202058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562022213220201a0d1b1d1b1c20202221212120202020202232222020382058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562022202020201a0d1b1b0d1c20202221202220200a0b0c2020202020203258000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562324312020201a1b1b1b1b1c20232420202220201a1b1c2020202023242058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
563334202222202a2b2b2b2b2c20333420202220202a2b2c2022202033342058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620322131202020202020202020232420202121202020202022202020202058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620322031202132322020222324333420202221212120202022202020203158000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620202221203131313131313334212020222038202039202020202020322058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5625262020252620202025262020202020222020202020202020202032202058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5635362020353620202035362020202020202020232420202020382020202058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620203239202020312020202022202020202020333420212120202020233158000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620202020203220202032202020202526202020202021212121322020333458000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620202020202020202022202020203536202032202121212120202020202058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620312020232432202020202526202020202020212021202020202526252658000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620202020333420322020203536200a0b0c2021202121202020203536353658000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620202020202020202020202020201a1b1c2021212020202324202526252658290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620222032203120202022202020202a2b2c2020202032203334203536353658290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620222020202020322020252620322020203820312020202020202526252658290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562020200a0b0c20202020353620202020202020313131200a0b0c3536353658290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562020201a1b1c20202020202020202020203120202031311a1d1c2526252658290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
562020202a2b2c2022203120202023242020312420202031312b2c35363536585a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56202020202020202020312031203334203231342032202031202020202526585a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56203120202038202020202031202020203220202020202020312020203536585a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56202324232423242324232423242020202020232420202020313120202020585a2800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5620333433343334333433343331203131202033342020202020313120202058282800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6667676767676767676767676767676767676767676767676767676767676768002800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000500000d6600d6400d6300d6200d610010000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d10000000316000260008600000000000000000000000000000000
00040000185601755017540175301651016500165001670013700117001f2001e2001b2001a2001b2001e20000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000015760187501a7501d7401f740207302272023710257002570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d7700a7700677005760037500274001720027100640005400054000000000000000000000000000000002c2000000000000000000000000000000000000000000000000000000000000000000000000
0001000011130161401d150221602617023160201601a150151500e1300b13007120021100110000000000000000000000000000b200000000000000000000000000000000000000000000000000000000000000
00010000376602f66028660236501e6501b6401664012640106300d6300a620086100661003600326000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
