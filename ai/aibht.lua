--
--  BehaviourTree
--
--  Created by Tilmann Hars on 2012-07-12.
--  Copyright (c) 2012 Headchant. All rights reserved.

-- You can find the original version at:
-- https://github.com/headchant/bhtlua/blob/master/aibht.lua

-- AI Behavior:
-- The crux of the idle behavior is dictated in "considerRandomAction"

local Tools = require( "helpers.Tools" )
local Class = require( "libraries.hump.class")

local bt = {}

local READY = "ready"
local RUNNING = "running"
local FAILED = "failed"

Action = Class({init = function(self, task)
    self.task = task
    self.completed = false
end})

function Action:update(creatureAI)
    if self.completed then return READY end
    self.completed = self.task(creatureAI)
    return RUNNING
end

Condition = Class({init = function(self, condition)
    self.condition = condition
end})

function Condition:update(creatureAI)
    return self.condition(creatureAI) and READY or FAILED
end

Selector = Class({init = function(self, children)
    self.children = children
end})

function Selector:update(creatureAI)
    for i,v in ipairs(self.children) do
        local status = v:update(creatureAI)
        if status == RUNNING then
            return RUNNING
        elseif status == READY then
            if i == #self.children then
                self:resetChildren()
                return READY
            end
        end
    end
    return READY
end

function Selector:resetChildren()
    for ii,vv in ipairs(self.children) do
        vv.completed = false
    end
end

Sequence = Class({init = function(self, children)
    self.children = children
    self.last = nil
    self.completed = false
end})

function Sequence:update(creatureAI)
    if self.completed then return READY end

    local last = 1

    if self.last and self.last ~= #self.children then
        last = self.last + 1
    end

    for i = last, #self.children do
        local v = self.children[i]:update(creatureAI)
        if v == RUNNING then
            self.last = i
            return RUNNING
        elseif v == FAILED then
            self.last = nil
            self:resetChildren()
            return FAILED
        elseif v == READY then
            if i == #self.children then
                self.last = nil
                self:resetChildren()
                self.completed = true
                return READY
            end
        end
    end

end

function Sequence:resetChildren()
    for ii,vv in ipairs(self.children) do
        vv.completed = false
    end
end

------

-- intelligence conditions --
local considerRangedSkill = Condition(function()
    -- to decide on whether to use the skill or not, depends on the last time he used it and his mp
    local random = math.min((system.getTimer() - bt.AIScript.player.lastRangedSkillTime) / 10000, 1)
    if math.random(0,random) * ( bt.AIScript.player.mpValue / bt.AIScript.player.fullmpValue ) > 0.9 then
        return true
    else
        return false
    end 
end)

local considerGettingItem = Condition(function()
    -- consider enemy and item distance
    bt.AIScript:nearestEnemy()
    bt.AIScript:nearestItem()

    local closestItemDist = math.sqrt( math.pow(bt.AIScript.player.closestItemDistanceX,2) + math.pow(bt.AIScript.player.closestItemDistanceY,2) )
    local closestEnemyDist = math.sqrt( math.pow(bt.AIScript.player.closestEnemyDistanceX,2) + math.pow(bt.AIScript.player.closestEnemyDistanceY,2) )
     
    if math.random(0.4,0.6)*closestItemDist < math.random(0.4,0.6)*closestEnemyDist then
        return true
    else
        return false
    end 
end)

-- location detecting conditions --

local detectIncomingAttack = Action( function()
    bt.AIScript.player.rangedDetectionDistance = Tools:generateRandomNumber(100,150,0.8) -- between 100 and 150, 100 almost fails every time, 150 usually passes
    if bt.AIScript:detectIncomingSkillOrItem() == true then
        bt.AIScript.player:defend()
    elseif bt.AIScript:detectIncomingAttack() == true then -- defend punch or not? 50% chance
        --if( Tools:generateRandomNumber(0,1,1) > 0.5 ) then -- this should be based on difficulty
            bt.AIScript.player:defend()
        --end
    end
    return true
end)

local doesAnEnemyEvenExist = Condition(function() 
    return bt.AIScript:doesEnemyExist() 
end)

local doesItemExist = Condition(function()
    return bt.AIScript:doesItemExist() 
end)

local isEnemyNearby = Condition(function() 
    -- if nearby, go into battle mode
    if( bt.AIScript:isEnemyNearby(150) == true ) then
        bt.AIScript.player.battleMode = true
        return true
    else
        bt.AIScript.player.battleMode = false
        return false
    end
end)

local isEnemyFarAway = Condition(function() 
    if( bt.AIScript:isEnemyNearby(150) == false ) then
        bt.AIScript.player.battleMode = false
        return true
    else
        bt.AIScript.player.battleMode = true
        return false
    end
end)

local isEnemyNearbyWithinPunchingDistance = Condition(function() 
    print("RUN?")
    return bt.AIScript:isEnemyNearby(50) 
end)

local isEnemyFarEnoughToRunAt = Condition(function() 
    return bt.AIScript:isEnemyFarEnoughToRunAt(200,50) 
end)

local isEnemyInLine = Condition(function()
    return bt.AIScript:isEnemyInLine()
end)

local isItemNearby = Condition(function() 
    return bt.AIScript:isItemNearby(100) 
end)

-- location actions --

local lineUpWithEnemy = Action( function()
    bt.AIScript:lineUpWithEnemy()
end)

local flee = Action( function()
    bt.AIScript:flee()
end)

local wander = Action( function()
    bt.AIScript:wander()
end)

local approachEnemy = Action( function()
    bt.AIScript:approachEnemy(100,20) -- will stay running if already running
    return true
end)

local approachEnemyToAttack = Action( function()
    print("APPROACH ENEMY TO ATTACK")
    -- readme required: this Action is first run when an AI steps close into your zone (less than a distance of (100,20))
    -- at that time, battleMode will still be set to false, which means you should cancel whatever running you were doing (goIdle), then walk just a teeny bit to go into battleMode = true 
    -- when battle mode is true, you should then return true so the AI doesnt keep unrealistically try to approach
    -- by returning true, this Action won't be "looped" automatically after entering the sequence anymore, so "attackRoutine" or whatever sequence node after this one
    -- will be rightfully executed
    if bt.AIScript.battleMode == false then 
        bt.AIScript.player:goIdle() 
        bt.AIScript:approachEnemy(40,10)
    else
        bt.AIScript:approachEnemy(40,10)
        if bt.AIScript.player.directionX == 0 and bt.AIScript.player.directionY == 0 then -- approached destination
            return true
        end
        return true
    end
end)

local run = Action( function()
    bt.AIScript:run()
end)

local runAndAttackAfter300ms = Action( function()
    bt.AIScript:run()
    timer.performWithDelay(300,
        function() bt.AIScript:normalAttack() end)

end)

local walkToItem = Action( function()
    bt.AIScript:walkTowards()
    return true
end)

-- state querying conditions --

local isItemHeld = Condition(function()
    return bt.AIScript.player.itemHeldFlag
end)

-- state/item based actions

local pickUpItem = Action( function()
    -- first go idle
    --bt.AIScript.player:goIdle()
    bt.AIScript.player:pickUpItem()
end)

-- attack actions --

local considerSkill = Condition(function()
    local timeSinceLastSkill = math.max(system.getTimer() - bt.AIScript.player.lastRangedSkillTime, system.getTimer() - bt.AIScript.player.lastMeleeSkillTime)
    if( timeSinceLastSkill > bt.AIScript.player.skillTimeout ) then
        if math.random() > 0.5 then
            if math.random() > 0.5 then
                bt.AIScript.player.chosenSkill = bt.AIScript.player.character.rangedSkills[ math.random(1,#bt.AIScript.player.character.rangedSkills) ]
                bt.AIScript.player.chosenSkillType = "ranged"
            else
                bt.AIScript.player.chosenSkill = bt.AIScript.player.character.meleeSkills[ math.random(1,#bt.AIScript.player.character.meleeSkills) ]
                bt.AIScript.player.chosenSkillType = "melee"
            end        
            return true
        else
            -- wait half a second before considering using skill again
            bt.AIScript.player.lastRangedSkillTime, bt.AIScript.player.lastMeleeSkillTime = system.getTimer()+500, system.getTimer()+500
        end
    else
        return false
    end
end)

local checkMana = Condition(function()
    return true -- well the skill itself has a mana check for now
end)

local performChosenSkill = Action(function()
    if bt.AIScript.player.chosenSkillType == "melee" then
        bt.AIScript:meleeSkill()
    else
        bt.AIScript:rangedSkill()
    end
    return true 
end)

local attackEnemy = Action( function()
    bt.AIScript:normalAttack()
end)

local useRangedSkill = Action( function()
    bt.AIScript:rangedSkill()
end)

local useMeleeSkill = Action( function()
    bt.AIScript:meleeSkill()
end)

local throwItem = Action( function()
    print(bt.AIScript.player.itemHeldFlag, ",called throw item")
    bt.AIScript.player:ItemAttack()
end)

-- random actions --
-- possible random actions: jumping, defending, stopping, running
local possibleActions = {
    "defending", -- includes rolling/sliding
    "stopping",
    "running",
    "jumping",
}

-- in performing a random action, since this code is looped every frame, we should consider how often to do it, eg. a timeout
-- so perhaps randomly do it once every 1-2 seconds
local considerRandomAction = Action( function()
    if system.getTimer() - bt.AIScript.player.lastRandomActionTime > bt.AIScript.player.lastRandomActionTimeout and bt.AIScript.battleMode == false then
        -- random scheme: jumping has higher priority, so random numbers usually come out higher
        local rand = math.random(1,#possibleActions)
        local randomAction = possibleActions[rand]
        print(rand, randomAction)

        -- don't repeat same action as last time; choose again in 500 ms
        if randomAction == bt.AIScript.player.lastRandomAction then
            bt.AIScript.player.lastRandomActionTimeout = 300
            print("Choose another action")
            return
        end

        if randomAction == "defending" then
            -- choose to defend, for example
            bt.AIScript.player:defend()
            -- lastRandomActionTimeOut is the amount of time before another random action will be chosen
            -- so if the range is (0.5,0.8), the AI might defend too often

            -- timeout is generated based on a random number range and a power (min,max,power)
            -- lower powers (<1) converge towards the max, higher powers (>1) converge towards the min
            -- (1,2,10) will give a mean of 1.09 over 20 samples
            -- (1,2,0.1) will give a mean of 1.95 over 20 samples
            bt.AIScript.player.lastRandomActionTimeout = Tools:generateRandomNumber(1,2,2)*1000 -- seconds
            bt.AIScript.player.lastRandomAction = "defending"
        elseif randomAction == "jumping" then
            bt.AIScript:jump()
            bt.AIScript.player.lastRandomActionTimeout = Tools:generateRandomNumber(2,3,1)*1000
            bt.AIScript.player.lastRandomAction = "jumping"
        elseif randomAction == "stopping" then
            bt.AIScript.player:goIdle()
            bt.AIScript.player.lastRandomActionTimeout = Tools:generateRandomNumber(0.2,0.3,1)*1000
            bt.AIScript.player.lastRandomAction = "stopping"
        elseif randomAction == "running" then
            -- no "running" in y-direction only
            if bt.AIScript.player.directionX ~= 0 then
                bt.AIScript:run()
                bt.AIScript.player.lastRandomActionTimeout = Tools:generateRandomNumber(1.5,3.0,5)*1000
                bt.AIScript.player.lastRandomAction = "running"

                timer.performWithDelay( bt.AIScript.player.lastRandomActionTimeout+1000, function()
                    -- dont't remain in running mode for too long, so go back to idle
                    -- but give a chance to do a defend move (run->defend->idle)
                    bt.AIScript.player:goIdle()
                end )
            end
        end

        bt.AIScript.player.lastRandomActionTime = system.getTimer()
        return true
    elseif bt.AIScript.battleMode == false then
        if bt.AIScript.player.lastRandomAction == "stopping" then
            return false -- if we wanted to go idle, we don't want to move the next frame, instead wait for the timeout duration (0.5-0.8 secs)
        else
            return true
        end
    elseif bt.AIScript.battleMode == true then
        return true
    end
end)

-- sample routines --

local rangedSkillRoutine = Selector{
                            Sequence{
                                isEnemyInLine,
                                useRangedSkill,
                            },
                            Sequence{
                                lineUpWithEnemy,
                            }
                        }

-- if not in line with enemy, line up with enemy first;
-- then throw the item
local throwItemRoutine = Selector{
                            Sequence{
                                isEnemyInLine,
                                throwItem,
                            },
                            Sequence{
                                lineUpWithEnemy,
                            }
                        }

-- if the item is nearby, pick it up, otherwise, walk to it first
local getItemRoutine = Selector{
                            Sequence{
                                isItemNearby,
                                pickUpItem,
                            },
                            -- item is not nearby. Is it worth getting?
                            Sequence{
                                walkToItem,
                            }
                        }

local attackRoutine = Selector{
                            Sequence{
                                isEnemyNearbyWithinPunchingDistance,
                                attackEnemy,
                            },
                            -- Sequence{
                            --     isEnemyFarEnoughToRunAt,
                            --     runAndAttackAfter300ms,
                            -- },
                        }

-- might use ranged skill
-- or melee skill
-- or just none at all
local considerSkillRoutine = Selector{
                                Sequence{
                                    considerSkill,
                                    checkMana,
                                    performChosenSkill
                                },
                            }

-- the approach enemy routine consists of random jumps and on-purpose pauses
local approachEnemyRoutine = Selector{
                                Sequence{
                                    considerRandomAction,
                                },                                
                                Sequence{
                                    doesAnEnemyEvenExist,
                                    approachEnemy,
                                },
                            }

-- attacking opponent is highest priority when he is nearby
-- otherwise, throw item at him if you have one
-- on a lower priority is to grab whatever item there is on the ground; this will be more random or weighted 
-- to prevent constant item grabbing;
-- last but not least, walk to enemy <- this action needs to return true because its the lone "item" in the sequence

local testRoutine = Selector{
    
    Sequence{
        detectIncomingAttack,
    },
    Sequence{
        isEnemyNearby, -- currently changed to 150 away
        approachEnemyToAttack, -- stop moving if enemy is close enough
        --considerSkillRoutine,
        attackRoutine,
    },
    -- -- Sequence{
    -- --     isItemHeld,
    -- --     throwItemRoutine,
    -- -- },
    -- -- Sequence{
    -- --     considerRangedSkill,
    -- --     rangedSkillRoutine
    -- -- },
    -- -- Sequence{
    -- --     doesItemExist,
    -- --     considerGettingItem,
    -- --     getItemRoutine,
    -- -- },
    Sequence{
        isEnemyFarAway,
        approachEnemyRoutine,
    }

}

function bt:setAI(script)
    bt.AIScript = script
end

bt.routine = testRoutine

---------------------------------------------------------------------------
-- Example

local TRUE = function() print('true') return true end
local FALSE = function() print('false') return false end

local isThiefNearTreasure = Condition(FALSE)
local stillStrongEnoughToCarryTreasure = Condition(TRUE)
local updated = false


local makeThiefFlee = Action(function() print("making the thief flee") return false end)
local chooseCastle = Condition(TRUE) --Action(function() print("1 choosing Castle") return true end)
local flyToCastle = Action(function() print("action node 1") return true end)
local fightAndEatGuards = Action(function() print("action node 2") return false end)
local takeGold = Action(function() print("3a picking up gold") return true end)
local flyHome = Action(function() print("3b1 flying home") end)
local putTreasureAway = Action(function() print("3b2 putting treasure away") return end)
local postPicturesOfTreasureOnFacebook = Action(function()
    print("5 posting pics on facebook")
    return true
end)

-- testing subtree
local packStuffAndGoHome = Selector{
    Sequence{
        stillStrongEnoughToCarryTreasure,
        takeGold,

    },
    Sequence{
        flyHome,
        putTreasureAway,
    }
}

local simpleBehaviour = Selector{
                            Sequence{
                                chooseCastle,
                                flyToCastle,  
                                fightAndEatGuards,
                                                              
                                --packStuffAndGoHome,
                                
                            },
                            -- Sequence{
                            --     flyHome,
                            --     putTreasureAway,
                            -- },
                        }


function bt:exampleLoop()
    for i=1,20 do
        simpleBehaviour:update()
    end
end
    
return bt