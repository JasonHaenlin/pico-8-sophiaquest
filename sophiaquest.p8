pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


-- const
left, right, up, down, fire1, fire2, none = 0, 1, 2, 3, 4, 5, 6
black, dark_blue, dark_purple, dark_green, brown, dark_gray, light_gray, white, red, orange, yellow, green, blue, indigo, pink, peach = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
player, bullet, ennemy, item, npc = 0, 1, 2, 3, 4
immortal_object = 10000
inf = 10000
melee, ranged = 1, 20
nb_of_ennemis = 2
f_heal, f_item, f_inv, f_obst = 0, 1, 5, 7
l_player, l_ennemy, l_boss = 50, 10, 150
walk, stay = "walk", "stay"

debug_enabled = true

-- init
function _init()
 debug_init()

 g_actors = {}
 g_dfx = {}
 g_weapons = {}
 g_dialogs = {}
 set_map_delimiter(8, 8, 225, 125)
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

function newdialog(text, trigger)
 return {
  text = text,
  is_triggered = to_trigger,
  base_triggered = trigger.type,
  arg = trigger.arg
 }
end

-- trigger

function trigger(arg, type)
 return {
  arg = arg,
  type = type
 }
end

function to_trigger(self)
 local next = false
 local hint = false
 if (self.actor) then
  next = self.actor.next
  if(self.actor.hint) then
   del(g_dialogs,self)
   return
  end
 end
 if(not self:base_triggered() and not next) return
 del(g_dialogs,self)

 if(not self.actor) return
 self.actor.line += 1
 self.actor.talking = true
 if(self.actor.line >= #self.actor.dialogs) then
  self.actor.talking = false
  self.actor.hint = true
  self.actor.line = 1
  g_p.control = controls_player
 end -- reset dialogs

end

function trig_time(self)
 self.arg -= 1
 return self.arg <= 0
end

function trig_btn(self)
 return btnp(self.arg)
end

-- make

function make_game()
 make_weapons()
 make_ennemies(nb_of_ennemis, {134})
 make_all_npc()
 make_player(128, 70, 128)
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

function make_all_npc()
  local npc = {}
  npc = make_npc(200, 66, 137)
  npc:create_dialogs({
   newdialog("hey1 ❎",trigger(200, trig_time)),
   newdialog("hey2 ❎",trigger(200, trig_time)),
   newdialog("hey3 ❎",trigger(200, trig_time)),
   newdialog("hey4 ❎",trigger(200, trig_time)),
   newdialog("hey5 ❎",trigger(200, trig_time)),
   newdialog("hey6 ❎",trigger(200, trig_time)),
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
 -- dialogs creation
 n.create_dialogs = create_dialogs
 return n
end

function make_player(x, y, s)
 g_p = make_actor({
  -- new player char
  entitie = newentitie(x, y, s, player, l_player),
  -- add a action controller
  control = controls_player,
  -- add a draw controller
  draw = draw_characters,
  -- set the hitbox
  box = {x1 = 0, y1 = 7, x2 = 7, y2 = 15},
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
    box = {x1 = 0, y1 = 7, x2 = 7, y2 = 15},
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

function create_dialogs(self, dialogs)
 self.line = 1
 self.talking = false
 self.hint = true
 self.dialogs = {}
 for d in all(dialogs) do
  add(self.dialogs,d)
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

function make_dialog(self, di)
 local di = di or self.dialogs[self.line]
 local nd = {
  x = self.x,
  y = self.y-10,
  text = di.text,
  is_triggered = di.is_triggered,
  base_triggered = di.base_triggered,
  arg = di.arg,
 }
 if (self.talking) then
  nd.actor = self
  self.talking = false
  self.next = false
 end
 add(g_dialogs, nd)
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
   c = flr(rnd(9)+6),
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

function hint(self)
 make_dialog(self, newdialog("❎", trigger(5, trig_time)))
end

function warning(self)
 make_dialog(self, newdialog("!", trigger(1, trig_time)))
end

function action_ennemies(a, d)
 if (a.tag ~= ennemy) return
 if (a.cd > 0) a.cd -= 1
 if (a.cd == 0) then
  shoot(a, d)
  a.cd = 50
 end
end

function controls_dialogs(self)
 local a = self.talkto
 if(btnp(fire2)) then
  if(self.talkto.line >= #self.talkto.dialogs) then
   self.control = controls_player
  else
   a.next = true
  end
 end
 if(btnp(fire1)) then
  self.control = controls_player
  self.talkto.hint = true
  g_p.cd = 20
 end
end

function controls_bullets(self)
   self.x += self.dx
   self.y += self.dy
   if (is_of_limit(self.x, self.y, self.bx, self.by, self.range)) del(g_actors, self)
end

function controls_npc(self)
 local dist = distance(self)
 if (dist >= 5 and dist < 10) then
  if(self.talking) make_dialog(self)
  if (self.hint) hint(self)
 end
end

function controls_ennemies(self)
 local dist = distance(self)
 if(is_player_near(dist)) then
  warning(self)
  self.anim = walk
  if (dist >= self.weapon.type) then
   local dir_m = going_forward(self)
   move_on(self, dir_m)
  end -- dist >= weapon type
 elseif (dist < self.weapon.type*8.2) then
  local dir_m = get_best_direction(self)
  move_on(self, dir_m)
  local dir_a = prepare_attack_opportunity(self)
  self.d = dir_a
  action_ennemies(self, dir_a)
 else
  self.anim = stay
 end -- is player near
end

function controls_player(self)
 self.anim = walk
 if (is_moving(left))  move(self,-1, 0, 0, 15)
 if (is_moving(right)) move(self, 1, 0, 6, 15)
 if (is_moving(up))    move(self, 0,-1, 7, 8)
 if (is_moving(down))  move(self, 0, 1, 7, 15)
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

function sqr(x) return x*x end

function distance_test(a)
 return sqrt(sqr(a.x - g_p.x)+sqr(a.y - g_p.y))
end

function distance(a)
 if(not a) return inf
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

function is_player_near(gap, lim)
 local lim = lim or 30
 return gap <= lim and gap > 8
end

function target_nearest_one(limit)
 limit = limit or inf
 local target = {npc = nil, enn = nil}
 for a in all(g_actors) do
  local dist = distance(a)
  if(a.tag == ennemy and distance(target.enn) > dist) target.enn = a
  if(a.tag == npc and distance(target.npc) > dist) target.npc = a
 end -- for all actors
 if (distance(target.enn) > limit) target.enn = nil
 if (distance(target.npc) > limit) target.npc = nil
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
 local sp1 = mget(get_tile(x1), get_tile(y1))
 local sp2 = mget(get_tile(x2), get_tile(y2))
 debug_front_matrix(a, x, y, ox, oy)
 for b in all(g_actors) do
  if(check_collisions(a, b, x, y)) return
 end
 debug_collision_matrix(x1, y1, x2, y2)

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
 local item_near = fget(mget(get_tile(g_p.x) ,get_tile(g_p.y + g_p.box.y1)), f_inv)
 if (btnp(fire2)) then
  log(4,fget(mget(get_tile(g_p.x) ,get_tile(g_p.y + g_p.box.y1)), f_inv))
  if (fget(mget(get_tile(g_p.x+((g_p.box.x2-g_p.box.x1)/2)) ,get_tile(g_p.y + (g_p.box.y1/2))), f_inv)) then
   g_open_inv = true
  else
  local target = target_nearest_one(30)
   if (target.enn ~= nil and g_p.cdfx == 0) then
    g_p.cdfx = g_p.weapon.cdfx
    g_p.weapon.dfx(target.enn.x, target.enn.y, 3, abs(g_fp.y - target.enn.y), g_p.weapon.draw)
    target.enn.health -= 10
    check_actor_health(target.enn)
   elseif (target.npc ~= nil and distance(target.npc) < 10) then
    begin_dialog(target.npc)
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

function begin_dialog(a)
 g_p.talkto = a
 a.talking = true
 a.hint = false
 g_p.control = controls_dialogs
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
 while(fget(mget(get_tile(a.x) ,get_tile(a.y)), f_obst)) do
  a.x = rnd(xmax)
  a.y = rnd(ymax)
 end
 return a
end

function get_tile(a)
 return ((a - (a % 8)) / 8)
end

function is_of_limit(x, y, bx, by, r)
 local bx = bx or x
 local by = by or y
 local r = r or 1
 if (x < g_fp.x or x >= g_fp.x + 128 or
		y < g_fp.y or y >= g_fp.y + 128) then
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
   y = a.y-7,
   s = a.weapon.animv,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   -- add hitbox
   box = {x1 = 4 - center, y1 = 0, x2 = 4 + center, y2 = 8},
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
   y = a.y+17,
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
  d:is_triggered()
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
 follow_player()

 cls()
 map()

 set_camera()

 draw_actors()
 draw_dfxs()
 draw_dialogs()
 draw_hud()

 log(1, g_p.x..":"..g_p.y)
 debug()
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
function get_formalised_position(mina, maxa, a)
 return max(mina, min(maxa, a-64))
end

function lerp(a,b,t)
 return (1-t)*a + t*b
end

function follow_player()
 g_fp = {
  x = get_formalised_position(g_map.x1, g_map.x2, g_p.x),
  y = get_formalised_position(g_map.y1, g_map.y2, g_p.y)
 }
end

function set_map_delimiter(x1,y1,x2,y2)
 g_map = {
  x1 = x1,
  y1 = y1,
  x2 = x2,
  y2 = y2
 }
end

function set_camera()
 reset_camera()
 g_scr.x = max(g_map.x1,min(g_map.x2,lerp(g_scr.x,g_p.x-64,0.4)))
 g_scr.y = max(g_map.y1,min(g_map.y2,lerp(g_scr.y,g_p.y-64,0.4)))
 log(2, g_scr.x..":"..g_scr.y)
 if (g_scr.shake > 0) then
  local a = rnd(1)
  g_scr.x += cos(a)*g_scr.intensity
  g_scr.y += sin(a)*g_scr.intensity
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
  g_dfx = {}
  g_weapons = {}
  g_dialogs = {}

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
  g_ft = {x1=0,y1=0,x2=0,y2=0}
  g_cl = {x1=0,y1=0,x2=0,y2=0}
end

function debug()
 if (not debug_enabled) return
 debug_log(g_fp.x+10, g_fp.y+10)
 display_hitbox_matrix()
 display_collision_matrix()
 display_front_matrix()
end

function display_front_matrix()
 log(5, g_ft.x1.." "..g_ft.y1.." "..g_ft.x2.." "..g_ft.y2)
 line(g_ft.x1, g_ft.y1, g_ft.x1, g_ft.y2, orange)
 line(g_ft.x1, g_ft.y1, g_ft.x2, g_ft.y1, orange)
 line(g_ft.x2, g_ft.y1, g_ft.x2, g_ft.y2, orange)
 line(g_ft.x2, g_ft.y2, g_ft.x1, g_ft.y2, orange)
end

function display_collision_matrix(params)
 line(g_cl.x1,g_cl.y1,g_cl.x2,g_cl.y2,pink)
end

function display_hitbox_matrix()
 local b = get_box(g_p)
 line(b.x1, b.y1, b.x1, b.y2, red)
 line(b.x1, b.y1, b.x2, b.y1, red)
 line(b.x2, b.y1, b.x2, b.y2, red)
 line(b.x2, b.y2, b.x1, b.y2, red)
end

function debug_collision_matrix(x1, y1, x2, y2)
 if (not debug_enabled) return
   g_cl = {x1=x1,y1=y1,x2=x2,y2=y2}
end

function debug_front_matrix(a, x, y, ox, oy)
 if (not debug_enabled) return
 g_ft.x1 = (a.x + x + ((ox - a.x%8 + (8*x))))
 g_ft.y1 = (a.y + y + ((oy - a.y%8 + (8*y))))
 g_ft.y2 = (a.y + y + oy + ((8 - a.y%8 + (8*y))))
 g_ft.x2 = (a.x + x + ox + ((8 - a.x%8 + (8*x))))
end

function log(tab,text)
 if (not debug_enabled) return
 if(tab < 0 or tab > #g_dbg) return
 g_dbg[tab] = text
end

function debug_log(x, y)
 for i=1,#g_dbg do
  print(g_dbg[i], x, y+(6*i), red)
 end
end

__gfx__
000000007777777733bb3b33517711550000000075577557a555555a000000000000000000000000006666666666666666666600000000000555555555555550
00000000555555553bbbb3b3517171550dd7ddd075577557a55555a50066666666666666666666005066666666666666666666050d7dddd00000000000000000
0070070055555555b33bbbbb517711550d7dddd075577557a5555a550600000000000000000000605066666666666666666666050dddddd00000000000000000
00077000777777773bbb3b33517171550dddddd075577557a555a5550660666066606660666066605066666666666666666666050dddddd00555555555555550
00077000777777773b3bb3bb517711550dddddd075577557a55a55550606060606060606060606605066666666666666666666050ddddd700555555555555550
0070070055555555bbb3bbb3511111550dddd7d075577557a5a555550666606660666066606660605066666666666666666666050d7dddd00000000000000000
000000005555555533bb3bbb517171550ddd7dd075577557aa55555506060606060606060606066050666666666666666666660507ddddd00000000000000000
00000000777777773b3bbbb3517771550dddddd075577557a5555555066066606660666066606660506666666666666666666605000000000555555555555550
000000005555555555555555511111550d5555d0555555555557555506060606060606060606066050666666666666666666660500dd1666666666666661dd00
665656565555555555555555517771550d7dddd0555775555557555506666066606660666066606050666666666666666666660550dd1666dddddddd6661dd05
656565655555555555555555517111550dddddd0555775555557555506060606060606060606066050666666666666666666660550dd1666dddddddd6661dd05
665656565777777555555555511771550dddddd0555775555557555506606660666066606660666050666666666666666666660550dd1666dddddddd6661dd05
656565655777777555555555617771660dddddd0555775555557555506060606060606060606066050666666666666666666660550dd1666dddddddd6661dd05
665656565555555555555555666066660ddd7dd0555775555557555506666066606660666066606050666666666666666666660550dd1666dddddddd6661dd05
656565655555555555555555777077770dd7ddd0555775555557555506060606060606060606066050666666666666666666660550dd1666dddddddd6661dd05
665656565555555555555555000000000d7dddd0555555555557555506606660666066606660666050666666666666666666660550dd1666dddddddd6661dd05
65656565333333330000000033333bbbbbb33333777777777777555506060606060606060606066070000006705555060120000050dd1666eeeeeeee6661dd05
6656565633333b33665666563333bb3bbbbbb333555555555557555506666066606660666066606070555506705555060123535350dd1666eeeeeeee6661dd05
65656565333b3b3366566656333bb3bb3b3bbb33555555555557555506060606060606060606066070555506705555060123535350dd1666eeeeeeee6661dd05
66565656333333336656665633bbbbbbb3bbbbb3555555555557555506606660666066606660666070555506705555060000000050dd1666eeeeeeee6661dd05
6565656533333333665666563bb333bbbbbbbbb35555555555575555060606060606060606060660705555067055550608dda6a650dd1666eeeeeeee6661dd05
665656563b3333b3665666563bbbb33bbbbbb3bb5555555555575555060000000000000000000060705555067055550608dda6a650dd1666eeeeeeee6661dd05
656565653b3333b366566656bb33bbbbbb333bbb5555555555575555006666666666666666666600705555067055550608dda6a650dd1666eeeeeeee6661dd05
0000000033333333665666563b3bb444bbbbbbb3555555555557555506000000000000000000006060555506600000060000000050dd1666eeeeeeee6661dd05
55bbb5b533333333665666563bbbbb4bbbbbbbb35557777777777777000000000000000036666663eceeeeee0000000077777776330011004055151570555506
5b3b3b5533333a336656665633b3b44bb44b3b3355575555555755550aaaaaa006666660355dd553ecceeeee5555555577777776335511404455151570555506
5bb3b3b53333a9a3665666563b3bbb24b4bbb3b355575555555755550a9999a007667660355d5d53eccceeee0000000077777776335511404455151570555506
55b34b5533333a3366566656b3bbbb2444bbbb3b55575555555755550a9889a006766760355565d3ecccceee5555555577777776000000000000000070555506
5111111533333333665666563333b344443b333355575555555755550a9889a00666666035565dd3eccc1eee0000000077777776c07990206163dc8470555506
517111153383333366566656333333244433333355575555555755550a9999a00000000031655553ecc1eeee5555555577777776cc7992206163dc8470555506
511111153828333366566656333332244443333355575555555755550aaaaaa0444004443c155553ec1eeeee0000000077777776cc7992206163dc8470555506
55111155338333330000000033333334244333335557555555575555000000000000000035555553e1eeeeee5555555566666666000000000000000060555506
000000000000000000000000000000005555555555555555ffffffff44444444eeee99eeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
07770777777777077777777004444440558aaaaaaaaaa855ffffffff444444449eee9eeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee58e58e568865e
07660666666666066666667004444440588aaaaaaaaaa885ffffffff444444449eee9eeeeeeec51eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeeeeeeee56899865
07660666666666066666667004444440aaaaaaaaaaaaaaaaffffffff4444444499eeeeeeeeeec51eeee88eeeeeeeeeee7eeeee5ecccccccee58eeeee689aa986
07665555555555555555000004444440aaa0000000000aaaffffffff44444444e99eeeeeeeeec51eeee898eeeee558eee74444551111111ceeee58ee689aa986
07665555555555555555667004444440aa000000000000aa4444444444444444eeee999eeeeec51eeee88eeeeeeeeeee7eeeee5eccccccceeeeeeeee56899865
07665555555555555555667004444440aa000000000000aa444444444444444499eeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeee58ee58e568865e
07665555555555555555667004444040aaa0000000000aaa4444444444444444eeeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
07665555555555555555667004444440a0aaaaaaaaaaaa0a2666666644444444eeee99eeeeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeeeceeeeee8e8eeeee5665ee
00005555555555555555667004444440a00aaaaaaaaaa00a26666666444444449eee9eeee111111eeeeeeeeeeeeeeeeeee555eeeeeccceeeee5e5eeee568865e
07665555555555555555667004444440aaaaaaaaaaaaaaaa26666666444444449eee9eee15555551eee8eeeeeee8eeeeeee4eeeeecc1cceeeeeeeeee56899865
07665555555555555555667004444440a00aaaaaaaaaa00a244444464444444499eeeeee55cccc55ee898eeeeee5eeeeeee4eeeeeec1ceeeeee8e8ee689aa986
07665555555555555555667004444440a00aaaaaaaaaa00a2444444622222222e99eeeee5ceeeec5ee888eeeeee5eeeeeee4eeeeeec1ceeee8e5e5ee689aa986
07665555555555555555667004444440a0aaaaaaaaaaaa0a6222222620000002eeee999eceeeeeeceeeeeeeeeeeeeeeeeee7eeeeeec1ceeee5eeeeee56899865
07665555555555555555000004444440aaaaaaaaaaaaaaaa626666262000000299eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7e7eeeeec1ceeeeeee8eeee568865e
07665555555555555555667004444440aaa0000000000aaa6266662620000002eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec1ceeeeeee5eeeee5665ee
07665555555555555555667070111106aa000000000000aa2222111166666666eeeeeeeeeeee1eeeeee8eeeeeeeeeeeeeeee4eeeeeee8eeeeeeeeeeeee888eee
07665555555555555555667070111106aa000000000000aa2222111176666667eee99eeeeeec1eeeee828eeeeeeeeeeeeeede4eeeee88eeeeeeeeeeeee888eee
07665555555555555555667070111106aa000000000000aa2222111177666677eee9e9eeeeec1eeeee48eeeeeeee8eeeeeedee4ee5555511eeee8eeeee8d8eee
00005555555555555555667070111106aaa0000000000aaa2222111177766777eeee5e9eeeec1eeeeee4eeeeee55559eeeedee4ee5555511e5555a55ee8d8eee
07666666606666666660667070111106aaaaaaaaaaaaaaaa2222111177766777eee5e99eeeec1eeeee4eeeeeeeddeeeeeeedee4eeeddeeeeeeddeaaeee8d8eee
07666666606666666660667070111106aaaaaaaaaaaaaaaa2222111177666677e95eeeeeeeec1eeeeee4eeeeeedeeeeeeeede4eeeedeeeeeeedeeaaeeedddeee
07777777707777777770777070111106566aaaaaaaaaa6652222111176666667ea9eeeeeeeeceeeeeee4eeeeeeeeeeeeeeee4eeeeeeeeeeeeeeeeeeeeeedeeee
000000000000000000000000601111065566aaaaaaaa66552222111166666666eeeeeeeeeee5eeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeee
5555555511111111eeeeeeeeeeeeeeee5550055566666662ee0550ee012000005022226277777777000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeee
5555555511111111eeeeeeeee757757e5550055566666662ee0550ee012353535022226200000000077777700777777066666666eeeeeeeeeeeeeeeeeeeeeeee
5555555511111111eeeeeeeee959959e5550055566666662ee0550ee0123535350222262ffffffff077777700707777066666666eeeeeeeeeeeeeeeeeeeeeeee
5555555511111111eeeeeeeeeeeeeeee5550055564444442ee0550ee0000000050666666ffffffff077777700707777066666666eeeeeeeeeeeeeeeeeeeeeeee
5555555511111111eeeeeeeee459954e5550055564444442ee0550ee08dda6a650226222ffffffff000000000777777066666666eeeeeeeeeeeeeeeeeeeeeeee
0000000011111111eeeeeeeee459954e5550055562222226ee0550ee08dda6a650226222ffffffff077777700777777066666666eeeeeeeeeeeeeeeeeeeeeeee
1111111111111111eeeeeeeee455554e5550055562666626ee0550ee08dda6a650226222ffffffff070777700777777066666666eeeeeeeeeeeeeeeeeeeeeeee
1111111111111111eeeeeeeeeeeeeeee5556655562666626ee0000ee0000000050666666ffffffff077777700000000066666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee67d7d7d6
eccccccceccccceecccccccee166661eee11166ee111111ee88888c8ee8888ee88888c8ee55f555eeee5555ee55ff55ee444444eee44444ee444444e67d7d7d6
cccccccccccccccecccccccce161161eee11161ee114411e88888888ee88888e8882888ee55ff55eee55555ee5f5ff5ee444444eee44444ee444444e6ffffff6
cc66cc6ccccc6ccecccccccc1111111eee111111e111111e88228828e888288e8822888eeffffffeee55fffee5fff55ee4ffff4eee44444ee444444e6f0ff0f6
c6fcfffcccccfffccccccccce4f4fffeee444f4ee444444e82ffff28e888fffe8882288eef0ff0feee55f0fee555555eef3ff3feee444f4ee444444e6f0ff0f6
cf0ff0fcecfcf0feccccccccef0ff0feee44f0fee444444e8f1ff1f8eef8f1fe8888828eeffffffeee5ffffee555555eef3ff3feee44f3fee444444e7ffffff7
cf0ff0fcccccf0fecc6cccccef0ff0feee4ff0fee444444e8f1ff1feee28f1fe88288feeef4444feee5fff4ee555555eeffffffeeee4f3fee444444e77777777
ccffffcccccccffeccc6c6cceeffffeeeeeffffeef4444fe88ffffeeee828ffee882ffeee44ff44eeeeff44ee555555eeeffffeeeeeffffeef4444fe7ff77ff7
cccdd1ccec6cccee6ccc6cc699999999eee999ee9999999985566555ee5856ee5855555511477411eee1774e1155551155588555eee555ee55555555eeeeeeee
f6cdd16fccf61deef6cccccfff9559ffeeeff5eef999999f555a6555ee5556ee5555555511477411eee1114e1111111155577555eee555ee55555555eeeeeeee
ff1111ffecff11eef16cc66fff5995ffeeeff9eef999999f55566555ee555eee5555555511177111eee111ee1111111155577555eee555ee55555555eeeeeeee
ff1111ffeeff11eef116611fff9999ffeeeff9eef999999fff5565ffeeff5eeef555555fff1111ffeeeff1eef111111fff5775ffeeeff5eef555555feeeeeeee
e111111eeee111eee111111ee111111eeeee11eee111111ee555d55eeee5deeee55d555ee111111eeeee11eee111711ee550055eeeee55eee555555eeeeeeeee
e511115eeee511eee511115ee11ee11eeeee11eee11ee11eeddeeddeeeeddeeeeddeeddee11ee11eeeee11eee11ee11ee00ee00eeeee00eee00ee00eeeeeeeee
e55ee55eeee55eeee55ee55ee11ee11eeeee11eee11ee11ee44ee44eeee44eeee44ee44ee11ee11eeeee11eee11ee11ee00ee00eeeee00eee00ee00eeeeeeeee
e55ee55eeee555eee55ee55ee55ee55eeeee555ee55ee55ee44ee44eeee444eee44ee44ee55ee55eeeee555ee55ee55ee00ee00eeeee000ee00ee00eeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eccccccceccccceecccccccee166661eee11166ee111111ee88888c8ee8888ee8888888ee55f555eeee5555ee55ff55ee444444eee44444ee444444eeeeeeeee
cccccccccccccccecccccccce161161eee11161ee114411e88888888ee88888e8882888ee55ff55eee55555ee5f5ff5ee444444eee44444ee444444eeeeeeeee
cc66cc6cccccfccecccccccc1111111eee111111e111111e88228828e888288e8882888eeffffffeee55fffee5fff55ee4ffff4eee444f4ee444444eeeeeeeee
c6fcfffcccccfffccccccccce4f4fffeee444f4ee444444e82ffff28e888fffe8888288eef0ff0feee55f0fee555555eef3ff3feee44f3fee444444eeeeeeeee
cf0ff0fcecfcf0fecc6cccccef0ff0feee44f0fee444444e8f1ff1f8eef8f1fe8888828eeffffffeee5ffffee555555eef3ff3feeee4f3fee444444eeeeeeeee
cf0ff0fcccccf0feccc6c6ccef0ff0feee4ff0fee444444e8f1ff1feee28f1fe88288feeef4444feee5fff4ee555555eeffffffeeeeffffee444444eeeeeeeee
ccffffcccccccffeeccc6ccceeffffeeeeeffffeef4444fe88ffffeeee828ffee882ffeee44ff44eeeeff44ee555555eeeffffeeeeeffffeef4444feeeeeeeee
cc1dd1ceec6ccceee6cccc6f9995599eeee999ee999999998556655eee5856ee585555551147741eeee1774e115555115558855eeee555ee55555555eeeeeeee
6c1ddf6eccf61deee16cc6fff9599ffeeeeffdeef99999ff2556655eee5556ee55555555f417411eeee1114e11111111f557755eeee555ee55555555eeeeeeee
e1111ffeecfff1eee116611ee9999ffeeeefffeef99999ffe5556ffeee5ffeeef55555ffe1177ffeeee111eef11111ffe5577ffeeee5ffeef55555ffeeeeeeee
e111111eee1111eee551111ee111111eeee999eee111111ee555dddeee555eeee555d55ee111111eeee1ffeee111711ee550000eeee555eee555555eeeeeeeee
e55ee55ee51111eee55ee55ee11ee11ee511111ee11ee11eeddeeddee4ddddeeeddeeddee11ee11ee511111ee11ee11ee00ee00ee000000ee00ee00eeeeeeeee
e55ee55ee55ee55ee55ee55ee11ee55ee55ee11ee55ee11ee44ee44ee44eed4ee44ee44ee11ee55ee55ee11ee55ee11ee00ee00ee00ee00ee00ee00eeeeeeeee
e55eeeeeeeeeee55eeeee55ee55eeeeeeeeeee55eeeee55ee44eeeeeeeeeee44eeeee44ee55eeeeeeeeeee55eeeee55ee00eeeeeeeeeee00eeeee00eeeeeeeee
525252525252525252525252000066666666666666666666660000000000000000007474d0d09797d0d09797c2d3979700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a7c2e3e3e3e3e3e3e3e3d3a700006666666666666666666666009797000097d0d09734346464646464646464c2d3646400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b7c2e3e3e3e3e3e3e3e3d3b70000b1b1f8b1b1f8b1b1f8b1b1008383979783646483353576767676767676767676767600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3c3c3c3c3c3c3c3c3c3c3c300000707070707070707070707007575838375757575767676000000007474767676767600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3a2c3c3a2c3c3a2c3c3a2c300001717171717171717171717007676757576767676767676000000003434767676747600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3f3c3c3f3c3c3f3c3c3f3c30000c7c7c7c7c7c7c7c7c7c7c7007676767676000000007676000000003535767676745700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3f3c3c3f3c3c3f3c3c3f3c30000657557c7657557c7657557000000767676009797977676000000007676767676757600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3f3c3c3f3c3c3f3c3c3f3c30000c7c7c7c7c7c7c7c7c7c7c7009797767676978383837676000000007676767676767600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3b2c3c3b2c3c3b2c3c3b2c30000657457c7657457c7657457006464767676647575757676000000007676767676767600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c336c3c336c3c336c3c336c30000657557c7657557c7657557007676767676767676767676000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c336c3c336c3c336c3c336c30000c7c7c7c7c7c7c7c7c7c7c7000000000076760000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3c3c3c3c3c3c3c3c3c3c3c30000c7c7c7c7000000c7c7c7c7009797779776769797777700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3c3c3c3c3c3c3c3c3c3c3c300000000000000000000000000006464776476766464777700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c3c3c3c300000000c3c3c3c300000000000000000000000000007676777676767676777700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000007676767600007676767600000000000000000000000000000000000000000000000000000000
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808000000002a000000000000000000000000080008000000000000000000000000000000080000000000000000000000000000080800000000000000005050505000000000000000000000000
0000008080800000000000000000000500000080808000000000000000000000000000808080000000000000000000000000008080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000171818070808080808080808080918181900000000002525252525002c2c2c2c2c2c2c007979790079797979797979
00000000000000000000000000000000000000000002022151521215125051212107080808080808080808090000000002020207080808080808080808080808080809515152121512500200000000000027282817181818181818181818192828290000000000301212127a003e3e3e3e3e3e3e004646460046464646464646
0000000000000000000000000000000000000000000202215152121512505121211718181818181818181819000000002324021718181818181818181818181818181951515212151250020000000000000a0d0d27282828282828282828290d0d1c0202000000575757577b005657755657757c007c7c7c7c7c7c7c7c7c1230
0000000000000000000000000000000000000000000202315152121512505102212728282828282828282829000000003334021718181818181818181818181818181951515212151250020000000000001a1b1b1d0d0d1e0d0d0d1e0d0d1f1b1b1c02020000003c3c3c3c3c7c7c7c7c7c7c7c7c7c7c7c7c007c7c7c7c7c1212
0000000000000000000000000000000000000000000202215152121512505102211d1e1e1e1e0d1e1e1e1e1f000000002324021718181818181818181818181818181951515212151250020000000000001a1b1b2d1e1e1e1e1e1e1e1e1e2f1b431c02020000003c3c3c3c3c007c7c7c7c7c7c7c007c7c7c0043003d797c793e
0000000000000000000000000000000000000000000202215152121512505102212d1e04041e0d1e04041e2f000000003334022728282828282828282828282828282951515212151250020000000202021a1b1b2d1e04041e1e1e04041e2f1b531c02020202003c3c3c3c3c0079474779797979007c7c7c0053003d467c463e
0002020202020202020202020202020202020202020202315152121512505123242d1e14141e1e1e14141e2f000000002324020a666666660b666666660b666666660c51515212151250020000002121212121212d1e14141e1e1e14141e2f12121221212121007777797979794643434677777700477c7c007c003d67676767
0002020202020202020202020202020202020202020202215152121512505133343131121231313112123131000000003334021a1b04041b1b1b04041b1b1b04041b1c5151521215125002000000515151515151515151515151515151515151515103515151007777464646467c53537c7777770038757c007c006767674767
0021212121212121212121212121213121212121213121315152121512505102020202121202020212120202000000000202021a1b14141b1b1b14141b1b1b14141b1c5151521215125002000000616161616161616161616161616161616161616113616161007c7c7c7c7c7c7c7c7c7c7c7c7c00477c7c007c006767674775
00515112515151515112515151515151510351515151515151520505055051515151515151515151121212120000000051515151515151303030515130303051515151515152121512500200000012121212121212121212121212121212121206060606061200567c477c7c7c7c7c7c7c7c7c7c00477c7c007c006757575767
00616161616161616161616161616161611361616161616161620505056061616161616161616161616161610000000051515151515151515151515151515151515151035152121512500200000011111111111111111111111111111111111111111111111100567c577c7c7c7c7c7c7c7c7c7c0047757c007c006767676767
00121212121212121212121212120606060606121212121201011212120101121212121212121212121212120000000061616161616161616161616161616161616161136162121512500200000012121212121212121212121212121212121212121212121200797979797c7c7c7c7c7c7c7c7c0038757c007c797979797979
00111111111111111111111111111111111111111111111101011212120101111111111111111111111111110000000012121212121212121212010112121212060606060612121512500200000041414141414141414141414141414141414141414141414100463846467c7c7c7c007c7c7c7c00477c7c007c464646464646
001212121212121212121212121212121212121212121212010112121201011212121212121212121212121200000000111111111111111111110101111111111111111111111112125002000000232423242324232423242324232423242324232423242324007757577c7c7c7c7c007c7c7c7c00477c7c007c7c7c7c7c7c7c
004141411215124141414141414141414141414141414141414141414141414141414141414141414141414100000000121212121212121212120101121212121212121212121212125002000000333433343334333433343334333433343334333433343334007c7c7c7c7c7c7c7c00387c7c7c00387c7c797979797979797c
00515112050505125151515151515151515151515151515151515151515151515151515151515151515151510000000041414141414141414141414141414141415151515141414141070808080808080809210000000000000000000000000000000000000000797979797c7c7c7c0047757c7c00577c7c464646464646467c
00101010222222101010101010101010101010101010101051511010101010101010101010101010101010100000000051515151515151515151515151515151515151515151020202171818181818181819210000000000000000000000000000000000000000464638467c7c7c7c00387c7c7c007c7c7c7c7c7c7c7c7c7c7c
002020203232322020202020202020202020202020202020515120202020202020202020202020202020202000000000616161616161616161616161616161616151125151510221311718181818181818192100000000000000000000000000000000000000007c57577c7c7c7c7c0038757c7c00797979797979797979797c
0002121212121212161212161212164445161212162324310e0f21212121212121212121212121212121210200000000741212161212164445164445161212161212125151022123242728282828282828292100000000000000000000000000000000000000007c7c7c7c7c7c7c7c0047757c7c00464646464646464646467c
0002121212121212161212161212165455161212163334020e0f21310221212121212121212121212121210200000000741212161212165455165455161212161251125151022133341d0d0d0d0d0d0d0d1f210000000000000000000000000000000000000000797979797c7c7c7c00387c7c7c007c79797979797979797979
0002070808080809161212161212166465161212162102210e0f21212121020202020202020202020202020200000000741212161212166465166465161212161251125151022131212d0d0d0d0d0d0d0d2f210000000000000000000000000000000000000000773846467c7c7c7c0047757c7c007c46464646464646464646
000217181818181912121212121212121212121212121212121221212121020202020202020202020000000000000000741212121212121212121212121212121251125112022324212d1e1e1e1e1e1e1e2f2100000000000000000000000000000000000000007c57577c7c7c7c7c00387c7c7c79797979797979797979791b
000227282828282912120708080808080808080808091212121207080808080808080808080902020000000000000000741212121212121212121212121212121212125112023334212d1e04041e04041e2f2100000000000000000000000000000000000000007c7c7c7c7c7c7c7c0047757c7c46464646464646464646461b
00020a666666660c12121718181818181818181818191212121217181818181818181818181902020000000000000000741212352525362525362525362525362525261212022121022d1e14141e14141e2f0200000000000000000000000000000000000000007c7c7c7c00007c7c00577c7c7c7c7c7c7c7c7c7c7c1b1b1b1b
00021a1b04041b1c121227282828282828282828282912121212272828282828282828282829020200000000000000007412121644451644451612121644451612121612121202310202021212301212020274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00021a1b14141b1c12120a0d0d0d0d0d0d0d0d0d0d0c121212120a0b0b0b0b0b0b0b0b0b0b0c020200000000000000007412121654551654551612121654551612121612121202213112121212121212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000231121212121212121a0d0d1b1b0d0d1b1b0d0d1c121212121a0d0d1b1b0d0d1b1b0d0d1c020200000000000000007412121664651664651612121664651612121612121212020212121240414212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000231121212121212121a1b1b1b1b1b1b1b1b1b1b1c121212121a1b1b1b1b1b1b1b1b1b1b1c020200000000000000007412121212121212121212121212121212121212121212121212121250305212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000231121212121212121a1b1b04041b1b04041b1b1c121212121a1b1b1b1b04041b1b1b1b1c020200000000000000007412121212121212121212121212121212121212121212121212121260616212121274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000231121212121212121a1b1b14141b1b14141b1b1c121212121a1b1b1b1b14141b1b1b1b1c020200000000000000000708080808080809020207080808080808080808080808080907080808080808080974000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002311212121212121212121212121212121212121212121212121212121212121212121212020200000000000000001718181818181819020217181818181818181818181818181917181818181818181974000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000231121212121212121212121212121212121212121212121212121212121212121212121202020000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeececccccccecccceecc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0110000017050000000000023050230500000000000210502105000000000001c05000000000001c0501a05000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000185600125017540175301651016500165001670013700117001f2001e2001b2001a2001b2001e20000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000015760187501a7501d7401f740207302272023710257002570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d7700a7700677005760037500274001720027100640005400054000000000000000000000000000000002c2000000000000000000000000000000000000000000000000000000000000000000000000
0001000011130161401d150221602617023160201601a150151500e1300b13007120021100110000000000000000000000000000b200000000000000000000000000000000000000000000000000000000000000
00010000376602f66028660236501e6501b6401664012640106300d6300a620086100661003600326000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000028750237602175025730257101a7101874017760167601674018720197702f5002f5002f5002f5002e50029500215001a5002e5002e5002d50028500225001c500195001a50028500275002650000000
000200002a63024630226302a6301d630236302a6301d6301a6302c6301f6302b6300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000376203762037620376203762037620366203661034610326102e60029600216001a6000e6000160003600000000000000000000000000000000000000000000000000000000000000000000000000000
0001000012040100400f0400e0400f0401004011040000000000000000110001200012000130000000014000140001c0001500015000160001700017000170000000000000000000000000000000000000000000
000500001364013630136200000013640136301362000000136401363013620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000f1305000000130500000000000130500000000000000001305000000000000000013550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000f1855000000185500000000000155500000015550000000000015550000001355017550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c750000001c750000001c750000001a7501c7501d7501e7501e7501e7501f750000001f7501f7501f7501f7501f7501f7501f7401f7301f7201f7100000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002820028200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 08020355
00 0b0c0e44
00 0e0f1044
