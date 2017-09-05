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
	if(not Game.inDebug) then
		local enemyCount = love.math.random(4, 10);
		for i = 0, enemyCount, 1 do
		 	spawnEnemy()
		end
	end

	love.graphics.setFont(Window.font, 15)
	spawnParticles(love.math.random(10, 35));
	turnShaders(true)
	setupSpriteBatch()
end

function love.load()
	--[[ Window & Mouse ]]--
		Window = {
			width = 1024,
			height = 768,
			focus = love.window.hasFocus(),
			background = love.graphics.newImage( "/src/tile_100.png" ),
			font = love.graphics.newFont("/src/kenpixel_mini_square.ttf", 22)
		}

		Mouse = {
			x = love.mouse.getX(),
			y = love.mouse.getY(),
		}
	--[[ ----- - ----- ]]--

	--[[ Game ]]--
		Game = {
			inDebug = false, -- DEVELOPER MODE!!!

			firstRound = true,
			isActive = false,		
			needReset = true,
			version = "Alpha v0.2",
			score = 0,
		}
	--[[ ---- ]]--

	--[[ Menu ]]--
		Menu = {
			isActive = true,
			buttons = {
				start = { 
					x = Window.width / 2 - 40, 
					y = 64 * 3 + 128, 
					width = 190,
					height = 49,
					text = "Start",
					sprite = love.graphics.newImage("/src/button_bg.png")
				},

				quit = { 
					x = Window.width / 2 - 40, 
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
			speed = 100,
			angle = 0,
			lifes = {
				amount = 5,
			},

			canControl = true,

			farts = {},
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
			bullets = {},
			canSpawn = true,
			respawnTime = 2,
			maxRespawnTime = 5,
			multiplier = 1,
			tanks = {
				instances = { },
				respawnTime = 25,
				maxRespawnTime = love.math.random(20, 60),
			}
		}
	--[[ ----- ]]--

	--[[ Pickups ]]--
		Pickups = { 
			instances = {},
			respawnTime = love.math.random(10.0, 30.0),
			speedTime = -1;
		}
	--[[ ------- ]]--

	--[[ Environment ]]--
		Environment = {
			map = {
				index = 0,
				scoreNeeded = 5000,
				spriteBatch = love.graphics.newSpriteBatch(Window.background, 100),
				maxX = math.ceil(Window.width  / Window.background:getWidth())  + 2,
  				maxY = math.ceil(Window.height / Window.background:getHeight()) + 2,
  				
  				particles = {}
			},
			teleporter = {
				x = Window.width/2,
				y = Window.height/2,
				width = 64,
				height = 64,
				sprite = love.graphics.newImage("/src/tile_505.png"),
				isActive = false,
			},
			blackbar = {
				width = Window.width,
				height = Window.height/2,
				x = 0,
				y1 = -Window.height/2,
				y2 = Window.height,
				delay = false,
				animation = "none",
				speed = 750,
			},
			wind = {
				speed = love.math.random(50, 275),
				dir = math.atan2(love.math.random(0, Window.height)-love.math.random(0, Window.height), love.math.random(0, Window.width)-love.math.random(0, Window.width)),
			}
		}
	--[[ ---------- ]]--

	--[[ Timer ]]--
		Timer = {
			twoSec = 2.0,
		}
	--[[ ------ ]]--

	--[[ Settings ]]--
		--fpsGraph = require "FPSGraph"
		--fps = fpsGraph.createGraph()
	--[[ -------- ]]--

	
	love.mouse.setVisible( false )

	local size = Environment.map.maxX * Environment.map.maxY
	Environment.map.spriteBatch = love.graphics.newSpriteBatch(Window.background, size)

	init();
 end

 function love.update( dt )
		Mouse.x = love.mouse.getX()
		Mouse.y = love.mouse.getY()
	--[[ ----- - ----- ]]--

		if(not Menu.isActive) then
			if(Mouse.x >= Window.width - 10) then
				love.mouse.setPosition(Window.width - 10, Mouse.y);
			end

			if(Mouse.x <= 10) then
				love.mouse.setPosition(10, Mouse.y);
			end

			if(Mouse.y >= Window.height - 10) then
				love.mouse.setPosition(Mouse.x, Window.height - 10);
			end

			if(Mouse.y <= 10) then
				love.mouse.setPosition(Mouse.x, 10);
			end
		end

 	if(Game.isActive) then
 			if Player.canControl then Player.angle = math.atan2(love.mouse.getY()-Player.y, love.mouse.getX()-Player.x); end

			Player.gun.heat = math.max(0, Player.gun.heat - dt);
			if(Player.gun.reloadTime > 0.0) then Player.gun.reloadTime = math.max(0, Player.gun.reloadTime - dt); end
			Enemy.respawnTime = math.max(0, Enemy.respawnTime - dt);
			Enemy.tanks.respawnTime = math.max(0, Enemy.tanks.respawnTime - dt);
			if(Pickups.speedTime > 0.0) then Pickups.speedTime = math.max(0, Pickups.speedTime - dt); end
			Timer.twoSec = math.max(0, Timer.twoSec - dt);


			if Timer.twoSec <= 0.0 then
				twoSec_Timer(dt);
				Timer.twoSec = 2.0
			end

			-- if(Pickups.respawnTime > 0.0) then Pickups.respawnTime = math.max(0, Pickups.respawnTime - dt); end

			if(Enemy.respawnTime <= 0.0) then
				if(not Game.inDebug) then
					for i = 1, math.floor(Enemy.multiplier), 1 do
						spawnEnemy();
					end

					Enemy.multiplier = Enemy.multiplier + 0.01;
					if(Enemy.maxRespawnTime > 2) then Enemy.maxRespawnTime = Enemy.maxRespawnTime - 0.1; end
					Enemy.respawnTime = Enemy.maxRespawnTime;
				end
			end

			if(Enemy.tanks.respawnTime == 0.0) then
				if(not Game.inDebug) then
					spawnTank();
					if(Enemy.tanks.maxRespawnTime > 10) then Enemy.tanks.maxRespawnTime = Enemy.tanks.maxRespawnTime - 0.0001; end
					Enemy.tanks.respawnTime = Enemy.tanks.maxRespawnTime;
				end
			end
			-- if(Pickups.respawnTime == 0.0) then
			-- 	spawnPickup();
			-- 	Pickups.respawnTime = -0.1
			-- end

			if(Pickups.speedTime == 0.0) then
				Player.speed = 100;
				Pickups.speedTime = -1;
				Player.reloadTime = Player.gun.reloadTime + (Player.gun.reloadTime/2);
				turnShaders(false);
			end

			if(Player.gun.reloadTime == 0.0)then
				Player.gun.rounds = 7;
				Player.gun.canReload = true;
				Player.gun.reloadTime = -1;
			end
			-- update bullets:
		    for i, o in ipairs(Player.bullets) do


		        for n, m in ipairs(Enemy.instances) do
			        if(circle_and_rectangle_overlap(o.x, o.y, 4, m.x - (m.width / 2), m.y - (m.height / 2), m.width, m.height))then
			        	table.remove(Player.bullets, i);
			        	local damage = love.math.random(25, 60);
			        	if(circle_and_rectangle_overlap(o.x, o.y, 4, m.x - (m.width / 4), m.y - (m.height / 2), m.width/2, m.height)) then
			        		damage = love.math.random(70, 100);
			        	end

			        	m.health = m.health - damage;
			        	--local direction = o.dir;
			   --      	m.x=m.x + love.math.cos(direction)*20;
						-- m.y=m.y-love.math.sin(direction)*20;
			        	Game.score = Game.score + math.floor(damage/2);
	    				if(m.health <= 0) then
	    					table.remove(Enemy.instances, n);
	    					
	    					if(maybe(m.dropRate) == true) then
	    						spawnPickup(m.x + (m.width/2) - 20, m.y + (m.height/2) - 20)
	    					end
	    				end
			        end
			    end

			    for n, m in ipairs(Enemy.tanks.instances) do
			        if(circle_and_rectangle_overlap(o.x, o.y, 4, m.x , m.y, m.width, m.height))then
			        	table.remove(Player.bullets, i);
			        	local rand = love.math.random(100, 200);
			        	Game.score = Game.score + math.floor(rand/2);
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

		    for f, a in ipairs(Player.farts) do
		    	a.x = a.x + math.cos(Environment.wind.dir) * Environment.wind.speed * dt
				a.y = a.y + math.sin(Environment.wind.dir) * Environment.wind.speed * dt

		    	a.opacity = math.max(0, (a.opacity - 2.5) - dt);

		    	if(a.opacity <= 0) then table.remove(Player.farts, f); end
		    end

		    for r, t in ipairs(Enemy.tanks.instances) do
		    	if rectangleCollision(t.x, t.y, t.width, t.height, Player.x, Player.y, Player.width, Player.height) and t.hit == false then
		    		Player.lifes.amount = Player.lifes.amount - 2
		    		t.hit = true;
		    	end

			    	if t.dir == 0 then --right
			    		t.x = t.x + t.speed * dt
			    	elseif t.dir == 1 then --left
			    		t.x = t.x - t.speed * dt
			    	end


		    	if t.x - (t.width/2) > Window.width + 500 then
		    		table.remove(Enemy.tanks.instances, r);
		    	end

		    	if(t.x + t.width < -500) then
		    		table.remove(Enemy.tanks.instances, r);
		    	end

		        for n, m in ipairs(Enemy.instances) do
		        	if rectangleCollision(m.x, m.y, m.width, m.height, t.x, t.y, t.width, t.height) then
		        		table.remove(Enemy.instances, n);
		        	end
			    end

			    for l, k in ipairs(Enemy.bullets) do
			    	if circle_and_rectangle_overlap(k.x, k.y, 4, t.x, t.y, t.width, t.height) then
			    		table.remove(Enemy.bullets, l)
			    	end
			    end
		    end

		    for g, h in ipairs(Pickups.instances) do
		    	if rectangleCollision(Player.x, Player.y, Player.width, Player.height, h.x, h.y, h.width, h.height) then
		    		if(h.pickup == 0) then
		    			if(Player.lifes.amount < 10) then
		    				Player.lifes.amount = Player.lifes.amount + 1;
		    				table.remove(Pickups.instances, g);
		    				turnShaders(false);
		    				--Pickups.respawnTime = love.math.random(10.0, 30.0)
		    			end
		    		elseif h.pickup == 1 then
		    			Player.speed = 250;
		    			Pickups.speedTime = 5.0;
		    			Player.reloadTime = Player.gun.reloadTime - (Player.gun.reloadTime/2);
		    			table.remove(Pickups.instances, g);
		    			turnShaders(false);
		    			--Pickups.respawnTime = love.math.random(10.0, 30.0)
		    		end
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

		    if Player.canControl then

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

		    for i, o in ipairs(Enemy.bullets) do
		        o.x = o.x + math.cos(o.dir) * o.speed * dt
				o.y = o.y + math.sin(o.dir) * o.speed * dt

				        for ö, ä in ipairs(Enemy.instances) do
				        	if circle_and_rectangle_overlap(o.x, o.y, 4, ä.x, ä.y, ä.width, ä.height) and o.invokerID ~= ä.id then
					        	table.remove(Enemy.bullets, i);
					        	local damage = love.math.random(25, 50);

					     
					        	ä.health = ä.health - damage;
					   --      	local direction = o.dir;
					   --      	ä.x=ä.x+love.math.cos(direction)*20;
								-- ä.y=ä.y-love.math.sin(direction)*20;
					        	--Game.score = Game.score + math.floor(damage/2);
			    				if(ä.health <= 0) then
			    					table.remove(Enemy.instances, ö);
			    					
			    					if(maybe(ä.dropRate) == true) then
			    						spawnPickup(ä.x + (ä.width/2) - 20, ä.y + (ä.height/2) - 20)
			    					end
			    				end
				        	end
				        end
					    for i, o in ipairs(Enemy.bullets) do

					        if(circle_and_rectangle_overlap(o.x, o.y, 4, Player.x - (Player.width / 2), Player.y - (Player.height / 2), Player.width, Player.height))then
					        	table.remove(Enemy.bullets, i);
					        	Player.lifes.amount = Player.lifes.amount - 1

			    				checkPlayerHealth();
					        end

					    end
						-- clean up out-of-screen bullets:
							for i = #Enemy.bullets, 1, -1 do
						        local o = Enemy.bullets[i]
						        if (o.x < -10) or (o.x > love.graphics.getWidth() + 10)
						        or (o.y < -10) or (o.y > love.graphics.getHeight() + 10) then
						            table.remove(Enemy.bullets, i)
						        end
						    end
		    end

		    for j, k in ipairs(Enemy.instances) do
		    	--k.x = k.x + ((Player.x - k.x) * 1000)
		    	--k.y = k.y + ((Player.y - k.y) * 1000)

		    	if(rectangleCollision(Player.x, Player.y, Player.width, Player.height, k.x, k.y, k.width, k.height)) then
		    		table.remove(Enemy.instances, j);
					checkPlayerHealth()
		    	end
				if k.isShooting then
					if k.x <= Window.width - (k.width/2) and k.x + (k.width/2) >= 0 and k.y <= Window.height - (k.height/2) and k.y + (k.height/2) >= 0 then


			    		k.heat = math.max(0, k.heat - dt);
			    		if k.heat <= 0 then
							local direction = math.atan2(Player.y - k.y, Player.x - k.x)

							local pistolX = k.x + ((10* math.cos(direction)) - (10 * math.sin(direction)));
							local pistolY = k.y + ((10* math.cos(direction)) + (10 * math.sin(direction)));

							table.insert(Enemy.bullets, {
								invokerID = k.id,
								x = pistolX,
								y = pistolY,
								dir = direction,
								speed = k.weapon.speed + k.speed,
							})
							k.heat = k.heatp

						end
					end
				end

--			 	if not rectangleCollision(k.x, k.y, k.width, k.height, Player.x - 100, Player.y - 100, Player.width + 200, Player.height + 200) then --debug chit
				-- local coughtInFart = false
				-- for f, a in ipairs(Player.farts) do
				-- 	if not rectangleCollision(a.x, a.y, a.width, a.height, k.x, k.y, k.width, k.height) then
				-- 		coughtInFart = true
				-- 	end
				-- end
				--if(not coughtInFart) then
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
--			 	end
				--end
		    end

			
		    if Game.score >= Environment.map.scoreNeeded and Environment.teleporter.isActive == false then
		    	if Enemy.canSpawn == true then Enemy.canSpawn = false end

		    	local eCount = 0;
		    	for i, o in ipairs(Enemy.instances) do
		    		eCount = eCount + 1
		    	end

		    	if eCount <= 0 then
		    		spawnTeleporter();
		    	end
		    end


		    if Environment.teleporter.isActive and Player.canControl then
		    	if rectangleCollision(Environment.teleporter.x, Environment.teleporter.y, Environment.teleporter.width, Environment.teleporter.height, Player.x, Player.y, Player.width, Player.height) then
		    		Player.canControl = false;
		    		Player.x = Environment.teleporter.x;
		    		Player.y = Environment.teleporter.y;
		    		Player.angle = -1.535;
		    		Environment.blackbar.animation = "down"
		    	end
		    end

			-- if Environment.blackbar.animation == "down" then

			-- 	while Environment.blackbar.y1 < 0 do

		 --    	Environment.blackbar.y1 = Environment.blackbar.y1 + Environment.blackbar.speed * dt;
		 --    	Environment.blackbar.y2 = Environment.blackbar.y2 - Environment.blackbar.speed * dt;

			-- 	end


		 --    	if Environment.blackbar.y1 >= 0 then
		 --    		if Environment.blackbar.y1 > 0 then Environment.blackbar.y1 = 0 end
		 --    		if Environment.blackbar.y2 < Window.height/2 then Environment.blackbar.y2 = Window.height/2 end

		 --    		Environment.blackbar.animation = "none";
		 --    		Environment.blackbar.delay = true;
		 --    		nextMap()
		 --    	end
		 --    end

		    if Environment.blackbar.animation == "down" then
		    	Environment.blackbar.y1 = Environment.blackbar.y1 + Environment.blackbar.speed * dt;
		    	Environment.blackbar.y2 = Environment.blackbar.y2 - Environment.blackbar.speed * dt;

		    	if Environment.blackbar.y1 >= 0 then
		    		if Environment.blackbar.y1 > 0 then Environment.blackbar.y1 = 0 end
		    		if Environment.blackbar.y2 < Window.height/2 then Environment.blackbar.y2 = Window.height/2 end

		    		Environment.blackbar.animation = "none";
		    		Environment.blackbar.delay = true;
		    		nextMap()
		    	end
		    end

		    if Environment.blackbar.animation == "up" then
		    	Environment.blackbar.y1 = Environment.blackbar.y1 - Environment.blackbar.speed * dt;
		    	Environment.blackbar.y2 = Environment.blackbar.y2 + Environment.blackbar.speed * dt;

		    	if Environment.blackbar.y1 + Environment.blackbar.height <= 0 then
		    		Environment.map.scoreNeeded = Environment.map.scoreNeeded * 2;
		    		Environment.blackbar.animation = "none";
		    		Environment.teleporter.isActive = false;
		    		Enemy.canSpawn = true;
		    		Player.canControl = true;
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

	--setupSpriteBatch()
 end

 function love.draw()
 	post_effect:draw(function()
	 	love.graphics.draw(Environment.map.spriteBatch);

	 	for t, z in ipairs(Environment.map.particles) do
	 		love.graphics.draw(z.sprite, z.x, z.y, z.angle, 0.6, 0.6, z.width/2, z.height/2)
	 	end

		if Environment.teleporter.isActive then
			love.graphics.draw(Environment.teleporter.sprite, Environment.teleporter.x, Environment.teleporter.y, 0, 1, 1, Environment.teleporter.width/2, Environment.teleporter.height/2)
		end

	 	for g, h in ipairs(Pickups.instances) do
	 		love.graphics.setColor(0, 0, 0, 50);
	 		love.graphics.draw(h.sprite, h.x + 3, h.y + 2, h.angle, h.resize, h.resize, h.width/2, h.height/2)
	 		love.graphics.setColor(255, 255, 255, 255);
	 		love.graphics.draw(h.sprite, h.x, h.y, h.angle, h.resize, h.resize, h.width/2, h.height/2)
	 	end

	    for f, a in ipairs(Player.farts) do
	    	love.graphics.setColor(255, 255, 255, a.opacity);
	    	love.graphics.draw(a.sprite, a.x, a.y, 0, 0.1, 0.1, a.width/2, a.height/2)
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

			local eHlth = (k.health*100)/k.maxHealth;

			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.rectangle("fill", k.x - 23, k.y + k.height - 7, eHlth / 2, 10)
			love.graphics.setColor(224, 62, 62, 255);
			love.graphics.rectangle("fill", k.x - 25, k.y + k.height - 10, eHlth / 2, 10)
			love.graphics.setColor(165, 92, 92, 255);
			love.graphics.rectangle("line", (k.x + (eHlth / 2)) - 25, k.y + k.height - 10, (100 - eHlth)/2, 10)
			love.graphics.setColor(255, 255, 255, 255);
			--love.graphics.setColor(0, 0, 0, 255);
	 		--love.graphics.rectangle("line", k.x, k.y, k.width, k.height)
		end

		for b, v in ipairs(Enemy.bullets) do
			love.graphics.setColor(70, 70, 70, 225)
			love.graphics.circle('fill', v.x, v.y, 5, 100)
			love.graphics.setColor(86, 83, 83, 225)
			love.graphics.circle('fill', v.x, v.y, 4, 100)
			love.graphics.setColor(255, 255, 255, 255)
		end

		for e, d in ipairs(Enemy.tanks.instances) do
			
			if(d.dir == 0) then 
				love.graphics.draw(d.sprite, d.x, d.y, 0, 1, 1, d.width/2, d.height/2)
				love.graphics.draw(d.spriteL, d.x + 32, d.y, 0, 1, 1, d.width/2, d.height/2) 
			else
				love.graphics.draw(d.sprite, d.x, d.y, 3.145, 1, 1, d.width/2, d.height/2) 
				love.graphics.draw(d.spriteL, d.x - 32, d.y, 3.145, 1, 1, d.width/2, d.height/2) 
			end
			--love.graphics.rectangle("line", d.x, d.y + d.height, d.width, d.height)
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
			if(Player.gun.rounds < 3) then love.graphics.setColor(255, 122, 122, 255); else love.graphics.setColor(255, 255, 255, 255); end
			love.graphics.draw(ammoIcon, 910 - elevation, Window.height - 77, 0, 0.35, 0.35)
		end

		if (Player.gun.rounds <= 0 and Player.gun.canReload) then
			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.print("Press R to RELOAD", 633, Window.height - 71);
			love.graphics.setColor(255, 122, 122, 255);
			love.graphics.print("Press R to RELOAD", 630, Window.height - 73);
		elseif Player.gun.canReload == false then
			love.graphics.setColor(0, 0, 0, 50);
			love.graphics.print("Reloading...", 673, Window.height - 71);
			love.graphics.setColor(255, 219, 112, 255);
			love.graphics.print("Reloading...", 670, Window.height - 73);
		end

		love.graphics.setColor(0, 0, 0, 50);
		love.graphics.print("Score "..Game.score, 96, Window.height - 106);
		love.graphics.setColor(255, 255, 255, 255);
		love.graphics.print("Score "..Game.score, 93, Window.height - 108);

		if(Pickups.speedTime > 0.0) then
		local eSpeedBar = (Pickups.speedTime*100)/5.0;
		eSpeedBar = eSpeedBar * 2
		love.graphics.setColor(0, 0, 0, 50);
		love.graphics.rectangle("fill", Window.width - 283, Window.height - 113, eSpeedBar, 25)
		love.graphics.setColor(53, 141, 211, 255);
		love.graphics.rectangle("fill", Window.width - 280, Window.height - 115, eSpeedBar, 25)
		love.graphics.setColor(47, 125, 188, 255);
		love.graphics.rectangle("line", (Window.width - 280) + (eSpeedBar), Window.height - 115, (200 - eSpeedBar), 25)
		love.graphics.setColor(255, 255, 255, 255);
		end
	end

	love.graphics.setColor(0, 0, 0, 255);
	love.graphics.rectangle("fill", Environment.blackbar.x, Environment.blackbar.y1, Environment.blackbar.width, Environment.blackbar.height)
	love.graphics.rectangle("fill", Environment.blackbar.x, Environment.blackbar.y2, Environment.blackbar.width, Environment.blackbar.height)
	love.graphics.setColor(255, 255, 255, 255);

	if (Menu.isActive) then
		-- for i = 0, Menu.buttons.count, 1 do
		-- 	love.g
		-- end
		love.graphics.setColor(0, 0, 0, 50);
		love.graphics.print(Game.version, Window.width - 127, 9);
		love.graphics.setColor(255, 255, 255, 255);
		love.graphics.print(Game.version, Window.width - 130, 7);

		love.graphics.draw(Menu.buttons.start.sprite, Menu.buttons.start.x - 30, Menu.buttons.start.y, 0, 1, 1)
		if(Game.needReset == false) then Menu.buttons.start.text = "Resume" elseif(Game.firstRound == true) then Menu.buttons.start.text = "Start" elseif(Game.needReset == true) then Menu.buttons.start.text = "Reset" end
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
		if (key == "r" and Player.gun.canReload and Player.canControl) then
			Player.gun.reloadTime = 0.75;
			Player.gun.rounds = 0;
			Player.gun.canReload = false;
		end
	end
end

function love.keyreleased( key )
	if (key == "escape") then
		if(not Game.needReset or not Game.firstRound) then
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

	if key == "space" then
		if(not Menu.isActive and not Game.needReset) then
			spawnFart()
		end
	end
	if(Game.inDebug) then
		if key == "x" then
			spawnTank()
		end

		if key == "y" then
			spawnEnemy()
		end

		if key == "c" then
			Game.score = Game.score + 500;
		end
	end
end

function love.textinput( text )

end

function love.mousefocus( f )

end

function love.mousepressed( x, y, button )
	if(Game.isActive) then
		if button == 1 and Player.gun.heat <= 0 and Player.gun.rounds > 0 and Player.canControl then
			local direction = math.atan2(love.mouse.getY() - Player.y, love.mouse.getX() - Player.x);

			pistolX = Player.x + ((10* math.cos(direction)) - (10 * math.sin(direction)));
			pistolY = Player.y + ((10* math.cos(direction)) + (10 * math.sin(direction)));

			table.insert(Player.bullets, {
				x = pistolX,
				y = pistolY,
				dir = direction,
				speed = 2000
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
					Game.firstRound = false,
					turnShaders(false)
					Game.needReset = false
				elseif Menu.buttons.start.text == "Reset" then
					love.load()
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
]]--

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
 ]]--

function twoSec_Timer(dt)
	if Environment.blackbar.delay then
		Environment.blackbar.delay = false;
		Environment.blackbar.animation = "up";
	end
end

function spawnTeleporter()
	--Environment.teleporter.isActive = true

	Environment.teleporter.x = love.math.random(150, Window.width - 150)
	Environment.teleporter.y = love.math.random(150, Window.height - 150)

	if rectangleCollision(Environment.teleporter.x, Environment.teleporter.y, Environment.teleporter.width, Environment.teleporter.height, Player.x, Player.y, Player.width + 200, Player.height + 200) then
		Environment.teleporter.isActive = false
		spawnTeleporter();
		return;
	end

	Environment.teleporter.isActive = true
end

function nextMap()
	Environment.map.index = Environment.map.index + 1

	if Environment.map.index == 1 then
		Window.background = love.graphics.newImage("/src/tile_17.png")
		local size = Environment.map.maxX * Environment.map.maxY
		Environment.map.spriteBatch = love.graphics.newSpriteBatch(Window.background, size)
		setupSpriteBatch()
		spawnParticles(love.math.random(10, 30));
	end

	if Environment.map.index == 2 then
		Window.background = love.graphics.newImage("/src/tile_09.png")
		local size = Environment.map.maxX * Environment.map.maxY
		Environment.map.spriteBatch = love.graphics.newSpriteBatch(Window.background, size)
		setupSpriteBatch()
		spawnParticles(love.math.random(10, 30));
	end
end

function getLocationOutsideBox()
	-- local w = 0
	-- local h = 0

	-- local rand = love.math.random(1, 4);

	-- if(rand == 1) then
	-- 	w = love.math.random(-250, -200);
	-- 	h = love.math.random(-250, Window.height + 250);
	-- end
	-- if(rand == 2) then
	-- 	w = love.math.random(Window.width + 200, Window.width + 250);
	-- 	h = love.math.random(-250, Window.height + 250);
	-- end
	-- if(rand == 3) then
	-- 	w = love.math.random(-250, Window.width + 250);
	-- 	h = love.math.random(-250, -200);
	-- end
	-- if(rand == 4) then
	-- 	w = love.math.random(-250, Window.width + 250);
	-- 	h = love.math.random(Window.height + 200, Window.height + 250);
	-- end

	-- local set = {width = w, height = h}
	-- return set;


	 -- local near_player = true
	 -- while near_player do
	 --  -- Random coordinates
	 --  local xS = love.math.random(-300, love.graphics.getWidth() + 300)
	 --  local yS = love.math.random(-300, love.graphics.getHeight() + 300)

	 --  -- Distance between player and zombie by X
	 --  local dist_x = math.abs(Player.x - xS)

	 --  -- Distance between player and zombie by Y
	 --  local dist_y = math.abs(Player.y - yS)

	 --  -- If distance > 100 by X and Y then quit loop 
	 --  if dist_x > Window.width and dist_y > Window.height then
	 --   near_player = false
	 --  end
	 -- end
	 local result = {x = 0, y = 0}
	 return result;
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

	 	if Player.lifes.amount == 3 then desaturate = shine.desaturate{strength = 0.2, tint = {255, 229, 229}}; vignette.parameters = {radius = 0.8, opacity = 0.55} end
	 	if Player.lifes.amount == 2 then desaturate = shine.desaturate{strength = 0.4, tint = {252, 209, 209}}; vignette.parameters = {radius = 0.7, opacity = 0.60} end
	 	if Player.lifes.amount == 1 then desaturate = shine.desaturate{strength = 0.5, tint = {252, 196, 196}}; vignette.parameters = {radius = 0.6, opacity = 0.65} end
	 	
	 	if Pickups.speedTime > 0.0 then desaturate = shine.desaturate{strength = 0.4, tint = {86, 180, 255}}; vignette.parameters = {radius = 0.99, opacity = 0.3} end

	    -- you can chain multiple effects
	    post_effect = desaturate:chain(vignette)
	    -- warning - setting parameters affects all chained effects:
    	--ost_effect.opacity = 0.4 -- affects both vignette and film grain
    end
end

function spawnParticles(count)
	for j, k in ipairs(Environment.map.particles) do
		table.remove(Environment.map.particles, j);
	end

	for i = 0, count, 1 do
		createParticle()
	end
end

function spawnFart()

	local randFart = love.math.random(0, 8);
	local pSprite = love.graphics.newImage("/src/Fart/fart0"..randFart..".png");
	local pAngle = love.math.random(0, 1);
	table.insert(Player.farts, {
		x = Player.x - ((pSprite:getWidth()/9)/2),
		y = Player.y - ((pSprite:getHeight()/9)/2),
		width = pSprite:getWidth()/9,
		height = pSprite:getHeight()/9,
		opacity = 240,
		angle = pAngle,
		sprite = pSprite,
	});

end

function createParticle()
	local pX = love.math.random(-32, Window.width + 32);
	local pY = love.math.random(-32, Window.height + 32);
	local pAngle = love.math.random(0.01, 0.99);

	for i, o in ipairs(Environment.map.particles) do
		if rectangleCollision(o.x, o.y, o.width, o.height, pX, pY, 64, 64) then
			createParticle();
			return;
		end
	end


	local pSprite = "/src/tile_"..love.math.random(0, 12)..".png";


	table.insert(Environment.map.particles, {
		x = pX,
		y = pY,
		width = 64,
		height = 64,
		angle = pAngle,
		sprite = love.graphics.newImage(pSprite),
	});
end

function spawnTank()
	if Enemy.canSpawn == false then return; end

	local tX = 0;
	local tY = 0;
	local tDir = love.math.random(0,1)

	if(tDir==0)then
		tX = -128;
	elseif tDir==1 then
		tX = Window.width;
	end
	
	tY = love.math.random(25, Window.height - 200);
	table.insert(Enemy.tanks.instances, {
		x = tX,
		y = tY,
		width = 128,
		height = 80,
		speed = love.math.random(250, 350),
		sprite = love.graphics.newImage("/src/towerDefense_tile269.png"),
		spriteL = love.graphics.newImage("/src/towerDefense_tile292.png"),
		dir = tDir

	});
end

function checkPlayerHealth()
	Player.lifes.amount = Player.lifes.amount - 1
	if(Player.lifes.amount < 4) then turnShaders(false); end
	if (Player.lifes.amount <= 0) then --debug chit
		if(Game.inDebug) then Player.lifes.amount = 5; else Game.isActive = false; Game.needReset = true; end
	end
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

function getEnemy()
	local enemyUnlocked = 0;
	if Game.score > 1000 then enemyUnlocked = 1; end 
	if Game.score > 2000 then enemyUnlocked = 2; end
	if Game.score > 3000 then enemyUnlocked = 3; end
	if Game.score > 4500 then enemyUnlocked = 4; end
	local enemyType = love.math.random(0, enemyUnlocked);
	return enemyType;
end


function spawnEnemy()
	--local locSet = getLocationOutsideBox()
	if Enemy.canSpawn == false then return; end

	local wXX = 0
	local hXX = 0

	local randX = love.math.random(1, 4);

	if(randX == 1) then
		wXX = love.math.random(-150, -128);
		hXX = love.math.random(-150, Window.height + 150);
	end
	if(randX == 2) then
		wXX = love.math.random(Window.width + 128, Window.width + 150);
		hXX = love.math.random(-150, Window.height + 150);
	end
	if(randX == 3) then
		wXX = love.math.random(-150, Window.width + 150);
		hXX = love.math.random(-150, -128);
	end
 	if(randX == 4) then
		wXX = love.math.random(-150, Window.width + 150);
		hXX = love.math.random(Window.height + 128, Window.height + 150);
	end
	local locSet = {x = wXX, y = hXX}
	-- for i, o in ipairs(Enemy.instances) do
	-- 	if rectangleCollision(o.x, o.y, o.width, o.height, locSet.x - (o.width/2), locSet.y - (o.height/2), 37 + ((o.width/2)*2), 43 + o.height) then
	-- 		spawnEnemy()
	-- 		return;
	-- 	end
	-- end

	local eX = locSet.x;
	local eY = locSet.y;

	--local eX = getLocationOutsideBox(0, 100);
	--local eY = getLocationOutsideBox(1, 100);
	local eSprite = love.graphics.newImage( "/src/survivor1_hold.png" );
	local eSpeed = love.math.random(15, 40);

	local eHealth = 150;
	local eCanShoot = false;

	local eHeat = 0.0;
	local eHeatp = 0.0;

	local eWSpeed = 0;
	local eID = love.math.random(0, 9999);
	local enemyType = getEnemy();
	local eDropRate = 45;
	if enemyType == 0 then
		eSprite = love.graphics.newImage( "/src/manOld_hold.png" );
		eSpeed = love.math.random(15, 25);
		eHealth = 100;
		eDropRate = 5;
		eCanShoot = false;
	elseif enemyType == 1 then
		eSprite = love.graphics.newImage( "/src/survivor1_hold.png" );
		eSpeed = love.math.random(30, 45);
		eHealth = 150;
		eDropRate = 10;
		eCanShoot = false;
	elseif enemyType == 2 then
		eSprite = love.graphics.newImage( "/src/robot1_hold.png" );
		eSpeed = love.math.random(10, 20);
		eHealth = 350;
		eDropRate = 20;
		eCanShoot = false;
	elseif enemyType == 3 then
		eSprite = love.graphics.newImage( "/src/soldier1_gun.png" );
		eSpeed = love.math.random(40, 55);
		eHealth = 175;
		eDropRate = 35;
		eCanShoot = true;
		eHeatp = 1.5
		eWSpeed = 150;
	elseif enemyType == 4 then
		eSprite = love.graphics.newImage( "/src/hitman1_silencer.png" );
		eSpeed = love.math.random(55, 75);
		eHealth = 100;
		eDropRate = 42;
		eCanShoot = true;
		eHeatp = 1.0
		eWSpeed = 300;
	end

	table.insert(Enemy.instances, {
		id = eID,
		x = eX,
		y = eY,
		width = eSprite:getWidth(),
		height = eSprite:getHeight(),
		angle = 0,
		health = eHealth,
		maxHealth = eHealth,
		dropRate = eDropRate,
		speed = eSpeed,
		sprite =  eSprite ,
		weapon = { speed = eWSpeed, },
		isShooting = eCanShoot,
		heat = 0.0,
		heatp = eHeatp,
	});


end

function maybe(x) if 100 * math.random() < x then return true else return false end  end 

function setupSpriteBatch()
  Environment.map.spriteBatch:clear()

  -- Set up (but don't draw) our images in a grid
  for y = 0, Environment.map.maxY do
    for x = 0, Environment.map.maxX do
      -- Convert our x/y grid references to x/y pixel coordinates
      local xPos = x * (Window.background:getWidth())
      local yPos = y * Window.background:getHeight()

      -- Add the image we previously set to this point
      Environment.map.spriteBatch:add(xPos, yPos)
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