pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


-- const
left, right, up, down, fire1, fire2, none = 0, 1, 2, 3, 4, 5, 6
black, dark_blue, dark_purple, dark_green, brown, dark_gray, light_gray, white, red, orange, yellow, green, blue, indigo, pink, peach = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
player, bullet, ennemy = 0, 1, 2
immortal_object = 1000
inf = 1000
melee, ranged = 1, 20
nb_of_ennemis = 20
f_heal, f_item, f_inv, f_obst = 0, 1, 5, 7
l_player, l_ennemy, l_boss = 50, 10, 150
walk, stay = "walk", "stay"

debug_enabled = false

-- init
function _init()
 palt()
 palt(pink,true)
 debug_init()

 g_actors = {}
 g_particles = {}
 g_explosions = {}
 g_thunders = {}
 g_showers = {}
 g_items = {}

 g_open_inv=false
 g_selected_item=1
 g_ennemies_left=1
 _update = update_menu
 init_screen()
 make_game()
end

function init_screen()
 g_scr = {
  x = 0,
  y = 0,
  shake = 0,
  intensity = 2
 }
end

-- make

function make_actor(x, y, s, tag, health, direction)
 local actor = {
  tag = tag,
  d = direction or up,
  bx = x,
  by = y,
  x = x,
  y = y,
  s = s,
  dx = 0,
  dy = 0,
  health = health,
  box = {x1 = 0, y1 = 0, x2 = 7, y2 = 7}
 }
 add(g_actors, actor)
 return actor
end

function make_weapons()
 -- name, spr, sfx, animh, animv, cd, dmg, type, speed, hb, ox, oy, dfx, cdfx
 make_item("sword",    105, 4, 73,  89,  15, 7,  melee,  1,  8, 5, -4)
 make_item("firewand", 106, 1, 74,  90,  8,  8,  ranged, 3,  3, 5, -4)
 make_item("gun",      107, 5, 75,  91,  3,  3,  ranged, 10, 1, 5, -5)
 make_item("bow",      108, 3, 76,  92,  6,  5,  ranged, 6,  3, 5,-5)
 make_item("secret",   109, 6, 77,  93,  4,  5,  ranged, 5,  1, 5, -5, dfx_shower, 50)
 make_item("tatata",   110, 7, 78,  94,  2,  2,  ranged, 10, 1, 5, -5)
 make_item("boom",     111, 7, 79,  95,  18, 10, melee,  1,  8, 5, -4)
 make_item("elec",     160, 8, 128, 144, 20, 15, melee,  1,  8, 5, -5, dfx_thunder, 50)
end

function make_player()
 g_p = make_actor(333, 85, 129, player, l_player, up)
 g_p.weapon = g_items[5]
 g_p.anim = stay
 g_p.walk = make_anim(walk, create_direction_frames(162, 130, 162, 130, 163, 161), 1/5)
 g_p.stay = make_anim(stay, create_direction_frames(130, 130, 130, 130, 131, 129), 1/5)
 g_p.cd = 0
 g_p.cdfx = 0
 g_p.box = {x1 = 0, y1 = 1, x2 = 7, y2 = 14}
end

function make_anim(name, frames, spd)
 return {
  time = 0,
  anim = name,
  spd = spd,
  f = frames
 }
end

function make_game()
 make_weapons()
 make_player()
 make_map_items()
 -- make_ennemies(nb_of_ennemis, {132})
end

function make_map_items()
 for o in all(map_items) do
  for p in all(o.pos) do
   mset(g_p.x, g_p.y, o.spr)
  end
 end
end

function make_ennemies(nb, aspr)
 g_ennemies_left = 0
 for s in all(aspr) do
  for i=1, nb/#aspr do
   local a = g_good_spot(248, 248)
   local e = make_actor(a.x, a.y, s, ennemy, l_ennemy, up)
   e.weapon = g_items[4]
   e.cd = 50
   e.anim = stay
   e.walk = make_anim(walk, create_direction_frames(s+33, s+1, s+33, s+1, s+34, s+32), 1/10)
   e.stay = make_anim(stay, create_direction_frames(s+1, s+1, s+1, s+1, s+2, s), 1/10)
   e.dx = 0.9
   e.dy = 0.9
   e.box = {x1 = 0, y1 = 1, x2 = 7, y2 = 14}
   g_ennemies_left += 1
  end
 end
end

function make_particles(a, n, c)
 local c = c or 8
	while (n > 0) do
 	part = {}
 	part.x = a.x+4
 	part.y = a.y+4
 	part.c = flr(rnd(3)+c)
 	part.dx = (rnd(2)-1)*2
 	part.dy = (rnd(2)-1)*2
 	part.f = 0
 	part.maxf = 15
 	add(g_particles, part)
 	sfx(1)
 	n -= 1
 end
end

function make_item(name, spr, sfx, animh, animv, cd, dmg, type, speed, hb, ox, oy, dfx, cdfx)
 local item = {
  name = name,
  spr = spr,
  animh = animh,
  animv = animv,
  cd = cd,
  speed = speed,
  dmg = dmg,
  type = type,
  hb = hb,
  ox = ox,
  oy = oy,
  sfx = sfx,
  dfx = dfx or function (x, y, p, h) end,
  cdfx = cdfx or 20
 }
 add(g_items, item)
 return item
end

-- draw effect

function dfx_explosion(x, y, a, h)
	while (a > 0) do
		local explo = {
   x = x+(rnd(2)-1)*10,
   y = y+(rnd(2)-1)*10,
   r = 4 + rnd(4),
   c = 8
  }
		add(g_explosions, explo)
		sfx(0)
		a -= 1
	end
end

function dfx_thunder(x, y, p, h)
 if (#g_thunders > 100) return
 local xt = x + (rnd(10)-5)
 local thunder = {
  x = xt,
  y = g_fp.y,
  pos = {{x = xt, y = g_fp.y}},
  c = 10,
  p = p,
  h = h or 50
 }
 add(g_thunders, thunder)
 sfx(8)
 return thunder
end

function dfx_shower(x, y, p, h)
  if (#g_showers > 100) return {pos = {}}
  local shower = {
   x = x,
   y = y-30,
   pos = {},
   c = 12,
   p = p+5,
   h = 30
  }
  for r=x-(p/2), x+(p/2)do
   add(shower.pos, {x = r, y= shower.y, time=5})
  end
  add(g_showers, shower)
  -- sfx(8)
  return shower
end

function dfx_disapearance(x, y, a, h)
 local a = a or flr((rnd(5)+1))
	while (a > 0) do
		disa = {
   x = x+(rnd(2)-1)*5,
   y = y+(rnd(2)-1)*5,
   r = 2 + rnd(4),
   c = 5
  }
		add(g_explosions, disa)
		sfx(10)
		a -= 1
	end
end

-- move

function create_direction_frames(fl1, fl2, fr1, fr2, fu, fd)
 return {
  {{f = fl1, flip = true  },{f = fl2, flip = true }},
  {{f = fr1, flip = false },{f = fr2, flip = false}},
  {{f = fu,  flip = false },{f = fu,  flip = true }},
  {{f = fd,  flip = false },{f = fd,  flip = true }}
 }
end

function controls_menu()
 if (btnp(up) and g_selected_item > 1) then
  g_selected_item -= 1
 end
 if (btnp(down) and g_selected_item < #g_items) then
  g_selected_item += 1
 end
 if (btnp(fire1)) then
  g_p.weapon = g_items[g_selected_item]
  g_open_inv = false
  g_p.cd = 10
 end
end

function controls_player()
 g_p.anim = walk
 if (is_moving(left))  move(g_p,-1, 0, 0, 6)
 if (is_moving(right)) move(g_p, 1, 0, 6, 6)
 if (is_moving(up))    move(g_p, 0,-1, 6, 0)
 if (is_moving(down))  move(g_p, 0, 1, 6, 6)
 if (is_not_moving())  g_p.anim = stay
 action_player()
end

function action_ennemies(a, d)
 if (a.tag ~= ennemy) return
 if (a.cd > 0) a.cd -= 1
 if (a.cd == 0) then
  shoot(a, d)
  a.cd = 50
 end
end

function controls_ennemies()
 for a in all(g_actors) do
  if (a.tag == ennemy) then
   local dist = check_distance_from_player(a)
   if(is_player_near(dist)) then
    a.anim = walk
    if (dist >= a.weapon.type) then
     local dir_m = going_forward(a)
     move_on(a, dir_m)
    else
     local dir_m = get_best_direction(a)
     move_on(a, dir_m)
    end -- dist >= weapon type
    local dir_a = prepare_attack_opportunity(a)
    a.d = dir_a
    action_ennemies(a, dir_a)
   else
     a.anim = stay
   end -- is player near
  end -- tag is ennemy
  if (a.tag == bullet) then
   a.x += a.dx
   a.y += a.dy
   if (is_of_limit(a.x, a.y, a.bx, a.by, a.range)) del(g_actors, a)
  end
 end
end

function going_forward(a)
 local rx = a.x - g_p.x
 local ry = a.y - g_p.y
 if(abs(rx) > abs(ry)) then
   if(rx < 0) return right
   return left
 else
   if(ry < 0) return down
   return up
 end
end

function check_distance_from_player(a)
 local rx = a.x - g_p.x
 local ry = a.y - g_p.y
 return (abs(rx) + abs(ry)) / 2
end

function get_best_direction(a)
 local rx = a.x - g_p.x
 local ry = a.y - g_p.y
 if((abs(rx) - abs(ry)) < 0 and abs(rx) > 1) then
   if(rx < 0) return right
   return left
 elseif((abs(rx) - abs(ry)) > 0 and abs(ry) > 1) then
   if(ry < 0) return down
   return up
 end
 return none
end

function prepare_attack_opportunity(a, d)
 if(abs(a.x - g_p.x) < abs(a.y - g_p.y)) then
   if(a.y < g_p.y) return down
   return up
 else
   if(a.x < g_p.x) return right
   return left
 end
end

function is_player_near(gap)
 return gap <= 30 and gap > 8
end

function target_nearest_one(limit)
 limit = limit or inf
 local rx = inf
 local ry = inf
 local target = {x = inf , y=inf}
 for a in all(g_actors) do
  if(a.tag == ennemy) then
   if((rx+ry)/2 > check_distance_from_player(a)) then
    rx = abs(a.x-g_p.x)
    ry = abs(a.y-g_p.y)
    target = a
   end -- check distance from player
  end -- tag is ennemy
 end -- for all actors
 if (check_distance_from_player(target) > limit) return {}
 return target
end

function move_on(a, go)
 if (go == left)  move(a ,-a.dx, 0, 0, 8)
 if (go == right) move(a, a.dx, 0, 8, 8)
 if (go == up)    move(a, 0 ,-a.dy, 8, 0)
 if (go == down)  move(a, 0, a.dy, 8, 8)
 if (go ~= none)  a.d = go
end

function is_moving(direction)
 if (btn(direction)) then
  g_p.d = direction
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

function move(a, x, y, ox, oy)
 local x1 = (a.x + x + (ox * x)) / 8
 local y1 = (a.y + y + (oy * y)) / 8
 local x2 = (a.x + x + ox) / 8
 local y2 = (a.y + y + oy) / 8
 g_cm.x1 = x1 * 8
 g_cm.y1 = y1 * 8
 g_cm.x2 = x2 * 8
 g_cm.y2 = y2 * 8
 local sp1 = mget(x1, y1)
 local sp2 = mget(x2, y2)

 if (fget(sp1, f_obst) == false and fget(sp2, f_obst) == false) then
  a.x += x
  a.y += y
 end
 if(a.tag == player) then
  if(fget(sp1, f_heal) and a.health < l_player) then
   pick_item((a.x + x + (ox * x)) / 8 ,(a.y + y + (oy * y)) / 8)
   a.health += 10
   if (a.health > l_player) a.healh = l_player
  end
  if(fget(sp2, f_heal) and a.health < l_player) then
   pick_item((a.x + x + ox) / 8 ,(a.y + y + oy) / 8)
   a.health += 10
   if (a.health > l_player) a.healh = l_player
  end
 end
end

-- action

function action_player()
 if (g_p.cd > 0) g_p.cd -= 1
 if ((g_p.cd == 0) and btn(fire1)) then
  shoot()
  g_p.cd = g_p.weapon.cd
 end
 if (g_p.cdfx > 0) g_p.cdfx -= 1
 if (btnp(fire2)) then
  sp = mget(g_p.x / 8 ,(g_p.y - 1) / 8)
  if (fget(sp, f_inv)) then
   g_open_inv = true
  elseif (g_p.cdfx == 0) then
   g_p.cdfx = g_p.weapon.cdfx
   local target = target_nearest_one(50)
   if (target.x ~= nil) then
    g_p.weapon.dfx(target.x, target.y, 3, abs(g_fp.y - target.y))
    target.health -= 10
    check_actor_health(target)
   else
    sfx(9)
   end -- is target present
  end -- case is inv else cdfx is over
 end -- fire 2 button triggered
end

function pick_item(x, y)
 sfx(2)
 mset(x, y, 32)
end

function wait_inventory_close()
 if (btnp(fire2)) then
  g_open_inv = false;
 end
end

function anim_state(a, f)
 f.time += f.spd
 if(f.time >= 2) f.time = 0
	return f.f[a.d+1][flr(f.time)+1]
end

function anim_player(a)
	if(a.anim == stay) then
		return anim_state(a, a.stay)
	else
		return anim_state(a, a.walk)
	end
end

-- util

function g_good_spot(xmax, ymax)
 local a = {
  x = 0,
  y = 0
 }
 local f = f_obst
 while(fget(mget(a.x / 8 ,(a.y) / 8), f_obst)) do
  a.x = rnd(xmax)
  a.y = rnd(ymax)
 end
 return a
end

function is_of_limit(x, y, bx, by, r)
 local fpx = get_formalised_position(g_p.x);
 local fpy = get_formalised_position(g_p.y);
 local bx = bx or x
 local by = by or y
 local r = r or 1
 if (x < fpx or x >= fpx + 128 or
		y < fpy or y >= fpy + 128) then
		return true
 end
 if (x < bx - r or x >= bx + r or
  y < by - r or y >= by + r) then
  return true
 end
 return false
end

function shoot(a, d)
 local a = a or g_p
 local d = d or a.d
 local speed = a.weapon.speed
 local center = a.weapon.hb / 2
 local b = {}
 if(d == left) then
  b = make_actor(a.x-6, a.y+4, a.weapon.animh, bullet, immortal_object, left)
  b.box = {x1 = 0, y1 = 4-center, x2 = 5, y2 = 4+center}
  b.dx = -speed
 end
 if(d == right) then
  b = make_actor(a.x+6, a.y+4, a.weapon.animh, bullet, immortal_object, right)
  b.box = {x1 = 3, y1 = 4-center, x2 = 8, y2 = 4+center}
  b.dx = speed
 end
 if(d == up) then
  b = make_actor(a.x, a.y-8, a.weapon.animv, bullet, immortal_object, up)
  b.box = {x1 = 4-center, y1 = 0, x2 = 4+center, y2 = 5}
  b.dy = -speed
 end
 if(d == down) then
  b = make_actor(a.x, a.y+18, a.weapon.animv, bullet, immortal_object, down)
  b.box = {x1 = 4-center, y1 = 3, x2 = 4+center, y2 = 8}
  b.dy = speed
 end
 b.dmg = a.weapon.dmg
 if (d ~= none or a.tag == player) then
  sfx(a.weapon.sfx)
 end
 if (a.weapon.type == melee) then
  b.range = 5
 else
  b.range = 128
 end
end

function get_formalised_position(a)
 return a - 64 < 0 and 0 or a - 64
end

function manage_weapon_direction(direction)
 direction = direction or none
 local inv = {
  h = false,
  v = false,
  ox = 0,
  oy = 0
 }
 if (direction == left or direction == up) then
  inv.h = true
  inv.v = false
  inv.ox = -6
 end
 if (direction == right) inv.ox = -4
 if (direction == up) inv.ox = -10
 return inv
end

function manage_aim_direction(direction)
 direction = direction or none
 local inv = {
  h = false,
  v = false
 }
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

function draw_border_on_caracter(anim, x, y, c)
	for i=1, 16 do
		pal(i, c)
 end
 spr(anim.f, x,   y+1, 1, 2, anim.flip, false)
 spr(anim.f, x,   y-1, 1, 2, anim.flip, false)
 spr(anim.f, x-1, y,   1, 2, anim.flip, false)
 spr(anim.f, x+1, y,   1, 2, anim.flip, false)
 pal()
 palt(pink,true)
 spr(anim.f, x,   y,   1, 2, anim.flip, false)
end

-- collisions

function get_box(a)
 return {
  x1 = a.x + a.box.x1,
  y1 = a.y + a.box.y1,
  x2 = a.x + a.box.x2,
  y2 = a.y + a.box.y2
 }
end

function check_collisions(a, b)
 if(a == b or a.tag == b.tag) return false
 local box_a = get_box(a)
 local box_b = get_box(b)
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

function is_game_done()
 return g_ennemies_left <= 0
end

function check_actor_health(damaged_actor)
 if (is_dead(damaged_actor)) then
  if (damaged_actor.tag == ennemy) g_ennemies_left -= 1
  dfx_disapearance(damaged_actor.x, damaged_actor.y)
  screenshake(5)
  del(g_actors, damaged_actor)
 end
end

function controls_collisions()
 for a in all(g_actors) do
  for b in all(g_actors) do
   if (check_collisions(a, b)) then
    local damaged_actor = a
    if (a.tag == bullet and b.tag ~= bullet) then
     b.health -= a.dmg
     damaged_actor = b
     make_particles(b, 10, 5)
     del(g_actors, a)
    elseif (b.tag == bullet and a.tag ~= bullet) then
     a.health -= b.dmg
     make_particles(a, 10, 5)
     del(g_actors, b)
    end -- collision from bullet
    check_actor_health(damaged_actor)
   end -- if collision
  end
 end
end

function rnd_color(colors)
 local rndv = flr(rnd(1000))
 for m=1 ,#colors do
  if (rndv >= 100/m+1) return colors[m]
 end
 return colors[1]
end

-- draw

function _draw()
 cls()
 draw_menu()
end

function draw_particles()
	for part in all(g_particles) do
		pset(part.x, part.y, part.c)
		part.x += part.dx
		part.y += part.dy
		part.f += 1
		if (part.f > part.maxf or is_of_limit(part.x, part.y)) then
			del(g_particles, part)
		end
	end
end

function draw_explosions()
	for e in all(g_explosions) do
  circfill(e.x, e.y, e.r, e.c)
  e.r -= 0.5
  if (e.r < 4) e.c += 1
  if (e.r < 2) e.c += 1
  if (e.r <= 0) del(g_explosions, e)
	end
end

function draw_thunders()
 for t in all(g_thunders) do
  for xy in all(t.pos) do
   pset(xy.x, xy.y, t.c)
  end
  for nt=1, 10 do
   t.x += (rnd(2)-1)
   t.y += 1
   t.h -= 1
   add(t.pos ,{x = t.x, y=t.y})
  end
  if (flr(rnd(t.p)) == 0) dfx_thunder(t.x, t.y, t.p+2, t.h)
  if (t.h < -10) del(g_thunders, t)
 end
end

function draw_waterfalls()
 for s in all(g_showers) do
  for xy in all(s.pos) do
   if (xy.time > 0) then
    pset(xy.x, xy.y, rnd_color({s.c, 7}))
    xy.time -= 1
   end
  end
  for i=1, 3 do
   if (s.h < 5) s.p +=1
   s.y += 1
   s.h -= 1
   for r=s.x-(s.p/2), s.x+(s.p/2)do
    add(s.pos, {x = r, y= s.y, time=5})
   end
  end
  if (s.h < 0) del(g_showers, s)
 end
end

function draw_skills(bx, by)
 draw_item_shape(bx-10, by+7, 55, g_p.cdfx, g_p.weapon.cdfx)
 draw_item_shape(bx+18, by+7, g_p.weapon.animv, g_p.cd, g_p.weapon.cd)
end

function draw_actors()
 for a in all(g_actors) do
  if (a.tag == player or a.tag == ennemy) then
   draw_border_on_caracter(anim_player(a), a.x, a.y, black)
   draw_weapon(a,manage_weapon_direction(a.d))
  else
   local inv = manage_aim_direction(a.d)
   spr(a.s, a.x, a.y, 1, 1, inv.h, inv.v)
  end
 end
end

function draw_weapon(a,f)
 spr(a.weapon.spr, a.x + a.weapon.ox + f.ox, a.y - a.weapon.oy + f.oy, 1, 1, f.h, f.v)
end

function draw_hud()
 local bx = g_fp.x+60
 local by = g_fp.y+108
 draw_life(bx, by)
 draw_skills(bx, by)
end

function draw_life(bx, by)
 local offsetlife = #spr_life - flr(((g_p.health * #spr_life) / l_player))
 for y = 1 , #spr_life do
  for x = 1 , #spr_life[y] do
   if (spr_life[y][x] ~= black) then
    if (offsetlife >= y and spr_life[y][x] == red) then
     pset(bx + x, by + y, light_gray)
    else
     pset(bx + x, by + y, spr_life[y][x])
    end
   end
  end
 end
end

function draw_menu()
 map(0, 48, 0, 0, 16, 16)
 print("sophia quest", 35, 75, white)
 print("press x+c", 50, 90, white)
end

function draw_inventory(x, y)
 if (g_open_inv) then
  rectfill(x, y, x + 48, y + 128, dark_blue)
  line(x, y, x, y + 128, light_gray)
  local tx = x + 7
  local ty = y + 10
  for i = 1 ,#g_items do
   draw_item_shape(tx, ty, g_items[i].spr)
   print(g_items[i].name, tx + 12, ty - 2, white)
   if (g_selected_item == i) then
    spr(58, tx - 7, ty - 2)
   end
   ty += 12
  end
 end
end

function draw_item_shape(x, y, s, cd, max)
 local cd = cd or 0
 local max = max or 1
 rectfill(x - 2, y - 5,  x + 9, y + 5, white)
 local curcd = ceil((cd*8)/max)
 rectfill(x - 2, y - 5 + curcd, x + 9, y + 5, light_gray)
 line(x - 2, y - 5, x - 2, y + 5, dark_gray)
 line(x - 2, y - 5, x + 9, y - 5, dark_gray)
 line(x + 9, y - 5, x + 9, y + 5, dark_gray)
 line(x + 9, y + 5, x - 2, y + 5, dark_gray)
 spr(s, x, y - 4)
end

function draw_game()
 cls()
 map(0, 0, 0, 0, 48, 48)
 g_fp = follow_player()

 set_camera()

 draw_particles()
 draw_explosions()
 draw_thunders()
 draw_actors()
 draw_waterfalls()
 draw_hud()
 draw_inventory(g_fp.x+80, g_fp.y)

 if(debug_enabled) debug()
end

-- update

function update_menu()
 if (btn(fire1) and btn(fire2)) then
  _update = update_game
  _draw = draw_game
  g_p.cd = 10
 end
end

function update_game()
 if (g_open_inv == false) then
  controls_ennemies()
  controls_player()
  controls_collisions()
 else
  wait_inventory_close()
  controls_menu()
 end
 check_game_state()
end
-- camera

function follow_player(ofx, ofy)
 local ofx = ofx or 0
 local ofy = ofy or 0
 return {
  x = (get_formalised_position(g_p.x)) + ofx,
  y = (get_formalised_position(g_p.y)) + ofy
 }
end

function set_camera()
 g_scr.x = get_formalised_position(g_p.x)
 g_scr.y = get_formalised_position(g_p.y)
 if (g_scr.shake > 0) then
  g_scr.x += (rnd(2)-1)*g_scr.intensity
  g_scr.y += (rnd(2)-1)*g_scr.intensity
  g_scr.shake -= 1
 end
 camera(g_scr.x, g_scr.y)
end

function reset_camera()
  camera(0, 0)
end

function check_game_state()
 if (is_dead(g_p) or is_game_done()) then
  cls()
  g_actors = {}
  g_particles = {}
  g_explosions = {}
  g_items = {}
  make_game()
  reset_camera()
  _draw = draw_menu
  _update = update_menu
 end
end

function screenshake(n)
 g_scr.shake = n
end

-- sprites

spr_life = {
 {0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0},
 {0, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5, 0},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5},
 {0, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5, 0},
 {0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0}
}

-- map items positions

map_items = {
 {
  name = "heal_potion",
   spr = 118,
   pos = {
   {x = 9, y = 4},
   {x = 17, y = 16},
   {x = 25, y = 14},
   {x = 21, y = 7},
   {x = 25, y = 10}
  }
 }
}

-- debug

function debug_init()
  g_dbg = {"","","","","","","","","",""}
  g_cm = {
  x1 = 0,
  y1 = 0,
  x2 = 0,
  y2 = 0
 }
end

function debug()
 debug_collision_matrix()
 debug_hitbox_matrix()
 debug_log(g_fp.x+10, g_fp.y+10)
end

function debug_collision_matrix()
 line(g_cm.x1,g_cm.y1,g_cm.x2,g_cm.y2,pink)
end

function debug_hitbox_matrix()
 local b = get_box(g_p)
 line(b.x1, b.y1, b.x1, b.y2, red)
 line(b.x1, b.y1, b.x2, b.y1, red)
 line(b.x2, b.y1, b.x2, b.y2, red)
 line(b.x2, b.y2, b.x1, b.y2, red)
end

function log(tab,text)
 if(tab < 0 or tab > #g_dbg) return
 g_dbg[tab] = text
end

function debug_log(x, y)
 for i=1,#g_dbg do
  print(g_dbg[i], x, y+(6*i), red)
 end
end

__gfx__
eeeeeeee5555555533bb3b33517711550000000057557557a555555a550000000000000000000055001111111111111111111100cccccccce55555555555555e
eeeeeeee777777773bbbb3b3617171660cc7ccc057557557a55555a500666666666666666666660050dddddddddddddddddddd05cccccccceeeeeeeeeeeeeeee
ee7ee7ee55555555b33bbbbb617711660c7cccc057557557a5555a55060000000000000000000060501111111111111111111105ccc77ccce55555555555555e
eee77eee555555553bbb3b33517171550cccccc057557557a555a555076066606660666066606670501111111111111111111105cccccccce55555555555555e
eee77eee777777773b3bb3bb617711650cccccc057557557a55a555507060606060606060606067050dddddddddddddddddddd05cccccccceeeeeeeeeeeeeeee
ee7ee7ee55555555bbb3bbb3611111650cccc7c057557557a5a55555076660666066606660666070501111111111111111111105cccccccce55555555555555e
eeeeeeee5555555533bb3bbb617171650ccc7cc057557557aa555555070606060606060606060670501111111111111111111105c77ccc7ce55555555555555e
eeeeeeee777777773b3bbbb3517771550cccccc057557557a555555507606660666066606660667050dddddddddddddddddddd05cccccccceeeeeeeeeeeeeeee
6ee66ee65555555555555555511111550c5555c05557755555575555070606060606060606060670501111111111111111111105ccca91cceeeeeeeeeeeeeeee
033003305555555555555555617771660c7cccc05557755555575555076660666066606660666070501111111111111111111105caaaa81ceeeeeeeeeeeeeeee
033003305555555555555555617111660cccccc0555775555557555507060606060606060606067050dddddddddddddddddddd05aa990aa1eeeeeeeeeeeeeeee
033003307777775555555555511771550cccccc05557755555575555076066606660666066606670501111111111111111111105aa990aa1eeeeeeeeeeeeeeee
033003307777775555555555617771650cccccc05557755555575555070606060606060606060670501111111111111111111105caaaa81ceeeeeeeeeeeeeeee
033003b05555555555555555666066650ccc7cc0555775555557555507666066606660666066607050dddddddddddddddddddd05ccca91cceeeeeeeeeeeeeeee
03b003b05555555555555555666066650cc7ccc05557755555575555070606060606060606060670501111111111111111111105cccccccceeeeeeeeeeeeeeee
03300330555555555555555555505555555555555555555555575555076066606660666066606670501111111111111111111105cccccccceeeeeeeeeeeeeeee
03300330333333333333333333333bbbbbb3333333333bbbbbb3333307060606060606060606067050dddddddddddddddddddd05eeeeeeeeeeeeeeeeeeeeeeee
0330033033333b33333883333333bbbbbbbbb3333333bbbbbbbbb333076660666066606660666070501111111111111111111105eeeeeeeeeeeeeeeeeeeeeeee
03300330333b3b3333899833333bbb2bb2bbbb33333bbb8bb8bbbb33070606060606060606060670501111111111111111111105eeeeeeeeeeeeeeeeeeeeeeee
03b0033033333333389aa98333bb2bbbbbb2bbb333bb8bbbbbb8bbb307606660666066606660667050dddddddddddddddddddd05eeeeeeeeeeeeeeeeeeeeeeee
03b003b033333333b89aa98b3bbbbbbbbbbbbbb33bbbbbbbbbbbbbb3070606060606060606060670501111111111111111111105eeeeeeeeeeeeeeeeeeeeeeee
0b3003303b3333b3bb8998bb3b2bbb2bb2bbb2bb3b8bbb8bb8bbb8bb070000000000000000000070501111111111111111111105eeeeeeeeeeeeeeeeeeeeeeee
033003303b3333b33bb88bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00666666666666666666660050dddddddddddddddddddd05eeeeeeeeeeeeeeeeeeeeeeee
0330033033333333333bb3333bb2b444bbbb2bb33bb8b444bbbb8bb3060000000000000000000060555555555555555555555555eeeeeeeeeeeeeeeeeeeeeeee
3333333333333333333333333bbbbb4bbbbbbbb33bbbbb4bbbbbbbb300000000333ee33336666663eceeeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeee
3333888333333a333223223333b3b44bb44b3b3333b3b44bb44b3b330aaaaaa033a22a33355dd553ecceeeee5555555544444554eeeeeeeeeeeeeeeeeeeeeeee
333338333333a9a3328282333b3bbb44b4bbb3b33b3bbb44b4bbb3b30a9999a03a8aa8a3355d5d53eccceeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeee
3333383333333a3332888233b3bbbb4444bbbb3bb3bbbb4444bbbb3b0a9889a0e2a88a2e355565d3ecccceee5555555544444444eeeeeeeeeeeeeeeeeeeeeeee
3333333333333333b28882b33333b344443b33333333b344443b33330a9889a0e2a88a2e35565dd3eccc1eeeeeeeeeee44554454eeeeeeeeeeeeeeeeeeeeeeee
3333333333833333bb282bb3333333444433333333333344443333330a9999a03a8aa8a331655553ecc1eeee5555555545554444eeeeeeeeeeeeeeeeeeeeeeee
33333333382833333bbbbb33333334444443333333333444444333330aaaaaa033a22a333c155553ec1eeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeee
333333333383333333bbb3333333344444433333333334444443333300000000333ee33335555553e1eeeeee5555555544444444eeeeeeeeeeeeeeeeeeeeeeee
555555555555555555555555111111115555555555555555eeeeeeeeeeeeeeeeeeee99eeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
56666666656666666566666561555516558aaaaaaaaaa855eeeeeeeeeeeeeee99eee9eeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee58e58e568865e
56666666656666666566666565566556588aaaaaaaaaa885eeeeeeeeeeeeeeee9eee9eeeeeeec51eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeeeeeeee56899865
56666666656666666566666561666616aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeee99eeeeeeeeeec51eeee88eeeeeeeeeee7eeeee5ecccccccee58eeeee689aa986
56665555555555555555666511666611aaa0000000000aaaeeeeeeeeeeeeeeeee99eeeeeeeeec51eeee898eeeee558eee74444551111111ceeee58ee689aa986
56665666666665666665666561666616aa000000000000aaeeeeeeeeeeeeeeeeeeee999eeeeec51eeee88eeeeeeeeeee7eeeee5eccccccceeeeeeeee56899865
55555666666665666665666561666616aa000000000000aaeeeeeeeeeeeeeeee99eeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeee58ee58e568865e
56665665555555555665666511666611aaa0000000000aaaeeeeeeeeeeeeeeeeeeeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
56665665666666665665666566666666a0aaaaaaaaaaaa0aeeeeeeeeeeeeeeeeeeee99eeeeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeeeceeeeee8e8eeeee5665ee
56665665666666665665555566666666a00aaaaaaaaaa00aeeeeeeeeeeeeeee99eee9eeee111111eeeeeeeeeeeeeeeeeee555eeeeeccceeeee5e5eeee568865e
56665555666666665665666566666666aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeee9eee9eee15555551eee8eeeeeee8eeeeeee4eeeeecc1cceeeeeeeeee56899865
56665665666666665665666566666666a00aaaaaaaaaa00aeeeeeeeeeeeeeeee99eeeeee55cccc55ee898eeeeee5eeeeeee4eeeeeec1ceeeeee8e8ee689aa986
56665665666666665665666566666666a00aaaaaaaaaa00aeeeeeeeeeeeeeeeee99eeeee5ceeeec5ee888eeeeee5eeeeeee4eeeeeec1ceeee8e5e5ee689aa986
56665665666666665555666566666666a0aaaaaaaaaaaa0aeeeeeeeeeeeeeeeeeeee999eceeeeeeceeeeeeeeeeeeeeeeeee7eeeeeec1ceeee5eeeeee56899865
55555665666666665665666566666666aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeee99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7e7eeeeec1ceeeeeee8eeee568865e
56665665666666665665666566666666aaa0000000000aaaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec1ceeeeeee5eeeee5665ee
56665665555555555665666566666666aa000000000000aaeeeeeeeeeeeeeeeeeeeeeeeeeeee1eeeeee8eeeeeeeeeeeeeeee4eeeeeee8eeeeeeeeeeeee888eee
56665666665666666665555566666666aa000000000000aaeeeeeeeeeeeeeeeeeee99eeeeeec1eeeee828eeeeeeeeeeeeeede4eeeee88eeeeeeeeeeeee888eee
56665666665666666665666566666666aa000000000000aaeeeeeeeeeeeeeeeeeee9e9eeeeec1eeeee48eeeeeeee8eeeeeedee4ee5555511eeee8eeeee8d8eee
56665555555555555555666566666666aaa0000000000aaaeeeeeeeeeeeeeeeeeeee5e9eeeec1eeeeee4eeeeee55559eeeedee4ee5555511e5555a55ee8d8eee
56666656666666566666666566666666aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeee5e99eeeec1eeeee4eeeeeeeddeeeeeeedee4eeeddeeeeeeddeaaeee8d8eee
56666656666666566666666566666666aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeee95eeeeeeeec1eeeeee4eeeeeedeeeeeeeede4eeeedeeeeeeedeeaaeeedddeee
56666656666666566666666566666666566aaaaaaaaaa665eeeeeeeeeeeeeeeeea9eeeeeeeeceeeeeee4eeeeeeeeeeeeeeee4eeeeeeeeeeeeeeeeeeeeeedeeee
555555555555555555555555666666665566aaaaaaaa6655eeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3334433333344333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e787787ee717717ee737737ee757757eeeeeeeeeeeeeeeee33d44d3333d44d33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ea8aa8aee616616eeb3bb3bee959959eeeeeeeeeeeeeeeee33d22d3333d11d33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3d6666d33d6666d3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8aa8eeed1661dee63bb36ee459954eeeeeeeeeeeeeeeee3d8888d33dccccd3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8aa8eeed1661dee63bb36ee459954eeeeeeeeeeeeeeeee3d8888d33dccccd3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8888eeed1111dee633336ee455554eeeeeeeeeeeeeeeee3d8888d33dccccd3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee33dddd3333dddd33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eccccccceccccceecccccccee166661eee11166ee111111ee88888c8ee8888ee88888c8ee55f555eeee5555ee55ff55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccccccccccccccecccccccce161161eee11161ee114411e88888888ee88888e8882888ee55ff55eee55555ee5f5ff5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cc66cc6ccccc6ccecccccccc1111111eee111111e111111e88228828e888288e8822888eeffffffeee55fffee5fff55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c6fcfffcccccfffccccccccce4f4fffeee444f4ee444444e82ffff28e888fffe8882288eef0ff0feee55f0fee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cf0ff0fcecfcf0feccccccccef0ff0feee44f0fee444444e8f1ff1f8eef8f1fe8888828eeffffffeee5ffffee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cf0ff0fcccccf0fecc6cccccef0ff0feee4ff0fee444444e8f1ff1feee28f1fe88288feeef4444feee5fff4ee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ccffffcccccccffeccc6c6cceeffffeeeeeffffeef4444fe88ffffeeee828ffee882ffeee44ff44eeeeff44ee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccdd1ccec6cccee6ccc6cc699999999eee999ee9999999985566555ee5856ee5855555511477411eee1774e11555511eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
f6cdd16fccf61deef6cccccfff9559ffeeeff5eef999999f555a6555ee5556ee5555555511477411eee1114e11111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ff1111ffecff11eef16cc66fff5995ffeeeff9eef999999f55566555ee555eee5555555511177111eee111ee11111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ff1111ffeeff11eef116611fff9999ffeeeff9eef999999fff5565ffeeff5eeef555555fff1111ffeeeff1eef111111feeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e111111eeee111eee111111ee111111eeeee11eee111111ee555d55eeee5deeee55d555ee111111eeeee11eee111711eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e511115eeee511eee511115ee11ee11eeeee11eee11ee11eeddeeddeeeeddeeeeddeeddee11ee11eeeee11eee11ee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e55ee55eeee55eeee55ee55ee11ee11eeeee11eee11ee11ee44ee44eeee44eeee44ee44ee11ee11eeeee11eee11ee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e55ee55eeee555eee55ee55ee55ee55eeeee555ee55ee55ee44ee44eeee444eee44ee44ee55ee55eeeee555ee55ee55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eccccccceccccceecccccccee166661eee11166ee111111ee88888c8ee8888ee8888888ee55f555eeee5555ee55ff55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccccccccccccccecccccccce161161eee11161ee114411e88888888ee88888e8882888ee55ff55eee55555ee5f5ff5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cc66cc6cccccfccecccccccc1111111eee111111e111111e88228828e888288e8882888eeffffffeee55fffee5fff55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c6fcfffcccccfffccccccccce4f4fffeee444f4ee444444e82ffff28e888fffe8888288eef0ff0feee55f0fee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cf0ff0fcecfcf0fecc6cccccef0ff0feee44f0fee444444e8f1ff1f8eef8f1fe8888828eeffffffeee5ffffee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cf0ff0fcccccf0feccc6c6ccef0ff0feee4ff0fee444444e8f1ff1feee28f1fe88288feeef4444feee5fff4ee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ccffffcccccccffeeccc6ccceeffffeeeeeffffeef4444fe88ffffeeee828ffee882ffeee44ff44eeeeff44ee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cc1dd1ceec6ccceee6cccc6f9995599eeee999ee999999998556655eee5856ee585555551147741eeee1774e11555511eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
6c1ddf6eccf61deee16cc6fff9599ffeeeeffdeef99999ff2556655eee5556ee55555555f417411eeee1114e11111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e1111ffeecfff1eee116611ee9999ffeeeefffeef99999ffe5556ffeee55feeef55555ffe1177ffeeee111eef11111ffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e111111eee1111eee551111ee111111eeee999eee111111ee555dddeee555eeee555d55ee111111eeee11feee111711eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e55ee55ee51111eee55ee55ee11ee11ee511111ee11ee11eeddeeddee4ddddeeeddeeddee11ee11ee511111ee11ee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e55ee55ee55ee55ee55ee55ee11ee55ee55ee11ee55ee11ee44ee44ee44eed4ee44ee44ee11ee55ee55ee11ee55ee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e55eeeeeeeeeee55eeeee55ee55eeeeeeeeeee55eeeee55ee44eeeeeeeeeee44eeeee44ee55eeeeeeeeeee55eeeee55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808080800002a000000000000000000000000080808000000000000000000000000000800080000000000000000000000000008080800000000000000005050505000003030000000000000000
0000008080800000000000000000000000000080808000000000000000000000000000808080000000000000000000000000008080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215252121512505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215252121512505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202315252121512505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215252121512505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215252121512505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000020202020202020202020202315252121512505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000002020202020202020202020221525212151250500000000000001f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000002121212131212121212131213152521215125050000000001f1f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000616161616161036161616161616252050505506061616161616161610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000616161616161136161616161616162050505606161616161616161616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000121212121212121212121212120101121212010112121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000111111111111111111111111110101121212010111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000121212121212121212121212120101121212010112121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000414141414141414141414141414141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000414141414141414141414141414141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000101010101010101010101010101010101010101010105151101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000202020202020202020202020202020202020202020205151202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070808080809161212161212164445161212162324310e0f212121212132212121212121210200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000171818181819161212161212165455161212163334020e0f213102212121212221213221210200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000272828282829161212161212166465161212162102210e0f232421210202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000a040b0b040c121212121212121212121212122121220e0f333423240200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001a1b1b1b1b1c121212121212121212121212121212121212212133340200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001a1b04041b1c121207080808080808080808080912121212020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002a2b14142b2c121217181818181818181818181912121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000121212121212121227282828282828282828282912121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000012121212121212120a0b0b0b0b0b0b0b0b0b0b0c12121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000012121212121212121a04041b1b04041b1b04041c12121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000012121212121212121a1b1b1b1b1b1b1b1b1b1b1c12121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000012121212121212121a1b1b04041b1b04041b1b1c12121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000012121212121212122a2b2b14142b2b14142b2b2c12121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000121212121212121212121212121212121212121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000500000d6600d6400d6300d6200d610010000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d1000d10000000316000260008600000000000000000000000000000000
00040000185601755017540175301651016500165001670013700117001f2001e2001b2001a2001b2001e20000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000015760187501a7501d7401f740207302272023710257002570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d7700a7700677005760037500274001720027100640005400054000000000000000000000000000000002c2000000000000000000000000000000000000000000000000000000000000000000000000
0001000011130161401d150221602617023160201601a150151500e1300b13007120021100110000000000000000000000000000b200000000000000000000000000000000000000000000000000000000000000
00010000376602f66028660236501e6501b6401664012640106300d6300a620086100661003600326000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000028750237602175025730257101a7101874017760167601674018720197702f5002f5002f5002f5002e50029500215001a5002e5002e5002d50028500225001c500195001a50028500275002650000000
000200002a63024630226302a6301d630236302a6301d6301a6302c6301f6302b6300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000376203762037620376203762037620366203661034610326102e60029600216001a6000e6000160003600000000000000000000000000000000000000000000000000000000000000000000000000000
0001000012040100400f0400e0400f0401004011040000000000000000110001200012000130000000014000140001c0001500015000160001700017000170000000000000000000000000000000000000000000
000500001364013630136200000013640136301362000000136401363013620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
