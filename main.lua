display.setStatusBar(display.HiddenStatusBar);
local physics = require("physics");
local widget = require("widget");

physics.start();
physics.setGravity(0, 9.8*2);

local WIDTH = display.actualContentWidth;
local HEIGHT = display.actualContentHeight;
local CENTER_X = WIDTH * 0.5;
local CENTER_Y = HEIGHT * 0.5;

local WALL_WIDTH = 20;
local PLATFORM_WIDTH = 50;
local PLATFORM_HEIGHT = 20;
local PLATFORM_PADDING = 80;
local MAX_HEIGHT_PLATFORM = display.actualContentHeight + PLATFORM_HEIGHT + PLATFORM_PADDING + 10; -- 10 is a buffer
local MIN_VISIBLE_OFFSET = (display.actualContentHeight * 0.5) - PLATFORM_HEIGHT + PLATFORM_PADDING + 10; -- 10 is a buffer
local JUMP_HEIGHT = 100;

local FORCE_JUMP_LATERAL = 4;
local FORCE_JUMP_VERTICAL = -25;
local MAX_VEL_X = 500;
local MAX_VEL_Y = 500;

local wallLeft = display.newRect(0 + (WALL_WIDTH / 2), CENTER_Y, WALL_WIDTH, HEIGHT);
local wallRight = display.newRect(WIDTH - (WALL_WIDTH / 2), CENTER_Y, WALL_WIDTH, HEIGHT);
local wallBottom = display.newRect(CENTER_X, HEIGHT - (WALL_WIDTH / 2), WIDTH, WALL_WIDTH);
local wallTop = display.newRect(CENTER_X, 0 + (WALL_WIDTH / 2), WIDTH, WALL_WIDTH);
local player = display.newRect(CENTER_X, CENTER_Y, 20, 50);

local platformTemplate = {
    left = WALL_WIDTH + PLATFORM_WIDTH, middle = display.contentCenterX, right = display.actualContentWidth - WALL_WIDTH - PLATFORM_WIDTH;
}
local platforms = display.newGroup();
local lastPattern = 1;
local lastPlatformY = 0;

local environment_offset = 0;

physics.addBody(player, "dynamic", {bounce = 0.0, friction = 0.8, density=2.0});
player.isFixedRotation = true;
physics.addBody(wallLeft, "static", {bounce = 0.0, friction = 0.5});
physics.addBody(wallRight, "static", {bounce = 0.0, friction = 0.5});
physics.addBody(wallBottom, "static", {bounce = 0.0, friction = 0.5});
wallBottom.isSensor = true;
physics.addBody(wallTop, "static", {bounce = 0.0, friction = 0.5});

local function initPlatforms()
    local platform, platform_2;
    local y = 0;
    for i=1,10 do
        y = (display.actualContentHeight - PLATFORM_PADDING) - (i * PLATFORM_PADDING);
        if i%2 == 1 then
            platform = display.newRect(platformTemplate.middle, (display.actualContentHeight - PLATFORM_PADDING) - (i * PLATFORM_PADDING), PLATFORM_WIDTH, PLATFORM_HEIGHT);
            
            platform:setFillColor(0,0,0);
            platform.strokeWidth = 2;
            platform:setStrokeColor(0.5,0.5,0.5);

            platforms:insert(platform);
            physics.addBody(platform, "static", {bounce = 0.0, friction = 0.5});
            platform.collType = "passthrough";
            platform:toBack();
        else
            platform = display.newRect(platformTemplate.left, (display.actualContentHeight - PLATFORM_PADDING) - (i * PLATFORM_PADDING), PLATFORM_WIDTH, PLATFORM_HEIGHT);
            
            platform:setFillColor(0,0,0);
            platform.strokeWidth = 2;
            platform:setStrokeColor(0.5,0.5,0.5);

            platforms:insert(platform);
            physics.addBody(platform, "static", {bounce = 0.0, friction = 0.5});
            platform.collType = "passthrough";
            platform:toBack();

            platform_2 = display.newRect(platformTemplate.right, (display.actualContentHeight - PLATFORM_PADDING) - (i * PLATFORM_PADDING), PLATFORM_WIDTH, PLATFORM_HEIGHT);
            
            platform_2:setFillColor(0,0,0);
            platform_2.strokeWidth = 2;
            platform_2:setStrokeColor(0.5,0.5,0.5);

            platforms:insert(platform_2);
            physics.addBody(platform_2, "static", {bounce = 0.0, friction = 0.5});
            platform_2.collType = "passthrough";
            platform_2:toBack();
        end
    end
    lastPlatformY = y;
end

local function handlePlatform()
    lastPlatformY = platforms[platforms.numChildren].y;
    for i= 1, platforms.numChildren do
        if platforms[i].y >= MAX_HEIGHT_PLATFORM then
            platforms.remove(platforms[i]);
            i=i-1;
        end
    end

    if environment_offset >= MIN_VISIBLE_OFFSET then
        environment_offset = 0;

        local newPattern = math.random(6);
        if newPattern == lastPattern then
            if newPattern == 6 then
                newPattern = 1;
            else
                newPattern = newPattern + 1;
            end
        end
        lastPattern = newPattern;
        local newPlatform = display.newRect(0, lastPlatformY - PLATFORM_PADDING, PLATFORM_WIDTH, PLATFORM_HEIGHT);
        local newPlatform_2 = display.newRect(0, lastPlatformY - PLATFORM_PADDING, PLATFORM_WIDTH, PLATFORM_HEIGHT);

        newPlatform:setFillColor(0,0,0);
        newPlatform.strokeWidth = 2;
        newPlatform:setStrokeColor(0.5,0.5,0.5);

        platforms:insert(newPlatform);
        physics.addBody(newPlatform, "static", {bounce = 0.0, friction = 0.5});
        newPlatform.collType = "passthrough";
        newPlatform:toBack();

        newPlatform_2:setFillColor(0,0,0);
        newPlatform_2.strokeWidth = 2;
        newPlatform_2:setStrokeColor(0.5,0.5,0.5);

        platforms:insert(newPlatform_2);
        physics.addBody(newPlatform_2, "static", {bounce = 0.0, friction = 0.5});
        newPlatform_2.collType = "passthrough";
        newPlatform_2:toBack();

        if newPattern == 1 then
            newPlatform.x = platformTemplate.left;
            newPlatform_2:removeSelf();
        elseif newPattern == 2 then
            newPlatform.x = platformTemplate.middle;
            newPlatform_2:removeSelf();
        elseif newPattern == 3 then
            newPlatform.x = platformTemplate.right;
            newPlatform_2:removeSelf();
        elseif newPattern == 4 then
            newPlatform.x = platformTemplate.left;

            newPlatform_2.x = platformTemplate.middle;
        elseif newPattern == 5 then
            newPlatform.x = platformTemplate.middle;

            newPlatform_2.x = platformTemplate.right;
        elseif newPattern == 6 then
            newPlatform.x = platformTemplate.left;

            newPlatform_2.x = platformTemplate.right;
        end
    end
end

local function inputHandler(event)
    local x, y = event.x, event.y;

    local diffX = event.x - player.x;

    local vx, vy = player:getLinearVelocity();

    if vy == 0 then
        player:applyLinearImpulse(diffX/15, FORCE_JUMP_VERTICAL, player.x, player.y);
        for i=1,platforms.numChildren do
            transition.moveTo(platforms[i], {y=platforms[i].y + JUMP_HEIGHT, transition=easing.inOutSine, time=800});
        end
        environment_offset = environment_offset + JUMP_HEIGHT;
    end
end

local function localPreCollision(self, event)
	if ("passthrough" == event.other.collType) then
		if (self.y + (self.height * 0.5) > event.other.y - (event.other.height * 0.5) + 0.2) then
			if event.contact then
                event.contact.isEnabled = false;
			end
		end
	end
	return true;
end

local function reset(event)
    player.x = CENTER_X;
    player.y = CENTER_Y;
    player:setLinearVelocity(0,0);
end

local function localCollision(self, event)
    if event.phase == "ended" then
        if event.other == wallBottom then
            reset();
        end
    end
end


local reset = widget.newButton({
    x = CENTER_X,
    y = HEIGHT - 20 - 50;
    label = "RESET",
    onEvent = reset
});

local function loop(event)
    handlePlatform();
end

initPlatforms();

player.preCollision = localPreCollision;
player.collision = localCollision;
player:addEventListener("collision", player);
player:addEventListener("preCollision", player);
Runtime:addEventListener("enterFrame", loop);
Runtime:addEventListener("tap", inputHandler);