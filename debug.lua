-- debug tools used for the project
-- but it was consuming too much tokens ahah

-- constante to enable or disable the debuging
debug_enabled = true

function _init()
    debug_init()
    -- other stuff
end

function _draw()
    -- other stuff
    debug()
end

-- utils

function set_camera()
 g_scr.x = max(g_map.x1,min(g_map.x2,lerp(g_scr.x,g_p.x-64,0.4)))
 g_scr.y = max(g_map.y1,min(g_map.y2,lerp(g_scr.y,g_p.y-64,0.4)))
 camera(g_scr.x, g_scr.y)
end

function get_formalised_position(mina, maxa, a)
 return max(mina, min(maxa, a-64))
end

function get_box(a)
 return {
  x1 = a.x + a.box.x1,
  y1 = a.y + a.box.y1,
  x2 = a.x + a.box.x2,
  y2 = a.y + a.box.y2
 }
end

function lerp(a,b,t)
 return (1-t)*a + t*b
end

-- debug

function debug_init()
  g_dbg = {"","","","","","","","","",""}
  g_ft = {x1=0,y1=0,x2=0,y2=0}
  g_cl = {x1=0,y1=0,x2=0,y2=0}
end

function debug()
 if (not debug_enabled) return
 debug_log(g_fp.x+10, g_fp.y+10)
 log_cpu_mem(g_fp.x+70, g_fp.y+5)
 display_hitbox_matrix()
 display_collision_matrix()
 display_front_matrix()
 display_scr_info()
end

function display_front_matrix()
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

function display_scr_info()
 print("scr "..flr(g_scr.x)..":"..flr(g_scr.y), g_scr.x+1, g_scr.y+1, red)
 print("scr "..flr(g_scr.x+128)..":"..flr(g_scr.y+128), g_scr.x+80, g_scr.y+118, red)
 print("pl "..flr(g_p.x)..":"..flr(g_p.y), g_scr.x+50, g_scr.y+50, red)
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

function log_cpu_mem(x, y)
 print("cpu "..flr(stat(1)*100).."%", x, y, red)
 print("mem "..stat(0), x, y+6, red)
end
