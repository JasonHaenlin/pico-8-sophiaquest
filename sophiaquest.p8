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

debug_enabled = true

-- init
function _init()
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
000000005555555533bb3b33517711550000000057557557a555555a550000000000000000000055001111111111111111111100cccccccc0555555555555550
00000000777777773bbbb3b3617171660cc7ccc057557557a55555a500666666666666666666660050dddddddddddddddddddd05cccccccc0000000000000000
0070070055555555b33bbbbb617711660c7cccc057557557a5555a55060000000000000000000060501111111111111111111105ccc77ccc0555555555555550
00077000555555553bbb3b33517171550cccccc057557557a555a555076066606660666066606670501111111111111111111105cccccccc0555555555555550
00077000777777773b3bb3bb617711650cccccc057557557a55a555507060606060606060606067050dddddddddddddddddddd05cccccccc0000000000000000
0070070055555555bbb3bbb3611111650cccc7c057557557a5a55555076660666066606660666070501111111111111111111105cccccccc0555555555555550
000000005555555533bb3bbb617171650ccc7cc057557557aa555555070606060606060606060670501111111111111111111105c77ccc7c0555555555555550
00000000777777773b3bbbb3517771550cccccc057557557a555555507606660666066606660667050dddddddddddddddddddd05cccccccc0000000000000000
600660065555555555555555511111550c5555c05557755555575555070606060606060606060670501111111111111111111105ccca91cc0000000000000000
033003305555555555555555617771660c7cccc05557755555575555076660666066606660666070501111111111111111111105caaaa81c0000000000000000
033003305555555555555555617111660cccccc0555775555557555507060606060606060606067050dddddddddddddddddddd05aa990aa10000000000000000
033003307777775555555555511771550cccccc05557755555575555076066606660666066606670501111111111111111111105aa990aa10000000000000000
033003307777775555555555617771650cccccc05557755555575555070606060606060606060670501111111111111111111105caaaa81c0000000000000000
033003b05555555555555555666066650ccc7cc0555775555557555507666066606660666066607050dddddddddddddddddddd05ccca91cc0000000000000000
03b003b05555555555555555666066650cc7ccc05557755555575555070606060606060606060670501111111111111111111105cccccccc0000000000000000
03300330555555555555555555505555555555555555555555575555076066606660666066606670501111111111111111111105cccccccc0000000000000000
03300330333333333333333333333bbbbbb3333333333bbbbbb3333307060606060606060606067050dddddddddddddddddddd05000000000000000000000000
0330033033333b33333883333333bbbbbbbbb3333333bbbbbbbbb333076660666066606660666070501111111111111111111105000000000000000000000000
03300330333b3b3333899833333bbb2bb2bbbb33333bbb8bb8bbbb33070606060606060606060670501111111111111111111105000000000000000000000000
03b0033033333333389aa98333bb2bbbbbb2bbb333bb8bbbbbb8bbb307606660666066606660667050dddddddddddddddddddd05000000000000000000000000
03b003b033333333b89aa98b3bbbbbbbbbbbbbb33bbbbbbbbbbbbbb3070606060606060606060670501111111111111111111105000000000000000000000000
0b3003303b3333b3bb8998bb3b2bbb2bb2bbb2bb3b8bbb8bb8bbb8bb070000000000000000000070501111111111111111111105000000000000000000000000
033003303b3333b33bb88bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00666666666666666666660050dddddddddddddddddddd05000000000000000000000000
0330033033333333333bb3333bb2b444bbbb2bb33bb8b444bbbb8bb3060000000000000000000060555555555555555555555555000000000000000000000000
3333333333333333333333333bbbbb4bbbbbbbb33bbbbb4bbbbbbbb300000000333ee333366666630c0000000000000044444444000000000000000000000000
3333888333333a333223223333b3b44bb44b3b3333b3b44bb44b3b330aaaaaa033a22a33355dd5530cc000005555555544444554000000000000000000000000
333338333333a9a332e2e2333b3bbb44b4bbb3b33b3bbb44b4bbb3b30a9999a03a8aa8a3355d5d530ccc00000000000044444444000000000000000000000000
3333383333333a3332eee233b3bbbb4444bbbb3bb3bbbb4444bbbb3b0a9889a0e2a88a2e355565d30cccc0005555555544444444000000000000000000000000
3333333333333333b2eee2b33333b344443b33333333b344443b33330a9889a0e2a88a2e35565dd30ccc10000000000044554454000000000000000000000000
3333333333833333bb2e2bb3333333444433333333333344443333330a9999a03a8aa8a3316555530cc100005555555545554444000000000000000000000000
33333333382833333bbbbb33333334444443333333333444444333330aaaaaa033a22a333c1555530c1000000000000044444444000000000000000000000000
333333333383333333bbb3333333344444433333333334444443333300000000333ee33335555553010000005555555544444444000000000000000000000000
55555555555555555555555511111111555555555555555543444444444344444444444400c55100000000000000000000000000000000000000000000566500
56666666656666666566666561555516558aaaaaaaaaa855444434344444443444444344000c5510000000000000000000000000000000000005805805688650
56666666656666666566666565566556588aaaaaaaaaa8854444444443444444434444440000c51000000000000000000000000000000c000000000056899865
56666666656666666566666561666616aaaaaaaaaaaaaaaa4344444444444444444443440000c510000880000000000070000050ccccccc005800000689aa986
56665555555555555555666511666611aaa0000000000aaa4444433444434444444444440000c5100008980000055800074444551111111c00005800689aa986
56665666666665666665666561666616aa000000000000aa44433bbb34b344b3334443440000c510000880000000000070000050ccccccc00000000056899865
55555666666665666665666561666616aa000000000000aa44444bbbb3bbb3bbbb344444000c551000000000000000000000000000000c000058005805688650
<<<<<<< HEAD
56665665555555556665666511666611aaa0000000000aaa434434bbbbbbbbbbbb44444400c55100000000000000000000000000000000000000000000566500
=======
56665665555555555665666511666611aaa0000000000aaa434434bbbbbbbbbbbb44444400c55100000000000000000000000000000000000000000000566500
>>>>>>> clean unused sprites and replace old map
56665665666666665665666566666666a0aaaaaaaaaaaa0a443444bbbbbbbbbbbb44444400000000000000000000000000050000000c00000080800000566500
56665665666666665665555566666666a00aaaaaaaaaa00a443443bbbbbbbbbbbb3443440111111000000000000000000055500000ccc0000050500005688650
56665555666666665665666566666666aaaaaaaaaaaaaaaa3444443bbbbbbbbbb3444444155555510008000000080000000400000cc1cc000000000056899865
56665665666666665665666566666666a00aaaaaaaaaa00a4444444bbbbbbbbbb444344455cccc5500898000000500000004000000c1c00000080800689aa986
56665665666666665665666566666666a00aaaaaaaaaa00a434344bbbbbbbbbbbb4444345c0000c500888000000500000004000000c1c00008050500689aa986
56665665666666665555666566666666a0aaaaaaaaaaaa0a444443bbbbbbbbbbbb344444c000000c00000000000000000007000000c1c0000500000056899865
55555665666666665665666566666666aaaaaaaaaaaaaaaa3444443bbbbbbbbbb34443440000000000000000000000000070700000c1c0000000800005688650
56665665666666665665666566666666aaa0000000000aaa4443444bbbbbbbbbb44343440000000000000000000000000000000000c1c0000000500000566500
56665665555555555665666566666666aa000000000000aa444344bbbbbbbbbbbb44444400001000000800000000000000004000000080000000000000888000
56665666665666666665555566666666aa000000000000aa444343bbb3bb33bbbb344344000c10000082800000000000000d0400000880000000000000888000
56665666665666666665666566666666aa000000000000aa434434333433443333444444000c10000048000000008000000d00400555551100008000008d8000
56665555555555555555666566666666aaa0000000000aaa444444444434444444344344000c10000004000000555590000d00400555551105555a55008d8000
56666656666666566666666566666666aaaaaaaaaaaaaaaa444444444444434444444444000c10000040000000dd0000000d004000dd000000dd0aa0008d8000
56666656666666566666666566666666aaaaaaaaaaaaaaaa333444444444443443444444000c10000004000000d00000000d040000d0000000d00aa000ddd000
56666656666666566666666566666666566aaaaaaaaaa665444444344344444444434444000c00000004000000000000000040000000000000000000000d0000
555555555555555555555555666666665566aaaaaaaa6655444434444444434444444443000500000004000000000000000000000000000000000000000d0000
00000000000000000000000000000000000000000000000033344333333443330000000000000000000000000000000000000000000000000000000000000000
07877870071771700737737007577570000000000000000033d44d3333d44d330000000000000000000000000000000000000000000000000000000000000000
0a8aa8a0061661600b3bb3b009599590000000000000000033d22d3333d11d330000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000003d6666d33d6666d30000000000000000000000000000000000000000000000000000000000000000
0e8aa8e00d1661d0063bb3600459954000000000000000003d8888d33dccccd30000000000000000000000000000000000000000000000000000000000000000
0e8aa8e00d1661d0063bb3600459954000000000000000003d8888d33dccccd30000000000000000000000000000000000000000000000000000000000000000
0e8888e00d1111d0063333600455554000000000000000003d8888d33dccccd30000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000033dddd3333dddd330000000000000000000000000000000000000000000000000000000000000000
<<<<<<< HEAD
00000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
990009000ccccccc0ccccc00ccccccc0016666100011166001111110088888c80088880008888880055f555000055550055ff550000000000000000000000000
09000900ccccccccccccccc0cccccccc016116100011161001144110888888880088888008828880055ff5500055555005f5ff50000000000000000000000000
09900000cc66cc6ccccc6cc0cccccccc1111111000111111011111108822882808882880082288800ffffff00055fff005fff550000000000000000000000000
00990000c6fcfffcccccfffccccccccc04f4fff000444f400444444082ffff280888fff0088228800f0ff0f00055f0f005555550000000000000000000000000
00000999cf0ff0fc0cfcf0f0cccccccc0f0ff0f00044f0f0044444408f1ff1f800f8f1f0088882800ffffff0005ffff005555550000000000000000000000000
09900000cf0ff0fcccccf0f0cc6ccccc0f0ff0f0004ff0f0044444408f1ff1f00028f1f000288f000f4444f0005fff4005555550000000000000000000000000
00000000ccffffcccccccff0ccc6c6cc00ffff00000ffff00f4444f088ffff0000828ff00082ff00044ff440000ff44005555550000000000000000000000000
00000990cccdd1cc0c6ccc006ccc6cc6999999990009990099999999855665550058560055555555114774110001774011555511000000000000000000000000
99000900f6cdd16fccf61d00f6cccccfff9559ff000ff500f999999f555a65550055560055555555114774110001114011111111000000000000000000000000
09000900ff1111ff0cff1100f16cc66fff5995ff000ff900f999999f555665550055500055555555111771110001110011111111000000000000000000000000
09900000ff1111ff00ff1100f116611fff9999ff000ff900f999999fff5565ff00ff5000f555555fff1111ff000ff100f111111f000000000000000000000000
009900000111111000011100011111100111111000001100011111100555d5500005d0000555d550011111100000110001117110000000000000000000000000
000009990511115000051100051111500110011000001100011001100dd00dd0000dd0000dd00dd0011001100000110001100110000000000000000000000000
09900000055005500005500005500550011001100000110001100110044004400004400004400440011001100000110001100110000000000000000000000000
00000000055005500005550005500550055005500000555005500550044004400004440004400440055005500000555005500550000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000090900ccccccc0ccccc00ccccccc0016666100011166001111110088888c80088880088888880055f555000055550055ff550000000000000000000000000
00000509ccccccccccccccc0cccccccc016116100011161001144110888888880088888088888888055ff5500055555005f5ff50000000000000000000000000
00005099cc66cc6cccccfcc0cccccccc1111111000111111011111108822882808882880888888880ffffff00055fff005fff550000000000000000000000000
00950000c6fcfffcccccfffccccccccc04f4fff000444f400444444082ffff280888fff0888888880f0ff0f00055f0f005555550000000000000000000000000
00a90000cf0ff0fc0cfcf0f0cc6ccccc0f0ff0f00044f0f0044444408f1ff1f800f8f1f0882888880ffffff0005ffff005555550000000000000000000000000
00000000cf0ff0fcccccf0f0ccc6c6cc0f0ff0f0004ff0f0044444408f1ff1f00028f1f0888282880f4444f0005fff4005555550000000000000000000000000
00000000ccffffcccccccff00ccc6ccc00ffff00000ffff00f4444f088ffff0000828ff008882888044ff440000ff44005555550000000000000000000000000
00000000cc1dd1c00c6ccc0006cccc6f99955990000999009999999985566550005856000288882f114774100001774011555511000000000000000000000000
000000006c1ddf60ccf61d00016cc6fff9599ff0000ffd00f99999ff2556655000555600062882fff41741100001114011111111000000000000000000000000
0000000001111ff00cfff1000116611009999ff0000fff00f99999ff05556ff00055f0000662266001177ff0000111001111111f000000000000000000000000
000000000111111000111100055111100111111000099900011111100555ddd000555000055666600111111000011f0001117110000000000000000000000000
000000000550055005111100055005500110011005111110011001100dd00dd004dddd0005500550011001100511111001100110000000000000000000000000
000000000550000005500550000005500110055005500110055001100440044004400d4005500550011005500550011005500110000000000000000000000000
00000000000000000000005500000000055000000000005500000550044000000000004400000550055000000000005500000550000000000000000000000000
=======
00000991000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
990009000ccccccc0ccccc00ccccccc0016666100011166001111110088888c80888880088888880000000000000000000000000000000000000000000000000
09000900ccccccccccccccc0cccccccc016116100011161001144110888888888888888088888888000000000000000000000000000000000000000000000000
09900000cc66cc6ccccc6cc0cccccccc111111100011111101111110882288288888288088888888000000000000000000000000000000000000000000000000
00990000c6fcfffcccccfffccccccccc04f4fff000444f400444444082f8fff88888fff888888888000000000000000000000000000000000000000000000000
00000999cf0ff0fc0cfcf0f0cccccccc0f0ff0f00044f0f0044444408f0ff0f808f8f0f088888888000000000000000000000000000000000000000000000000
09900000cf0ff0fcccccf0f0cc6ccccc0f0ff0f0004ff0f0044444408f0ff0f88888f0f088288888000000000000000000000000000000000000000000000000
00000000ccffffcccccccff0ccc6c6cc00ffff00000ffff00f4444f088ffff8888888ff088828288000000000000000000000000000000000000000000000000
00000990cccdd1cc0c6ccc006ccc6cc6999999990009990099999999888dd6880828880028882882000000000000000000000000000000000000000000000000
99000900f6cdd16fccf61d00f6cccccfff9559ff000ff500f999999fff8dd6ff88ff6d00f288888f000000000000000000000000000000000000000000000000
09000900ff1111ff0cff1100f16cc66fff5995ff000ff900f999999fff6666ff08ff6600f628822f000000000000000000000000000000000000000000000000
09900000ff1111ff00ff1100f116611fff9999ff000ff900f999999fff6666ff00ff6600f662266f000000000000000000000000000000000000000000000000
00990000011111100001110001111110011111100000110001111110066666600006660006666660000000000000000000000000000000000000000000000000
00000999051111500005110005111150011001100000110001100110056666500005660005666650000000000000000000000000000000000000000000000000
09900000055005500005500005500550011001100000110001100110055005500005500005500550000000000000000000000000000000000000000000000000
00000000055005500005550005500550055005500000555005500550055005500005550005500550000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000090900ccccccc0ccccc00ccccccc0016666100011166001111110088888c80888880088888880000000000000000000000000000000000000000000000000
00000509ccccccccccccccc0cccccccc016116100011161001144110888888888888888088888888000000000000000000000000000000000000000000000000
00005099cc66cc6cccccfcc0cccccccc111111100011111101111110882288288888f88088888888000000000000000000000000000000000000000000000000
00950000c6fcfffcccccfffccccccccc04f4fff000444f400444444082f8fff88888fff888888888000000000000000000000000000000000000000000000000
00a90000cf0ff0fc0cfcf0f0cc6ccccc0f0ff0f00044f0f0044444408f0ff0f808f8f0f088288888000000000000000000000000000000000000000000000000
00000000cf0ff0fcccccf0f0ccc6c6cc0f0ff0f0004ff0f0044444408f0ff0f88888f0f088828288000000000000000000000000000000000000000000000000
00000000ccffffcccccccff00ccc6ccc00ffff00000ffff00f4444f088ffff8888888ff008882888000000000000000000000000000000000000000000000000
00000000cc1dd1c00c6ccc0006cccc6f999559900009990099999999886dd680082888000288882f000000000000000000000000000000000000000000000000
000000006c1ddf60ccf61d00016cc6fff9599ff0000ffd00f99999ff286ddf2088f26d00062882ff000000000000000000000000000000000000000000000000
0000000001111ff00cfff1000116611009999ff0000fff00f99999ff06666ff008fff60006622660000000000000000000000000000000000000000000000000
00000000011111100011110005511110011111100009990001111110066666600066660005566660000000000000000000000000000000000000000000000000
00000000055005500511110005500550011005500511111005500110055005500566660005500550000000000000000000000000000000000000000000000000
00000000055000000550055000000550055000000550011000000550055000000550055000000550000000000000000000000000000000000000000000000000
00000000000000000000005500000000000000000000005500000000000000000000005500000000000000000000000000000000000000000000000000000000
>>>>>>> clean unused sprites and replace old map
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808080800002a000000000000000000000000080808000000000000000000000000000800080000000000000000000000000008080800000000000000005050505000003030000000000000000
0000000080808000000000000000000000000000808080000000000000000000a00000008080800000000000000000000000000080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
