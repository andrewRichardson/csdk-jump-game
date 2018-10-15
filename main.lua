--[[INITIALIZE GAME
local GRAVITY = 0.9;
local playerVelocity = {x = 0, y = 0};
local background;
local JUMP_HEIGHT = 22;
local LATERAL_SPEED = 10;
local LATERAL_RANGE = 300;
local MAX_VEL_X = 30;
local MAX_VEL_Y = 40;
local lastPosition = {x = 0, y = 0};
local lastVelocity = {x = 0, y = 0};
local platformPadding = 200;
local isCheckingCollisions = false;
local isOnPlatform = false;
local platformTemplate = {
    left = 140+20, middle = display.contentCenterX, right = display.actualContentWidth - 140 - 20
}
local platforms = {
    {}, {}, {}, {}, {}, {}
};
local platformGroup;
local playerSprite;
local playerWidth = 60;
local playerHeight = 100;
local playerBounds = display.newRect(display.contentCenterX, display.contentCenterY, playerWidth, playerHeight);
local platformGroupHeight = display.contentCenterY + playerHeight;

local function initPlatforms()
    platforms[1][1] = display.newRect(platformTemplate.middle, 5 * platformPadding, 120, 50);
    platforms[1][1]:setFillColor(0,0,0);
    platforms[1][1].strokeWidth = 5;
    platforms[1][1]:setStrokeColor(1,1,1);

    local lastScheme = 0;
    for i=2,6 do
        local platformScheme = math.random(6);
        if platformScheme == lastScheme then
            if platformScheme == 6 then
                platformScheme = 5;
            else
                platformScheme = platformScheme + 1;
            end
        end
        lastScheme = platformScheme;

        if platformScheme == 1 then
            platforms[i][1] = display.newRect(platformTemplate.left, (6 - i) * platformPadding, 120, 50);
            platforms[i][1]:setFillColor(0,0,0);
            platforms[i][1].strokeWidth = 5;
            platforms[i][1]:setStrokeColor(1,1,1);
        elseif platformScheme == 2 then
            platforms[i][1] = display.newRect(platformTemplate.middle, (6 - i) * platformPadding, 120, 50);
            platforms[i][1]:setFillColor(0,0,0);
            platforms[i][1].strokeWidth = 5;
            platforms[i][1]:setStrokeColor(1,1,1);
        elseif platformScheme == 3 then
            platforms[i][1] = display.newRect(platformTemplate.right, (6 - i) * platformPadding, 120, 50);
            platforms[i][1]:setFillColor(0,0,0);
            platforms[i][1].strokeWidth = 5;
            platforms[i][1]:setStrokeColor(1,1,1);
        elseif platformScheme == 4 then
            platforms[i][1] = display.newRect(platformTemplate.left, (6 - i) * platformPadding, 120, 50);
            platforms[i][1]:setFillColor(0,0,0);
            platforms[i][1].strokeWidth = 5;
            platforms[i][1]:setStrokeColor(1,1,1);


            platforms[i][2] = display.newRect(platformTemplate.middle, (6 - i) * platformPadding, 120, 50);
            platforms[i][2]:setFillColor(0,0,0);
            platforms[i][2].strokeWidth = 5;
            platforms[i][2]:setStrokeColor(1,1,1);
        elseif platformScheme == 5 then
            platforms[i][1] = display.newRect(platformTemplate.middle, (6 - i) * platformPadding, 120, 50);
            platforms[i][1]:setFillColor(0,0,0);
            platforms[i][1].strokeWidth = 5;
            platforms[i][1]:setStrokeColor(1,1,1);


            platforms[i][2] = display.newRect(platformTemplate.right, (6 - i) * platformPadding, 120, 50);
            platforms[i][2]:setFillColor(0,0,0);
            platforms[i][2].strokeWidth = 5;
            platforms[i][2]:setStrokeColor(1,1,1);
        elseif platformScheme == 6 then
            platforms[i][1] = display.newRect(platformTemplate.left, (6 - i) * platformPadding, 120, 50);
            platforms[i][1]:setFillColor(0,0,0);
            platforms[i][1].strokeWidth = 5;
            platforms[i][1]:setStrokeColor(1,1,1);


            platforms[i][2] = display.newRect(platformTemplate.right, (6 - i) * platformPadding, 120, 50);
            platforms[i][2]:setFillColor(0,0,0);
            platforms[i][2].strokeWidth = 5;
            platforms[i][2]:setStrokeColor(1,1,1);
        end
    end
end

--DRAW BACKGROUND
function setDisplay()
    display.setStatusBar(display.HiddenStatusBar);
    background = display.newImage("./assets/background.png", display.contentCenterX, display.contentCenterY);
end

setDisplay();
initPlatforms();

--DRAW PLAYER
playerSprite = display.newRect(display.contentCenterX, display.contentCenterY, playerWidth, playerHeight);
playerSprite:setFillColor(0,0,0);
playerSprite.strokeWidth = 6;
playerSprite:setStrokeColor(0.2,0.1,1)

local function hasCollided(obj1, obj2)
    if obj1 == nil then
        return false;
    end
    if obj2 == nil then
        return false;
    end
    local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin;
    local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax;
    local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin;
    local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax;

    return (left or right) and (up or down);
end

local function hasCollidedCircle(obj1, obj2) 
    if obj1 == nil then 
        return false;
    end 
    if obj2 == nil then
        return false;
    end 
    local sqrt = math.sqrt 
    local dx = obj1.x - obj2.x;
    local dy = obj1.y - obj2.y;
    local distance = sqrt(dx*dx + dy*dy);
    local objectSize = (obj2.actualContentWidth/2) + (obj1.actualContentWidth/2) ;
    if distance < objectSize then 
        return true;
    end 
    return false;
end

local function checkCollision()
    if isCheckingCollisions then
        return true;
    end
    isCheckingCollisions = true;
    for i=1,6 do
        for j,v in ipairs(platforms[i]) do
            if hasCollided(v, playerSprite) then
                if playerVelocity.y > 0 then
                    if hasCollided(v, playerBounds) == false then
                        if lastPosition.y - playerHeight/2 <= v.y + 25 then
                            platformGroupHeight = ((v.y) - (i*platformPadding));
                            playerVelocity.y = 0;
                            playerVelocity.x = 0;
                            isOnPlatform = true;
                        end
                    end
                end
            end
        end
    end
    isCheckingCollisions = false;
    return true;
end

--MAIN GAME LOOP
local function loop(event)
    lastPosition.x = playerSprite.x;
    lastPosition.y = platformGroupHeight-playerHeight;
    lastVelocity.x = playerVelocity.x;
    lastVelocity.y = playerVelocity.y;
    playerBounds.x = lastPosition.x;
    playerBounds.y = lastPosition.y;

    if isOnPlatform == false then
        playerVelocity.y = playerVelocity.y + GRAVITY;
    end

    if playerVelocity.x > MAX_VEL_X then
        playerVelocity.x = MAX_VEL_X;
    end
    if playerVelocity.x < -MAX_VEL_X then
        playerVelocity.x = -MAX_VEL_X;
    end
    if playerVelocity.y > MAX_VEL_Y then
        playerVelocity.y = MAX_VEL_Y;
    end
    if playerVelocity.y < -MAX_VEL_Y then
        playerVelocity.y = -MAX_VEL_Y;
    end

    playerSprite.x = playerSprite.x + playerVelocity.x;

    platformGroupHeight = platformGroupHeight - playerVelocity.y;

    for i=1,6 do
        for j,v in ipairs(platforms[i]) do
            v.y = (i * platformPadding) + platformGroupHeight;
        end
    end

    if playerSprite.x < 80 + playerWidth/2 then
        playerSprite.x = 80 + playerWidth/2;
    end

    if playerSprite.x > display.actualContentWidth - 80 - playerWidth/2 then
        playerSprite.x = display.actualContentWidth - 80 - playerWidth/2;
    end
end

--INPUT HANDLER
local function inputHandler(event)
    if event.name == "tap" then
        isOnPlatform = false;

        local x, y = event.target:contentToLocal(event.x, event.y);
        x = x + display.contentCenterX;
        y = y + display.contentCenterY;

        if x < 80 + playerWidth/2 then
            x = 80 + playerWidth/2;
        end
        if x > display.actualContentWidth - 80 - playerWidth/2 then
            x = display.actualContentWidth - 80 - playerWidth/2;
        end

        if x - playerSprite.x > 0 then
            playerVelocity.x = ((math.abs(x - playerSprite.x)/(display.actualContentWidth / 16)));
        elseif x - playerSprite.x < 0 then
            playerVelocity.x = -((math.abs(x - playerSprite.x)/(display.actualContentWidth / 16)));
        end

        playerVelocity.y = -JUMP_HEIGHT;
    end
end

background:addEventListener("tap", inputHandler);
background:addEventListener("touch", inputHandler);

Runtime:addEventListener("enterFrame", loop);
Runtime:addEventListener("enterFrame", checkCollision);--]]

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
local PLATFORM_PADDING = 2;
local MAX_NUM_PLATFORMS = 10;

local FORCE_JUMP_LATERAL = 4;
local FORCE_JUMP_VERTICAL = -10;
local MAX_VEL_X = 500;
local MAX_VEL_Y = 500;

local wallLeft = display.newRect(0 + (WALL_WIDTH / 2), CENTER_Y, WALL_WIDTH, HEIGHT);
local wallRight = display.newRect(WIDTH - (WALL_WIDTH / 2), CENTER_Y, WALL_WIDTH, HEIGHT);
local wallBottom = display.newRect(CENTER_X, HEIGHT - (WALL_WIDTH / 2), WIDTH, WALL_WIDTH);
local wallTop = display.newRect(CENTER_X, 0 + (WALL_WIDTH / 2), WIDTH, WALL_WIDTH);
local player = display.newRect(CENTER_X, CENTER_Y, 20, 50);

local platformTemplate = {
    left = WALL_WIDTH+PLATFORM_PADDING, middle = display.contentCenterX, right = display.actualContentWidth - WALL_WIDTH - PLATFORM_PADDING;
}
local platforms = display.newGroup();
local platformPatterns = 

local env_offset = 0;

physics.addBody(player, "dynamic", {bounce = 0.0, friction = 0.5});
player.isFixedRotation = true;
physics.addBody(wallLeft, "static", {bounce = 0.0, friction = 0.5});
physics.addBody(wallRight, "static", {bounce = 0.0, friction = 0.5});
physics.addBody(wallBottom, "static", {bounce = 0.0, friction = 0.5});
physics.addBody(wallTop, "static", {bounce = 0.0, friction = 0.5});

local function createPlatform()
    if platforms.numChildren >= MAX_NUM_PLATFORMS then
        platforms.remove(1);
    
        local lastScheme = platform[9].x == ;
            local platformScheme = math.random(6);
            if platformScheme == lastScheme then
                if platformScheme == 6 then
                    platformScheme = 5;
                else
                    platformScheme = platformScheme + 1;
                end
            end
            lastScheme = platformScheme;
    
            if platformScheme == 1 then
                platforms[i][1] = display.newRect(platformTemplate.left, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][1]:setFillColor(0,0,0);
                platforms[i][1].strokeWidth = 5;
                platforms[i][1]:setStrokeColor(1,1,1);
            elseif platformScheme == 2 then
                platforms[i][1] = display.newRect(platformTemplate.middle, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][1]:setFillColor(0,0,0);
                platforms[i][1].strokeWidth = 5;
                platforms[i][1]:setStrokeColor(1,1,1);
            elseif platformScheme == 3 then
                platforms[i][1] = display.newRect(platformTemplate.right, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][1]:setFillColor(0,0,0);
                platforms[i][1].strokeWidth = 5;
                platforms[i][1]:setStrokeColor(1,1,1);
            elseif platformScheme == 4 then
                platforms[i][1] = display.newRect(platformTemplate.left, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][1]:setFillColor(0,0,0);
                platforms[i][1].strokeWidth = 5;
                platforms[i][1]:setStrokeColor(1,1,1);
    
    
                platforms[i][2] = display.newRect(platformTemplate.middle, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][2]:setFillColor(0,0,0);
                platforms[i][2].strokeWidth = 5;
                platforms[i][2]:setStrokeColor(1,1,1);
            elseif platformScheme == 5 then
                platforms[i][1] = display.newRect(platformTemplate.middle, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][1]:setFillColor(0,0,0);
                platforms[i][1].strokeWidth = 5;
                platforms[i][1]:setStrokeColor(1,1,1);
    
    
                platforms[i][2] = display.newRect(platformTemplate.right, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][2]:setFillColor(0,0,0);
                platforms[i][2].strokeWidth = 5;
                platforms[i][2]:setStrokeColor(1,1,1);
            elseif platformScheme == 6 then
                platforms[i][1] = display.newRect(platformTemplate.left, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][1]:setFillColor(0,0,0);
                platforms[i][1].strokeWidth = 5;
                platforms[i][1]:setStrokeColor(1,1,1);
    
    
                platforms[i][2] = display.newRect(platformTemplate.right, (6 - i) * PLATFORM_PADDING, 120, 50);
                platforms[i][2]:setFillColor(0,0,0);
                platforms[i][2].strokeWidth = 5;
                platforms[i][2]:setStrokeColor(1,1,1);
            end
        end
    end
end

local function inputHandler(event)
    local x, y = event.x, event.y;

    local dx = x - player.x;
    local dy = player.y - y;

    local direction = 0;
    local rx = 0;
    if dx < 0 then
        direction = -1;
    else
        direction = 1;
    end
    rx = math.abs(dx) / (display.actualContentWidth - (WALL_WIDTH*2));

    local vx, vy = player:getLinearVelocity();

    print(rx..", "..direction);

    if vy == 0 then
        player:setLinearVelocity(0, vy);
        player:applyForce(direction * FORCE_JUMP_LATERAL * rx, FORCE_JUMP_VERTICAL, player.x, player.y);
    end
end

local function reset(event)
    player.x = CENTER_X;
    player.y = CENTER_Y;
    player:setLinearVelocity(0,0);
end

local reset = widget.newButton({
    x = CENTER_X,
    y = HEIGHT - 20 - 50;
    label = "RESET",
    onEvent = reset
});

local function loop(event)
    local vx, vy = player:getLinearVelocity();
    if vy > MAX_VEL_Y then
        player:setLinearVelocity(vx, MAX_VEL_Y);
    elseif vy < -MAX_VEL_Y then
        player:setLinearVelocity(vx, -MAX_VEL_Y);
    end
end

Runtime:addEventListener("enterFrame", loop);
Runtime:addEventListener("tap", inputHandler);