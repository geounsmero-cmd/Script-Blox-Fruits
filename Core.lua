return function(window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local VirtualUser = game:GetService("VirtualUser")
    local HttpService = game:GetService("HttpService")

    local player = Players.LocalPlayer

    local Config = {
        AutoFarm = false,
        UseQuest = true,
        AutoBuso = true,
        Bring = true,
        WeaponType = "Melee",
        WeaponName = "",
        Speed = 280,
        Height = 10,
        BringRange = 300,
        Noclip = false,
        AutoFruit = false,
        AutoRandomFruit = false,
        RandomInterval = 30,
        AutoStat = false,
        StatTarget = "Melee",
        StatAmount = 5,
        ProbeLimit = 8
    }

    local State = {
        Combat = false,
        Traveling = false,
        FruitBusy = false,
        Anchor = nil,
        FarmRunning = false,
        FruitRunning = false,
        StatRunning = false,
        RandomRunning = false,
        QuestSkipUntil = 0,
        QuestCache = nil,
        Catalog = nil,
        QuestNpc = {},
        LastBuso = 0,
        LastRadius = 0,
        LastClear = 0,
        LastClick = 0
    }

    local SaveFile = "HubQuestMap.json"

    local Contingency = {
        {
            {0, "BanditQuest1", 1, "Bandit"},
            {10, "JungleQuest", 1, "Monkey"},
            {15, "JungleQuest", 2, "Gorilla"},
            {30, "BuggyQuest1", 1, "Pirate"},
            {40, "BuggyQuest1", 2, "Brute"},
            {60, "DesertQuest", 1, "Desert Bandit"},
            {75, "DesertQuest", 2, "Desert Officer"},
            {90, "SnowQuest", 1, "Snow Bandit"},
            {100, "SnowQuest", 2, "Snowman"},
            {120, "MarineQuest2", 1, "Chief Petty Officer"},
            {150, "SkyQuest", 1, "Sky Bandit"},
            {175, "SkyQuest", 2, "Dark Master"},
            {190, "PrisonerQuest", 1, "Prisoner"},
            {210, "PrisonerQuest", 2, "Dangerous Prisoner"},
            {250, "ColosseumQuest", 1, "Toga Warrior"},
            {275, "ColosseumQuest", 2, "Gladiator"},
            {300, "MagmaQuest", 1, "Military Soldier"},
            {325, "MagmaQuest", 2, "Military Spy"},
            {375, "FishmanQuest", 1, "Fishman Warrior"},
            {400, "FishmanQuest", 2, "Fishman Commando"},
            {450, "SkyExp1Quest", 1, "God's Guard"},
            {475, "SkyExp1Quest", 2, "Shanda"},
            {525, "SkyExp2Quest", 1, "Royal Squad"},
            {550, "SkyExp2Quest", 2, "Royal Soldier"},
            {625, "FountainQuest", 1, "Galley Pirate"},
            {650, "FountainQuest", 2, "Galley Captain"}
        },
        {
            {700, "Area1Quest", 1, "Raider"},
            {725, "Area1Quest", 2, "Mercenary"},
            {775, "Area2Quest", 1, "Swan Pirate"},
            {800, "Area2Quest", 2, "Factory Staff"},
            {875, "MarineQuest3", 1, "Marine Lieutenant"},
            {900, "MarineQuest3", 2, "Marine Captain"},
            {950, "ZombieQuest", 1, "Zombie"},
            {975, "ZombieQuest", 2, "Vampire"},
            {1000, "SnowMountainQuest", 1, "Snow Trooper"},
            {1050, "SnowMountainQuest", 2, "Winter Warrior"},
            {1100, "IceSideQuest", 1, "Lab Subordinate"},
            {1125, "IceSideQuest", 2, "Horned Warrior"},
            {1175, "FireSideQuest", 1, "Magma Ninja"},
            {1200, "FireSideQuest", 2, "Lava Pirate"},
            {1250, "ShipQuest1", 1, "Ship Deckhand"},
            {1275, "ShipQuest1", 2, "Ship Engineer"},
            {1300, "ShipQuest2", 1, "Ship Steward"},
            {1325, "ShipQuest2", 2, "Ship Officer"},
            {1350, "FrostQuest", 1, "Arctic Warrior"},
            {1375, "FrostQuest", 2, "Snow Lurker"},
            {1425, "ForgottenQuest", 1, "Sea Soldier"},
            {1450, "ForgottenQuest", 2, "Water Fighter"}
        },
        {
            {1500, "PiratePortQuest", 1, "Pirate Millionaire"},
            {1525, "PiratePortQuest", 2, "Pistol Billionaire"},
            {1575, "AmazonQuest", 1, "Dragon Crew Warrior"},
            {1600, "AmazonQuest", 2, "Dragon Crew Archer"},
            {1625, "AmazonQuest2", 1, "Female Islander"},
            {1650, "AmazonQuest2", 2, "Giant Islander"},
            {1700, "MarineTreeIsland", 1, "Marine Commodore"},
            {1725, "MarineTreeIsland", 2, "Marine Rear Admiral"},
            {1775, "DeepForestIsland3", 1, "Fishman Raider"},
            {1800, "DeepForestIsland3", 2, "Fishman Captain"},
            {1825, "DeepForestIsland", 1, "Forest Pirate"},
            {1850, "DeepForestIsland", 2, "Mythological Pirate"},
            {1900, "DeepForestIsland2", 1, "Jungle Pirate"},
            {1925, "DeepForestIsland2", 2, "Musketeer Pirate"},
            {1975, "HauntedQuest1", 1, "Reborn Skeleton"},
            {2000, "HauntedQuest1", 2, "Living Zombie"},
            {2025, "HauntedQuest2", 1, "Demonic Soul"},
            {2050, "HauntedQuest2", 2, "Posessed Mummy"},
            {2075, "NutsIslandQuest", 1, "Peanut Scout"},
            {2100, "NutsIslandQuest", 2, "Peanut President"},
            {2125, "IceCreamIslandQuest", 1, "Ice Cream Chef"},
            {2150, "IceCreamIslandQuest", 2, "Ice Cream Commander"},
            {2200, "CakeQuest1", 1, "Cookie Crafter"},
            {2225, "CakeQuest1", 2, "Cake Guard"},
            {2250, "CakeQuest2", 1, "Baking Staff"},
            {2275, "CakeQuest2", 2, "Head Baker"},
            {2300, "ChocQuest1", 1, "Cocoa Warrior"},
            {2325, "ChocQuest1", 2, "Chocolate Bar Battler"},
            {2350, "ChocQuest2", 1, "Sweet Thief"},
            {2375, "ChocQuest2", 2, "Candy Rebel"},
            {2400, "CandyQuest1", 1, "Candy Pirate"},
            {2425, "CandyQuest1", 2, "Snow Demon"},
            {2450, "TikiQuest1", 1, "Isle Outlaw"},
            {2475, "TikiQuest1", 2, "Island Boy"},
            {2500, "TikiQuest2", 1, "Sun-kissed Warrior"},
            {2525, "TikiQuest2", 2, "Isle Champion"},
            {2550, "TikiQuest3", 1, "Serpent Hunter"},
            {2575, "TikiQuest3", 2, "Skull Slayer"},
            {2600, "SubmergedQuest1", 1, "Reef Bandit"},
            {2625, "SubmergedQuest1", 2, "Coral Pirate"},
            {2650, "SubmergedQuest2", 1, "Sea Chanter"},
            {2675, "SubmergedQuest2", 2, "Ocean Prophet"}
        }
    }

    local SeaByPlace = {
        [2753915549] = 1,
        [85211729168715] = 1,
        [4442272183] = 2,
        [79091703265657] = 2,
        [7449423635] = 3,
        [100117331123089] = 3
    }

    local farmTab = window:AddTab("Farm")
    local levelLabel = farmTab:AddLabel("Nível: 0")
    local questLabel = farmTab:AddLabel("Missão: aguardando")
    local nextLabel = farmTab:AddLabel("Próxima: nenhuma")
    local stateLabel = farmTab:AddLabel("Estado: parado")

    local fruitTab = window:AddTab("Frutas")
    local fruitLabel = fruitTab:AddLabel("Frutas: inativo")

    local statTab = window:AddTab("Atributos")
    local pointsLabel = statTab:AddLabel("Pontos: 0")

    local configTab = window:AddTab("Config")

    local function getRoot()
        local character = player.Character
        return character and character:FindFirstChild("HumanoidRootPart")
    end

    local function getHumanoid()
        local character = player.Character
        return character and character:FindFirstChildOfClass("Humanoid")
    end

    local function isAlive()
        local humanoid = getHumanoid()
        return humanoid ~= nil and humanoid.Health > 0 and getRoot() ~= nil
    end

    local function farmAlive()
        return Config.AutoFarm and isAlive()
    end

    local function fruitAlive()
        return Config.AutoFruit and isAlive()
    end

    local function invoke(...)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local remote = remotes and remotes:FindFirstChild("CommF_")
        if not remote then
            return nil
        end
        local arguments = table.pack(...)
        local ok, result = pcall(function()
            return remote:InvokeServer(table.unpack(arguments, 1, arguments.n))
        end)
        return ok and result or nil
    end

    local function getLevel()
        local data = player:FindFirstChild("Data")
        local level = data and data:FindFirstChild("Level")
        return level and level.Value or 0
    end

    local function getSea(level)
        return SeaByPlace[game.PlaceId] or (level >= 1500 and 3 or level >= 700 and 2 or 1)
    end

    local function escapePattern(text)
        return (text:gsub("%p", "%%%0"))
    end

    local function nameMatches(name, mob)
        if name == mob then
            return true
        end
        return name:match("^" .. escapePattern(mob) .. "%s*[%[%(%d]") ~= nil
    end

    local function findSpawnPositions(mob)
        local list = {}
        local origin = Workspace:FindFirstChild("_WorldOrigin")
        local folder = origin and origin:FindFirstChild("EnemySpawns")
        if folder then
            for _, spawn in ipairs(folder:GetChildren()) do
                if spawn:IsA("PVInstance") and nameMatches(spawn.Name, mob) then
                    table.insert(list, spawn:GetPivot().Position)
                end
            end
        end
        return list
    end

    local function getEnemies(mob)
        local list = {}
        local folder = Workspace:FindFirstChild("Enemies")
        if not folder then
            return list
        end
        for _, enemy in ipairs(folder:GetChildren()) do
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            local root = enemy:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.Health > 0 and nameMatches(enemy.Name, mob) then
                table.insert(list, enemy)
            end
        end
        return list
    end

    local function nearestPosition(list)
        local root = getRoot()
        if not root then
            return list[1]
        end
        local best = nil
        local bestDistance = math.huge
        for _, position in ipairs(list) do
            local distance = (position - root.Position).Magnitude
            if distance < bestDistance then
                best = position
                bestDistance = distance
            end
        end
        return best
    end

    local function mobAvailable(mob)
        return #findSpawnPositions(mob) > 0 or #getEnemies(mob) > 0
    end

    local function buildCatalog()
        if State.Catalog then
            return State.Catalog
        end
        local catalog = {}
        local container = ReplicatedStorage:FindFirstChild("Quests")
        if container then
            local ok, quests = pcall(require, container)
            if ok and type(quests) == "table" then
                for questId, tiers in pairs(quests) do
                    if type(tiers) == "table" then
                        for index, data in pairs(tiers) do
                            if type(data) == "table" and type(data.Task) == "table" then
                                local required = data.LevelReq or data.Level
                                local mob, count = next(data.Task)
                                if type(required) == "number" and type(mob) == "string" and type(count) == "number" then
                                    if count >= 2 and count <= 20 then
                                        table.insert(catalog, {
                                            quest = questId,
                                            index = index,
                                            mob = mob,
                                            level = required,
                                            source = "módulo"
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        table.sort(catalog, function(a, b)
            if a.level ~= b.level then
                return a.level < b.level
            end
            return tostring(a.quest) < tostring(b.quest)
        end)
        State.Catalog = catalog
        return catalog
    end

    local function contingencyEntries(level)
        local rows = Contingency[getSea(level)] or Contingency[1]
        local entries = {}
        for _, row in ipairs(rows) do
            table.insert(entries, {
                quest = row[2],
                index = row[3],
                mob = row[4],
                level = row[1],
                source = "tabela"
            })
        end
        return entries
    end

    local function selectFrom(entries, level)
        local current = nil
        local following = nil
        for position = #entries, 1, -1 do
            local entry = entries[position]
            if entry.level <= level and mobAvailable(entry.mob) then
                current = entry
                break
            end
        end
        for _, entry in ipairs(entries) do
            if entry.level > level and (not current or entry.mob ~= current.mob) and mobAvailable(entry.mob) then
                following = entry
                break
            end
        end
        return current, following
    end

    local function resolveQuest(level)
        local cache = State.QuestCache
        if cache and cache.level == level and os.clock() < cache.expires then
            return cache.current, cache.following
        end
        local current, following = selectFrom(buildCatalog(), level)
        local expires = math.huge
        if not current then
            local entries = contingencyEntries(level)
            local fallbackCurrent, fallbackFollowing = selectFrom(entries, level)
            if not fallbackCurrent then
                for _, entry in ipairs(entries) do
                    if entry.level <= level then
                        fallbackCurrent = entry
                    end
                end
                fallbackCurrent = fallbackCurrent or entries[1]
            end
            current = fallbackCurrent
            following = following or fallbackFollowing
            expires = os.clock() + 10
        end
        State.QuestCache = {
            level = level,
            current = current,
            following = following,
            expires = expires
        }
        return current, following
    end

    local function getQuestFrame()
        local gui = player:FindFirstChild("PlayerGui")
        local main = gui and gui:FindFirstChild("Main")
        return main and main:FindFirstChild("Quest")
    end

    local function questActive()
        local frame = getQuestFrame()
        return frame ~= nil and frame.Visible
    end

    local function questTitle()
        local frame = getQuestFrame()
        if not frame then
            return ""
        end
        local ok, text = pcall(function()
            return frame.Container.QuestTitle.Title.Text
        end)
        return ok and text or ""
    end

    local function travel(destination, keepGoing)
        local root = getRoot()
        if not root then
            return false
        end
        local distance = (root.Position - destination.Position).Magnitude
        if distance < 4 then
            return true
        end
        State.Traveling = true
        local tween = TweenService:Create(
            root,
            TweenInfo.new(distance / math.max(Config.Speed, 50), Enum.EasingStyle.Linear),
            {CFrame = destination}
        )
        local finished = false
        local connection = tween.Completed:Connect(function()
            finished = true
        end)
        tween:Play()
        while not finished and keepGoing() and getRoot() == root do
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait()
        end
        connection:Disconnect()
        if not finished then
            tween:Cancel()
        end
        State.Traveling = false
        return finished
    end

    local function loadQuestMap()
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(SaveFile))
        end)
        if ok and type(data) == "table" then
            for questId, point in pairs(data) do
                if type(point) == "table" and #point == 3 then
                    State.QuestNpc[questId] = Vector3.new(point[1], point[2], point[3])
                end
            end
        end
    end

    local function saveQuestMap()
        local data = {}
        for questId, position in pairs(State.QuestNpc) do
            data[questId] = {position.X, position.Y, position.Z}
        end
        pcall(function()
            writefile(SaveFile, HttpService:JSONEncode(data))
        end)
    end

    loadQuestMap()

    local function questStarted(info)
        if not questActive() then
            return false
        end
        local title = questTitle():lower()
        return title == "" or title:find(info.mob:lower(), 1, true) ~= nil
    end

    local function tryStart(info)
        invoke("StartQuest", info.quest, info.index)
        task.wait(0.5)
        return questStarted(info)
    end

    local function rankNpcs(reference)
        local containers = {}
        local live = Workspace:FindFirstChild("NPCs")
        local stored = ReplicatedStorage:FindFirstChild("NPCs")
        if live then
            table.insert(containers, live)
        end
        if stored then
            table.insert(containers, stored)
        end
        local ranked = {}
        for _, container in ipairs(containers) do
            for _, npc in ipairs(container:GetChildren()) do
                if npc:IsA("Model") then
                    local ok, pivot = pcall(function()
                        return npc:GetPivot()
                    end)
                    if ok then
                        local position = pivot.Position
                        local duplicate = false
                        for _, other in ipairs(ranked) do
                            if (other.position - position).Magnitude < 4 then
                                duplicate = true
                                break
                            end
                        end
                        if not duplicate then
                            local hinted = npc.Name:lower():find("quest", 1, true) ~= nil
                                or npc:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
                                or npc:FindFirstChildWhichIsA("ClickDetector", true) ~= nil
                            table.insert(ranked, {
                                position = position,
                                score = (position - reference).Magnitude * (hinted and 0.5 or 1)
                            })
                        end
                    end
                end
            end
        end
        table.sort(ranked, function(a, b)
            return a.score < b.score
        end)
        return ranked
    end

    local function discoverQuestNpc(info, spawns)
        local root = getRoot()
        local reference = nearestPosition(spawns) or (root and root.Position)
        if not reference then
            return false
        end
        local ranked = rankNpcs(reference)
        local limit = math.min(#ranked, Config.ProbeLimit)
        for position = 1, limit do
            if not farmAlive() then
                return false
            end
            stateLabel:Set(string.format("Estado: detectando NPC (%d/%d)", position, limit))
            if travel(CFrame.new(ranked[position].position + Vector3.new(0, 3, 0)), farmAlive) then
                task.wait(0.3)
                if tryStart(info) then
                    local current = getRoot()
                    if current then
                        State.QuestNpc[info.quest] = current.Position
                        saveQuestMap()
                    end
                    return true
                end
            end
        end
        return false
    end

    local function ensureQuest(info, spawns)
        if questStarted(info) then
            return true
        end
        State.Combat = false
        if questActive() then
            invoke("AbandonQuest")
            task.wait(0.4)
        end
        if tryStart(info) then
            return true
        end
        local known = State.QuestNpc[info.quest]
        if known then
            stateLabel:Set("Estado: indo ao NPC aprendido")
            if travel(CFrame.new(known), farmAlive) and tryStart(info) then
                return true
            end
            State.QuestNpc[info.quest] = nil
            saveQuestMap()
        end
        return discoverQuestNpc(info, spawns)
    end

    local function ensureBuso()
        if not Config.AutoBuso then
            return
        end
        local character = player.Character
        if character and not character:FindFirstChild("HasBuso") and os.clock() - State.LastBuso > 3 then
            State.LastBuso = os.clock()
            invoke("Buso")
        end
    end

    local function findTool()
        local backpack = player:FindFirstChildOfClass("Backpack")
        local sources = {player.Character, backpack}
        for _, source in ipairs(sources) do
            if source then
                for _, tool in ipairs(source:GetChildren()) do
                    if tool:IsA("Tool") then
                        if Config.WeaponName ~= "" then
                            if tool.Name:lower():find(Config.WeaponName:lower(), 1, true) then
                                return tool
                            end
                        elseif tool.ToolTip == Config.WeaponType then
                            return tool
                        end
                    end
                end
            end
        end
        return nil
    end

    local function equipWeapon()
        local character = player.Character
        local humanoid = getHumanoid()
        if not character or not humanoid then
            return
        end
        local tool = findTool()
        if tool and tool.Parent ~= character then
            humanoid:EquipTool(tool)
        end
    end

    local function clearCooldowns(tool)
        for _, value in ipairs(tool:GetDescendants()) do
            if value:IsA("NumberValue") or value:IsA("IntValue") then
                if value.Name:lower():find("cooldown", 1, true) then
                    value.Value = 0
                end
            end
        end
        for name, value in pairs(tool:GetAttributes()) do
            if type(value) == "number" and name:lower():find("cooldown", 1, true) then
                tool:SetAttribute(name, 0)
            end
        end
    end

    local function gather(enemies)
        local root = getRoot()
        local anchor = nil
        local bestDistance = math.huge
        for _, enemy in ipairs(enemies) do
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local distance = root and (enemyRoot.Position - root.Position).Magnitude or 0
                if distance < bestDistance then
                    anchor = enemyRoot
                    bestDistance = distance
                end
            end
        end
        State.Anchor = anchor
        if anchor and Config.Bring then
            if os.clock() - State.LastRadius > 5 then
                State.LastRadius = os.clock()
                pcall(function()
                    sethiddenproperty(player, "SimulationRadius", math.huge)
                end)
            end
            for _, enemy in ipairs(enemies) do
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                if enemyRoot and enemyRoot ~= anchor then
                    if (enemyRoot.Position - anchor.Position).Magnitude <= Config.BringRange then
                        enemyRoot.CFrame = anchor.CFrame
                        enemyRoot.CanCollide = false
                        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.WalkSpeed = 0
                        end
                    end
                end
            end
        end
        return anchor
    end

    local function farmStep()
        while State.FruitBusy and Config.AutoFarm do
            task.wait(0.2)
        end
        if not Config.AutoFarm then
            return
        end
        if not isAlive() then
            State.Combat = false
            stateLabel:Set("Estado: aguardando respawn")
            task.wait(1)
            return
        end
        local level = getLevel()
        levelLabel:Set(string.format("Nível %d | Mar %d", level, getSea(level)))
        local info, following = resolveQuest(level)
        if not info then
            stateLabel:Set("Estado: nenhuma missão encontrada")
            task.wait(2)
            return
        end
        questLabel:Set(string.format("%s [%d] | %s (%s)", info.quest, info.index, info.mob, info.source))
        if following then
            nextLabel:Set(string.format(
                "Próxima: %s (nível %d) | local %s",
                following.mob,
                following.level,
                State.QuestNpc[following.quest] and "aprendido" or "pendente"
            ))
        else
            nextLabel:Set("Próxima: nenhuma")
        end
        ensureBuso()
        equipWeapon()
        local spawns = findSpawnPositions(info.mob)
        if Config.UseQuest and os.clock() >= State.QuestSkipUntil then
            if not ensureQuest(info, spawns) then
                State.QuestSkipUntil = os.clock() + 45
            end
        end
        if not Config.AutoFarm then
            return
        end
        local enemies = getEnemies(info.mob)
        if #enemies == 0 then
            State.Combat = false
            State.Anchor = nil
            local destination = nearestPosition(spawns)
            if destination then
                stateLabel:Set("Estado: indo ao ponto de spawn")
                travel(CFrame.new(destination + Vector3.new(0, Config.Height, 0)), farmAlive)
            else
                stateLabel:Set("Estado: procurando inimigos")
            end
            task.wait(0.3)
            return
        end
        local anchor = gather(enemies)
        local root = getRoot()
        if root and anchor and (root.Position - anchor.Position).Magnitude > 80 then
            State.Combat = false
            stateLabel:Set("Estado: deslocando até os inimigos")
            travel(CFrame.new(anchor.Position + Vector3.new(0, Config.Height, 0)), farmAlive)
        end
        State.Combat = true
        stateLabel:Set("Estado: combatendo " .. info.mob)
    end

    local function startFarm()
        if State.FarmRunning then
            return
        end
        State.FarmRunning = true
        task.spawn(function()
            while Config.AutoFarm do
                local ok = pcall(farmStep)
                if not ok then
                    task.wait(0.5)
                end
                task.wait(0.1)
            end
            State.Combat = false
            State.Anchor = nil
            State.FarmRunning = false
            stateLabel:Set("Estado: parado")
        end)
    end

    local function storeFruits()
        local stored = 0
        local backpack = player:FindFirstChildOfClass("Backpack")
        local sources = {backpack, player.Character}
        for _, source in ipairs(sources) do
            if source then
                for _, tool in ipairs(source:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                        local fruitName = tool:GetAttribute("OriginalName") or tool.Name
                        invoke("StoreFruit", fruitName, tool)
                        stored = stored + 1
                    end
                end
            end
        end
        return stored
    end

    local function nearestDroppedFruit()
        local root = getRoot()
        local best = nil
        local bestDistance = math.huge
        for _, item in ipairs(Workspace:GetChildren()) do
            if item:IsA("Tool") and item.Name:find("Fruit") then
                local handle = item:FindFirstChild("Handle")
                if handle and root then
                    local distance = (handle.Position - root.Position).Magnitude
                    if distance < bestDistance then
                        best = item
                        bestDistance = distance
                    end
                end
            end
        end
        return best
    end

    local function fruitStep()
        storeFruits()
        local fruit = nearestDroppedFruit()
        if not fruit then
            fruitLabel:Set("Frutas: nenhuma no mapa")
            return false
        end
        local handle = fruit:FindFirstChild("Handle")
        if not handle or not isAlive() then
            return false
        end
        State.FruitBusy = true
        State.Combat = false
        fruitLabel:Set("Coletando: " .. fruit.Name)
        travel(handle.CFrame, fruitAlive)
        task.wait(0.4)
        local root = getRoot()
        if root and fruit.Parent == Workspace then
            pcall(function()
                firetouchinterest(root, handle, 0)
                firetouchinterest(root, handle, 1)
            end)
        end
        task.wait(0.4)
        storeFruits()
        return true
    end

    local function startFruit()
        if State.FruitRunning then
            return
        end
        State.FruitRunning = true
        task.spawn(function()
            while Config.AutoFruit do
                local ok, collected = pcall(fruitStep)
                State.FruitBusy = ok and collected == true
                task.wait(collected == true and 0.3 or 1)
            end
            State.FruitBusy = false
            State.FruitRunning = false
            fruitLabel:Set("Frutas: inativo")
        end)
    end

    local function startRandom()
        if State.RandomRunning then
            return
        end
        State.RandomRunning = true
        task.spawn(function()
            while Config.AutoRandomFruit do
                invoke("Cousin", "Buy")
                storeFruits()
                local waited = 0
                while Config.AutoRandomFruit and waited < Config.RandomInterval do
                    task.wait(1)
                    waited = waited + 1
                end
            end
            State.RandomRunning = false
        end)
    end

    local function startStats()
        if State.StatRunning then
            return
        end
        State.StatRunning = true
        task.spawn(function()
            while Config.AutoStat do
                pcall(function()
                    local data = player:FindFirstChild("Data")
                    local points = data and data:FindFirstChild("Points")
                    if points then
                        pointsLabel:Set(string.format("Pontos: %d", points.Value))
                        if points.Value > 0 then
                            invoke("AddPoint", Config.StatTarget, math.min(points.Value, Config.StatAmount))
                        end
                    end
                end)
                task.wait(1)
            end
            State.StatRunning = false
        end)
    end

    local function numeric(text, fallback, low, high)
        local value = tonumber(text)
        if not value then
            return fallback
        end
        return math.clamp(value, low, high)
    end

    table.insert(window.Connections, RunService.Stepped:Connect(function()
        if not (Config.Noclip or State.Traveling or State.Combat) then
            return
        end
        local character = player.Character
        if not character then
            return
        end
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end))

    table.insert(window.Connections, RunService.Heartbeat:Connect(function()
        if not State.Combat or State.FruitBusy then
            return
        end
        local root = getRoot()
        local humanoid = getHumanoid()
        if not root or not humanoid or humanoid.Health <= 0 then
            return
        end
        local anchor = State.Anchor
        if anchor and anchor.Parent then
            root.CFrame = CFrame.new(anchor.Position + Vector3.new(0, Config.Height, 0)) * root.CFrame.Rotation
            root.AssemblyLinearVelocity = Vector3.zero
        end
        local character = player.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool then
            local now = os.clock()
            if now - State.LastClear > 0.25 then
                State.LastClear = now
                pcall(clearCooldowns, tool)
            end
            tool:Activate()
            if now - State.LastClick > 0.1 then
                State.LastClick = now
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(851, 158))
                end)
            end
        end
    end))

    table.insert(window.Connections, player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end))

    local farmToggle = farmTab:AddToggle("Auto Farm", false, function(value)
        Config.AutoFarm = value
        if value then
            startFarm()
        end
    end)
    farmTab:AddToggle("Usar missões", Config.UseQuest, function(value)
        Config.UseQuest = value
        State.QuestSkipUntil = 0
    end)
    farmTab:AddToggle("Ativar Buso automático", Config.AutoBuso, function(value)
        Config.AutoBuso = value
    end)
    farmTab:AddToggle("Agrupar inimigos", Config.Bring, function(value)
        Config.Bring = value
    end)
    farmTab:AddCycle("Tipo de arma", {"Melee", "Sword", "Gun", "Blox Fruit"}, Config.WeaponType, function(value)
        Config.WeaponType = value
    end)
    farmTab:AddTextbox("Nome da arma", "opcional", "", function(text)
        Config.WeaponName = text
    end)

    local fruitToggle = fruitTab:AddToggle("Coletar e guardar frutas", false, function(value)
        Config.AutoFruit = value
        if value then
            startFruit()
        end
    end)
    fruitTab:AddButton("Guardar frutas agora", function()
        local count = storeFruits()
        fruitLabel:Set(string.format("Frutas enviadas: %d", count))
    end)
    fruitTab:AddButton("Comprar fruta aleatória", function()
        invoke("Cousin", "Buy")
        task.wait(0.5)
        storeFruits()
    end)
    local randomToggle = fruitTab:AddToggle("Compra aleatória automática", false, function(value)
        Config.AutoRandomFruit = value
        if value then
            startRandom()
        end
    end)
    fruitTab:AddTextbox("Intervalo (s)", "30", tostring(Config.RandomInterval), function(text)
        Config.RandomInterval = numeric(text, Config.RandomInterval, 5, 3600)
    end)

    statTab:AddCycle("Atributo", {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, Config.StatTarget, function(value)
        Config.StatTarget = value
    end)
    statTab:AddTextbox("Pontos por ciclo", "5", tostring(Config.StatAmount), function(text)
        Config.StatAmount = math.floor(numeric(text, Config.StatAmount, 1, 1000))
    end)
    local statToggle = statTab:AddToggle("Distribuir pontos", false, function(value)
        Config.AutoStat = value
        if value then
            startStats()
        end
    end)

    configTab:AddTextbox("Velocidade", "280", tostring(Config.Speed), function(text)
        Config.Speed = numeric(text, Config.Speed, 50, 600)
    end)
    configTab:AddTextbox("Altura de combate", "10", tostring(Config.Height), function(text)
        Config.Height = numeric(text, Config.Height, 2, 40)
    end)
    configTab:AddTextbox("Raio de agrupamento", "300", tostring(Config.BringRange), function(text)
        Config.BringRange = numeric(text, Config.BringRange, 20, 1000)
    end)
    configTab:AddToggle("Noclip permanente", false, function(value)
        Config.Noclip = value
    end)
    configTab:AddTextbox("NPCs testados", "8", tostring(Config.ProbeLimit), function(text)
        Config.ProbeLimit = math.floor(numeric(text, Config.ProbeLimit, 1, 30))
    end)
    configTab:AddButton("Limpar locais aprendidos", function()
        State.QuestNpc = {}
        saveQuestMap()
    end)
    configTab:AddButton("Parar tudo", function()
        farmToggle:Set(false)
        fruitToggle:Set(false)
        randomToggle:Set(false)
        statToggle:Set(false)
    end)
    configTab:AddButton("Fechar interface", function()
        Config.AutoFarm = false
        Config.AutoFruit = false
        Config.AutoRandomFruit = false
        Config.AutoStat = false
        window:Destroy()
    end)

    return {
        Config = Config,
        QuestMap = State.QuestNpc
    }
end
