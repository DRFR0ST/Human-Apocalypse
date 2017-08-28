--[[
	Script by
		 ________  ________  ________ ________  ________  ________  _________   
		|\   ___ \|\   __  \|\  _____\\   __  \|\   __  \|\   ____\|\___   ___\ 
		\ \  \_|\ \ \  \|\  \ \  \__/\ \  \|\  \ \  \|\  \ \  \___|\|___ \  \_| 
		 \ \  \ \\ \ \   _  _\ \   __\\ \   _  _\ \  \\\  \ \_____  \   \ \  \  
		  \ \  \_\\ \ \  \\  \\ \  \_| \ \  \\  \\ \  \\\  \|____|\  \   \ \  \ 
		   \ \_______\ \__\\ _\\ \__\   \ \__\\ _\\ \_______\____\_\  \   \ \__\
		    \|_______|\|__|\|__|\|__|    \|__|\|__|\|_______|\_________\   \|__|
		                                                    \|_________|        
	Copyright © 2017, Mike Eling (#DRFR0ST)
]]--

--[[
  __  __       _       
 |  \/  |     (_)      
 | \  / | __ _ _ _ __  
 | |\/| |/ _` | | '_ \ 
 | |  | | (_| | | | | |
 |_|  |_|\__,_|_|_| |_|

]]--

local shine = require '/lib/shine'
                       
function init()
	spawnEnemy()
	love.graphics.setFont(Window.font, 15)
	spawnParticles(20);
	turnShaders(true)
end

function love.load()
	--[[ Window & Mouse ]]--
		Window = {
			width = 1024,
			height = 768,
			focus = love.window.hasFocus(),
			background = love.graphics.newImage( "/src/tile_46.png" ),
			font = love.graphics.newFont("/src/kenpixel_mini_square.ttf", 22)
		}

		Mouse = {
			x = love.mouse.getX(),
			y = love.mouse.getY(),
		}
	--[[ ----- - ----- ]]--

	--[[ Game ]]--
		Game = {
			isActive = false,
			needReset = true,
			version = "Alpha v0.1",
		}
	--[[ ---- ]]--

	--[[ Menu ]]--
		Menu = {
			isActive = true,
			buttons = {
				start = { 
					x = Window.width / 2, 
					y = 64 * 3 + 128, 
					width = 190,
					height = 49,
					text = "Start",
					sprite = love.graphics.newImage("/src/button_bg.png")
				},

				quit = { 
					x = Window.width / 2, 
					y = 64 * 3 + 128 * 2, 
					width = 190,
					height = 49,
					text = "Quit",
					sprite = love.graphics.newImage("/src/button_bg.png")
				},

			},
		}
	--[[ ---- ]]--

	--[[ Player ]]--
		Player = {
			sprite = love.graphics.newImage( "/src/zoimbie1_gun.png" ),
			x = 1024/2 - (49/2),
			y = 768/2 - (43/2),
			width = 49,
			height = 43,
			speed = 200,
			angle = 0,
			lifes = {
				amount = 5,
			},

			bullets = {},
			gun = {
				heat = 0,
				heatp = 0.0,
				rounds = 6,
				reloadTime = -1,
				canReload = true,
			},

		}
	--[[ ------ ]]--

	--[[ Enemy ]]--
		Enemy = {
			instances = { },
			respawnTime = 2,
		}
	--[[ ----- ]]--

	--[[ Pickups ]]--
		Pickups = { 
			instances = {},
			respawnTime = love.math.random(10.0, 30.0),
		}
	--[[ ------- ]]--

	--[[ Environment ]]--
		Environment = {
			Map = {
				spriteBatch = love.graphics.newSpriteBatch(Window.background, 100),
				maxX = math.ceil(Window.width  / Window.background:getWidth())  + 2,
  				maxY = math.ceil(Window.height / Window.background:getHeight()) + 2,
  				
  				particles = {}
			}
		}
	--[[ ---------- ]]--

	--[[ Settings ]]--
		--fpsGraph = require "FPSGraph"
		--fps = fpsGraph.createGraph()
	--[[ -------- ]]--

	
	love.mouse.setVisible( false )

	local size = Environment.Map.maxX * Environment.Map.maxY
	Environment.Map.spriteBatch = love.graphics.newSpriteBatch(Window.background, size)

	init();
 end

 function love.update( dt )
		Mouse.x = love.mouse.getX()
		Mouse.y = love.mouse.getY()
	--[[ ----- - ----- ]]--

		if(Mouse.x >= Window.width) then
			love.mouse.setPosition(Window.width - 10, Mouse.y);
		end

		if(Mouse.x <= 10) then
			love.mouse.setPosition(10, Mouse.y);
		end

		if(Mouse.y >= Window.height) then
			love.mouse.setPosition(Mouse.x, Window.height - 10);
		end

		if(Mouse.y <= 10) then
			love.mouse.setPosition(Mouse.x, 10);
		end

 	if(Game.isActive) then
 			Player.angle = math.atan2(love.mouse.getY()-Player.y, love.mouse.getX()-Player.x);

			Player.gun.heat = math.max(0, Player.gun.heat - dt);
			if(Player.gun.reloadTime > 0.0) then Player.gun.reloadTime = math.max(0, Player.gun.reloadTime - dt); end
			Enemy.respawnTime = math.max(0, Enemy.respawnTime - dt);
			-- if(Pickups.respawnTime > 0.0) then Pickups.respawnTime = math.max(0, Pickups.respawnTime - dt); end

			if(Enemy.respawnTime <= 0.0) then
				spawnEnemy();
				Enemy.respawnTime = 5.0;
			end

			-- if(Pickups.respawnTime == 0.0) then
			-- 	spawnPickup();
			-- 	Pickups.respawnTime = -0.1
			-- end

			if(Player.gun.reloadTime == 0.0)then
				Player.gun.rounds = 6;
				Player.gun.canReload = true;
				Player.gun.reloadTime = -1;
			end
			-- update bullets:
		    for i, o in ipairs(Player.bullets) do


		        for n, m in ipairs(Enemy.instances) do
			        if(circle_and_rectangle_overlap(o.x, o.y, 4, m.x - (m.width / 2), m.y - (m.height / 2), m.width, m.height))then
			        	table.remove(Player.bullets, i);
			        	m.health = m.health - love.math.random(15, 45);

	    				if(m.health <= 0) then
	    					table.remove(Enemy.instances, n);

	    					if(maybe(15) == true) then
	    						spawnPickup(m.x + (m.width/2) - 20, m.y + (m.height/2) - 20)
	    					end
	    				end
			        end
			    end

			    o.x = o.x + math.cos(o.dir) * o.speed * dt
		        o.y = o.y + math.sin(o.dir) * o.speed * dt
		    end
			-- clean up out-of-screen bullets:
			for i = #Player.bullets, 1, -1 do
		        local o = Player.bullets[i]
		        if (o.x < -10) or (o.x > love.graphics.getWidth() + 10)
		        or (o.y < -10) or (o.y > love.graphics.getHeight() + 10) then
		            table.remove(Player.bullets, i)
		        end
		    end

		    for g, h in ipairs(Pickups.instances) do
		    	if rectangleCollision(Player.x, Player.y, Player.width, Player.height, h.x, h.y, h.width, h.height) then
		    		if(h.pickup == 0) then
		    			Player.lifes.amount = Player.lifes.amount + 1;
		    		elseif h.pickup == 1 then
		    			Player.gun.rounds = 10
		    		end
		    		table.remove(Pickups.instances, g);
		    		Pickups.respawnTime = love.math.random(10.0, 30.0)
		    	end

		    	h.angle = h.angle + 0.5 * dt

		    	if(h.resizeDir == "up") then h.resize = h.resize + 0.5 * dt end
		    	if(h.resizeDir == "down") then h.resize = h.resize - 0.5 * dt end

		    	if(h.resize >= 1.0) then
		    		h.resizeDir = "down"
		    	elseif(h.resize <= 0.55) then
		    		h.resizeDir = "up"
		    	end
		    end

		    if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
		    	Player.y = Player.y - Player.speed * dt;
		    end

		    if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
		    	Player.y = Player.y + Player.speed * dt;
		    end

		    if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
		    	Player.x = Player.x - Player.speed * dt;
		    end

		    if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
		    	Player.x = Player.x + Player.speed * dt;
		    end

		    if(Player.x >= Window.width - Player.width) then
		    	Player.x = Window.width - Player.width
		    end

		    if(Player.x <= 0) then
		    	Player.x = 0
		    end

		    if(Player.y >= Window.height - Player.height) then
		    	Player.y = Window.height - Player.height
		    end

		    if (Player.y <= 0) then
		    	Player.y = 0
		    end

		    for j, k in ipairs(Enemy.instances) do
		    	--k.x = k.x + ((Player.x - k.x) * 1000)
		    	--k.y = k.y + ((Player.y - k.y) * 1000)

		    	if(rectangleCollision(Player.x, Player.y, Player.width, Player.height, k.x, k.y, k.width, k.height)) then
		    		table.remove(Enemy.instances, j);
		    		Player.lifes.amount = Player.lifes.amount - 1

		    		if (Player.lifes.amount <= 0) then
		    			Player.lifes.amount = 5;
		    		end
		    	end

			    if k.x < Player.x then
			        k.x = k.x + k.speed * dt
			    end
			    if k.x > Player.x then
			        k.x = k.x - k.speed * dt
			    end
			    if k.y < Player.y then
			        k.y = k.y + k.speed * dt
			    end
			    if k.y > Player.y then
			        k.y = k.y - k.speed * dt
			    end
		    end

			
		--[[ -------- ]]--
			--fpsGraph.updateFPS(fps, dt)
	else
		local isCollidingStart = rectangleCollision(Mouse.x, Mouse.y , 15, 15, Menu.buttons.start.x, Menu.buttons.start.y, Menu.buttons.start.width, Menu.buttons.start.height)
		local isCollidingQuit = rectangleCollision(Mouse.x, Mouse.y , 15, 15, Menu.buttons.quit.x, Menu.buttons.quit.y, Menu.buttons.quit.width, Menu.buttons.quit.height)

		if(isCollidingStart and Menu.buttons.start.height == 49) then
			Menu.buttons.start.sprite = love.graphics.newImage("/src/button_bg_active.png")
			Menu.buttons.start.y = Menu.buttons.start.y + 4
			Menu.buttons.start.height = 45
		elseif(not isCollidingStart and Menu.buttons.start.height == 45) then
			Menu.buttons.start.sprite = love.graphics.newImage("/src/button_bg.png")
			Menu.buttons.start.y = Menu.buttons.start.y - 4
			Menu.buttons.start.height = 49
		end

		if(isCollidingQuit and Menu.buttons.quit.height == 49) then
			Menu.buttons.quit.sprite = love.graphics.newImage("/src/button_bg_active.png")
			Menu.buttons.quit.y = Menu.buttons.quit.y + 4
			Menu.buttons.quit.height = 45
		elseif(not isCollidingQuit and Menu.buttons.quit.height == 45) then
			Menu.buttons.quit.sprite = love.graphics.newImage("/src/button_bg.png")
			Menu.buttons.quit.y = Menu.buttons.quit.y - 4
			Menu.buttons.quit.height = 49
		end
	end

	setupSpriteBatch()
 end

 function love.draw()
 	post_effect:draw(function()
	 	love.graphics.draw(Environment.Map.spriteBatch);

	 	for t, z in ipairs(Environment.Map.particles) do
	 		love.graphics.draw(z.sprite, z.x, z.y, z.angle, 1, 1, z.width/2, z.height/2)
	 	end

	 	for g, h in ipairs(Pickups.instances) do
	 		love.graphics.setColor(0, 0, 0, 50);
	 		love.graphics.draw(h.sprite, h.x + 3, h.y + 2, h.angle, h.resize, h.resize, h.width/2, h.height/2)
	 		love.graphics.setColor(255, 255, 255, 255);
	 		love.graphics.draw(h.sprite, h.x, h.y, h.angle, h.resize, h.resize, h.width/2, h.height/2)
	 	end

		for i, o in ipairs(Player.bullets) do
			love.graphics.setColor(70, 70, 70, 225)
			love.graphics.circle('fill', o.x, o.y, 5, 100)
			love.graphics.setColor(86, 83, 83, 225)
			love.graphics.circle('fill', o.x, o.y, 4, 100)
		end

		love.graphics.setColor(255, 255, 255, 255)
		for j, k in ipairs(Enemy.instances) do
			k.angle = math.atan2(Player.y-k.y, Player.x-k.x);
			love.graphics.draw(k.sprite, k.x, k.y, k.angle, 1, 1, k.width/2, k.height/2);

			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.rectangle("fill", k.x - 23, k.y + k.height - 7, k.health / 2, 10)
			love.graphics.setColor(224, 62, 62, 255);
			love.graphics.rectangle("fill", k.x - 25, k.y + k.height - 10, k.health / 2, 10)
			love.graphics.setColor(165, 92, 92, 255);
			love.graphics.rectangle("line", (k.x + (k.health / 2)) - 25, k.y + k.height - 10, (100 - k.health)/2, 10)
			love.graphics.setColor(255, 255, 255, 255);
			--love.graphics.setColor(0, 0, 0, 255);
	 		--love.graphics.rectangle("line", k.x, k.y, k.width, k.height)
		end

		if( Menu.isActive == false) then
			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.circle("line", Mouse.x + 3, Mouse.y + 2, 10.7, 100)
			love.graphics.setColor(255, 255, 255, 255);
			love.graphics.circle("line", Mouse.x, Mouse.y, 11, 100)
		end

	 	love.graphics.draw(Player.sprite, Player.x, Player.y, Player.angle, 1, 1, Player.width/2, Player.height/2);

	 	--local greyscale = gradient { direction = 'horizontal'; {0, 0, 0, 0}; {0, 0, 0, 100}}

	 	--drawinrect(greyscale, 0, Window.height - 60, Window.width, 60);

	end)


		local healthIcon = love.graphics.newImage("src/plus.png");
		local ammoIcon = love.graphics.newImage("src/fightJ.png");

	if(Menu.isActive == false)	then	
		love.graphics.setColor(255, 255, 255, 255);
		love.graphics.draw(love.graphics.newImage("src/btm_bar.png"), 100, Window.height - 96, 0, 0.8, 0.8)

		for lfs=1,Player.lifes.amount,1 do
			local elevation = (45 * lfs);
			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.draw(healthIcon, 78 + elevation, Window.height - 75, 0, 0.35, 0.35)
			love.graphics.setColor(255, 255, 255, 255);
			love.graphics.draw(healthIcon, 75 + elevation, Window.height - 77, 0, 0.35, 0.35)
		end

		for amo=1,Player.gun.rounds,1 do
			local elevation = (45 * amo);
			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.draw(ammoIcon, 913 - elevation, Window.height - 75, 0, 0.35, 0.35)
			love.graphics.setColor(255, 255, 255, 255);
			love.graphics.draw(ammoIcon, 910 - elevation, Window.height - 77, 0, 0.35, 0.35)
		end

		if (Player.gun.rounds <= 0 and Player.gun.canReload) then
			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.print("Press R to reload!", 633, Window.height - 71);
			love.graphics.setColor(255, 255, 255, 255);
			love.graphics.print("Press R to reload!", 630, Window.height - 73);
		elseif Player.gun.canReload == false then
			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.print("Reloading...", 673, Window.height - 71);
			love.graphics.setColor(255, 255, 255, 255);
			love.graphics.print("Reloading...", 670, Window.height - 73);
		end
	end

	if (Menu.isActive) then
		-- for i = 0, Menu.buttons.count, 1 do
		-- 	love.g
		-- end
		love.graphics.setColor(0, 0, 0, 50);
		love.graphics.print(Game.version, Window.width - 127, 9);
		love.graphics.setColor(255, 255, 255, 255);
		love.graphics.print(Game.version, Window.width - 130, 7);

		love.graphics.draw(Menu.buttons.start.sprite, Menu.buttons.start.x - 30, Menu.buttons.start.y, 0, 1, 1)
		if(Game.needReset == false) then Menu.buttons.start.text = "Resume" else Menu.buttons.start.text = "Start" end
		love.graphics.print(Menu.buttons.start.text, Menu.buttons.start.x + (Menu.buttons.start.width/6) - 9, Menu.buttons.start.y + 8, 0, 1, 1);

		love.graphics.draw(Menu.buttons.quit.sprite, Menu.buttons.quit.x - 30, Menu.buttons.quit.y, 0, 1, 1)
		love.graphics.print(Menu.buttons.quit.text, Menu.buttons.quit.x + (Menu.buttons.quit.width/4) - 2, Menu.buttons.quit.y + 8, 0, 1, 1);

		love.graphics.setColor(0, 0, 0, 50);
		--love.graphics.circle("line", Mouse.x + 3, Mouse.y + 2, 11, 100)
		love.graphics.draw(love.graphics.newImage("/src/cursorHand_grey.png"), Mouse.x + 3, Mouse.y + 2, 0, 0.95, 0.95, 27/2, 28/2)
		love.graphics.setColor(255, 255, 255, 255);
		--love.graphics.circle("line", Mouse.x, Mouse.y, 10.7, 100)
		love.graphics.draw(love.graphics.newImage("/src/cursorHand_grey.png"), Mouse.x + 3, Mouse.y + 2, 0, 1, 1, 27/2, 28/2)
	end

	
 end

--[[
  _____                   _       
 |_   _|                 | |      
   | |  _ __  _ __  _   _| |_ ___ 
   | | | '_ \| '_ \| | | | __/ __|
  _| |_| | | | |_) | |_| | |_\__ \
 |_____|_| |_| .__/ \__,_|\__|___/
             | |                  
             |_|                  
]]--

function love.keypressed( key, isrepeat )
	if(Game.isActive) then
		if (key == "r" and Player.gun.canReload) then
			Player.gun.reloadTime = 1.0;
			Player.gun.rounds = 0;
			Player.gun.canReload = false;
		end
	end
end

function love.keyreleased( key )
	if (key == "escape") then
		if(not Game.needReset) then
			if(Menu.isActive) then
					Game.isActive = true
					Menu.isActive = false
					turnShaders(false)
			else
					Game.isActive = false
					Menu.isActive = true
					turnShaders(true)
			end
		end
		--love.event.quit()
	end


end

function love.textinput( text )

end

function love.mousefocus( f )

end

function love.mousepressed( x, y, button )
	if(Game.isActive) then
		if button == 1 and Player.gun.heat <= 0 and Player.gun.rounds > 0 then
			local direction = math.atan2(love.mouse.getY() - Player.y, love.mouse.getX() - Player.x)

			pistolX = Player.x + ((10* math.cos(direction)) - (10 * math.sin(direction)));
			pistolY = Player.y + ((10* math.cos(direction)) + (10 * math.sin(direction)));

			table.insert(Player.bullets, {
				x = pistolX,
				y = pistolY,
				dir = direction,
				speed = 1400
			})
			Player.gun.heat = Player.gun.heatp
			Player.gun.rounds = Player.gun.rounds - 1
		end
	end

end

function love.mousereleased( x, y, button )
	if(Menu.isActive) then
		if button == 1 then
			if(rectangleCollision(x, y, 10, 10, Menu.buttons.start.x, Menu.buttons.start.y, Menu.buttons.start.width, Menu.buttons.start.height)) then
				if Menu.buttons.start.text == "Resume" then
					Menu.isActive = false
					Game.isActive = true
					turnShaders(false)
				elseif Menu.buttons.start.text == "Start" then
					Menu.isActive = false
					Game.isActive = true
					turnShaders(false)
					Game.needReset = false
				end
			end

			if(rectangleCollision(x, y, 10, 10, Menu.buttons.quit.x, Menu.buttons.quit.y, Menu.buttons.quit.width, Menu.buttons.quit.height)) then
				love.event.quit()
			end
		end
	end
end

--[[
 __          ___           _               
 \ \        / (_)         | |              
  \ \  /\  / / _ _ __   __| | _____      __
   \ \/  \/ / | | '_ \ / _` |/ _ \ \ /\ / /
    \  /\  /  | | | | | (_| | (_) \ V  V / 
     \/  \/   |_|_| |_|\__,_|\___/ \_/\_/                                             
]]

function love.focus( f )

end

function love.visible( v )

end

function love.resize( w, h )

end

function love.threaderror( thread, errorstr )

end

function love.quit()

end

 --[[
  ______                _   _                 
 |  ____|              | | (_)                
 | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
 |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
 | |  | |_| | | | | (__| |_| | (_) | | | \__ \
 |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/                                            
 ]]

function getLocationOutsideBox()
	local w = 0
	local h = 0

	local rand = love.math.random(1, 4);

	if(rand == 1) then
		w = love.math.random(-250, -200);
		h = love.math.random(-250, Window.height + 250);
	end
	if(rand == 2) then
		w = love.math.random(Window.width + 200, Window.width + 250);
		h = love.math.random(-250, Window.height + 250);
	end
	if(rand == 3) then
		w = love.math.random(-250, Window.width + 250);
		h = love.math.random(-250, -200);
	end
	if(rand == 4) then
		w = love.math.random(-250, Window.width + 250);
		h = love.math.random(Window.height + 200, Window.height + 250);
	end

	local set = {width = w, height = h}
	return set;
end

function turnShaders(turn)
	if(turn) then
		-- load the effects you want
	    local grain = shine.gaussianblur()
	    -- many effects can be parametrized

	    -- multiple parameters can be set at once
	    local vignette = shine.vignette()
	    vignette.parameters = {radius = 0.9, opacity = 0.3}
	    -- you can also provide parameters on effect construction
	    local desaturate = shine.desaturate{strength = 0.4, tint = {255,250,200}}
	    -- you can chain multiple effects
	    post_effect = desaturate:chain(grain):chain(vignette)
	    -- warning - setting parameters affects all chained effects:
	    post_effect.opacity = 0.6 -- affects both vignette and film grain
	else
		local vignette = shine.vignette()
	    vignette.parameters = {radius = 0.9, opacity = 0.5}
	    -- you can also provide parameters on effect construction
	    local desaturate = shine.desaturate{strength = 0.15, tint = {255,250,200}}
	    -- you can chain multiple effects
	    post_effect = desaturate:chain(vignette)
	    -- warning - setting parameters affects all chained effects:
    	--ost_effect.opacity = 0.4 -- affects both vignette and film grain
    end
end

function spawnParticles(count)
	for i = 0, count, 1 do
		createParticle()
	end
end

function createParticle()
	local pX = love.math.random(-32, Window.width + 32);
	local pY = love.math.random(-32, Window.height + 32);
	local pAngle = love.math.random(0.01, 0.99);

	for i, o in ipairs(Environment.Map.particles) do
		if rectangleCollision(o.x, o.y, o.width, o.height, pX, pY, 64, 64) then
			createParticle();
			return;
		end
	end


	local pSprite = "/src/tile_"..love.math.random(0, 12)..".png";


	table.insert(Environment.Map.particles, {
		x = pX,
		y = pY,
		width = 64,
		height = 64,
		angle = pAngle,
		sprite = love.graphics.newImage(pSprite),
	});
end

function spawnPickup(x, y)
	--local pX = love.math.random(-32, Window.width + 32);
	--local pY = love.math.random(-32, Window.height + 32);
	local pX = x
	local pY = y
	local pType = love.math.random(0, 1);
	local pAngle = love.math.random(0, 1);

	local pSprite = nil;
	local pWidth = 0;
	local pHeight = 0;
	if(pType == 0) then
		pSprite = "/src/genericItem_color_089.png";
		pWidth = 40
		pHeight = 40
	elseif(pType == 1) then
		pSprite = "/src/genericItem_color_090.png";
		pWidth = 40
		pHeight = 40
	end

	table.insert(Pickups.instances, {
		x = pX,
		y = pY,
		width = pWidth,
		height = pHeight,
		angle = pAngle,
		pickup = pType,
		resize = 0.55,
		resizeDir = "up",
		sprite = love.graphics.newImage(pSprite),
	});
end

function spawnEnemy()
	local locSet = getLocationOutsideBox();
	local eX = locSet.width;
	local eY = locSet.height;

	--local eX = getLocationOutsideBox(0, 100);
	--local eY = getLocationOutsideBox(1, 100);
	local eSprite = "/src/survivor1_hold.png";
	local eSpeed = love.math.random(15, 40);

	table.insert(Enemy.instances, {
		x = eX,
		y = eY,
		width = 37,
		height = 43,
		angle = 0,
		health = 100,
		speed = eSpeed,
		sprite = love.graphics.newImage( eSprite ),
	});


end

function maybe(x) if 100 * math.random() < x then return true else return false end  end 

function setupSpriteBatch()
  Environment.Map.spriteBatch:clear()

  -- Set up (but don't draw) our images in a grid
  for y = 0, Environment.Map.maxY do
    for x = 0, Environment.Map.maxX do
      -- Convert our x/y grid references to x/y pixel coordinates
      local xPos = x * Window.background:getWidth()
      local yPos = y * Window.background:getHeight()

      -- Add the image we previously set to this point
      Environment.Map.spriteBatch:add(xPos, yPos)
    end
  end
end

function distance(x1, y1, x2, y2)
  d = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
  return d;
end

function circle_and_rectangle_overlap(cx, cy, cr, rx, ry, rw, rh)
   local circle_distance_x = math.abs(cx - rx - rw/2)
   local circle_distance_y = math.abs(cy - ry - rh/2)

   if circle_distance_x > (rw/2 + cr) or circle_distance_y > (rh/2 + cr) then
      return false
   elseif circle_distance_x <= (rw/2) or circle_distance_y <= (rh/2) then
      return true
   end

   return (math.pow(circle_distance_x - rw/2, 2) + math.pow(circle_distance_y - rh/2, 2)) <= math.pow(cr, 2)
end

function rectangleCollision(rx, ry, rw, rh, rx2, ry2, rw2, rh2)
	if rx < rx2 + rw2 and rx2 < rx + rw and ry < ry2 + rh2 and ry2 < ry + rh then
		return true
	else 
		return false
	end
end

function gradient(colors)
    local direction = colors.direction or "horizontal"
    if direction == "horizontal" then
        direction = true
    elseif direction == "vertical" then
        direction = false
    else
        error("Invalid direction '" .. tostring(direction) "' for gradient.  Horizontal or vertical expected.")
    end
    local result = love.image.newImageData(direction and 1 or #colors, direction and #colors or 1)
    for i, color in ipairs(colors) do
        local x, y
        if direction then
            x, y = 0, i - 1
        else
            x, y = i - 1, 0
        end
        result:setPixel(x, y, color[1], color[2], color[3], color[4] or 255)
    end
    result = love.graphics.newImage(result)
    result:setFilter('linear', 'linear')
    return result
end

function drawinrect(img, x, y, w, h, r, ox, oy, kx, ky)
    return -- tail call for a little extra bit of efficiency
    love.graphics.draw(img, x, y, r, w / img:getWidth(), h / img:getHeight(), ox, oy, kx, ky)
end

 --[[
 ____________________________________
/                                    \

	$$$$$$$$\  $$$$$$\   $$$$$$\  
	$$  _____|$$  __$$\ $$  __$$\ 
	$$ |      $$ /  $$ |$$ /  \__|
	$$$$$\    $$ |  $$ |\$$$$$$\  
	$$  __|   $$ |  $$ | \____$$\ 
	$$ |      $$ |  $$ |$$\   $$ |
	$$$$$$$$\  $$$$$$  |\$$$$$$  |
	\________| \______/  \______/ 
                              
\____________________________________/
]]