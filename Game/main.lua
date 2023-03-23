--Starters
--#region

local backgroundImage = nil
local CharX = 200
local CharY = 200

local DefaultSpeed = 80
local CurrentSpeed = 80
local DashMultiplier = 8

local Bullets = {}
local BulletSpeed = 300

local Shells = {}
local DefaultShellDuration = 2

local SeedCreatingValue = os.time()

local Enemies = {}
local CurrentEnemyCount = 1
local EnemySpeed = 50
local MinEnemyCount = 10

local Particles = {}

local Damage = 25

local BarrelLength = 27
local BarrelRotation = 0

local DefaultChasiRotationSpeed = 25
local ChasiRotationSpeed = 25
local ChasiRotation = 0
local ChasiDirection = {X = 0, Y = 0}

local moving = false

local LeftShoot = false

local KillCount = 0
local CollectedJuiceCount = 10
local JuiceCountInTable = 0
local juiceDuration = 30
local Juices = {}

---------
local GunHeat = 0
local GunHeatMin = 0
local GunHeatMax = 100
local GunHeatIncrease = 20
local GunHeatDecrease = 40
local GunHeatDecreaseDefault = 40
local GunHeatUISize = 200
local DefaultGunHeatUISize = 200
local GunHeatUIColorR = 0
local GunHeatUIColorG = 1

local Overheat = false
---------

---------
local isDashing = false
local canDash = true
local DashingCoolDownStopwatch = 0
local DashingDurationStopwatch = 0
local DashingDuration = 0.15
local DashingCoolDown = 1.4

local DashUISize = 200
local DefaultDashUISize = 200

local DashUIColorR = 0
local DashUIColorG = 255
---------

---------
local canShoot = true
local ShootingCoolDownStopwatch = 0
local ShootingCoolDown = 0.26

local ShootUISize = 25
local DefaultShootUISize = 25

local ShootUIColorR = 0
local ShootUIColorG = 255
---------

---------
local Health = 100
local HealthMax = 100

local GameOver = false
---------

local width, height = love.graphics.getDimensions()

local Apc = love.graphics.newImage("data/Sprites/Apc.png")
local Jeep = love.graphics.newImage("data/Sprites/Jeep.png")
local TankHull = love.graphics.newImage("data/Sprites/PlayerHull.png")
local TankTurret = love.graphics.newImage("data/Sprites/PlayerTurret.png")
local ArtilleryHull = love.graphics.newImage("data/Sprites/ArtilleryHull.png")
local GlassofPetrol = love.graphics.newImage("data/Sprites/GlassofPetrol.png")
local ArtilleryTurret = love.graphics.newImage("data/Sprites/ArtilleryTurret.png")
local KillCountText

local artilleryRange = 230

local mouseX, mouseY = 0, 0

local ColorForEndScreen = 0.3
--#endregion

local HC = require 'HC'

local PlayerHullCollider

function love.load()

    mouseX, mouseY = love.mouse.getPosition()

    UpdateKillUI()

    local intro =
    {
        "           _______   _         _______   _______   _______   _______   _",
        "|\\     /| (  ____ \\ ( \\       (  ____ \\ (  ___  ) (       ) (  ____ \\ ( )",
        "| )   ( | | (    \\/ | (       | (    \\/ | (   ) | | () () | | (    \\/ | |",
        "| | _ | | | (__     | |       | |       | |   | | | || || | | (__     | |",
        "| |( )| | |  __)    | |       | |       | |   | | | |(_)| | |  __)    | |",
        "| || || | | (       | |       | |       | |   | | | |   | | | (       (_)",
        "| () () | | (____/\\ | (____/\\ | (____/\\ | (___) | | )   ( | | (____/\\  _ ",
        "(_______) (_______/ (_______/ (_______/ (_______) |/     \\| (_______/ (_)",
        " ",
        " ",
        " ",
        "Keys:",
        "'WASD'/'Arrow Keys' to move.",
        "'Shift' dashes forward.",
        "'Left Click' to shoot.",
        "'Esc' quit.",
        " ",
        "Tips:",
        "Juices Heal you.",
        "If your gun overheats it cools down slower.",
        "You turn faster when you are not moving.",
        " ",
        "And most importantly",
        "Thanks for playing!"
    }

    print("Seed: " .. SeedCreatingValue)
    for index, txt in ipairs(intro) do
        print(txt)
    end

--Sounds
--#region
    BgMusic = love.audio.newSource("data/bgm.mp3", "static")
    BgMusic:setVolume(0.35)
    BgMusic:setLooping(true)
    BgMusic:play()

    ShootSFX = love.audio.newSource("data/attack.wav", "stream")
    ShootSFX:setVolume(0.15)

    HitSFX = love.audio.newSource("data/hit.wav", "stream")
    HitSFX:setVolume(0.5)

    DestroyedSFX = love.audio.newSource("data/destroy.wav", "stream")
    DestroyedSFX:setVolume(0.65)
--#endregion

    love.mouse.setVisible(false)
    backgroundImage = love.graphics.newImage("data/Sprites/Test.png")

    SpawnEnemies(10)

    PlayerHullCollider = HC.rectangle(1, 5, 30, 26)
    PlayerHullCollider:moveTo(CharX, CharY)
end

function love.draw()

    mouseX, mouseY = love.mouse.getPosition()

    -- Background
    --#region
    love.graphics.push()
    love.graphics.setColor(0, 0, 1)
    love.graphics.draw(backgroundImage, 0, 0)
    love.graphics.pop()
    --#endregion

    if GameOver then

        --Kill count shower
        love.graphics.push()
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", (width / 2) - 63, 150 - 23, 126, 46)
        love.graphics.pop()

        love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", (width / 2) - 60, 150 - 20, 120, 40)
        love.graphics.pop()

        love.graphics.push()
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Kill Count: " .. KillCount, width / 2, 150, 0, 1.25, 1.25, 35, 8)
        love.graphics.pop()

        --Game Over button
        love.graphics.push()
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", (width / 2) - 83, (height / 2) - 33, 166, 66)
        love.graphics.pop()

        love.graphics.push()
        love.graphics.setColor(ColorForEndScreen, ColorForEndScreen, ColorForEndScreen)
        love.graphics.rectangle("fill", (width / 2) - 80, (height / 2) - 30, 160, 60)
        love.graphics.pop()

        love.graphics.push()
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Game Over", width / 2, height / 2, 0, 2, 2, 33, 8)
        love.graphics.pop()
    else
    -- Draws Enemies using predetermined information
    --#region
    for i,CurrentEnemy in pairs(Enemies)
    do

        if CurrentEnemy.label == "EnemyNormal"
        then
            love.graphics.push()
            love.graphics.setColor(1, 1, 1)
            love.graphics.translate(CurrentEnemy.PosX, CurrentEnemy.PosY)
            love.graphics.rotate(CurrentEnemy.Rotation)
            love.graphics.draw(Apc, -Apc:getWidth() * 0.3, -Apc:getHeight() * 0.3, 0, 0.6, 0.6)
            love.graphics.pop()

        elseif CurrentEnemy.label == "ArtilleryEnemy"
        then
            --Hull
            love.graphics.push()
            love.graphics.setColor(1, 1, 1)
            love.graphics.translate(CurrentEnemy.PosX, CurrentEnemy.PosY)
            love.graphics.rotate(CurrentEnemy.Rotation)
            love.graphics.draw(ArtilleryHull, -ArtilleryHull:getWidth() * 0.3, -ArtilleryHull:getHeight() * 0.3, 0, 0.6, 0.6)
            love.graphics.pop()
            --Turret
            love.graphics.push()
            love.graphics.setColor(1, 1, 1)
            love.graphics.translate(CurrentEnemy.PosX, CurrentEnemy.PosY)
            love.graphics.rotate(CurrentEnemy.RotationTurret)
            love.graphics.draw(ArtilleryTurret, -ArtilleryTurret:getWidth() * 0.3, -ArtilleryTurret:getHeight() * 0.3, 0, 0.6, 0.6)
            love.graphics.pop()

        elseif CurrentEnemy.label == "FastEnemy"
        then
            love.graphics.push()
            love.graphics.setColor(1, 1, 1)
            love.graphics.translate(CurrentEnemy.PosX, CurrentEnemy.PosY)
            love.graphics.rotate(CurrentEnemy.Rotation)
            love.graphics.draw(Jeep, -Jeep:getWidth() * 0.3, -Jeep:getHeight() * 0.3, 0, 0.6, 0.6)
            love.graphics.pop()
        end
    end
    --#endregion

    -- Draws Particles using information that is determined on createCorpse
    --#region
    for pIndex, Particle in pairs(Particles)
    do
        love.graphics.push()
        love.graphics.setColor(Particle.Color, 1, Particle.Color)
        love.graphics.translate(Particle.PosX, Particle.PosY)
        love.graphics.circle("fill", 0, 0, Particle.Radius)
        love.graphics.pop()
    end
    --#endregion

    -- Character
    --#region
        love.graphics.push()
        love.graphics.translate(CharX, CharY)
        love.graphics.rotate(ChasiRotation)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(TankHull, -TankHull:getWidth() / 2, -TankHull:getHeight() / 2)
        love.graphics.pop()

        love.graphics.push()
        love.graphics.translate(CharX, CharY)
        BarrelRotation = CalculateRadianBetween(CharX, CharY, mouseX, mouseY)
        love.graphics.rotate(BarrelRotation)

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(TankTurret, -TankTurret:getWidth() / 2, -TankTurret:getHeight() / 2)
        love.graphics.pop()
    --#endregion

    -- Draws Juices
    --#region
    for i,CurrentJuice in pairs(Juices)
    do
        local scale = 0.8 * CurrentJuice.Size

        love.graphics.push()
        love.graphics.setColor(1, 1, 0, CurrentJuice.ColorA)
        love.graphics.translate(CurrentJuice.PosX, CurrentJuice.PosY)
        love.graphics.draw(GlassofPetrol, -(GlassofPetrol:getWidth() / 2), -(GlassofPetrol:getHeight() / 2),
        scale, scale, scale)
        love.graphics.pop()
    end
    --#endregion

    -- Draws Bullets using information that is determined on shoot
    --#region
    for i,CurrentBullet in pairs(Bullets)
    do
        love.graphics.push()
        love.graphics.setColor(1, 0, 0)
        love.graphics.translate(CurrentBullet.PosX, CurrentBullet.PosY)
        love.graphics.circle("fill", 0, 0, CurrentBullet.Radius)
        love.graphics.pop()
    end
    --#endregion

    -- Draws Shells using information that is determined on shoot
    --#region
    for i,CurrentShell in pairs(Shells)
    do
        love.graphics.push()
        love.graphics.setColor(1, 0, 0)
        love.graphics.translate(CurrentShell.PosX, CurrentShell.PosY)
        love.graphics.circle("fill", 0, 0, CurrentShell.Radius)
        love.graphics.pop()
    end
    --#endregion

    -- UI Elements
    --#region

        -- Dash UI Element
        love.graphics.push()
        love.graphics.setColor(love.math.colorFromBytes(DashUIColorR, DashUIColorG, 0))
        love.graphics.rectangle("fill", 10, 300 - 25 -( DashUISize / 2), 15, DashUISize, 5, 5)
        love.graphics.pop()

        -- Shoot UI Element
        love.graphics.push()
        love.graphics.setColor(love.math.colorFromBytes(ShootUIColorR, ShootUIColorG, 0))
        love.graphics.rectangle("fill", width - 25 - (ShootUISize / 2), 360, ShootUISize, 15)
        love.graphics.pop()

        -- Overheat UI Element
        love.graphics.push()
        love.graphics.setColor(GunHeatUIColorR, GunHeatUIColorG, 0)
        love.graphics.rectangle("fill", width - 32.5, 350, 15, -GunHeatUISize)
        love.graphics.pop()

        -- Health UI Element
        local HealthUISizeDefault = 200
        local HealthUISize = HealthUISizeDefault * (Health / HealthMax)

        love.graphics.push()
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", (width / 2) - HealthUISize / 2, height - 30, HealthUISizeDefault, 20)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", (width / 2) - HealthUISize / 2, height - 30, HealthUISize, 20)
        love.graphics.pop()

        love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(KillCountText, (width / 2) - (KillCountText:getWidth() / 2), 0)
        love.graphics.pop()
    --#endregion

    -- FPS
    --#region
        love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
        love.graphics.pop()
    --#endregion
    end

    -- Cursor
    --#region
        love.graphics.push()
        love.graphics.translate(mouseX, mouseY)

        -- Outer Cursor
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", 0, 0, 5)
        -- Mid Cursor
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 0, 0, 4)
        -- Inner Cursor
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", 0, 0, 2)

        love.graphics.pop()
    --#endregion

end

function love.update(dt)

    if GameOver
    then
        if mouseX > (width / 2) - 85 and mouseX < (width / 2) + 85 and
        mouseY > (height / 2) - 45 and mouseY < (height / 2) + 45 then

            ColorForEndScreen = 0.9

            --resets the game
            if love.mouse.isDown(1) then

                Particles = {}
                Enemies = {}
                Bullets = {}
                Shells = {}
                Juices = {}
                love.load()
                SeedCreatingValue = SeedCreatingValue + 1500
                ChasiRotationSpeed = 25
                ChasiRotation = 0
                ChasiDirection = {X = 0, Y = 0}
                CurrentSpeed = DefaultSpeed
                CharX, CharY = 200, 200
                KillCount = 0
                UpdateKillUI()
                GunHeat = 0
                Overheat = false
                isDashing = false
                canDash = true
                DashingCoolDownStopwatch = 0
                DashingDurationStopwatch = 0
                canShoot = true
                ShootingCoolDownStopwatch = 0
                GameOver = false
            end
        else
            ColorForEndScreen = 0.3
        end
    else
    --Particle Updating
    --#region
    for pIndex, Particle in pairs(Particles)
    do
        if Particle.timer > Particle.dissappearTime then

            table.remove(Particles, pIndex)
            Particle = nil
        else
            Particle.PosX = Particle.PosX + (Particle.directionX * Particle.speed * (1 - (Particle.timer / Particle.dissappearTime))) * dt
            Particle.PosY = Particle.PosY + (Particle.directionY * Particle.speed * (1 - (Particle.timer / Particle.dissappearTime))) * dt
            Particle.timer = Particle.timer + dt
        end
    end
    --#endregion

    --Reloading, Reaload UI & GunHeat, GunHeat UI managing #region
    --#region
    if canShoot and not Overheat
    then
        if love.mouse.isDown(1) then
            canShoot = false

            ShootUIColorR = 255
            ShootUIColorG = 0

            ShootUISize = 0

            Shoot()
            GunHeat = GunHeat + GunHeatIncrease
            if GunHeat > GunHeatMax then
                Overheat = true
                GunHeat = GunHeatMax

                --Making sure shootUI is at default state
                canShoot = true
                ShootingCoolDownStopwatch = 0

                ShootUIColorR = 0
                ShootUIColorG = 255

                ShootUISize = DefaultShootUISize

                GunHeatDecrease = GunHeatDecreaseDefault / 2
            end
        end
    elseif not Overheat
    then
        ShootUISize = (ShootingCoolDownStopwatch / ShootingCoolDown) * DefaultShootUISize

        ShootingCoolDownStopwatch = ShootingCoolDownStopwatch + dt
        if ShootingCoolDownStopwatch > ShootingCoolDown
        then
            canShoot = true
            ShootingCoolDownStopwatch = 0

            ShootUIColorR = 0
            ShootUIColorG = 255

            ShootUISize = DefaultShootUISize
        end
    else
    end

    if GunHeat > 0 then
        GunHeat = GunHeat - (GunHeatDecrease * dt)
        if GunHeat <= GunHeatMin then

            GunHeat = GunHeatMin

            Overheat = false
            GunHeat = GunHeatMin

            GunHeatDecrease = GunHeatDecreaseDefault
        end
    end

    local HeatPercentage = GunHeat / GunHeatMax

    GunHeatUIColorR = HeatPercentage
    GunHeatUIColorG = 1 - HeatPercentage
    GunHeatUISize = HeatPercentage * DefaultGunHeatUISize
    --#endregion

    --Enemy Updating
    --#region
    local normal, artillery, fast = 1, 1, 1

    for i,CurrentEnemy in pairs(Enemies)
    do
        local dir =
        CalculateDirection(CurrentEnemy.PosX, CurrentEnemy.PosY, CharX, CharY)

        if CurrentEnemy.label == "EnemyNormal"
        then
            local SpeedMultiplier = 1
            local RotatingSpeed = 0.006544984695 -- π/180 1 degree

            local AimToRadian = CalculateRadian(dir.X, dir.Y)
            local difference = CurrentEnemy.Rotation - AimToRadian

            difference = difference + 6.28318530718
            difference = difference % 6.28318530718

            if CurrentEnemy.Rotation == 0 then
                CurrentEnemy.Rotation = CalculateRadianBetween(
                    CurrentEnemy.PosX, CurrentEnemy.PosY, CharX, CharY) + 0.0001
            else

                if difference > 3.14159265359 then
                    CurrentEnemy.Rotation = CurrentEnemy.Rotation + RotatingSpeed
                else
                    CurrentEnemy.Rotation = CurrentEnemy.Rotation - RotatingSpeed
                end

                if difference < 0.05235987756 then -- π/60 3 degrees
                    CurrentEnemy.Rotation = AimToRadian
                end
            end

            local dir = DirectionFromRadian(CurrentEnemy.Rotation)
            CurrentEnemy.PosX = CurrentEnemy.PosX + dir.X * dt * EnemySpeed * SpeedMultiplier
            CurrentEnemy.PosY = CurrentEnemy.PosY + dir.Y * dt * EnemySpeed * SpeedMultiplier

            CurrentEnemy.Collider:moveTo(CurrentEnemy.PosX, CurrentEnemy.PosY)
            CurrentEnemy.Collider:rotate(CurrentEnemy.Rotation , CurrentEnemy.PosX, CurrentEnemy.PosY)
            if CurrentEnemy.Collider:collidesWith(PlayerHullCollider)
            then
                DecreaseHealth()
                DamageGivenEnemy(CurrentEnemy, i, true)
            end

            normal = normal + 1

        elseif CurrentEnemy.label == "ArtilleryEnemy"
        then
            if not CurrentEnemy.CanShoot
            then
                CurrentEnemy.ShootTimer = CurrentEnemy.ShootTimer + dt

                if CurrentEnemy.ShootTimer > CurrentEnemy.shootDelay
                then
                    CurrentEnemy.CanShoot = true
                    ShootTimer = 0
                end
            end

            local RotatingSpeed = 0.006544984695 -- π/180 1 degree

            local AimToRadian = CalculateRadian(dir.X, dir.Y)
            CurrentEnemy.RotationTurret = AimToRadian
            local difference = CurrentEnemy.Rotation - AimToRadian

            difference = difference + 6.28318530718
            difference = difference % 6.28318530718

            local _speedMultiplier = 0.5

            local difBetweenArtileryAndChar = CalculateDifference(CurrentEnemy.PosX, CurrentEnemy.PosY, CharX, CharY)
            if difBetweenArtileryAndChar < 400
            then
                RotatingSpeed = 0.0098174770425 -- π/120 1.5 degrees
                _speedMultiplier = 0

                if CurrentEnemy.CanShoot then
                    CurrentEnemy.ShootTimer = 0
                    CurrentEnemy.CanShoot = false
                    ShootArtillery(CurrentEnemy.PosX + dir.X * 30, CurrentEnemy.PosY + dir.Y * 30, CharX, CharY, difBetweenArtileryAndChar / 400)
                end
            end

            if CurrentEnemy.Rotation == 0 then
                CurrentEnemy.Rotation = CalculateRadianBetween(
                    CurrentEnemy.PosX, CurrentEnemy.PosY, CharX, CharY) + 0.0001
            else

                if difference > 3.14159265359 then
                    CurrentEnemy.Rotation = CurrentEnemy.Rotation + RotatingSpeed
                else
                    CurrentEnemy.Rotation = CurrentEnemy.Rotation - RotatingSpeed
                end

                if difference < 0.05235987756 then -- π/60 3 degrees
                    CurrentEnemy.Rotation = AimToRadian
                end
            end

            local dir = DirectionFromRadian(CurrentEnemy.Rotation)
            CurrentEnemy.PosX = CurrentEnemy.PosX + dir.X * dt * EnemySpeed * _speedMultiplier
            CurrentEnemy.PosY = CurrentEnemy.PosY + dir.Y * dt * EnemySpeed * _speedMultiplier

            CurrentEnemy.Collider:moveTo(CurrentEnemy.PosX, CurrentEnemy.PosY)
            CurrentEnemy.Collider:rotate(CurrentEnemy.Rotation, CurrentEnemy.PosX, CurrentEnemy.PosY)
            if CurrentEnemy.Collider:collidesWith(PlayerHullCollider)
            then
                DecreaseHealth()
                DamageGivenEnemy(CurrentEnemy, i, true)
            end

            artillery = artillery + 1
        elseif CurrentEnemy.label == "FastEnemy"
        then
            local SpeedMultiplier = 2
            local RotatingSpeed = 0.006544984695 -- π/180 1 degree

            local AimToRadian = CalculateRadian(dir.X, dir.Y)
            local difference = CurrentEnemy.Rotation - AimToRadian

            difference = difference + 6.28318530718
            difference = difference % 6.28318530718

            if CalculateDifference(CurrentEnemy.PosX, CurrentEnemy.PosY, CharX, CharY) > 150
            then
                RotatingSpeed = 0.01308996939 -- π/90 2 degrees
                SpeedMultiplier = 1.3
            end

            if CurrentEnemy.Rotation == 0 then
                CurrentEnemy.Rotation = CalculateRadianBetween(
                    CurrentEnemy.PosX, CurrentEnemy.PosY, CharX, CharY) + 0.0001
            else

                if difference > 3.14159265359 then
                    CurrentEnemy.Rotation = CurrentEnemy.Rotation + RotatingSpeed
                else
                    CurrentEnemy.Rotation = CurrentEnemy.Rotation - RotatingSpeed
                end

                if difference < 0.05235987756 then -- π/60 3 degrees
                    CurrentEnemy.Rotation = AimToRadian
                end
            end

            local dir = DirectionFromRadian(CurrentEnemy.Rotation)
            CurrentEnemy.PosX = CurrentEnemy.PosX + dir.X * dt * EnemySpeed * SpeedMultiplier
            CurrentEnemy.PosY = CurrentEnemy.PosY + dir.Y * dt * EnemySpeed * SpeedMultiplier

            CurrentEnemy.Collider:moveTo(CurrentEnemy.PosX, CurrentEnemy.PosY)
            CurrentEnemy.Collider:rotate(CurrentEnemy.Rotation , CurrentEnemy.PosX, CurrentEnemy.PosY)
            if CurrentEnemy.Collider:collidesWith(PlayerHullCollider)
            then
                DecreaseHealth()
                DamageGivenEnemy(CurrentEnemy, i, true)
            end

            fast = fast + 1
        end

        --Check if Collided with PlayerHull--------------------------------------------------------------------------------------------------------------------------------------
    end
    --#endregion

    --Decrease Health
    --#region

    function DecreaseHealth()
    Health = Health - 10

    if Health <= 0
    then
        Health = 0
        GameOver = true
    end
    end
    --#endregion

    --Bullet Updating   
    --#region
    for i,CurrentBullet in pairs(Bullets)
    do
        if CurrentBullet.Timer > 3 then

            table.remove(Bullets, i)
            CurrentBullet = nil
        else
            CurrentBullet.Timer = CurrentBullet.Timer + dt
            CurrentBullet.PosX = CurrentBullet.PosX + (CurrentBullet.directionX * dt * BulletSpeed)
            CurrentBullet.PosY = CurrentBullet.PosY + (CurrentBullet.directionY * dt * BulletSpeed)

            CurrentBullet.Collider:moveTo(CurrentBullet.PosX, CurrentBullet.PosY)

            for j,CurrentEnemy in pairs(Enemies)
            do
                if Exists(CurrentBullet)
                then
                    if CurrentBullet.Collider:collidesWith(CurrentEnemy.Collider)
                    then
                        CrateDamageParticle(CurrentBullet, CurrentEnemy)

                        DamageGivenEnemy(CurrentEnemy, j, false)

                        table.remove(Bullets, i)
                        CurrentBullet = nil
                    end
                end
            end
        end
    end
    --#endregion

    --Shell Updating
    --#region
    for i,CurrentShell in pairs(Shells)
    do
    CurrentShell.Timer = CurrentShell.Timer + dt
    local percentage = CurrentShell.Timer / CurrentShell.Duration

    if CurrentShell.Timer > CurrentShell.Duration
    then
        if  HC.circle(CurrentShell.toX, CurrentShell.toY, 5):collidesWith(PlayerHullCollider)
        then
            DecreaseHealth()
        end


        local newCorpse =
        {
            PosX = CurrentShell.toX,
            PosY = CurrentShell.toY,
            Radius = 5,
            ColorR = 255,
            ColorG = 0,
            ColorB = 0,
            label = ""
        }

        CreateCorpse(newCorpse)

        table.remove(Shells, i)
        CurrentShell = nil

    else
        CurrentShell.PosX = CurrentShell.fromX + (CurrentShell.toX - CurrentShell.fromX) * percentage
        CurrentShell.PosY = CurrentShell.fromY + (CurrentShell.toY - CurrentShell.fromY) * percentage

        CurrentShell.Radius = 1 + (math.sin(percentage * 3.14159265359) * 5)
        --if percentage < 0.5 then
        --    CurrentShell.Radius = 1 + (percentage * 10)
        --else-- percentage > 5
        --    CurrentShell.Radius = 1 + (10 - (percentage * 10))
        --end
    end
    end
    --#endregion

    --Basic dashing and regranting controlls & Dash UI managing.
    --#region
    if canDash then
        if love.keyboard.isDown("lshift") and (moving) then
            canDash = false
            isDashing = true
        end
    else
        DashUISize = DefaultDashUISize * (1 - (DashingCoolDown - DashingCoolDownStopwatch) / DashingCoolDown)

        DashingCoolDownStopwatch = DashingCoolDownStopwatch + dt
        if DashingCoolDownStopwatch > DashingCoolDown
        then
            DashingCoolDownStopwatch = 0
            canDash = true

            DashUISize = DefaultDashUISize

            DashUIColorR = 0
            DashUIColorG = 255
        end
    end
    --#endregion

    -- If we're not dashing we check for movement and turn inputs.
    --#region
    moving = false

    if not isDashing
    then
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
            if (not love.keyboard.isDown("down") and not love.keyboard.isDown("s")) then

                MoveForward(dt, true)
                moving = true
            end
        elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then

            MoveForward(dt, false)
            moving = true
        end

        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            if (not love.keyboard.isDown("right") and not love.keyboard.isDown("d")) then
                Turn(dt, false)
            end
        elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            Turn(dt, true)
        end
    else
    --#endregion+

    --If it's dashing we just lock movement, boost our current speed, and check if the duration is longer than it is supposed to be w/ a stopwatch.
    --#region
        if DashingDurationStopwatch > DashingDuration
        then
            CurrentSpeed = DefaultSpeed
            DashingDurationStopwatch = 0
            isDashing = false

            DashUIColorR = 255
            DashUIColorG = 0

            DashUISize = 0
        else
            DashingDurationStopwatch = DashingDurationStopwatch + dt
            CurrentSpeed = DefaultSpeed * DashMultiplier

            DashUISize = DefaultDashUISize * (DashingDuration - DashingDurationStopwatch) / DashingDuration

            MoveForward(dt, true)
        end
    end
    --#endregion

    --Updates juices
    --#region
    for i,CurrentJuice in pairs(Juices)
    do
        if CurrentJuice.Timer > juiceDuration then
            table.remove(Juices, i)
            CurrentJuice = nil
        else
            CurrentJuice.Timer = CurrentJuice.Timer + dt
            CurrentJuice.ColorA = ((CurrentJuice.ColorA - (CurrentJuice.Timer / juiceDuration)) * 0.75 ) + 0.25

            --GettingBigger
            --if CurrentJuice.GettingBigger then
            --    CurrentJuice.Size = CurrentJuice.Size + (dt * 0.5)
            --    if CurrentJuice.Size > 1.2 then
            --        CurrentJuice.Size = 1.2
            --        CurrentJuice.GettingBigger = false
            --    end
            --else
            --    CurrentJuice.Size = CurrentJuice.Size - (dt * 0.5)
            --    if CurrentJuice.Size < 0.8 then
            --        CurrentJuice.Size = 0.8
            --        CurrentJuice.GettingBigger = true
            --    end
            --end

            if HC.circle(CurrentJuice.PosX - 2, CurrentJuice.PosY, 0.65 * CurrentJuice.Size):collidesWith(PlayerHullCollider)
            then
                Health = Health + 50
                if Health > 100 then
                    Health = 100
                end

                table.remove(Juices, i)
                CurrentJuice = nil
            end
        end
    end
    --#endregion

    --Limits the player to the screen.
    --#region
    if CharX > width * 0.98 then
        CharX = width * 0.98
    elseif CharX < width * 0.02 then
        CharX = width * 0.02
    end

    if CharY > height * 0.965 then
        CharY = height * 0.965
    elseif CharY < height * 0.035 then
        CharY = height * 0.035
    end
    --#endregion

    PlayerHullCollider:moveTo(CharX, CharY)
    PlayerHullCollider:rotate(ChasiRotation)
    end

    --Collider:Update(dt)
    ChasiDirection = DirectionFromRadian(ChasiRotation)

--Quiting the game
    function love.keypressed(key)
        if key == "escape" then
            love.event.quit()
        end
    end

end

--Changes the direction of the chasi based on the rotation.
function MoveForward(dt, Forward)

    local sign = -1
    if Forward then
        sign = 1
    end

    local dir = ChasiDirection

    CharX = CharX + CurrentSpeed * dt * dir.X * sign
    CharY = CharY + CurrentSpeed * dt * dir.Y * sign
end

--Changes the rotation of the chasi.
function Turn(dt, ToRight)

    if not moving then
        ChasiRotationSpeed = DefaultChasiRotationSpeed * 2.3
    else
        ChasiRotationSpeed = DefaultChasiRotationSpeed
    end

    if ToRight
    then
        ChasiRotation = ChasiRotation +
        ((0.03490658503988659153847381537) * ChasiRotationSpeed) * dt-- +((π / 90) * speed)
    else
        ChasiRotation = ChasiRotation -
        ((0.03490658503988659153847381537) * ChasiRotationSpeed) * dt-- -((π / 90) * speed)
    end
end

--Shoots a bullet in the direction of the mouse.
function Shoot()

    ShootSFX:stop()
    ShootSFX:play()

    local dir = DirectionFromRadian(BarrelRotation)

    for i = 1, 2 do

        LeftShoot = not LeftShoot

        local X, Y = 0, 0

        --shoot from a little left of the barrel when left shoot is true
        if LeftShoot
        then
            X = dir.X * (BarrelLength - 3) - dir.Y * 3
            Y = dir.Y * (BarrelLength - 3) + dir.X * 3
        else
            X = dir.X * (BarrelLength - 3) + dir.Y * 3
            Y = dir.Y * (BarrelLength - 3) - dir.X * 3
        end

        local NewBullet =
        {
            PosX = CharX + X, PosY = CharY + Y, Radius = 2, label = "Bullet",
            directionX = dir.X, directionY = dir.Y, Timer = 0,
            Collider = nil
        }

        NewBullet.Collider = HC.circle(NewBullet.PosX, NewBullet.PosY, NewBullet.Radius)
        table.insert(Bullets, NewBullet)
    end
end

--Damages given enemy
function DamageGivenEnemy(CurrEy, index, killed)

    CurrEy.Hp = CurrEy.Hp - Damage

    if killed then
        CurrEy.Hp = 0
    end

    if CurrEy.Hp <= 0
    then

        KillCount = KillCount + 1
        UpdateKillUI()
        CreateCorpse(CurrEy)

        if(RandNumber() <= 0.15)
        then
            SpawnJuice(CurrEy.PosX, CurrEy.PosY)
        end

        DestroyedSFX:stop()
        DestroyedSFX:play()

        CurrentEnemyCount = CurrentEnemyCount - 1

        table.remove(Enemies, index)
        CurrEy = nil



        if(CurrentEnemyCount <= MinEnemyCount)
        then
            SpawnEnemies(10)
        end
    else
        HitSFX:stop()
        HitSFX:play()
    end
end

--Shoots artillery shell
function ShootArtillery(FromX, FromY, ToX, ToY, lengthMultiplier)

    local NewShell =
    {
        PosX = FromX, PosY = FromY, label = "ArtilleryBullet",
        fromX = FromX, fromY = FromY, toX = ToX, toY = ToY,
        Timer = 0, Radius = 1, Duration = DefaultShellDuration * lengthMultiplier
    }

    table.insert(Shells, NewShell)
end

--Spawns Enemies
function SpawnEnemies(SpawnThisMuch)

    local Spawned = 0
    -- Creates "EnemyCount" ammount of random enemy information and sorts them into a table
    while Spawned <= SpawnThisMuch
    do
        local Enemy = CreateEnemyObj()
        table.insert(Enemies,Enemy)

        CurrentEnemyCount = CurrentEnemyCount + 1
        Spawned = Spawned + 1
    end

    --Sorts player biggest to smallest so that smaller objects are drawen last
    --Therefor they appear on top of bigger ones
    table.sort (Enemies, function (k1, k2) return k1.Radius > k2.Radius end )
end

--Creates an enemy object
function CreateEnemyObj()

    local x, y = CalculateAPosOutsideWindow()
    local CurrentLabel
    local Enemy


    local r = RandNumber()
    if r < 0.7 then
        CurrentLabel = "EnemyNormal"
    elseif r < 0.85 then
        CurrentLabel = "ArtilleryEnemy"
    else
        CurrentLabel = "FastEnemy"
    end

    local ax, ay, bx, by = 0, 0, 0, 0

    if CurrentLabel == "EnemyNormal"
    then
        Enemy =
        {
            PosX = x, PosY = y, Radius = 15, Hp = 100, Rotation = 0,
            label = "EnemyNormal", index = CurrentEnemyCount,
            Collider = nil
        }
        -- To be changed later
        ax = 7 * 0.6
        ay = 2 * 0.6
        bx = 56 * 0.6
        by = 29 * 0.6

        Enemy.Collider = HC.rectangle(ax, ay, bx, by)

    elseif CurrentLabel == "ArtilleryEnemy"
    then
        Enemy =
        {
            PosX = x, PosY = y, Radius = 15, Hp = 50, Rotation = 0,
            label = "ArtilleryEnemy", index = CurrentEnemyCount, RotationTurret = 0,
            CanShoot = true, ShootTimer = 0, shootDelay = 8,
            Collider = nil
        }

        --0.6 is the scale of the image
        ax = 1 * 0.6
        ay = 3 * 0.6
        bx = 29 * 0.6
        by = 28 * 0.6

        Enemy.Collider = HC.rectangle(ax, ay, bx, by)

    elseif CurrentLabel == "FastEnemy"
    then
        Enemy =
        {
            PosX = x, PosY = y, Radius = 15, Hp = 75, Rotation = 0,
            label = "FastEnemy", index = CurrentEnemyCount,
            Collider = nil
        }

        --0.6 is the scale of the image
        ax = 7 * 0.6
        ay = 2 * 0.6
        bx = 56 * 0.6
        by = 29 * 0.6

        Enemy.Collider = HC.rectangle(ax, ay, bx, by)

    end

    return Enemy
end

--Creates a Juice 
function SpawnJuice(x, y)

    local Juice =
    {
        PosX = x, PosY = y, label = "Juice", Index = JuiceCountInTable, Timer = 0,
        ColorA = 1, Size = 1, GettingBigger = true
    }

    JuiceCountInTable = JuiceCountInTable + 1
    table.insert(Juices, Juice)
end

--Creates a collection of particles to represent the damage done to an enemy
function CrateDamageParticle(Bullet, Corpse)

    local ParticleCount = (Corpse.Radius / 3 + 10);
    local CorpseParticleCount = 0

    while CorpseParticleCount <= (ParticleCount + 2)
    do
        local x, y = CalculateAPosInRadius(Corpse.Radius)
        local NewParticle = {}

        if Corpse.label == "FastEnemy" or Corpse.label == "ArtilleryEnemy" then
            NewParticle =
            {
                PosX = Corpse.PosX + x, PosY = Corpse.PosY  + y, Radius = 1,
                label = "Particle", timer = 0, speed = (RandNumber() * BulletSpeed * 0.5) + 300, dissappearTime = (RandNumber() * 3),
                directionX = 0, directionY = 0, Color = 0.2 + RandNumber()
            }
        else
            NewParticle =
            {
                PosX = Corpse.PosX + x, PosY = Corpse.PosY  + y, Radius = 1,
                label = "Particle", timer = 0, speed = (RandNumber() * BulletSpeed * 0.5) + 300, dissappearTime = (RandNumber() * 3),
                directionX = 0, directionY = 0, Color = 0.2 + RandNumber()
            }
        end

        if CorpseParticleCount >= ParticleCount then

            NewParticle.directionX = Bullet.directionX
            NewParticle.directionY = Bullet.directionY

            NewParticle.Radius = 1
            NewParticle.ColorR = 255
            NewParticle.ColorG = 0
            NewParticle.ColorB = 0
        else
            local dir1 = CalculateDirection(Bullet.PosX, Bullet.PosY, NewParticle.PosX, NewParticle.PosY)
            local dir2 = {X = 0, Y = 0}
            dir2.X, dir2.Y = Bullet.directionX, Bullet.directionY

            local dir = {X = 0, Y = 0}
            dir.X, dir.Y = (dir1.X + dir2.X) / 2, (dir1.Y + dir2.Y) / 2

            --print("1: x;" .. dir.X .. ", y; " .. dir.Y)
            dir = Normalize(dir)--It is worth the extra cost of normalizing the vector.
            --print("2: x;" .. dir.X .. ", y; " .. dir.Y)

            NewParticle.directionX = dir.X
            NewParticle.directionY = dir.Y
        end

        table.insert(Particles, NewParticle)
        CorpseParticleCount = CorpseParticleCount + 1
    end
end

--Creates a collection of particles as in corpse.
function CreateCorpse(Corpse)

    local ParticleCount = Corpse.Radius;
    local CorpseParticleCount = 0

    local NewParticle = {}

    while CorpseParticleCount <= ParticleCount + 4
    do
        local x, y = CalculateAPosInRadius(Corpse.Radius)

        if Corpse.label == "FastEnemy" or Corpse.label == "ArtilleryEnemy" then
            NewParticle =
            {
                PosX = Corpse.PosX + x, PosY = Corpse.PosY  + y,
                Radius = 1.8, ColorR = 0, ColorG = 1, ColorB = 0,
                label = "Particle", timer = 0, speed = (RandNumber() * BulletSpeed * 0.5) + 300, dissappearTime = (RandNumber() * 3),
                directionX = 0, directionY = 0, Color = RandNumber()
            }
            NewParticle.ColorB = 0
        else
            NewParticle =
            {
                PosX = Corpse.PosX + x, PosY = Corpse.PosY  + y,
                Radius = 1.8, ColorR = 0, ColorG = 1, ColorB = 0,
                label = "Particle", timer = 0, speed = (RandNumber() * BulletSpeed * 0.5) + 300, dissappearTime = (RandNumber() * 3),
                directionX = 0, directionY = 0, Color = RandNumber()
            }
        end

        local dir = CalculateDirection(Corpse.PosX, Corpse.PosY, NewParticle.PosX, NewParticle.PosY)
        NewParticle.directionX = dir.X
        NewParticle.directionY = dir.Y

        NewParticle.ColorB = 0

        table.insert(Particles, NewParticle)
        CorpseParticleCount = CorpseParticleCount + 1
    end
end

--Updates the kill count UI
function UpdateKillUI()

    local font = love.graphics.getFont()
    ---@diagnostic disable-next-line: param-type-mismatch
    KillCountText = love.graphics.newText(font, {{0, 1, 0}, "Kill Count: ", {1, 0.5, 1}, KillCount})
end

--*Functions below this are pure math Functions that are used in the game*--

--Makes given vector have a length of 1
function Normalize(vector)
    local length = math.sqrt(vector.X * vector.X + vector.Y * vector.Y)

    if length ~= 0 then
        vector.X = vector.X / length
        vector.Y = vector.Y / length
    end

    return vector
end

--Create a position that is in given circle
function CalculateAPosInRadius(r)

    local signX = 1
    if RandNumber() < 0.5 then
        signX = -1
    end

    local signY = 1
    if RandNumber() < 0.5 then
        signY = -1
    end

    local PosX = 0
    local PosY = 0

    repeat
        PosX = (RandNumber() * r) * signX
        PosY = (RandNumber() * r) * signY
    until (PosX * PosX + PosY * PosY) < (r * r)

    return PosX, PosY
end

--Creates a position that is outside of the screen
function CalculateAPosOutsideWindow()

    local PosX
    local PosY

    local width, height = (1.25 * width), (1.25 * height)

    local signX = 1
    if RandNumber() < 0.5 then
        signX = -1
    end

    local signY = 1
    if RandNumber() < 0.5 then
        signY = -1
    end

    --vertically out of the screen
    if RandNumber() < 0.5 then

        PosX = (width / 2) * signX
        PosY = RandNumber() * (height / 2) * signY
    --horizontally out of the screen
    else
        PosX = RandNumber() * (width / 2) * signX
        PosY = (height / 2) * signY
    end

    --we calculate it like center of the screen is (0, 0)
    --so we need to add half the width and height to the position to correct it.
    PosX = PosX + (width / 2)
    PosY = PosY + (height / 2)

    return PosX, PosY
end

--Calculates the vector2 values between two positions
function CalculateDirection(x1, y1, x2, y2)

    local DiffX = x2 - x1
    local DiffY = y2 - y1

    local Magnitude = math.sqrt(DiffX * DiffX + DiffY * DiffY)

    local dirX = DiffX / Magnitude
    local dirY = DiffY / Magnitude

    local dir = { X = dirX, Y = dirY}

    return dir
end

--Calculates the vector2 values from a radianz
function DirectionFromRadian(radian)

    local dir = { X = math.cos(radian), Y = math.sin(radian) }
    return dir
end

--Calculates radian in between via magic.
function CalculateRadianBetween(x1, y1, x2, y2)

    return math.atan2(y2 - y1, x2 - x1)
end

--Calculates radian via magic.
function CalculateRadian(x1, y1)

    return math.atan2(y1, x1)
end

--Calculates position to be with magnitude of 1
function PosFromRadian(a)

    local dir = { X = math.sin(a), Y = math.cos(a) }
    return dir
end

--VectorDifference
function CalculateDifference(x1, y1, x2, y2)

    local difX = x2 - x1
    local difY = y2 - y1

    return math.sqrt(difX * difX + difY * difY)
end

--Converts degree to radian value
function AngleToRaidan(value)
    return value * 0.01745329251 -- π / 180°
end

--Converts degree to radian value
function RaidanToAngle(value)
    return value * 57.2957795131 -- 180° / π
end

--Creates a random number
function RandNumber()

    SeedCreatingValue = SeedCreatingValue + 1
    math.randomseed(SeedCreatingValue)

    return math.random()
end

--Checks if given thing exists
function Exists(a)
    return a ~= nil
end