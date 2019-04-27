pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


-- const
left, right, up, down, fire1, fire2, none = 0, 1, 2, 3, 4, 5, 6
black, dark_blue, dark_purple, dark_green, brown, dark_gray, light_gray, white, red, orange, yellow, green, blue, indigo, pink, peach = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
player, bullet, ennemy, item, npc = 0, 1, 2, 3, 4
immortal_object = 1000
inf = 1000
melee, ranged = 1, 20
nb_of_ennemis = 2
f_heal, f_item, f_inv, f_obst = 0, 1, 5, 7
l_player, l_ennemy, l_boss = 50, 10, 150
walk, stay = "walk", "stay"

debug_enabled = false

-- init
function _init()
 debug_init()

 g_actors = {}
 g_dfx = {}
 g_weapons = {}
 g_dialogs = {}

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

-- new

function newentitie(x, y, sprite, tag, health, direction, mvn)
 return {
  x = x,
  y = y,
  s = sprite,
  tag = tag,
  health = health or immortal_object,
  direction = direction or up,
  mvn = mvn or {}
 }
end

function newdfx(pattern, draw, cd)
 return {
  pattern = pattern or function (self) end,
  draw = draw or function (self) end,
  cd = cd or 100
 }
end

function newweapon(name, sprite, sfx, anim, cd, dmg, type, speed, hitbox, offsetx, offsety)
 return {
  name = name,
  sprite = sprite,
  sfx = sfx,
  anim = anim,
  cd = cd,
  dmg = dmg,
  type = type,
  speed = speed,
  hitbox = hitbox,
  offsetx = offsetx,
  offsety = offsety
 }
end

-- make

function make_game()
 make_weapons()
 make_ennemies(nb_of_ennemis, {134})
 make_npc(239, 66, 137)
 make_player(128)
 make_items()
end

function make_weapon(cmpnttable)
 local item = {
  name = cmpnttable.wpm.name,
  spr = cmpnttable.wpm.sprite,
  animh = cmpnttable.wpm.anim.h,
  animv = cmpnttable.wpm.anim.v,
  cd = cmpnttable.wpm.cd,
  speed = cmpnttable.wpm.speed,
  dmg = cmpnttable.wpm.dmg,
  type = cmpnttable.wpm.type,
  hb = cmpnttable.wpm.hitbox,
  ox = cmpnttable.wpm.offsetx,
  oy = cmpnttable.wpm.offsety,
  sfx = cmpnttable.wpm.sfx,
  dfx = cmpnttable.dfx.pattern,
  draw = cmpnttable.dfx.draw,
  cdfx = cmpnttable.dfx.cd
 }
 add(g_weapons, item)
end

function make_actor(cmpnttable)
 local actor = {
  tag = cmpnttable.entitie.tag,
  d = cmpnttable.entitie.direction or none,
  bx = cmpnttable.entitie.x,
  by = cmpnttable.entitie.y,
  x = cmpnttable.entitie.x,
  y = cmpnttable.entitie.y,
  s = cmpnttable.entitie.s,
  health = cmpnttable.entitie.health,
  control = cmpnttable.control,
  draw = cmpnttable.draw,
  weapon = cmpnttable.weapon or nil,
  box = cmpnttable.box,
  dx = cmpnttable.entitie.mvn.dx or 0,
  dy = cmpnttable.entitie.mvn.dy or 0,
  cd = 0,
  cdfx = 0
 }
 add(g_actors, actor)
 return actor
end

function make_weapons()
 make_weapon({
  wpm = newweapon("elec", 104, 8, {h = 72, v = 88}, 20, 15, melee, 2, 8, 5, -5),
  dfx = newdfx(dfx_thunder, draw_thunder, 100)
 })
 make_weapon({
  wpm = newweapon("sword", 105, 4, {h = 73, v = 89}, 15, 7, melee, 2, 8, 5, -4),
  dfx = newdfx()
 })
 make_weapon({
  wpm = newweapon("firewand", 106, 1, {h = 74, v = 90}, 8, 8, ranged, 3, 3, 5, -4),
  dfx = newdfx()
 })
 make_weapon({
  wpm = newweapon("gun", 107, 5, {h = 75, v = 91}, 3, 3, ranged, 10, 2, 5, -5),
  dfx = newdfx()
 })
 make_weapon({
  wpm = newweapon("bow", 108, 3, {h = 76, v = 92}, 6, 5, ranged, 6, 3, 5, -5),
  dfx = newdfx()
 })
 make_weapon({
  wpm = newweapon("secret", 109, 6, {h = 77, v = 93}, 4, 5, ranged, 5, 1, 5, -5),
  dfx = newdfx(dfx_waterfall, draw_waterfall, 100)
 })
 make_weapon({
  wpm = newweapon("tatata", 110, 7, {h = 78, v = 94}, 2, 2, ranged, 10, 1, 5, -5),
  dfx = newdfx()
 })
 make_weapon({
  wpm = newweapon("boom", 111, 8, {h = 79, v = 95}, 18, 10, melee, 2, 8, 5, -4),
  dfx = newdfx(dfx_explosion, draw_explosion, 100)
 })
end

function make_npc(x, y, s)
 local n = make_actor({
  -- new player char
  entitie = newentitie(x, y, s, npc, immortal_object, down),
  -- add a action controller
  control = controls_npc,
  -- add a draw controller
  draw = draw_characters,
  -- set the hitbox
  box = {x1 = 0, y1 = 0, x2 = 7, y2 = 14},
 })
  -- add animations
 n.anim = stay
 n.walk = make_anim(make_walk_anim(s))
 n.stay = make_anim(make_stay_anim(s))
end

function make_player(s)
 g_p = make_actor({
  -- new player char
  entitie = newentitie(333, 85, s, player, l_player),
  -- add a action controller
  control = controls_player,
  -- add a draw controller
  draw = draw_characters,
  -- set the hitbox
  box = {x1 = 0, y1 = 10, x2 = 7, y2 = 15},
  -- add weapon
  weapon = g_weapons[1]
 })
 -- add animations
 g_p.anim = stay
 g_p.walk = make_anim(make_walk_anim(s))
 g_p.stay = make_anim(make_stay_anim(s))
end

function make_ennemies(nb, aspr)
 g_ennemies_left = 0
 for s in all(aspr) do
  for i=1, nb/#aspr do
   local a = g_good_spot(248, 248)
   local e = make_actor({
    -- new player char
    entitie = newentitie(a.x, a.y, s, ennemy, l_ennemy, up, {dx = 0.9, dy = 0.9}),
    -- add a action controller
    control = controls_ennemies,
    -- add a draw controller
    draw = draw_characters,
    -- set the hitbox
    box = {x1 = 0, y1 = 10, x2 = 7, y2 = 15},
    -- add weapon
    weapon = g_weapons[1]
   })
   -- add animations
   e.anim = stay
   e.walk = make_anim(make_walk_anim(s))
   e.stay = make_anim(make_stay_anim(s))
   g_ennemies_left += 1
  end
 end
end

function make_items()
  for i in all(g_map_items) do
    for p in all(i.pos) do
      make_actor({
      -- new player char
      entitie = newentitie(p.x, p.y, i.spr, item),
      -- add a action controller
      control = function (self) end,
      -- add a draw controller
      draw = draw_item,
      -- set the hitbox
      box = {x1 = 0, y1 = 0, x2 = 7, y2 = 7},
      })
    end
  end
end

function make_walk_anim(s)
 return {
  name = walk,
  frames = create_direction_frames(s+33, s+1, s+33, s+1, s+34, true, s+32, true),
  speed = 1/10
 }
end

function make_stay_anim(s)
 return {
  name = stay,
  frames = create_direction_frames(s+1, s+1, s+1, s+1, s+2, false, s, false),
  speed = 1/10
 }
end

function make_anim(anim)
 return {
  time = 0,
  anim = anim.name,
  spd = anim.speed,
  f = anim.frames
 }
end

function make_particles(a, n, c)
 local c = c or 8
	while (n > 0) do
 	part = {
   x = a.x+4,
   y = a.y+4,
   c = flr(rnd(3)+c),
   dx = (rnd(2)-1)*2,
   dy = (rnd(2)-1)*2,
   f = 0,
   maxf = 15,
   draw = draw_particles
  }
 	add(g_dfx, part)
 	sfx(1)
 	n -= 1
 end
end

function make_dialog(x,y,t,d)
 add(g_dialogs,{x=x,y=y-10,text=t,time=d})
end

-- draw effect

function dfx_explosion(x, y, a, h, draw)
	while (a > 0) do
		local explo = {
   x = x+(rnd(2)-1)*10,
   y = y+(rnd(2)-1)*10,
   r = 4 + rnd(4),
   c = 8,
   draw = draw
  }
		add(g_explosions, explo)
		sfx(0)
		a -= 1
	end
end

function dfx_thunder(x, y, p, h, draw)
 local xt = x + (rnd(10)-5)
 local thunder = {
  x = xt,
  y = g_fp.y,
  pos = {{x = xt, y = g_fp.y}},
  c = 10,
  p = p,
  h = h or 50,
  draw = draw
 }
 add(g_dfx, thunder)
 sfx(8)
 return thunder
end

function dfx_waterfall(x, y, p, h, draw)
  local shower = {
   x = x,
   y = y-30,
   pos = {},
   c = 12,
   p = p+5,
   h = 30,
   draw = draw
  }
  for r=x-(p/2), x+(p/2)do
   add(shower.pos, {x = r, y= shower.y, time=5})
  end
  add(g_dfx, shower)
  sfx(8)
  return shower
end

function dfx_disapearance(x, y, a, h, draw)
 local a = a or flr((rnd(5)+1))
	while (a > 0) do
		disa = {
   x = x+(rnd(2)-1)*5,
   y = y+(rnd(2)-1)*5,
   r = 2 + rnd(4),
   c = 5,
   draw = draw
  }
		add(g_dfx, disa)
		sfx(10)
		a -= 1
	end
end

-- move

function create_direction_frames(fl1, fl2, fr1, fr2, fu, fuflip, fd, fdflip)
 return {
  {{f = fl1, flip = true  },{f = fl2, flip = true }},
  {{f = fr1, flip = false },{f = fr2, flip = false}},
  {{f = fu,  flip = false },{f = fu,  flip = fuflip }},
  {{f = fd,  flip = false },{f = fd,  flip = fdflip }}
 }
end

function create_dialogs(texts)

end

function controls_menu()
 if (btnp(up) and g_selected_item > 1) then
  g_selected_item -= 1
 end
 if (btnp(down) and g_selected_item < #g_weapons) then
  g_selected_item += 1
 end
 if (btnp(fire1)) then
  g_p.weapon = g_weapons[g_selected_item]
  g_open_inv = false
  g_p.cd = 10
 end
end


function action_ennemies(a, d)
 if (a.tag ~= ennemy) return
 if (a.cd > 0) a.cd -= 1
 if (a.cd == 0) then
  shoot(a, d)
  a.cd = 50
 end
end

function controls_bullets(self)
   self.x += self.dx
   self.y += self.dy
   if (is_of_limit(self.x, self.y, self.bx, self.by, self.range)) del(g_actors, self)
end

function controls_npc(self)
 local dist = check_distance_from_player(self)
 log(4, dist)
 if (dist >= 5 and dist < 10) then
  make_dialog(self.x, self.y, "hey !!", 30)
 end
end

function controls_ennemies(self)
 local dist = check_distance_from_player(self)
 if(is_player_near(dist)) then
  make_dialog(self.x, self.y, "!", 1)
  self.anim = walk
  if (dist >= self.weapon.type) then
   local dir_m = going_forward(self)
   move_on(self, dir_m)
  end -- dist >= weapon type
 else
  self.anim = stay
 end -- is player near
 log(5, dist)
 if (dist < self.weapon.type*8.2) then
  local dir_m = get_best_direction(self)
  move_on(self, dir_m)
  local dir_a = prepare_attack_opportunity(self)
  self.d = dir_a
  action_ennemies(self, dir_a)
 end
end

function controls_player(self)
 self.anim = walk
 if (is_moving(left))  move(self,-1, 0, 0, 15)
 if (is_moving(right)) move(self, 1, 0, 6, 15)
 if (is_moving(up))    move(self, 0,-1, 6, 0)
 if (is_moving(down))  move(self, 0, 1, 6, 15)
 if (is_not_moving())  self.anim = stay
 action_player()
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
 if (go == left)  move(a ,-a.dx, 0, 0, 15)
 if (go == right) move(a, a.dx, 0, 6, 15)
 if (go == up)    move(a, 0 ,-a.dy, 6, 0)
 if (go == down)  move(a, 0, a.dy, 6, 15)
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
 local x1 = (a.x + x + (ox * x))
 local y1 = max(a.box.y1 + a.y, a.y + y + ((oy/2) * y) + oy/2)
 local x2 = (a.x + x + ox)
 local y2 = max(a.box.y1 + a.y, a.y + y + oy)
 local sp1 = mget(x1 / 8, y1 / 8)
 local sp2 = mget(x2 / 8, y2 / 8)

 for b in all(g_actors) do
  if(check_collisions(a, b, x, y)) return
 end

 g_cm.x1 = x1
 g_cm.x2 = x2
 g_cm.y1 = y1
 g_cm.y2 = y2

 if (fget(sp1, f_obst)) then
  a.x += abs(y)
  a.y += abs(x)
 elseif (fget(sp2, f_obst)) then
  a.x -= abs(y)
  a.y -= abs(x)
 else
  a.x += x
  a.y += y
 end -- check obstacles onn map
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
    g_p.weapon.dfx(target.x, target.y, 3, abs(g_fp.y - target.y), g_p.weapon.draw)
    target.health -= 10
    check_actor_health(target)
   else
    sfx(9)
   end -- is target present
  end -- case is inv else cdfx is over
 end -- fire 2 button triggered
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
  x = rnd(xmax),
  y = rnd(ymax)
 }
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
  fire({
   -- new bullet
   x = a.x-6,
   y = a.y+4,
   s = a.weapon.animh,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   -- add hitbox
   box = {x1 = 0, y1 = 4-center, x2 = 5, y2 = 4 + center},
   -- set the speed
   mvn = {dx = -speed, dy = 0},
   -- set the direction
   direction = left
  })
 end
 if(d == right) then
  fire({
   -- new bullet
   x = a.x+6,
   y = a.y+4,
   s = a.weapon.animh,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   -- add hitbox
   box = {x1 = 0, y1 = 4 - center, x2 = 5, y2 = 4 + center},
   -- set the speed
   mvn = {dx = speed, dy = 0},
   -- set the direction
   direction = right
  })
 end
 if(d == up) then
  fire({
   -- new bullet
   x = a.x,
   y = a.y-8,
   s = a.weapon.animv,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   -- add hitbox
   box = {x1 = 4 - center, y1 = 0, x2 = 4 + center, y2 = 5},
   -- set the speed
   mvn = {dx = 0, dy = -speed},
   -- set the direction
   direction = up
  })
 end
 if(d == down) then
  fire({
   -- new bullet
   x = a.x,
   y = a.y+18,
   s = a.weapon.animv,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   -- add hitbox
   box = {x1 = 4 - center, y1 = 3, x2 = 4 + center, y2 = 8},
   -- set the speed
   mvn = {dx = 0, dy = speed},
   -- set the direction
   direction = down
  })
 end
 if (d ~= none or a.tag == player) then
  sfx(a.weapon.sfx)
 end

end

function fire(en)
 local b = make_actor({
  -- new player char
  entitie = newentitie(en.x, en.y, en.s, bullet, immortal_object, en.direction, en.mvn),
  -- add a action controller
  control = controls_bullets,
  -- add a draw controller
  draw = draw_bullets,
  -- set the hitbox
  box = en.box,
 })
 b.dmg = en.dmg
 if (en.type == melee) then
  b.range = 5
 else
  b.range = 128
 end
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

function draw_border_on_entities(entitie, x, y, c)
	for i=1, 16 do
		pal(i, c)
 end
 spr(entitie.f, x,   y+1, 1, 2, entitie.flip, false)
 spr(entitie.f, x,   y-1, 1, 2, entitie.flip, false)
 spr(entitie.f, x-1, y,   1, 2, entitie.flip, false)
 spr(entitie.f, x+1, y,   1, 2, entitie.flip, false)
 pal()
 palt(pink,true)
 spr(entitie.f, x,   y,   1, 2, entitie.flip, false)
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

function check_collisions(a, b, newx, newy)
 local newx = newx or 0
 local newy = newy or 0
 if(a == b or a.tag == b.tag) return false
 local box_a = get_box(a)
 local box_b = get_box(b)
 if (box_a.x1 + newx > box_b.x2 or
     box_a.y1 + newy > box_b.y2 or
     box_b.x1 > box_a.x2 + newx or
     box_b.y1 > box_a.y2 + newy ) then
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
  dfx_disapearance(damaged_actor.x, damaged_actor.y, flr((rnd(5)+1)), nil, draw_explosion)
  screenshake(5)
  del(g_actors, damaged_actor)
 end
end

function controls_collisions()
 for a in all(g_actors) do
  for b in all(g_actors) do
   if (check_collisions(a, b)) then
    if (a.tag == bullet and b.tag ~= bullet) then
     b.health -= a.dmg
     local damaged_actor = b
     make_particles(b, 10, 5)
     del(g_actors, a)
     check_actor_health(damaged_actor)
    end -- collision from bullet
   end -- if collision
  end
 end
end

function printoutline(t,x,y,c)
  -- draw the outline
  for xoff=-1,1 do
    for yoff=-1,1 do
      print(t,x+xoff,y+yoff,0)
    end
  end
  --draw the text
  print(t,x,y,c)
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

function draw_particles(self)
 pset(self.x, self.y, self.c)
 self.x += self.dx
 self.y += self.dy
 self.f += 1
 if (self.f > self.maxf or is_of_limit(self.x, self.y)) then
  del(g_dfx, self)
 end
end

function draw_explosion(self)
 circfill(self.x, self.y, self.r, self.c)
 self.r -= 0.5
 if (self.r < 4) self.c += 1
 if (self.r < 2) self.c += 1
 if (self.r <= 0) del(g_dfx, self)
end

function draw_thunder(self)
 for xy in all(self.pos) do
  pset(xy.x, xy.y, self.c)
 end
 for nt=1, 10 do
  self.x += (rnd(2)-1)
  self.y += 1
  self.h -= 1
  add(self.pos ,{x = self.x, y=self.y})
 end
 if (flr(rnd(self.p)) == 0) dfx_thunder(self.x, self.y, self.p+2, self.h, self.draw)
 if (self.h < -10) del(g_dfx, self)
end

function draw_waterfall(self)
 for xy in all(self.pos) do
  if (xy.time > 0) then
   pset(xy.x, xy.y, rnd_color({self.c, 7}))
   xy.time -= 1
  end
 end
 for i=1, 3 do
  if (self.h < 5) self.p +=1
  self.y += 1
  self.h -= 1
  for r=s.x-(self.p/2), self.x+(self.p/2)do
   add(self.pos, {x = r, y= self.y, time=5})
  end
 end
 if (self.h < 0) del(g_dfx, self)
end

function draw_skills(bx, by)
 draw_item_shape(bx-10, by+7, 55, g_p.cdfx, g_p.weapon.cdfx)
 draw_item_shape(bx+18, by+7, g_p.weapon.animv, g_p.cd, g_p.weapon.cd)
end

function draw_characters(self)
 draw_border_on_entities(anim_player(self), self.x, self.y, black)
 if(self.tag ~= npc) draw_weapon(self,manage_weapon_direction(self.d))
end

function draw_bullets(self)
 local inv = manage_aim_direction(self.d)
 spr(self.s, self.x, self.y, 1, 1, inv.h, inv.v)
end

function draw_weapon(a,f)
 spr(a.weapon.spr, a.x + a.weapon.ox + f.ox, a.y - a.weapon.oy + f.oy, 1, 1, f.h, f.v)
end

function draw_item(self)
  spr(self.s,self.x,self.y)
  log(2,self.x..":"..self.y)
end

function draw_actors()
 for a in all(g_actors) do
  a:draw()
 end
end

function draw_dfxs()
  for d in all(g_dfx) do
   d:draw()
  end
end

function draw_dialogs()
 for d in all(g_dialogs) do
  printoutline(d.text,d.x,d.y,white)
  d.time -= 1
  if (d.time <= 0) del(g_dialogs,d)
 end
end

function draw_hud()
 draw_life(g_fp.x+60, g_fp.y+108)
 draw_skills(g_fp.x+60, g_fp.y+108)
 draw_inventory(g_fp.x+80, g_fp.y)
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
  for i = 1 ,#g_weapons do
   draw_item_shape(tx, ty, g_weapons[i].spr)
   print(g_weapons[i].name, tx + 12, ty - 2, white)
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
 follow_player()

 set_camera()

 draw_actors()
 draw_dfxs()
 draw_dialogs()
 draw_hud()


 log(1,g_p.x..":"..g_p.y)
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
  controls_update()
  controls_collisions()
 else
  wait_inventory_close()
  controls_menu()
 end
 check_game_state()
end

function controls_update()
 for a in all(g_actors) do
  a:control()
 end
end
-- camera

function get_formalised_position(a, cam)
 return a - 64 < 0 and 0 or a - 64
end

function lerp(a,b,t)
 return (1-t)*a + t*b
end

function follow_player()
 g_fp = {
  x = get_formalised_position(g_p.x),
  y = get_formalised_position(g_p.y)
 }
end

function set_camera()
 reset_camera()
 g_scr.x = max(0,lerp(g_scr.x,g_p.x-64,0.3))
 g_scr.y = max(0,lerp(g_scr.y,g_p.y-64,0.3))
 log(3, g_scr.x..":"..g_scr.y)
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
  g_weapons = {}
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

g_map_items = {
 {
  name = "heal_potion",
  spr = 118,
  pos = {
   {x = 201, y = 113}
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
000000007777777733bb3b33517711550000000075577557a555555a550000000000000000000055001111111111111111111100000000000555555555555550
00000000555555553bbbb3b3517171550cc7ccc075577557a55555a500666666666666666666660050dddddddddddddddddddd050c7cccc00000000000000000
0070070055555555b33bbbbb517711550c7cccc075577557a5555a550600000000000000000000605011111111111111111111050cccccc00000000000000000
00077000777777773bbb3b33517171550cccccc075577557a555a5550760666066606660666066705011111111111111111111050cccccc00555555555555550
00077000777777773b3bb3bb517711550cccccc075577557a55a555507060606060606060606067050dddddddddddddddddddd050ccccc700555555555555550
0070070055555555bbb3bbb3511111550cccc7c075577557a5a555550766606660666066606660705011111111111111111111050c7cccc00000000000000000
000000005555555533bb3bbb517171550ccc7cc075577557aa55555507060606060606060606067050111111111111111111110507ccccc00000000000000000
00000000777777773b3bbbb3517771550cccccc075577557a555555507606660666066606660667050dddddddddddddddddddd05000000000555555555555550
600660065555555555555555511111550c5555c0555555555557555507060606060606060606067050111111111111111111110500dddd6ddddddddd6ddddd00
033003305555555555555555517771550c7cccc0555775555557555507666066606660666066607050111111111111111111110550dddd6ddddddddd6ddddd05
033003305555555555555555517111550cccccc0555775555557555507060606060606060606067050dddddddddddddddddddd05506666666666666666666605
033003305777777555555555511771550cccccc0555775555557555507606660666066606660667050111111111111111111110550ddddddddd6dddddddddd05
033003305777777555555555617771660cccccc0555775555557555507060606060606060606067050111111111111111111110550ddddddddd6dddddddddd05
033003b05555555555555555666066660ccc7cc0555775555557555507666066606660666066607050dddddddddddddddddddd05506666666666666666666605
03b003b05555555555555555777077770cc7ccc0555775555557555507060606060606060606067050111111111111111111110550dddd6ddddddd6ddddddd05
0330033055555555555555550000000055555555555555555557555507606660666066606660667050111111111111111111110550dddd6ddddddd6ddddddd05
03300330333333333333333333333bbbbbb33333777777777777555507060606060606060606067050dddddddddddddddddddd05506666666666666666666605
0330033033333b33333883333333bb3bbbbbb333555555555557555507666066606660666066607050111111111111111111110550ddddddd6dddddddd6ddd05
03300330333b3b3333899833333bb3bb3b3bbb33555555555557555507060606060606060606067050111111111111111111110550ddddddd6dddddddd6ddd05
03b0033033333333389aa98333bbbbbbb3bbbbb3555555555557555507606660666066606660667050dddddddddddddddddddd05506666666666666666666605
03b003b033333333b89aa98b3bb333bbbbbbbbb3555555555557555507060606060606060606067050111111111111111111110550ddd6dddddddd6ddddddd05
0b3003303b3333b3bb8998bb3bbbb33bbbbbb3bb555555555557555507000000000000000000007050111111111111111111110550ddd6dddddddd6ddddddd05
033003303b3333b33bb88bb3bb33bbbbbb333bbb555555555557555500666666666666666666660050dddddddddddddddddddd05506666666666666666666605
0330033033333333333bb3333b3bb444bbbbbbb3555555555557555506000000000000000000006055555555555555555555555550dd6ddddddd6dddddd6dd05
55bbb5b533333333333333333bbbbb4bbbbbbbb3555777777777777700000000333ee33336666663eceeeeee000000004544444450dd6ddddddd6dddddd6dd05
5b3b3b5533333a333223223333b3b44bb44b3b3355575555555755550aaaaaa033a22a33355dd553ecceeeee5555555544444454506666666666666666666605
5bb3b3b53333a9a3328282333b3bbb24b4bbb3b355575555555755550a9999a03a8aa8a3355d5d53eccceeee000000004444444450dddddd6ddddddd6ddddd05
55b34b5533333a3332888233b3bbbb2444bbbb3b55575555555755550a9889a0e2a88a2e355565d3ecccceee555555554444444450dddddd6ddddddd6ddddd05
5111111533333333b28882b33333b344443b333355575555555755550a9889a0e2a88a2e35565dd3eccc1eee0000000044444454506666666666666666666605
5171111533833333bb282bb3333333244433333355575555555755550a9999a03a8aa8a331655553ecc1eeee555555554544444450ddd6dddddd6ddddddddd05
51111115382833333bbbbb33333332244443333355575555555755550aaaaaa033a22a333c155553ec1eeeee000000004444444450ddd6dddddd6ddddddddd05
551111553383333333bbb3333333333424433333555755555557555500000000333ee33335555553e1eeeeee5555555544444444555555555555555555555555
000000000000000000000000111111115555555555555555eeeeeeeeeeeeeeeeeeee99eeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
07770777777777077777777016666661558aaaaaaaaaa855eeeeeeeeeeeeeee99eee9eeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee58e58e568865e
07660666666666066666667016666661588aaaaaaaaaa885eeeeeeeeeeeeeeee9eee9eeeeeeec51eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeeeeeeee56899865
07660666666666066666667016666661aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeee99eeeeeeeeeec51eeee88eeeeeeeeeee7eeeee5ecccccccee58eeeee689aa986
07665555555555555555000016666661aaa0000000000aaaeeeeeeeeeeeeeeeee99eeeeeeeeec51eeee898eeeee558eee74444551111111ceeee58ee689aa986
07665555555555555555667016666661aa000000000000aaeeeeeeeeeeeeeeeeeeee999eeeeec51eeee88eeeeeeeeeee7eeeee5eccccccceeeeeeeee56899865
07665555555555555555667016666661aa000000000000aaeeeeeeeeeeeeeeee99eeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeee58ee58e568865e
07665555555555555555667016666161aaa0000000000aaaeeeeeeeeeeeeeeeeeeeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
07665555555555555555667016666661a0aaaaaaaaaaaa0aeeeeeeeeeeeeeeeeeeee99eeeeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeeeceeeeee8e8eeeee5665ee
00005555555555555555667016666661a00aaaaaaaaaa00aeeeeeeeeeeeeeee99eee9eeee111111eeeeeeeeeeeeeeeeeee555eeeeeccceeeee5e5eeee568865e
07665555555555555555667016666661aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeee9eee9eee15555551eee8eeeeeee8eeeeeee4eeeeecc1cceeeeeeeeee56899865
07665555555555555555667016666661a00aaaaaaaaaa00aeeeeeeeeeeeeeeee99eeeeee55cccc55ee898eeeeee5eeeeeee4eeeeeec1ceeeeee8e8ee689aa986
07665555555555555555667016666661a00aaaaaaaaaa00aeeeeeeeeeeeeeeeee99eeeee5ceeeec5ee888eeeeee5eeeeeee4eeeeeec1ceeee8e5e5ee689aa986
07665555555555555555667016666661a0aaaaaaaaaaaa0aeeeeeeeeeeeeeeeeeeee999eceeeeeeceeeeeeeeeeeeeeeeeee7eeeeeec1ceeee5eeeeee56899865
07665555555555555555000016666661aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeee99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7e7eeeeec1ceeeeeee8eeee568865e
07665555555555555555667055555555aaa0000000000aaaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec1ceeeeeee5eeeee5665ee
07665555555555555555667066666666aa000000000000aaeeeeeeeeeeeeeeeeeeeeeeeeeeee1eeeeee8eeeeeeeeeeeeeeee4eeeeeee8eeeeeeeeeeeee888eee
07665555555555555555667066666666aa000000000000aaeeeeeeeeeeeeeeeeeee99eeeeeec1eeeee828eeeeeeeeeeeeeede4eeeee88eeeeeeeeeeeee888eee
07665555555555555555667066666666aa000000000000aaeeeeeeeeeeeeeeeeeee9e9eeeeec1eeeee48eeeeeeee8eeeeeedee4ee5555511eeee8eeeee8d8eee
00005555555555555555667066666666aaa0000000000aaaeeeeeeeeeeeeeeeeeeee5e9eeeec1eeeeee4eeeeee55559eeeedee4ee5555511e5555a55ee8d8eee
07666666606666666660667066666666aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeee5e99eeeec1eeeee4eeeeeeeddeeeeeeedee4eeeddeeeeeeddeaaeee8d8eee
07666666606666666660667066666666aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeee95eeeeeeeec1eeeeee4eeeeeedeeeeeeeede4eeeedeeeeeeedeeaaeeedddeee
07777777707777777770777066666666566aaaaaaaaaa665eeeeeeeeeeeeeeeeea9eeeeeeeeceeeeeee4eeeeeeeeeeeeeeee4eeeeeeeeeeeeeeeeeeeeeedeeee
000000000000000000000000666666665566aaaaaaaa6655eeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55500555eeeeeeee3334433333344333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e787787ee717717ee737737ee757757e55500555eeeeeeee33d44d3333d44d33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ea8aa8aee616616eeb3bb3bee959959e55500555eeeeeeee33d22d3333d11d33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55500555eeeeeeee3d6666d33d6666d3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8aa8eeed1661dee63bb36ee459954e55500555eeeeeeee3d8888d33dccccd3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8aa8eeed1661dee63bb36ee459954e55500555eeeeeeee3d8888d33dccccd3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8888eeed1111dee633336ee455554e55500555eeeeeeee3d8888d33dccccd3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55566555eeeeeeee33dddd3333dddd33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eccccccceccccceecccccccee166661eee11166ee111111ee88888c8ee8888ee88888c8ee55f555eeee5555ee55ff55ee444444eee44444ee111111eeeeeeeee
cccccccccccccccecccccccce161161eee11161ee114411e88888888ee88888e8882888ee55ff55eee55555ee5f5ff5ee444444eee44444ee114411eeeeeeeee
cc66cc6ccccc6ccecccccccc1111111eee111111e111111e88228828e888288e8822888eeffffffeee55fffee5fff55ee4ffff4eee44444ee111111eeeeeeeee
c6fcfffcccccfffccccccccce4f4fffeee444f4ee444444e82ffff28e888fffe8882288eef0ff0feee55f0fee555555eef3ff3feee444f4ee444444eeeeeeeee
cf0ff0fcecfcf0feccccccccef0ff0feee44f0fee444444e8f1ff1f8eef8f1fe8888828eeffffffeee5ffffee555555eef3ff3feee44f3fee444444eeeeeeeee
cf0ff0fcccccf0fecc6cccccef0ff0feee4ff0fee444444e8f1ff1feee28f1fe88288feeef4444feee5fff4ee555555eeffffffeeee4f3fee444444eeeeeeeee
ccffffcccccccffeccc6c6cceeffffeeeeeffffeef4444fe88ffffeeee828ffee882ffeee44ff44eeeeff44ee555555eeeffffeeeeeffffeef4444feeeeeeeee
cccdd1ccec6cccee6ccc6cc699999999eee999ee9999999985566555ee5856ee5855555511477411eee1774e1155551155588555eee555ee99999999eeeeeeee
f6cdd16fccf61deef6cccccfff9559ffeeeff5eef999999f555a6555ee5556ee5555555511477411eee1114e1111111155577555eee555eef999999feeeeeeee
ff1111ffecff11eef16cc66fff5995ffeeeff9eef999999f55566555ee555eee5555555511177111eee111ee1111111155577555eee555eef999999feeeeeeee
ff1111ffeeff11eef116611fff9999ffeeeff9eef999999fff5565ffeeff5eeef555555fff1111ffeeeff1eef111111fff5775ffeeeff5eef999999feeeeeeee
e111111eeee111eee111111ee111111eeeee11eee111111ee555d55eeee5deeee55d555ee111111eeeee11eee111711ee550055eeeee55eee111111eeeeeeeee
e511115eeee511eee511115ee11ee11eeeee11eee11ee11eeddeeddeeeeddeeeeddeeddee11ee11eeeee11eee11ee11ee00ee00eeeee00eee11ee11eeeeeeeee
e55ee55eeee55eeee55ee55ee11ee11eeeee11eee11ee11ee44ee44eeee44eeee44ee44ee11ee11eeeee11eee11ee11ee00ee00eeeee00eee11ee11eeeeeeeee
e55ee55eeee555eee55ee55ee55ee55eeeee555ee55ee55ee44ee44eeee444eee44ee44ee55ee55eeeee555ee55ee55ee00ee00eeeee000ee55ee55eeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eccccccceccccceecccccccee166661eee11166ee111111ee88888c8ee8888ee8888888ee55f555eeee5555ee55ff55ee166661eee11166ee111111eeeeeeeee
cccccccccccccccecccccccce161161eee11161ee114411e88888888ee88888e8882888ee55ff55eee55555ee5f5ff5ee161161eee11161ee114411eeeeeeeee
cc66cc6cccccfccecccccccc1111111eee111111e111111e88228828e888288e8882888eeffffffeee55fffee5fff55e1111111eee111111e111111eeeeeeeee
c6fcfffcccccfffccccccccce4f4fffeee444f4ee444444e82ffff28e888fffe8888288eef0ff0feee55f0fee555555ee4f4fffeee444f4ee444444eeeeeeeee
cf0ff0fcecfcf0fecc6cccccef0ff0feee44f0fee444444e8f1ff1f8eef8f1fe8888828eeffffffeee5ffffee555555eef0ff0feee44f0fee444444eeeeeeeee
cf0ff0fcccccf0feccc6c6ccef0ff0feee4ff0fee444444e8f1ff1feee28f1fe88288feeef4444feee5fff4ee555555eef0ff0feee4ff0fee444444eeeeeeeee
ccffffcccccccffeeccc6ccceeffffeeeeeffffeef4444fe88ffffeeee828ffee882ffeee44ff44eeeeff44ee555555eeeffffeeeeeffffeef4444feeeeeeeee
cc1dd1ceec6ccceee6cccc6f9995599eeee999ee999999998556655eee5856ee585555551147741eeee1774e115555119995599eeee999ee99999999eeeeeeee
6c1ddf6eccf61deee16cc6fff9599ffeeeeffdeef99999ff2556655eee5556ee55555555f417411eeee1114e11111111f9599ffeeeeffdeef99999ffeeeeeeee
e1111ffeecfff1eee116611ee9999ffeeeefffeef99999ffe5556ffeee55feeef55555ffe1177ffeeee111eef11111ffe9999ffeeeefffeef99999ffeeeeeeee
e111111eee1111eee551111ee111111eeee999eee111111ee555dddeee555eeee555d55ee111111eeee11feee111711ee111111eeee999eee111111eeeeeeeee
e55ee55ee51111eee55ee55ee11ee11ee511111ee11ee11eeddeeddee4ddddeeeddeeddee11ee11ee511111ee11ee11ee11ee11ee511111ee11ee11eeeeeeeee
e55ee55ee55ee55ee55ee55ee11ee55ee55ee11ee55ee11ee44ee44ee44eed4ee44ee44ee11ee55ee55ee11ee55ee11ee11ee55ee55ee11ee55ee11eeeeeeeee
e55eeeeeeeeeee55eeeee55ee55eeeeeeeeeee55eeeee55ee44eeeeeeeeeee44eeeee44ee55eeeeeeeeeee55eeeee55ee55eeeeeeeeeee55eeeee55eeeeeeeee
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808000000002a000000000000000000000000080808000000000000000000000000000800080000000000000000000000000008080800000000000000005050505000003030000000000000000
0000008080800000000000000000000000000080808000000000000000000000000000808080000000000000000000000000008080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215152121512505121210708080808080808080809000000000202020708080808080808080808080808080951515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215152121512505121211718181818181818181819000000002324021718181818181818181818181818181951515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202315152121512505102212728282828282828282829000000003334021718181818181818181818181818181951515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215152121512505102211d1e0d0d1e0d1e0d0d1e1f000000002324021718181818181818181818181818181951515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000202215152121512505102212d2e04042e0d2e04042e2f000000003334022728282828282828282828282828282951515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002020202020202020202020202020202020202020202315152121512505123243d3e14143e3e3e14143e3f000000002324021d1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f51515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020202020202020202020202020202020202020202022151521215125051333431313c3c3131313c3c3131000000003334022d2e04042e2e2e04042e2e2e04042e2f51515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00212121212121212121212121212131212121212131213151521215125051020202023c3c0202023c3c0202000000000202023d3e14143e3e3e14143e3e3e14143e3f51515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0051515151515151515151515151515151035151515151515152050505505151515151515151515112121212000000005151515151515130303051513030305151515151515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0061616161616161616161616161616161136161616161616162050505606161616161616161616161616161000000005151515151515151515151515151515151515103515212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0012121212121212121212121212060606060612121212120101121212010112121212121212121212121212000000006161616161616161616161616161616161616113616212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011111111111111111111111111111111111111111111110101121212010111111111111111111111111111000000001212121212121212121201011212121206060606061212151250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0012121212121212121212121212121212121212121212120101121212010112121212121212121212121212000000001111111111111111111101011111111111111111111111121250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041414141414141414141414141414141414141414141414141414141414141414141414141414141414141000000001212121212121212121201011212121212121212121212121250020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0051515151515151515151515151515151515151515151515151515151515151515151515151515151515151000000004141414141414141414141414141414141414141414141414107080808080808080921000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010101010101010101010101010101010105151101010101010101010101010101010101010000000005151515151515151515151515151515151515151515102020217181818181818181921000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020202020202020202020202020202020202020202020205151202020202020202020202020202020202020000000006161616161616161616161616161616161616151515102213117181818181818181921000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002070808080809161212161212164445161212162324310e0f212121212132212121212121212121212102000000007412121612121644451644451612121612121612120221232427282828282828282921000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002171818181819161212161212165455161212163334020e0f21310221212121222121322121212121210200000000741212161212165455165455161212161212161212022133341d0d0d0d0d0d0d0d1f21000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002272828282829161212161212166465161212162102210e0f21212121020202020202020202020202020200000000741212161212166465166465161212161212161212022131212d0d0d0d0d0d0d0d2f21000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020a040b0b040c12121212121212121212121212121212121221212121020202020202020202020000000000000000741212121212121212121212121212121212121212022324212d2e2e2e2e2e2e2e2f21000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00021a1b1b1b1b1c12120708080808080808080808091212121207080808080808080808080902020000000000000000741212121212121212121212121212121212121212023334212d2e04042e04042e2f21000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00021a1b04041b1c12121718181818181818181818191212121217181818181818181818181902020000000000000000741212352525362525362525362525362525261212022121213d3e14143e14143e3f02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022a2b14142b2c121227282828282828282828282912121212272828282828282828282829020200000000000000007412121644451644451612121644451612121612121202313212121212121212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000222121212121212120a0b0b0b0b0b0b0b0b0b0b0c121212120a0b0b0b0b0b0b0b0b0b0b0c020200000000000000007412121654551654551612121654551612121612121202213112121212121212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000231121212121212121a0d0d1b1b0d0d1b1b0d0d1c121212121a0d0d1b1b0d0d1b1b0d0d1c020200000000000000007412121664651664651612121664651612121612121212020212121240414212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000222121212121212121a1b1b1b1b1b1b1b1b1b1b1c121212121a1b1b1b1b1b1b1b1b1b1b1c020200000000000000007412121212121212121212121212121212121212121212121212121250225212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000231121212121212121a1b1b04041b1b04041b1b1c121212121a1b1b04041b1b04041b1b1c020200000000000000007412121212121212121212121212121212121212121212121212121260616212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000222121212121212122a2b2b14142b2b14142b2b2c121212122a2b2b14142b2b14142b2b2c020200000000000000000708080808080809020207080808080808080808080808080907080808080808080974000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002311212121212121212121212121212121212121212121212121212121212121212121212020200000000000000001718181818181819020217181818181818181818181818181917181818181818181974000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000222121212121212121212121212121212121212121212121212121212121212121212121202020000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeececccccccecccceecc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
