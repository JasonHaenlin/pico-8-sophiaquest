pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


left, right, up, down, fire1, fire2, none = 0, 1, 2, 3, 4, 5, 6
black, dark_blue, dark_purple, dark_green, brown, dark_gray, light_gray, white, red, orange, yellow, green, blue, indigo, pink, peach = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
pl, bullet, ennemy, item, npc, invisible, outside, inside,  boss = 0, 1, 2, 3, 4, 5, 6, 7, 8
immortal_object = 10000
inf = 10000
melee, ranged = 1, 20
f_heal, f_item, f_door, f_inv, f_obst = 0, 1, 4, 5, 7
l_pl, l_ennemy, l_boss = 200, 20, 150
walk, stay = "walk", "stay"

g_dbg = {"","","","","","","","","",""}
g_cl = {x1=0,y1=0,x2=0,y2=0}
function debug_log(x, y)
 for i=1,#g_dbg do
  print(g_dbg[i], x, y+(6*i), red)
 end
end

function log_cpu_mem(x, y)
 print("cpu "..flr(stat(1)*100).."%", x, y, red)
 print("mem "..stat(0), x, y+6, red)
end

function log(tab,text)
 if(tab < 0 or tab > #g_dbg) return
 g_dbg[tab] = text
end

function display_collision_matrix(params)
 line(g_cl.x1,g_cl.y1,g_cl.x2,g_cl.y2,pink)
end

function _init()
 g_actors = {}
 g_dfx = {}
 g_dialogs = {}
 g_menus = {}
 g_npcs = {}
 g_weapons = {}
 g_to_win = 3
 g_loots = {
  {obj = "heal", s = 239, drop_rate = 40},
  {obj = "coin", s = 255, drop_rate = 60}
 }
 _update = update_menu
 init_area()
 init_screen()
 m_game()
end

function init_current_area(area,s)
 local ca = g_area[area]
 log(1, ca)
 log(2, ca.name)
 log(3, ca.spawns[s].x..":"..ca.spawns[s].y)
 g_spawn = {}
 g_spawn.x = ca.spawns[s].x
 g_spawn.y = ca.spawns[s].y
 clean_memory()
 ca.instantiate_entities()
 if(g_p)  then
  g_p.x = g_spawn.x
  g_p.y = g_spawn.y
  g_p.current_area = area
 end
 set_map_delimiter(ca.map.x1, ca.map.y1, ca.map.x2, ca.map.y2)
end

function clean_memory()
 g_actors = {}
 g_dfx = {}
 g_dialogs = {}
 g_menus = {}
 g_npcs = {}
 add(g_actors,g_p)
end

 function init_area()
  g_area_keys = {"biot", "antibes", "valbonne"}
  g_area = {
   cheat = {
    tag = nolimit,
    name = "cheat",
    map = {x1 = -inf, y1 = -inf, x2 = inf, y2 = inf},
    spawns = {
     default = { x = 125, y = 70 }
    },
    instantiate_entities = function () end
   },
   biot = {
    tag = outside,
    name = "biot (c)",
    map = {x1 = 8, y1 = 8, x2 = 225, y2 = 125},
    spawns = {
     bus = { x = 125, y = 70 },
     capgemo = { x = 285, y = 53 },
     sophiatechest = { x = 253, y = 239 },
     sophiatechouest = { x = 109, y = 240 },
     sophiatechru = { x = 36, y = 211 }
    },
    instantiate_entities = function ()
     m_tp(138, 71, 46, 5, 5, "biot", "bus", trig_btn_hud,"❎")
     m_tp(281, 41, 46, 15, 10, "capgemo", "entrance", trig_dist_hud,"⬆️")
     m_tp(321, 41, 46, 15, 10, "capgemo", "entrance", trig_dist_hud,"⬆️")
     m_tp(250, 225, 46, 15, 10, "sophiatechest", "entrance", trig_dist_hud,"⬆️")
     m_tp(105, 224, 46, 15, 10, "sophiatechouest", "entrance", trig_dist_hud,"⬆️")
     m_tp(136, 224, 46, 15, 10, "sophiatechouest", "entrance", trig_dist_hud,"⬆️")
     m_tp(33, 192, 46, 15, 10, "sophiatechru", "entrance", trig_dist_hud,"⬆️")
     local npc_outside_man_biot = {}
     npc_outside_man_biot = m_npc(108,71,204)
     npc_outside_man_biot:create_dialogs({
       n_dialog("que… quoi ? ❎",trigger(200, trig_time)),
       n_dialog("vous arrivez a sophia sans aucune competence ?! ❎",trigger(200, trig_time)),
       n_dialog("vous devez avoir beaucoup de courage… ou de betise ❎",trigger(200, trig_time)),
       n_dialog("pour survivre ici, il va vous falloir vous faire une place parmi les entreprises. et elles sont implacables. ❎",trigger(200, trig_time)),
       n_dialog("le coin grouille de recruteurs qui sont prets à vous faire passer des entretiens en pleine rue. ❎",trigger(200, trig_time)),
       n_dialog("sans competences, vous ne tiendrez pas 2h ici. ❎",trigger(200, trig_time)),
       n_dialog("je vous conseille de vous diriger vers l'ecole qui est juste de l'autre cote de cette route. ❎",trigger(200, trig_time)),
       n_dialog("sophiatech je crois que ca s'appelle. ❎",trigger(200, trig_time)),
       n_dialog("la-bas, vous devriez en apprendre assez pour survivre ici assez longtemps. ❎",trigger(200, trig_time)),
       n_dialog("le directeur de l'ecole se trouve juste apres l'entree. ❎",trigger(200, trig_time)),
       n_dialog("ah ! et ne pensez meme pas aller vers l'est si vous n'etes pas prete. ❎",trigger(200, trig_time)),
       n_dialog("il y a des recruteurs sans vergogne qui rodent dans ces environs. ❎",trigger(200, trig_time)),
      })

      local npc_r1_biot = {}
      npc_r1_biot = m_npc(341,86,204)
      npc_r1_biot:create_dialogs({
       n_dialog("eh la, jeune fille ! ❎",trigger(200, trig_time)),
       n_dialog("ou pensez-vous aller comme ca ? ❎",trigger(200, trig_time)),
       n_dialog("quel est votre domaine de competence ? ❎",trigger(200, trig_time)),
      })

      local npc_r2_biot = {}
      npc_r2_biot = m_npc(239,12,198)
      npc_r2_biot:create_dialogs({
       n_dialog("tiens tiens, qu'est-ce qu'on a la ? ❎",trigger(200, trig_time)),
       n_dialog("vous etes sans emploi ? ❎",trigger(200, trig_time)),
       n_dialog("vous savez quoi ? laissez-moi regarder votre cv ! ❎",trigger(200, trig_time)),
      })

      local npc_daminaca_sophiatech_biot = {}
      npc_daminaca_sophiatech_biot = m_npc(179,163,201,immortal_object,false)
      npc_daminaca_sophiatech_biot:create_dialogs({
       n_dialog("hmm, une nouvelle tete ? ❎",trigger(200, trig_time)),
       n_dialog("je ne vous avais jamais vu jeune fille.❎",trigger(200, trig_time)),
       n_dialog("et pourtant je connais tous mes etudiants ! ❎",trigger(200, trig_time)),
       n_dialog("vous ne faites pas partie de cette ecole n'est-ce pas ? ❎",trigger(200, trig_time)),
       n_dialog("c'est bien ce que je me disais. ❎",trigger(200, trig_time)),
       n_dialog("que venez-vous faire ici ? ❎",trigger(200, trig_time)),
       n_dialog("en temps normal ma prestigieuse ecole n'accepte personne sans inscription prealable. ❎",trigger(200, trig_time)),
       n_dialog("mais je percois chez vous une certaine flamme. ❎",trigger(200, trig_time)),
       n_dialog("vous savez quoi ? ❎",trigger(200, trig_time)),
       n_dialog("je vais vous laisser une chance. ❎",trigger(200, trig_time)),
       n_dialog("bienvenue a sophiatech ! ❎",trigger(200, trig_time)),
       n_dialog("laissez-moi vous expliquer le fonctionnement de cette ecole. ❎",trigger(200, trig_time)),
       n_dialog("votre objectif est simple : obtenir votre diplome pour etre recrutee dans l'entreprise de vos reves. ❎",trigger(200, trig_time)),
       n_dialog("pour se faire vous devez effectuer trois stages differents qui permettront d'ameliorer vos competences et votre materiel. ❎",trigger(200, trig_time)),
       n_dialog("l'ordre que je vous conseil pour les stages est le suivant : d'abord capgemo qui se trouve a biot, puis leonardo energie a antibes et enfin thelas à valbonne. ❎",trigger(200, trig_time)),
       n_dialog("vous devrez aller parler aux recruteurs de chacune de ces entreprises et passer leurs epreuves afin d'etre recrutee. ❎",trigger(200, trig_time)),
       n_dialog("dans le campus, des etudiants et professeurs viendront vous aborder pour vous aider a prendre de l�█▥experience et tester vos connaissances. ❎",trigger(200, trig_time)),
       n_dialog("et noublies pas de récupérer ton équipement sur le terminal à côté. ❎",trigger(200, trig_time)),
       n_dialog("en cas de doute, durant votre parcours n'hesitez pas a revenir me voir et je vous repeterai tout cela. ❎",trigger(200, trig_time)),
       n_dialog("n'oubliez pas votre materiel! ❎",trigger(200, trig_time)),
       n_dialog("vous pouvez le choisir sur le terminal derriere moi! ❎",trigger(200, trig_time)),
       n_dialog("votre materiel est extremement precieux. ❎",trigger(200, trig_time)),
       n_dialog("sans materiel vous ne pourrez jamais terminer vos etudes et realiser votre reve à sophia. ❎",trigger(200, trig_time)),
       n_dialog("votre materiel constitue l'outil principal de votre connaissance. ❎",trigger(200, trig_time)),
       n_dialog("utilisez-le pour demontrer vos connaissances aux etudiants et aux professeurs qui veulent vous tester. ❎",trigger(200, trig_time)),
       n_dialog("et il y en a beaucoup sur le campus et sur les routes. ❎",trigger(200, trig_time)),
     })

      local npc_st1_biot = {}
      npc_st1_biot = m_npc(199,214,195)
      npc_st1_biot:create_dialogs({
       n_dialog("ma specialite c'est genie de l'eau ! et toi ?! ❎",trigger(200, trig_time)),
      })

      local npc_st2_biot = {}
      npc_st2_biot = m_npc(103,136,195)
      npc_st2_biot:create_dialogs({
       n_dialog("il parait que le restaurant universitaire se trouve a l'ouest d'ici… ❎",trigger(200, trig_time)),
       n_dialog("va y faire un tour, la nourriture va te requinquer. ❎",trigger(200, trig_time)),
      })
    end
   },
   antibes = {
    tag = outside,
    name = "antibes (c)",
    map = {x1 = 384 , y1 = 8, x2 = 474, y2 = 118},
   spawns = {
    bus = { x = 528, y = 77 },
    carrouffe = { x = 468, y = 73 },
    leonardoenergy = { x = 545, y = 191 }
   },
   instantiate_entities = function ()
    m_tp(538, 79, 46, 5, 5, "antibes", 'bus',trig_btn_hud,"❎")
    m_tp(425, 56, 46, 15, 10, "carrouffe",  "entrance", trig_dist_hud,"⬆️")
    m_tp(504, 56, 46, 15, 10, "carrouffe",  "entrance", trig_dist_hud,"⬆️")
    m_tp(465, 56, 46, 15, 10, "carrouffe",  "entrance", trig_dist_hud,"⬆️")
    m_tp(546, 177, 46, 15, 10, "leonardoenergy",  "entrance", trig_dist_hud,"⬆️")
    m_tp(569, 177, 46, 15, 10, "leonardoenergy",  "entrance", trig_dist_hud,"⬆️")
   end
  },
  valbonne = {
   tag = outside,
   name = "valbonne (c)",
   map = {x1 = 625, y1 = -10, x2 = 688, y2 = -9},
   spawns = {
    bus = { x = 777, y = 53 },
    thelas = { x = 693, y = 55 }
   },
   instantiate_entities = function ()
    m_tp(785, 55, 46, 5, 5, "valbonne", "bus",trig_btn_hud,"❎")
    m_tp(689, 40, 46, 15, 10, "thelas",  "entrance", trig_dist_hud,"⬆️")
    m_tp(729, 40, 46, 15, 10, "thelas",  "entrance", trig_dist_hud,"⬆️")
    local npc_st_valbonne = {}
    npc_st_valbonne = m_npc(712,43,195)
    npc_st_valbonne:create_dialogs({
     n_dialog("j'ai entendu dire que le drh de cet entreprise… thelas ❎",trigger(200, trig_time)),
     n_dialog("est assez rude avec ses recrues. ❎",trigger(200, trig_time)),
     n_dialog("sois bien prete avant d'y entrer. ❎",trigger(200, trig_time)),
     n_dialog("je te conseille d'avoir effectue deux stages auparavant. ❎",trigger(200, trig_time)),
    })
   end
  },
  capgemo = {
   tag = inside,
   name = "capgemo",
   map = {x1 = 206, y1 = 258, x2 = 294, y2 = 258},
   spawns = { entrance = { x = 260, y = 360 }},
   instantiate_entities = function ()
    m_tp(257, 375, 46, 15, 10, "biot", "capgemo", trig_dist_hud,"⬇️")
    local npc_drh_capgemo_biot = {}
    npc_drh_capgemo_biot = m_npc(346,425,204,boss)
    npc_drh_capgemo_biot:create_dialogs({
     n_dialog("présentez vous ! ❎",trigger(200, trig_time)),
    })
    local npc_st_capgemo_biot = {}
    npc_st_capgemo_biot = m_npc(349,304,195)
    npc_st_capgemo_biot:create_dialogs({
     n_dialog("tu vas passer un entretien a capgemo ? ❎",trigger(200, trig_time)),
     n_dialog("tu n'as pas l'air si douee que ça. ❎",trigger(200, trig_time)),
     n_dialog("laisse-moi t'evaluer rapidement. ❎",trigger(200, trig_time)),
    })
   end
  },
  leonardoenergy = {
   tag = inside,
   name = "leonardo energie",
   map = {x1 = 402, y1 = 256, x2 = 563, y2 = 256},
   spawns = { entrance = { x = 444, y = 360 }},
   instantiate_entities = function ()
    m_tp(441, 374, 46, 15, 10, "antibes", "leonardoenergy", trig_dist_hud,"⬇️")
    local npc_drh_leonardo_antibes = {}
    npc_drh_leonardo_antibes = m_npc(638,344,204,boss,100,true,g_weapons[8])
    npc_drh_leonardo_antibes:create_dialogs({
     n_dialog("hola ! qu'est-ce qu'on a la ? ❎",trigger(200, trig_time)),
     n_dialog("vous cherchez un stage hein ? ❎",trigger(200, trig_time)),
     n_dialog("et qu'est ce qui vous fait dire que vous sortez de la masse d'etudiants qui postulent chez nous ? ❎",trigger(200, trig_time)),
     n_dialog(" j'espere que vous avez prepare cet entretien ! je n'aime pas du tout perdre mon temps… ❎",trigger(200, trig_time)),
    })
   end
  },
  thelas = {
   tag = inside,
   name = "thelas",
   map = {x1 = 821, y1 = -30, x2 = 960, y2 = 107},
   spawns = { entrance = { x = 868, y = 180 }},
   instantiate_entities = function ()
    m_tp(864, 192, 46, 15, 10, "valbonne", "thelas", trig_dist_hud,"⬇️")
    local npc_thelas_drh_valbonne = {}
    npc_thelas_drh_valbonne = m_npc(999,53,198,boss,100,true,g_weapons[6])
    npc_thelas_drh_valbonne:create_dialogs({
     n_dialog("zzzzz… zzzzz… zz… hein ? quoi ? quelqu'un ! ❎",trigger(200, trig_time)),
     n_dialog("ici ? mais ca fait des mois que personne ne s'est presente ici pour un stage ! ❎",trigger(200, trig_time)),
     n_dialog("personne n'en a encore ete digne ! mais… ❎",trigger(200, trig_time)),
     n_dialog("attendez, oui c'est bien vous ! j'ai entendu parler de vous. ❎",trigger(200, trig_time)),
     n_dialog("mais thelas n'accepte que l'lite vous le savez ! ❎",trigger(200, trig_time)),
     n_dialog("parlez-moi de ce dont vous etes capable. presentez-vous ! ❎",trigger(200, trig_time)),
    })
   end
  },
  sophiatechest = {
   tag = inside,
   name = "sophiatech batiment est",
   map = {x1 = 602, y1 = 122, x2 = 695, y2 = 129},
   spawns = { entrance = { x = 717, y = 227 }},
   instantiate_entities = function ()
    m_tp(713, 239, 46, 15, 10, "biot", "sophiatechest", trig_dist_hud,"⬇️")
    local npc_daminaca_bestcorp = {}
    npc_daminaca_bestcorp = m_npc(772,176,201,boss,100,true,g_weapons[2])
    npc_daminaca_bestcorp:create_dialogs({
     n_dialog("hein ? vous voulez etre directrice de sophiatech ? ❎",trigger(200, trig_time)),
     n_dialog("hmm… vous etes donc venus a sophia dans le seul but de me remplacer dans ma fonction… ❎",trigger(200, trig_time)),
     n_dialog("je vois. votre plan est temeraire. eh bien pour cela, ❎",trigger(200, trig_time)),
     n_dialog("vous allez devoir surpasser mes connaissances ! montrez-moi ce que vous savez faire ! ❎",trigger(200, trig_time)),
    })
   end
  },
  sophiatechouest = {
   tag = inside,
   name = "sophiatech batiment ouest",
   map = {x1 = 682, y1 = 256, x2 = 918, y2 = 256},
   spawns = { entrance = { x = 724, y = 360 }},
   instantiate_entities = function ()
    m_tp(721, 376, 46, 15, 10, "biot", "sophiatechouest", trig_dist_hud,"⬇️")
   end
  },
  sophiatechru = {
   tag = inside,
   name = "sophiatech restaurant",
   map = {x1 = 96, y1 = 258, x2 = 96, y2 = 258},
   spawns = { entrance = { x = 132, y = 335 }},
   instantiate_entities = function ()
    m_tp(129, 352, 46, 15, 10, "biot", "sophiatechru", trig_dist_hud,"⬇️")
   end
  },
  carrouffe = {
   tag = inside,
   name = "carrouffe",
   map = {x1 = -27, y1 = 259, x2 = -27, y2 = 259},
   spawns = { entrance = { x = 43, y = 387 }},
   instantiate_entities = function ()
    m_tp(40, 367, 46, 15, 10, "antibes", "carrouffe", trig_dist_hud,"⬇️")
   end
  }
 }
end

function init_screen()
 g_scr = {x = 0, y = 0, shake = 0, intensity = 2}
end

function n_entitie(x, y, sprite, tag, health, direction, mvn)
 return {
  x = x,
  y = y,
  s = sprite,
  tag = tag,
  health = health or immortal_object,
  direction = direction or down,
  mvn = mvn or {}
 }
end

function n_dfx(pattern, draw, cd)
 return {
  pattern = pattern or function (self) end,
  draw = draw or function (self) end,
  cd = cd or 100
 }
end

function n_weapon(name, sprite, sfx, anim, cd, dmg, type, speed, hitbox, offsetx, offsety)
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

function n_dialog(text, trigger)
 return {
  text = text,
  is_triggered = to_trigger,
  base_triggered = trigger.type,
  arg = trigger.arg
 }
end

function trigger(arg, type)
 return {arg = arg, type = type}
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
  g_p.control = controls_pl
  if(self.actor.furymode) go_in_fury(self.actor)
 end
end

function go_in_fury(a)
 a.weapon = a.weapon_in_pocket
 a.control = controls_enn
 a.tag = ennemy
end

function trig_time(self)
 self.arg -= 1
 return self.arg <= 0
end

function m_game()
 m_weapons()
 init_current_area("biot","bus")
 m_pl(g_spawn.x, g_spawn.y, 192)
end

function m_weapon(t)
 local item = {
  name = t.wpm.name,
  spr = t.wpm.sprite,
  animh = t.wpm.anim.h,
  animv = t.wpm.anim.v,
  cd = t.wpm.cd,
  speed = t.wpm.speed,
  dmg = t.wpm.dmg,
  type = t.wpm.type,
  hb = t.wpm.hitbox,
  ox = t.wpm.offsetx,
  oy = t.wpm.offsety,
  sfx = t.wpm.sfx,
  dfx = t.dfx.pattern,
  draw = t.dfx.draw,
  cdfx = t.dfx.cd
 }
 add(g_weapons, item)
end


function m_hud(t)
  local hud = {
    control = t.control,
    draw = t.draw,
    selected = 1
  }
  add(g_menus, hud)
end

function m_actor(t)
 local actor = {
  tag = t.en.tag,
  d = t.en.direction or none,
  bx = t.en.x,
  by = t.en.y,
  x = t.en.x,
  y = t.en.y,
  s = t.en.s,
  health = t.en.health,
  control = t.control,
  draw = t.draw,
  weapon = t.weapon or nil,
  box = t.box,
  dx = t.en.mvn.dx or 0.9,
  dy = t.en.mvn.dy or 0.9,
  cd = 0,
  cdfx = 0
 }
 add(g_actors, actor)
 return actor
end

function m_weapons()
 m_weapon({
  wpm = n_weapon("laptop", 104, 8, {h = 72, v = 88}, 20, 15, melee, 2, 8, 5, -5),
  dfx = n_dfx(dfx_thunder, draw_thunder, 100)
 })
 m_weapon({
  wpm = n_weapon("justice", 105, 4, {h = 73, v = 89}, 15, 7, melee, 2, 8, 5, -4),
  dfx = n_dfx()
 })
 m_weapon({
  wpm = n_weapon("feu", 106, 1, {h = 74, v = 90}, 8, 8, ranged, 3, 3, 5, -4),
  dfx = n_dfx()
 })
 m_weapon({
  wpm = n_weapon("diplomatie", 107, 5, {h = 75, v = 91}, 3, 3, ranged, 10, 2, 5, -5),
  dfx = n_dfx()
 })
 m_weapon({
  wpm = n_weapon("arc", 108, 3, {h = 76, v = 92}, 6, 5, ranged, 6, 3, 5, -5),
  dfx = n_dfx()
 })
 m_weapon({
  wpm = n_weapon("biohazard", 109, 6, {h = 77, v = 93}, 4, 5, ranged, 5, 1, 5, -5),
  dfx = n_dfx(dfx_waterfall, draw_waterfall, 100)
 })
 m_weapon({
  wpm = n_weapon("tatata", 110, 7, {h = 78, v = 94}, 2, 2, ranged, 10, 1, 5, -5),
  dfx = n_dfx()
 })
 m_weapon({
  wpm = n_weapon("boom", 111, 8, {h = 79, v = 95}, 18, 10, melee, 2, 8, 5, -4),
  dfx = n_dfx(dfx_explosion, draw_explosion, 100)
})
end

function m_npc(x, y, s, tag ,health, fury, weapon)
 local health = health or l_ennemy
 local n = m_actor({
  en = n_entitie(x, y, s, npc, health, down),
  control = controls_npc,
  draw = draw_characters,
  box = {x1 = 0, y1 = 8, x2 = 7, y2 = 15},
 })
 n.anim = stay
 n.walk = m_anim(m_walk_anim(s))
 n.stay = m_anim(m_stay_anim(s))
 n.create_dialogs = create_dialogs
 n.furymode = fury or true
 n.weapon_in_pocket = weapon or g_weapons[1]
 n.super = tag or npc
 return n
end

function m_pl(x, y, s)
 g_p = m_actor({
  en = n_entitie(x, y, s, pl, l_pl),
  control = controls_pl,
  draw = draw_characters,
  box = {x1 = 0, y1 = 7, x2 = 7, y2 = 14},
  weapon = g_weapons[1]
 })
 g_p.anim = stay
 g_p.walk = m_anim(m_walk_anim(s))
 g_p.stay = m_anim(m_stay_anim(s))
 g_p.coins = 0
 g_p.current_area = 1
end

function m_enn(x, y, s)
 local e = m_actor({
  en = n_entitie(x, y, s, ennemy, l_ennemy, up, {dx = 0.9, dy = 0.9}),
  control = controls_enn,
  draw = draw_characters,
  box = {x1 = 0, y1 = 8, x2 = 7, y2 = 15},
  weapon = g_weapons[5]
 })
 e.anim = stay
 e.walk = m_anim(m_walk_anim(s))
 e.stay = m_anim(m_stay_anim(s))
end

function m_loot(x, y, item)
 local i = m_actor({
  en = n_entitie(x+((rnd(2)-1)*10), y+((rnd(2)-1)*10), item.s, invisible),
  control = controls_loot,
  draw = draw_item,
  box = {x1 = 0, y1 = 0, x2 = 6, y2 = 6},
 })
 i.obj = item.obj
end


function trig_btn_hud(self, dist)
 if(btnp(fire2) and dist < 7) then
  m_hud({control = controls_tp, draw = draw_tp})
 end
end

function trig_dist_hud(self, dist)
  if (dist < 5) then
   init_current_area(self.linkto, self.spawn)
  end
end


function m_tp(x, y, s, w, h, link, spawn, trigger, hint)
 local n = m_actor({
  en = n_entitie(x, y, s, invisible, invisible, down),
  control = controls_doors,
  draw = draw_item,
  box = {x1 = 0, y1 = 0, x2 = w, y2 = h},
 })
 n.linkto = link
 n.spawn = spawn
 n.trigger = trigger
 n.sign = hint
 return n
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

function m_walk_anim(s)
 return {
  name = walk,
  frames = create_direction_frames(s+33, s+1, s+33, s+1, s+34, true, s+32, true),
  speed = 1/10
 }
end

function m_stay_anim(s)
 return {
  name = stay,
  frames = create_direction_frames(s+1, s+1, s+1, s+1, s+2, false, s, false),
  speed = 1/10
 }
end

function m_anim(anim)
 return {
  time = 0,
  anim = anim.name,
  spd = anim.speed,
  f = anim.frames
 }
end

function m_particles(a, n, c)
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

function format_text(text)
 local ftext = ""
 local offsety = 0
	local g = false
	for i=1, #text do
		ftext = ftext..sub(text, i,i)
		if (i%14 == 0 or g) then
			g = true
   if (sub(text, i,i) == " ") then
    offsety -= 3
    ftext = ftext.. "\n"
				g = false
			end
		end
 end
 return {text = ftext, offset = offsety}
end

function m_dialog(self, dialog, margin)
 local margin = margin or "default"
 local dialog = dialog or self.dialogs[self.line]
 local t = format_text(dialog.text)
 local x = self.x + (self.box.x2 / 4)
 local y = self.y - 10 + t.offset
 if (margin == "center") then
  x = g_fp.x + 32
  y = g_fp.y + 40
 end
 local n_dialog = {
  x = x,
  y = y,
  text = t.text,
  is_triggered = dialog.is_triggered,
  base_triggered = dialog.base_triggered,
  arg = dialog.arg,
 }
 if (self.talking) then
  n_dialog.actor = self
  self.talking = false
  self.next = false
 end
 add(g_dialogs, n_dialog)
end

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

function create_direction_frames(fl1, fl2, fr1, fr2, fu, fuflip, fd, fdflip)
 return {
  {{f = fl1, flip = true  },{f = fl2, flip = true }},
  {{f = fr1, flip = false },{f = fr2, flip = false}},
  {{f = fu,  flip = false },{f = fu,  flip = fuflip }},
  {{f = fd,  flip = false },{f = fd,  flip = fdflip }}
 }
end

function controls_loot(self)
 local dist = distance(self)
 if (dist < 8) then
  if(self.obj == "heal" and g_p.health < l_pl) then
   g_p.health += 10
   if (g_p.health > l_pl) g_p.health = l_pl
   sfx(2)
   del(g_actors,self)
  end
  if(self.obj == "coin") then
   g_p.coins += 1
   sfx(2)
   del(g_actors,self)
  end
 end
end

function controls_hud(self)
  local top_hud = g_menus[#g_menus]
  is_inventory_closed(top_hud)
  top_hud:control()
end

function controls_pl_inv(self)
 menu_selection(self,#g_weapons)
 if (btnp(fire1)) then
  g_p.weapon = g_weapons[self.selected]
  g_p.cd = 10
  del(g_menus,self)
 end
end

function controls_tp(self)
 menu_selection(self, #g_area_keys)
 if (btnp(fire1)) then
  init_current_area(g_area_keys[self.selected], "bus")
  g_p.cd = 10
  del(g_menus,self)
 end
end

function menu_selection(self,max)
  if (btnp(up) and self.selected > 1) then
  self.selected -= 1
 end
 if (btnp(down) and self.selected < max) then
  self.selected += 1
 end
end

function hint(self,sign)
 local sign = sign or "❎"
 m_dialog(self, n_dialog(sign, trigger(5, trig_time)))
end

function warning(self)
 m_dialog(self, n_dialog("!", trigger(1, trig_time)))
end

function action_enn(a, d)
 if (a.tag ~= ennemy) return
 if (a.cd > 0) a.cd -= 1
 if (a.cd == 0) then
  shoot(a, d)
  a.cd = a.weapon.cd*2
 end
end

function controls_doors(self)
 local dist = distance(self)
 if (dist < 8) then
  hint(self,self.sign)
 end
 self:trigger(dist)
end



function controls_dialogs(self)
 local a = self.talkto
 if(btnp(fire2)) then
  if(self.talkto.line >= #self.talkto.dialogs) then
   self.control = controls_pl
  else
   a.next = true
  end
 end
 if(btnp(fire1)) then
  self.control = controls_pl
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
 if (dist < 10) then
  if(self.talking) m_dialog(self, nil, "center")
  if (self.hint) hint(self)
 end
end

function controls_enn(self)
 local dist = distance(self)
 if(is_pl_near(dist)) then
  warning(self)
  self.anim = walk
  if (dist >= self.weapon.type) then
   local dir_m = going_forward(self)
   move_on(self, dir_m)
  end
 elseif (dist < self.weapon.type*8.2) then
  local dir_m = get_best_direction(self)
  move_on(self, dir_m)
  local dir_a = prepare_attack_opportunity(self)
  self.d = dir_a
  action_enn(self, dir_a)
 else
  self.anim = stay
 end
end

function controls_pl(self)
 self.anim = walk
 if (is_moving(left))  move(self,-1, 0, self.box.x1, self.box.y2)
 if (is_moving(right)) move(self, 1, 0, self.box.x2, self.box.y2)
 if (is_moving(up))    move(self, 0,-1, self.box.x2, self.box.y2-self.box.y1)
 if (is_moving(down))  move(self, 0, 1, self.box.x2, self.box.y2)
 if (is_not_moving())  self.anim = stay
 action_pl()
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

function is_pl_near(gap, lim)
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
 end
 if (distance(target.enn) > limit) target.enn = nil
 if (distance(target.npc) > limit) target.npc = nil
 return target
end

function move_on(a, go)
 if (go == left)  move(a ,-a.dx, 0, a.box.x1, a.box.y2)
 if (go == right) move(a, a.dx, 0, a.box.x2, a.box.y2)
 if (go == up)    move(a, 0 ,-a.dy, a.box.x2, a.box.y2-a.box.y1)
 if (go == down)  move(a, 0, a.dy, a.box.x2, a.box.y2)
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
 local y1 = max(a.box.y1 + a.y, a.y + y + ((oy/2) * y) + oy/2 + (1*abs(x)))
 local x2 = (a.x + x + ox)
 local y2 = max(a.box.y1 + a.y, a.y + y + oy)
 log(6, x1..":"..y1)
 log(7, x2..":"..y2)
 g_cl = {x1=x1,y1=y1,x2=x2,y2=y2}
 local sp1 = mget(get_tile(x1), get_tile(y1))
 local sp2 = mget(get_tile(x2), get_tile(y2))
 if(is_limit_of_map(x1,y1) or is_limit_of_map(x2,y2)) return

 for b in all(g_actors) do
  if(check_collisions(a, b, x, y) and b.tag ~= invisible and b.tag ~= item) then
   return
  end
 end

 if (not fget(sp1, f_obst) and not fget(sp2, f_obst))  then
  a.x += x
  a.y += y
 end
end

function action_pl()
 if (g_p.cd > 0) g_p.cd -= 1
 if ((g_p.cd == 0) and btn(fire1)) then
  shoot()
  g_p.cd = g_p.weapon.cd
 end
 if (g_p.cdfx > 0) g_p.cdfx -= 1
 local item_near = fget(mget(get_tile(g_p.x) ,get_tile(g_p.y + g_p.box.y1)), f_inv)
 if (btnp(fire2)) then
  local tile = mget(get_tile(g_p.x+((g_p.box.x2-g_p.box.x1)/2)) ,get_tile(g_p.y + (g_p.box.y1/2)))
  if (fget(tile, f_inv)) then
   m_hud({control = controls_pl_inv, draw = draw_pl_inv})
  else
  local target = target_nearest_one(30)
   if (target.enn ~= nil and g_p.cdfx == 0) then
    g_p.cdfx = g_p.weapon.cdfx
    g_p.weapon.dfx(target.enn.x, target.enn.y, 3, abs(g_fp.y - target.enn.y), g_p.weapon.draw)
    target.enn.health -= 20
    check_actor_health(target.enn)
   elseif (target.npc ~= nil and distance(target.npc) < 10) then
    begin_dialog(target.npc)
   else
    sfx(9)
   end
  end
 end
end

function is_inventory_closed(a)
 if (btnp(fire2)) then
  del(g_menus,a)
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

function anim_pl(a)
	if(a.anim == stay) then
		return anim_state(a, a.stay)
	else
		return anim_state(a, a.walk)
	end
end

function get_tile(a)
 return ((a - (a % 8)) / 8)
end

function is_limit_of_map(x, y)
 return not (x > g_map.x1
 and x < g_map.x2+128
 and y > g_map.y1
 and y < g_map.y2+128)
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
   x = a.x-6,
   y = a.y+4,
   s = a.weapon.animh,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   box = {x1 = 0, y1 = 4-center, x2 = 5, y2 = 4 + center},
   mvn = {dx = -speed, dy = 0},
   direction = left
  })
 end
 if(d == right) then
  fire({
   x = a.x+6,
   y = a.y+4,
   s = a.weapon.animh,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   box = {x1 = 0, y1 = 4 - center, x2 = 5, y2 = 4 + center},
   mvn = {dx = speed, dy = 0},
   direction = right
  })
 end
 if(d == up) then
  fire({
   x = a.x,
   y = a.y-3,
   s = a.weapon.animv,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   box = {x1 = 4 - center, y1 = 0, x2 = 4 + center, y2 = 8},
   mvn = {dx = 0, dy = -speed},
   direction = up
  })
 end
 if(d == down) then
  fire({
   x = a.x,
   y = a.y+17,
   s = a.weapon.animv,
   dmg = a.weapon.dmg,
   type = a.weapon.type,
   box = {x1 = 4 - center, y1 = 3, x2 = 4 + center, y2 = 8},
   mvn = {dx = 0, dy = speed},
   direction = down
  })
 end
 if (d ~= none or a.tag == pl) then
  sfx(a.weapon.sfx)
 end

end

function fire(en)
 local b = m_actor({
  en = n_entitie(en.x, en.y, en.s, bullet, immortal_object, en.direction, en.mvn),
  control = controls_bullets,
  draw = draw_bullets,
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

function draw_border_on_entities(en, x, y, c)
	for i=1, 16 do
		pal(i, c)
 end
 spr(en.f, x,   y+1, 1, 2, en.flip, false)
 spr(en.f, x,   y-1, 1, 2, en.flip, false)
 spr(en.f, x-1, y,   1, 2, en.flip, false)
 spr(en.f, x+1, y,   1, 2, en.flip, false)
 pal()
 palt(black,false)
 palt(pink,true)
 spr(en.f, x,   y,   1, 2, en.flip, false)
end

function get_box(a)
 return {
  x1 = a.x + a.box.x1,
  y1 = a.y + a.box.y1,
  x2 = a.x + a.box.x2,
  y2 = a.y + a.box.y2
 }
end

function check_collisions(a, b, n_x, n_y)
 local n_x = n_x or 0
 local n_y = n_y or 0
 if(a == b or a.tag == b.tag) return false
 local box_a = get_box(a)
 local box_b = get_box(b)
 if (box_a.x1 + n_x > box_b.x2 or
     box_a.y1 + n_y > box_b.y2 or
     box_b.x1 > box_a.x2 + n_x or
     box_b.y1 > box_a.y2 + n_y ) then
  return false
 end
 return true
end

function is_dead(a)
 if(a.health <= 0) then
  drop_loot(a)
  return true
 end
 return false
end

function drop_loot(a)
 local rndv = flr(rnd(100))
 for o in all(g_loots) do
  if(o.drop_rate <= rndv) m_loot(a.x, a.y, o)
 end
 if(a.super == boss) then
  for _=1,5 do
   m_loot(a.x, a.y, g_loots[2])
  end
 end
end

function check_actor_health(damaged_actor)
 if (is_dead(damaged_actor)) then
  dfx_disapearance(damaged_actor.x, damaged_actor.y, flr((rnd(5)+1)), nil, draw_explosion)
  screenshake(5)
  if (damaged_actor.super == boss) g_to_win -= 1
  del(g_actors, damaged_actor)
 end
end

function controls_collisions()
 for a in all(g_actors) do
  for b in all(g_actors) do
   if (check_collisions(a, b)) then
    if (a.tag == bullet and (b.tag == pl or b.tag == ennemy)) then
     b.health -= a.dmg
     local damaged_actor = b
     m_particles(b, 10, 5)
     del(g_actors, a)
     check_actor_health(damaged_actor)
    end
   end
  end
 end
end

function printoutline(t,x,y,c)
  for xoff=-1,1 do
    for yoff=-1,1 do
      print(t,x+xoff,y+yoff,0)
    end
  end
  print(t,x,y,c)
end

function rnd_color(colors)
 local rndv = flr(rnd(1000))
 for m=1 ,#colors do
  if (rndv >= 100/m+1) return colors[m]
 end
 return colors[1]
end

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
  for r=self.x-(self.p/2), self.x+(self.p/2)do
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
 draw_border_on_entities(anim_pl(self), self.x, self.y, black)
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
 palt(black,false)
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
 draw_coins(g_fp.x+110, g_fp.y+112)
 for m in all(g_menus) do
  m:draw()
 end
 draw_results()
end

function draw_results()
  if(g_to_win < 1) then
    printoutline("bravo", g_p.x,g_p.y,white)
  end
end

function draw_coins(x, y)
 spr(g_loots[2].s, x, y)
 printoutline(g_p.coins,x-5,y-5,white)
end

function draw_life(bx, by)
 local offsetlife = #spr_life - flr(((g_p.health * #spr_life) / l_pl))
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
 map(0, 0, 0, 0, 16, 16)
 print("sophia quest", 35, 75, white)
 print("press x+c", 50, 90, white)
end

function draw_tp(self)
  local x1 = g_fp.x+32
  local y1 = g_fp.y+32
  local x2 = g_fp.x+118
  local tx = x1 + 7
  local ty = y1 + 10
  rectfill(x1, y1, x2, y1 + (#g_area_keys*10) + 15, dark_blue)
  for k in all(g_area_keys) do
   print(k, tx + 12, ty - 2, white)
   if (g_area_keys[self.selected] == k) then
    spr(58, tx - 7, ty - 2)
   end
   ty += 12
  end
end

function draw_pl_inv(self)
  local x = g_fp.x+80
  local y = g_fp.y
  rectfill(x, y, x + 48, y + 128, dark_blue)
  line(x, y, x, y + 128, light_gray)
  local tx = x + 7
  local ty = y + 10
  for i = 1 ,#g_weapons do
   draw_item_shape(tx, ty, g_weapons[i].spr)
   print(g_weapons[i].name, tx + 12, ty - 2, white)
   if (self.selected == i) then
    spr(58, tx - 7, ty - 2)
   end
   ty += 12
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
 follow_pl()

 cls()
 map(0, 0, 0, 0, 128, 47)

 set_camera()

 draw_actors()
 draw_dfxs()
 draw_dialogs()
 draw_hud()
 log(4, g_p.x..":"..g_p.y)
 log(5, #g_actors)
 debug_log(g_fp.x+10, g_fp.y+10)
 log_cpu_mem(g_fp.x+70, g_fp.y+5)
 display_collision_matrix()
end

function update_menu()
 if (btn(fire1) and btn(fire2)) then
  _update = update_game
  _draw = draw_game
  g_p.cd = 10
 end
end

function update_game()
 if (#g_menus < 1) then
  controls_update()
  controls_collisions()
 else
  controls_hud()
 end
 check_game_state()
end

function controls_update()
 for a in all(g_actors) do
  a:control()
 end
end

function get_formalised_position(mina, maxa, a)
 return max(mina, min(maxa, a-64))
end

function lerp(a,b,t)
 return (1-t)*a + t*b
end

function follow_pl()
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
 if (is_dead(g_p)) then
  cls()

  g_actors = {}
  g_dfx = {}
  g_weapons = {}
  g_dialogs = {}

  m_game()
  reset_camera()
  _draw = draw_menu
  _update = update_menu
 end
end

function screenshake(n)
 g_scr.shake = n
end

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

__gfx__
000000007777777733bb3b3b517711550000000075577557a555555a000000000000000000000000000000000000000000000000000000000555555555555550
0000000055555555bbbbb3b3517171550dd7ddd075577557a55555a50066666666666666666666005066666666666666666666050d7dddd00000000000000000
0070070055555555b33bbbbb517711550d7dddd075577557a5555a550600000000000000000000605066666666666666666666050dddddd00000000000000000
00077000777777773bbb3b33517171550dddddd075577557a555a5550660666066606660666066605066666666666666666666050dddddd00555555555555550
0007700077777777bb3b43bb517711550dddddd075577557a55a55550606060606060606060606605066666666666666666666050ddddd700555555555555550
0070070055555555bbb4b3b3511111550dddd7d075577557a5a555550666606660666066606660605066666666666666666666050d7dddd00000000000000000
0000000055555555b3bb4bbb517171550ddd7dd075577557aa55555506060606060606060606066050666666666666666666660507ddddd00000000000000000
00000000777777773b3b4bb3517771550dddddd075577557a5555555066066606660666066606660506666666666666666666605000000000555555555555550
000000005555555555555555511111550d5555d0555555555557555506060606060606060606066050666666666666666666660500dd1666666666666661dd00
665656565555555555555555517771550d7dddd0555775555557555506666066606660666066606050666666666666666666660550dd1666dddddddd6661dd05
656565655555555555555555517111550dddddd0555775555557555506060606060606060606066050666666666666666666660550dd1666dddddddd6661dd05
665656565777777555555555511771550dddddd0555775555557555506606660666066606660666050666666666666666666660550dd1666dddddddd6661dd05
656565655777777555555555617771660dddddd0555775555557555506060606060606060606066050666666666666666666660550dd1666dddddddd6661dd05
665656565555555555555555666066660ddd7dd0555775555557555506666066606660666066606050666666666666666666660550dd1666dddddddd6661dd05
656565655555555555555555777077770dd7ddd0555775555557555506060606060606060606066050666666666666666666660550dd1666dddddddd6661dd05
665656565555555555555555000000000d7dddd0555555555557555506606660666066606660666050666666666666666666660550dd1666dddddddd6661dd05
65656565333333330000000033333bbbbbb3333377777777777755550606060606060606060606607000000670555506eeeeeeee50dd1666eeeeeeee6661dd05
6656565633333b33665666563333bb3bbbbbb33355555555555755550666606660666066606660607055550670555506eeeeeeee50dd1666eeeeeeee6661dd05
65656565333b3b3366566656333bb3bb3b3bbb3355555555555755550606060606060606060606607055550670555506eeeeeeee50dd1666eeeeeeee6661dd05
66565656333333336656665633bbbbbbb3bbbbb355555555555755550660666066606660666066607055550670555506eeeeeeee50dd1666eeeeeeee6661dd05
6565656533333333665666563bb333bbbbbbbbb355555555555755550606060606060606060606607055550670555506eeeeeeee50dd1666eeeeeeee6661dd05
665656563b3333b3665666563bbbb33bbbbbb3bb55555555555755550600000000000000000000607055550670555506eeeeeeee50dd1666eeeeeeee6661dd05
656565653b3333b366566656bb33bbbbbb333bbb55555555555755550066666666666666666666007055550670555506eeeeeeee50dd1666eeeeeeee6661dd05
0000000033333333665666563b3bb444bbbbbbb355555555555755550600000000000000000000606055550660000006eeeeeeee50dd1666eeeeeeee6661dd05
55bbb5b533333333665666563bbbbb4bbbbbbbb35557777777777777000880000000000098888898eceeeeee77777776eeeeeeee000000004444444470555506
5b3b3b5533333a336656665633b3b44bb44b3b3355575555555755550089980006666660855dd558ecceeeee77777776eeeeeeee2355dd450000000070555506
5bb3b3b53333a9a3665666563b3bbb24b4bbb3b35557555555575555089aa98007667660855d5d58eccceeee77777776eeeeeeee235511454443141970555506
55b34b5533333a3366566656b3bbbb2444bbbb3b555755555557555589aaaa9806766760855565d8ecccceee77777776eeeeeeee234411452243141970555506
5111111533333333665666563333b344443b33335557555555575555089aa9800666666085565dd8eccc1eee77777776eeeeeeee000000000000000070555506
51711115338333336656665633333324443333335557555555575555018998100000000081655558ecc1eeee77777776eeeeeeeecc79922a6163dc8470555506
5111111538283333665666563333322444433333555755555557555501188110444004448c155558ec1eeeee77777776eeeeeeeecc7992296163dc8470555506
55111155338333330000000033333334244333335557555555575555001111000000000098888889e1eeeeee66666666eeeeeeee000000000000000060555506
000000000000000000000000000000005555555555555555ffffffff44444444eeeebbeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
07770777777777077777777004444440558aaaaaaaaaa855ffffffff44444444aeeebeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee58e58e568865e
07660666666666066666667004444440588aaaaaaaaaa885ffffffff44444444aeeebeeeeeeec51eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeeeeeeee56899865
07660666666666066666667004444440aaaaaaaaaaaaaaaaffffffff44444444aaeeeeeeeeeec51eeee88eeeeeeeeeee7eeeee5ecccccccee58eeeee689aa986
07665555555555555555000004444440aaa0000000000aaaffffffff44444444eaaeeeeeeeeec51eeee898eeeee558eee74444551111111ceeee58ee689aa986
07665555555555555555667004444440aa000000000000aa4444444444444444eeee333eeeeec51eeee88eeeeeeeeeee7eeeee5eccccccceeeeeeeee56899865
07665555555555555555667004444440aa000000000000aa444444444444444488eeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeee58ee58e568865e
07665555555555555555667004044440aaa0000000000aaa4444444444444444eeeeeeeeeec551eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5665ee
07665555636363665555667004444440a0aaaaaaaaaaaa0a2666666644444444eeeebbeeeeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeeeceeeeee8e8eeeee5665ee
00005555663339365555667004444440a00aaaaaaaaaa00a26666666444444449eeebeeee111111eeeeeeeeeeeeeeeeeee555eeeeeccceeeee5e5eeee568865e
07665555633b33365555667004444440aaaaaaaaaaaaaaaa26666666444444449eeebeee15555551eee8eeeeeee8eeeeeee4eeeeecc1cceeeeeeeeee56899865
076655556363b3635555667004444440a00aaaaaaaaaa00a244444464444444499eeeeee55cccc55ee898eeeeee5eeeeeee4eeeeeec1ceeeeee8e8ee689aa986
07665555611111165555667004444440a00aaaaaaaaaa00a2444444622222222e99eeeee5ceeeec5ee888eeeeee5eeeeeee4eeeeeec1ceeee8e5e5ee689aa986
07665555611711165555667004444440a0aaaaaaaaaaaa0a6222222620000002eeeeaaaeceeeeeeceeeeeeeeeeeeeeeeeee7eeeeeec1ceeee5eeeeee56899865
07665555661111665555000004444440aaaaaaaaaaaaaaaa626666262000000288eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7e7eeeeec1ceeeeeee8eeee568865e
07665555661111665555667004444440aaa0000000000aaa6266662620000002eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec1ceeeeeee5eeeee5665ee
07665555555555555555667070111106aa000000000000aa2222111166666666eeeeeee0eeee1eeeeee8eeeeeeeeeeeeeeee4eeeeeee8eeeeeeeeeeeee888eee
07665555555555555555667070111106aa000000000000aa2222111176666667eeeeeee0eeec1eeeee828eeeeeeeeeeeeeede4eeeee88eeeeeeeeeeeee888eee
07665555555555555555667070111106aa000000000000aa2222111177666677eeeeeee0eeec1eeeee48eeeeeeee8eeeeeedee4ee5555511eeee8eeeee8d8eee
00005555555555555555667070111106aaa0000000000aaa2222111177766777eeeeeee0eeec1eeeeee4eeeeee55559eeeedee4ee5555511e5555a55ee8d8eee
07666666606666666660667070111106aaaaaaaaaaaaaaaa2222111177766777eeeeeee0eeec1eeeee4eeeeeeeddeeeeeeedee4eeeddeeeeeeddeaaeee8d8eee
07666666606666666660667070111106aaaaaaaaaaaaaaaa2222111177666677eeeeeee0eeec1eeeeee4eeeeeedeeeeeeeede4eeeedeeeeeeedeeaaeeedddeee
07777777707777777770777070111106566aaaaaaaaaa6652222111176666667e1111115eeeceeeeeee4eeeeeeeeeeeeeeee4eeeeeeeeeeeeeeeeeeeeeedeeee
000000000000000000000000601111065566aaaaaaaa6655222211116666666600000055eee5eeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeee
555555551111111155555555622222265550055566666662ee0550ee666666755022226200000000000000000000000066666666000000007707707700000000
555555551111111165555556622222265550055566666662ee0550ee66666675502222620000000007777770077777706666666666666666777cc77700000000
555555551111111166555566622222265550055566666662ee0550ee6666667550222262ffffffff0777777007077770666666666666666677cccc7700000000
555555551111111166655666644444465550055564444442ee0550ee6666667550666666ffffffff077777700707777066666666666666666777777600000000
555555551111111166655666644444465550055564444442ee0550ee6666667550226222ffffffff0000000007777770666666669696c6366677776600000000
000000001111111166555566622222265550055562222226ee0550ee6666667550226222ffffffff0777777007777770666666669696c6966666666600000000
111111111111111165555556626666265550055562666626ee0550ee6666667550226222ffffffff070777700777777066666666868696566666666600000000
111111111111111155555555626666265556655562666626ee0000ee6666667050666666ffffffff077777700000000066666666000000006666666600000000
5252525252525252525252520000666666666666666666666600000000000000000000007474d0d09797d0d09797e3e39797979797d0d0979797979797009797
97d0d0d09797d0d0d09797d0d0d09797d0d0d09797000097d0d0d0d09797d0d0d0d0d0d00097d0d0d0d0d09797d0d0d0d09797d0d0d0d0d09797d0d0d0d09700
a7d7d7d7d7d7d7d7a7000000000066666666666666666666660000009797000097d0d09734346464646464646464d3d364646464646464d3d3d364d3d3006464
64646464646464646464646464646464646464646400006464646464646464646464646400646464646464646464646464646464646464646464646464646400
b7d7d7d7d7d7d7d7b70000000000b1b1f8b1b1f8b1b1f8b1b1000000838397978364648335357676767676767676767676760000002727d3d3d327d3d3002727
27272727272727272727272727272727272727272700001576767676767676767674767700157676767676767676767476760015767676767676767476760000
b3b3b3b3b3b3b3b3b300000000000707070707070707070707000000757583837575757576767676760000747476767676760000002727272727272727002727
27272727272727272727271583271583271583272700007665747665747665747675577700766574766574766574767557770076657476657476767557770000
b3a2b3b3a2b3b3a2b300000000001717171717171717171717000000767675757676767676767676760000343476767674760000002727272765742727002727
27009797979797002727276575276575276575272700007665757665757665757676767797766575766575766575767676770076657576657576767676770000
b3f3b3b3f3b3b3f3b30000000000c7c7c7c7c7c7c7c7c7c7b1000000767676767676767676767676760000353576767674570000002727272765752727002727
27006464646464009797979797979797979797272700007665747665747665747676767664766574766574766574767676770076657476657476767676770000
b3f3b3b3f3b3b3f3b30000000000657557c7657557c7657557000000767676767600979797767676760000767676767675760000002727979797979797002727
27002727272727006464646464646464646464272700007665757665757665757676767676766575766575766575767676760076657576657576767676760000
b3f3b3b3f3b3b3f3b30000000000c7c7c7c7c7c7c7c7c7c7c7000000979776767697838383767676760000767676767676760000002727d364d3d364d3002727
27002727272727006527272727272727272727272700009797979797979797979797769797979797979797979797979776979797979797979797979734979700
b3b2b3b3b2b3b3b2b30000000000657457c7657457c7657457000000646476767664757575767676760000767676767676760000002727d315d3d315d3002727
271527270027270065272700979797979797979797000064d3d3d3a7a76464646464766464646464646464646464646476646464646464646464646435646400
b336b3b336b3b336b30000000000657557c7657557c7657557000000767676767676767676767676760000000000000000000000002727272727272727002783
272727270027270065272700a7a764646464646464000076d3d3d3a7a77676767676767676767676767676767676767676767676767676767676767676767600
b336b3b336b3b336b30000000000c7c7c7c7c7c7c7c7c7c7c7000000767676767676767676760000000000000000000000000000002727979797970027006575
272727270027270065272700a7a77615767683767600006576767676767676767676767676760097979797979797979797979797979797979797979797979700
b3b3b3b3b3b3b3b3b30000000000c7c7c7c7c7c7c7c7c7c7c70000009797e39776769797e3e30000000000000000000000000000002727646464640027979797
97979797972727007676760076767676766574577600006576767676767676009797979776760064646464646464a7a7a7d3d364646464646464646464646400
b3b3b3b3b3b3b3b3b30000000000c7c7f7f7c7c7c7c7c7c7c70000006464d36476766464d3d30000000000000000000000000000002727373737370027646464
64646464642727001576760076767676767675767600000000000000007676006464646476760076767676767676a7a7a7d3d376767676767676767676767600
b3b3b3b3b3b3b3b3b3000000000000f7f7f7f70000000000000000007676d37676767676d3d30000000000000000000000000000002727272727270027272727
15152727272727001576760076767676767676767600007676767676767676001537371576769776767676767676767676767676767600767676767683767600
b3b3b3b3b3f7f7b3b300000000000000000000000000000000000000767676767676767676760000000000000000000000000000002727272727270027272727
27272727272727007676767676767615767676767600007676767676767676007676767676766476767676767676767676767676767600767676766574577600
00000000f7f7f7f7000000000000000000000000000000000000000076767676f7f776767676f70000000000000000000000000000272727f727270027272727
2727272727272700000000000000000000000000000000767676f7f7767676001576767676767676767676767676767676767676767600157676766575767600
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee67d7d7d6
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00e00ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0880880e
eccccccceccccceecccccccee166661eee11166ee111111ee88888c8ee8888ee8888888ee55f555eeee5555ee55ff55ee444444eee44444ee444444e0888880e
cccccccccccccccecccccccce161161eee11161ee114411e88888888ee88888e8882888ee55ff55eee55555ee5f5ff5ee444444eee44444ee444444ee08880ee
cc66cc6cccccfccecccccccc1111111eee111111e111111e88228828e888288e8882888eeffffffeee55fffee5fff55ee4ffff4eee444f4ee444444eee080eee
c6fcfffcccccfffccccccccce4f4fffeee444f4ee444444e82ffff28e888fffe8888288eef0ff0feee55f0fee555555eef3ff3feee44f3fee444444eeee0eeee
cf0ff0fcecfcf0fecc6cccccef0ff0feee44f0fee444444e8f1ff1f8eef8f1fe8888828eeffffffeee5ffffee555555eef3ff3feeee4f3fee444444eeeeeeeee
cf0ff0fcccccf0feccc6c6ccef0ff0feee4ff0fee444444e8f1ff1feee28f1fe88288feeef4444feee5fff4ee555555eeffffffeeeeffffee444444eeeeeeeee
ccffffcccccccffeeccc6ccceeffffeeeeeffffeef4444fe88ffffeeee828ffee882ffeee44ff44eeeeff44ee555555eeeffffeeeeeffffeef4444feee00eeee
cc1dd1ceec6ccceee6cccc6f9995599eeee999ee999999998556655eee5856ee585555551147741eeee1774e115555115558855eeee555ee55555555e0440eee
6c1ddf6eccf61deee16cc6fff9599ffeeeeffdeef99999ff2556655eee5556ee55555555f417411eeee1114e11111111f557755eeee555ee55555555049490ee
e1111ffeecfff1eee116611ee9999ffeeeefffeef99999ffe5556ffeee5ffeeef55555ffe1177ffeeee111eef11111ffe5577ffeeee5ffeef55555ff044440ee
e111111eee1111eee551e71ee111111eeee999eee111111ee555dddeee555eeee555d55ee111111eeee1ffeee111711ee550000eeee555eee555555ee0490eee
e55ee55ee51111eee55ee55ee11ee11ee511111ee11ee11eeddeeddee4ddddeeeddeeddee11ee11ee511111ee11ee11ee00ee00ee000000ee00ee00eee00eeee
e55ee55ee55ee55ee55ee55ee11ee55ee55ee11ee55ee11ee44ee44ee44eed4ee44ee44ee11ee55ee55ee11ee55ee11ee00ee00ee00ee00ee00ee00eeeeeeeee
e55eeeeeeeeeee55eeeee55ee55eeeeeeeeeee55eeeee55ee44eeeeeeeeeee44eeeee44ee55eeeeeeeeeee55eeeee55ee00eeeeeeeeeee00eeeee00eeeeeeeee
__gff__
800080000000008080808080808000008000000000000080808080808080808080008080800000808080000000800000800080808000000002a000000080800000000080808080808000000000000000008000808080008080000000000000000000008080808000800000000000000085850505000000008080808000808000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000171818070808080808080808080918181900000000002525252525003e3e3e3e3e3e3e007979790079797b7b797979
00000000000000000000000000000000000000000002022112521215125012212107080808080808080808090000000002020207080808080808080808080808080809121252121512500200000000000027282817181818181818181818192828290000000000301212127a003d3d3d3d3d3d3d004646460046467b7b464646
0000000000000000000000000000000000000000000202211252121512501221211718181818181818181819000000002324021718181818181818181818181818181912125212151250020000000000000a0d0d27282828282828282828290d0d1c0202000000575757577b005657755657757c007c7c7c6767676767671230
0000000000000000000000000000000000000000000202311252121512501202212728282828282828282829000000003334021718181818181818181818181818181912125212151250020000000000001a1b1b1d0d0d1e0d0d0d1e0d0d1f1b1b1c02020000003b3b3b3b3b3b7c7c7c7c7c7c7c7c7c7c7c0067676767671212
0000000000000000000000000000000000000000000202211252121512501202211d1e1e1e1e0d1e1e1e1e1f000000002324021718181818181818181818181818181912125212151250020000000000001a1b1b2d1e1e1e1e1e1e1e1e1e2f1b431c02020000003b3b3b3b3b007c7c7c7c7c7c7c007c7c7c0000003e7967793e
0000000000000000000000000000000000000000000202211252121512501202212d1e04041e0d1e04041e2f000000003334022728282828282828282828282828282912125212151250020000000202021a1b1b2d1e04041e1e1e04041e2f1b531c02020202003b3b3b3b3b0079474779797979007c7c7c7c7c003d4667463d
0002020202020202020202020202020202020202020202311252121512501223242d1e14141e1e1e14141e2f000000002324020a666666660b666666660b666666660c12125212151250020000002121212121212d1e14141e1e1e14141e2f12121221212121003e3e79797979464343463e3e3e00477c7c7c7c003d67676767
0002020202020202020202020202020202020202020202211252121512501233343131121231313112123131000000003334021a1b04041b1b1b04041b1b1b04041b1c1212521215125002000000121212121212121212121212121212121212121203121212003d3d464646467c53537c3d3d3d0038757c7c7c006767674767
0021212121212121212121212121213121212121213121311252121512501202020202121202020212120202000000000202021a1b14141b1b1b14141b1b1b14141b1c1212521215125002000000616161616161616161616161616161616161616113616161007c7c7c7c7c7c7c7c7c7c7c7c7c00477c7c7c7c006767674775
00121212121212121212121212121212120312121212121212520505055012121212121212121212121212120000000012121212121212303030121230303012121212121252121512500200000012121212121212121212121212121212121206060606061200567c477c7c7c7c7c7c7c7c7c7c00387c7c7c7c006757575767
00616161616161616161616161616161611361616161616161620505056061616161616161616161616161610000000012121212121212121212121212121212121212031252121512500200000011111111111111111111111111111111111111111111111100567c577c7c7c7c7c7c7c7c7c7c0047757c7c7c006767676767
00121212121212121212121212120606060606121212121201011212120101121212121212121212121212120000000061616161616161616161616161616161616161136162121512500200000012121212121212121212121212121212121212121212121200797979797c7c7c7c7c7c7c7c7c0038757c7c7c797979797979
00111111111111111111111111111111111111111111111101011212120101111111111111111111111111110000000012121212121212121212010112121212060606060612121512500200000041414141414141414141414141414141414141414141414100463846467c7c7c7c007c7c7c7c00477c7c7c7c464646464646
001212121212121212121212121212121212121212121212010112121201011212121212121212121212121200000000111111111111111111110101111111111111111111111112125002000000232423242324232423242324232423242324232423242324003d57577c7c7c7c7c007c7c7c7c00477c7c7c7c7c7c7c7c7c7c
004141411215124141414141414141414141414141414141414141414141414141414141414141414141414100000000121212121212121212120101121212121212121212121212125002000000333433343334333433343334333433343334333433343334007c7c7c7c7c7c7c7c00387c7c7c00577c7c7c7c7c7c7c7c7c7c
0012121205050512121212121212121212121212121212121212121212121212121212121212121212121212000000004141414141414141414112121212414141410708080808080808090000000000000000000000000000003e00000000000000003e000000797979797c7c7c7c0047757c7c007979797979797979797c7c
00101010222222101010101010101010101010101010101012121010101010101010101010101010101010100000000012121212121212121212121212121202020217181818181818181900475647564756477700430b0b43003d56475647564756473d7c7700464638467c7c7c7c00387c7c7c007c7c7c7c7c7c7c7c7c7c7c
00202020323232202020202020202020202020202020202012122020202020202020202020202020202020200000000061616161616161616161121212121202213117181818181818181900575657565756577700537e7e53007c56575657565756577c7c77007c57577c7c7c7c7c0038757c7c007c7c7c7c7c7c7c7c7c7c7c
0002121212121212161212161212164445161212162121310e0f21212121212121212121212121212121210200000000444516444516121216121212121202212324272828282828282829007c7c7c1b7c7c7c77003b3b3b3b007c1b7c7c7c7c7c7c7c7c7c77007c7c7c7c7c7c7c7c0047757c7c007c7c797979797979797979
0002121212121212161212161212165455161212162139210e0f213102212121212121212121212121212102000000005455165455161212161212121212022133341d0d0d0d0d0d0d0d1f00797c3e3e3e3e3e3e79437979797979793e3e3e3e3e797c7c797900797979797c7c7c7c00387c7c7c007c7c7c7c7c7c7c7c7c7c7c
0002070808080809161212161212166465161212162121210e0f212121210202020202020202020202020202000000006465166465161212161212121212022131212d0d0d0d0d0d0d0d2f00467c3d3d3d3d3d3d46534646464646463d3d3d3d3d467c7c4646003d3846467c7c7c7c0047757c7c007c7c7c7c7c7c7c7c7c7c7c
0002171818181819121212121212121212121212121212121212212121210202020202020202020200000000000000001212121212121212121212121212022324212d1e1e1e1e1e1e1e2f007c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c51007c57577c7c7c7c7c00387c7c7c797979797979797979797c7c
0002272828282829121207080808080808080808080912121212070808080808080808080809020200000000000000001212121212121212121212121212023334212d1e04041e04041e2f007c7c7c1b7c7c7c7c7c7c7c7c7272727c727272727c7c7c7c7c7c007c7c7c7c7c7c7c7c0047757c7c7c7c7c7c7c7c7c7c7c7c7c7c
00020a666666660c121217181818181818181818181912121212171818181818181818181819020200000000000000002525362525362525362525261212022121022d1e14141e14141e2f007c7c7c7c7c7c7c7c7c7c7c7c727c7c7c727c7c727c7c7c7c7c51007c7c7c7c7c7c7c7c00577c7c7c7c7c7c7c7c7c7c7c7c7c7c7c
00021a1b04041b1c12122728282828282828282828291212121227282828282828282828282902020000000000000000444516121216444516121216121212023102020212123012120202007c7c7c7c7c7c7c7c7c7c7c7c7272727c727c7c727c7c7c7c7c7c007c7c7c7c7c7f7f7c0000000000000000000000000000000000
00021a1b14141b1c12120a0d0d0d0d0d0d0d0d0d0d0c121212120a0b0b0b0b0b0b0b0b0b0b0c0202000000000000000054551612121654551612121612121202213112121212121212121200797979797979797979007c7c7c7c727c727c7c727c7c7c7c7c5100000000007f7f7f7f0000000000000000000000000000000000
000231121212121212121a0d0d1b1b0d0d1b1b0d0d1c121212121a0d0d1b1b0d0d1b1b0d0d1c0202000000000000000064651612121664651612121612121212020212121240414212121200464646464646464646007c7c7272727c72727272727c7c7c7c7c0000000000000000000000000000000000000000000000000000
000231121212121212121a1b1b1b1b1b1b1b1b1b1b1c121212121a1b1b1b1b1b1b1b1b1b1b1c0202000000000000000012121212121212121212121212121212121212121250305212121200564756475647564777007c7c7c7c7c7c7c0079797979797979790000000000000000000000000000000000000000000000000000
000231121212121212121a1b1b04041b1b04041b1b1c121212121a1b1b1b1b04041b1b1b1b1c0202000000000000000012121212121212121212121212121212121212121260616212121200565756575657565777007c7c7c7c7c7c7c0046464646464646460000000000000000000000000000000000000000000000000000
000231121212121212121a1b1b14141b1b14141b1b1c121212121a1b1b1b1b14141b1b1b1b1c02020000000000000000070808080808080902020708080808080808080808080808090708007c7c7c7c7c7c7c7c77007c7c7c7c7c7c7c007c565756575657770000000000000000000000000000000000000000000000000000
0002311212121212121212121212121212121212121212121212121212121212121212121212020200000000000000001718181818181819020217181818181818181818181818181917180056575657565756577c7c7c7c7c7f7f7c7c7c7c7c7c7c7c7c7c770000000000000000000000000000000000000000000000000000
000231121212121212121212121212121212121212121212121212121212121212121212121202020000000000007f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f000000000000000000000000000000007f7f00000000000000000000000000000000000000000000000000000000000000000000000000
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
