ClassicGearSet = {}

CGS_DataBase = {}
CGS_DataBase.Gears = {}
CGS_DataBase.GearsCount = 0
CGS_DataBase.EnableMacro = false

-- Constants
INVENTORY_SLOT_NAME = { "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "AmmoSlot" }
EMPTY_ITEM_SLOT = "GCS_EMPTY_SLOT"

-- Utility functions
function ClassicGearSet.Tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function ClassicGearSet.ListCurrentGear()
    local currentGear = {}
    for _,v in ipairs(INVENTORY_SLOT_NAME) do
        local slotID = GetInventorySlotInfo(v)
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink == nil then 
            currentGear[v] = EMPTY_ITEM_SLOT
        else
            currentGear[v], _ = GetItemInfo(itemLink)
        end
    end
    return currentGear
end

function ClassicGearSet.NumberOfFreeSlotInBags()
    local freeSlots = 0
    for i = 0, NUM_BAG_SLOTS do
        numberOfFreeSlots, _ = GetContainerNumFreeSlots(i)
        freeSlots = freeSlots + numberOfFreeSlots
    end
    return freeSlots
end

function ClassicGearSet.CountRequiredFreeBagSlots(currentGear, candidateGear)
    local requiredFreeBagSlots = 0
    -- currentGear[v] == candidateGear[v] ==> +0
    -- currentGear[v] == EMPTY_ITEM_SLOT ==> +0    
    -- candidateGear[v] == EMPTY_ITEM_SLOT ==> +1
    -- candidateGear[v] != EMPTY_ITEM_SLOT ==> +0 (item swap or more free bag after equip)
    for _,v in ipairs(INVENTORY_SLOT_NAME) do
        if currentGear[v] ~= EMPTY_ITEM_SLOT and candidateGear[v] == EMPTY_ITEM_SLOT then
            requiredFreeBagSlots = requiredFreeBagSlots + 1
        end
    end
    return requiredFreeBagSlots
end


-- Test function
function ClassicGearSet.Test()
end


-- List function
function ClassicGearSet.ListGears()
    print("List of gears:", CGS_DataBase.GearsCount)
    if CGS_DataBase.GearsCount > 0 then
        for k,_ in pairs(CGS_DataBase.Gears) do
            print("-", k)
        end
    else
        print("No gear found")
    end
end


-- Save function

function ClassicGearSet.SaveGear(gearId)
    if CGS_DataBase.Gears[gearId] == nil then
        CGS_DataBase.GearsCount = CGS_DataBase.GearsCount + 1
    end
    CGS_DataBase.Gears[gearId] = ClassicGearSet.ListCurrentGear()

    SaveWeaponSwapMacro(gearId)

    print(format("Gear set '%s' has been saved", gearId))
end

function SaveWeaponSwapMacro(gearId)
    local mainhand = CGS_DataBase.Gears[gearId]["MainHandSlot"]        
    local offhand = CGS_DataBase.Gears[gearId]["SecondaryHandSlot"]
    local macroName = gearId .. "_cgs"
    
    if CGS_DataBase.EnableMacro == true then
        local macroIndex = GetMacroIndexByName(macroName)
        local macroHeader = "#showtooltip"
        local macro_text = ""
        
        if mainhand ~= EMPTY_ITEM_SLOT then
            macro_text = macro_text .. format("\n/equipslot 16 %s", mainhand)
        end
        if offhand ~= EMPTY_ITEM_SLOT then
            macro_text = macro_text .. format("\n/equipslot 17 %s", offhand)
        end

        if macroIndex == 0 then
            -- create macro
            CreateMacro(macroName, "INV_MISC_QUESTIONMARK", macroHeader .. macro_text, 1);
        else
            -- update macro
            local _, iconTexture, body, isLocal = GetMacroInfo(macroName);
            local tmpIdx, _ = strfind(body, "/equipslot")
            if tmpIdx ~= nil then
                body = strsub(body, 1, tmpIdx - 1)
                EditMacro(macroIndex, macroName, iconTexture, body .. macro_text, 1, 1)
            else
                print(format("Sorry, unable to update macro '%s' (maybe deleting it will solve the issue)", macroName))
            end            
        end
    end
end


-- Delete function

function ClassicGearSet.DeleteGear(gearId)
    if CGS_DataBase.Gears[gearId] ~= nil then
        CGS_DataBase.Gears[gearId] = nil
        CGS_DataBase.GearsCount = CGS_DataBase.GearsCount - 1
        print(format("Gear set '%s' has been deleted", gearId))
    end    
end


-- Load function
function ClassicGearSet.LoadGear(gearId)
    if InCombatLockdown() == false then
        print("Loading gear set:", gearId)
        if CGS_DataBase.Gears[gearId] ~= nil then
            local currentGear = ClassicGearSet.ListCurrentGear()

            local freeSlots = ClassicGearSet.NumberOfFreeSlotInBags()
            local requiredFreeSlots = ClassicGearSet.CountRequiredFreeBagSlots(currentGear, CGS_DataBase.Gears[gearId])

            if requiredFreeSlots <= freeSlots then
                for k,v in pairs(CGS_DataBase.Gears[gearId]) do
                    if v ~= EMPTY_ITEM_SLOT then                
                        if (currentGear[k] ~= v) then    
                            EquipItemByName(v)
                        end
                    else
                        C_Timer.After(0.3, function()
                            PickupInventoryItem(GetInventorySlotInfo(k)) PutItemInBackpack();
                            C_Timer.After(0.3, function()
                                PickupInventoryItem(GetInventorySlotInfo(k)) PutItemInBag(20);
                                C_Timer.After(0.3, function()
                                    PickupInventoryItem(GetInventorySlotInfo(k)) PutItemInBag(21);
                                    C_Timer.After(0.3, function()
                                        PickupInventoryItem(GetInventorySlotInfo(k)) PutItemInBag(22);
                                        C_Timer.After(0.3, function()
                                            PickupInventoryItem(GetInventorySlotInfo(k)) PutItemInBag(23);
                                            return
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end
                end
            else
                print(format("Not enough space in bags to equip selected gear (Required: %d, Free slots in bag: %d)", requiredFreeSlots, freeSlots))
            end
        else
            print(format("No gear set is named '%s'", gearId))
        end
    end
end


-- Macro handling
function ClassicGearSet.MacroHandling(arg)
    if arg == "true" then
        CGS_DataBase.EnableMacro = true
    else
        CGS_DataBase.EnableMacro = false
    end
end


-- SlashCmdList
function ClassicGearSet.PrintHelp()
    print("ClassicGearSet Usage:")
    print("/cgs - Show this message")
    print("/cgs help - Show this message")
    print("/cgs load <gear name> - Load the gear set (the gear name may contain spaces)")
    print("/cgs save <gear name> - Save the gear set (the gear name may contain spaces)")
    print("/cgs delete <gear name> - Delete the gear set (the gear name may contain spaces)")
    print("/cgs macro <true|false> - enable or disable creation/update of weaponswap macro on save (the macro is NEVER deleted automatically)")
    print("/cgs list - List the saved gear sets")
end

SlashCmdList['CLASSICGEARSET'] = function(msg)
    local tbl = { strsplit(" ", msg, 2) }
    local tblCount = ClassicGearSet.Tablelength(tbl)

    if tblCount == 0 then
        ClassicGearSet.PrintHelp()
    else
        if tbl[1] == "help" then
            ClassicGearSet.PrintHelp()
        elseif tbl[1] == "list" then
            ClassicGearSet.ListGears() 
--        elseif tbl[1] == "test" then
--            ClassicGearSet.Test()             
        elseif tblCount == 2 and tbl[1] == "load" then
            ClassicGearSet.LoadGear(tbl[2])            
        elseif tblCount == 2 and tbl[1] == "save" then
            ClassicGearSet.SaveGear(tbl[2])            
        elseif tblCount == 2 and tbl[1] == "delete" then
            ClassicGearSet.DeleteGear(tbl[2])         
        elseif tblCount == 2 and tbl[1] == "macro" then
            ClassicGearSet.MacroHandling(tbl[2])
        else
            ClassicGearSet.PrintHelp()
        end
    end
end
SLASH_CLASSICGEARSET1 = '/classicgearset'
SLASH_CLASSICGEARSET2 = '/cgs'
