ClassicGearSet = {}

CGS_DataBase = {}
CGS_DataBase.Gears = {}
CGS_DataBase.GearsCount = 0
CGS_DataBase.EnableMacro = false
CGS_DataBase.ActiveGear = nil

-- Constants
MAIN_HAND_SLOT_NAME = "MainHandSlot"
OFF_HAND_SLOT_NAME = "SecondaryHandSlot"
INVENTORY_SLOT_NAME = { "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", MAIN_HAND_SLOT_NAME, OFF_HAND_SLOT_NAME, "RangedSlot", "AmmoSlot" }
EMPTY_ITEM_SLOT = "GCS_EMPTY_SLOT"

-- Volatile memory
CGS_Volatile_DataBase = {}
CGS_Volatile_DataBase.gearID = nil
CGS_Volatile_DataBase.Gear = nil

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
        local itemID = GetInventoryItemID("player", slotID)
        if itemID == nil then
            currentGear[v] = EMPTY_ITEM_SLOT
        else
            currentGear[v] = itemID
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
function ClassicGearSet.SaveGear(gearID)
    ClassicGearSet.SaveGearAux(gearID,  ClassicGearSet.ListCurrentGear(), false)
    print(format("Gear set '%s' has been saved", gearID))
end

function ClassicGearSet.SaveGearAux(gearID, gearToSave, isCancel)
    if CGS_DataBase.Gears[gearID] == nil then
        CGS_DataBase.GearsCount = CGS_DataBase.GearsCount + 1
    elseif isCancel == false then
        ClassicGearSet.CopyGearInVolatileDatabase(gearID)
    end

    CGS_DataBase.Gears[gearID] = gearToSave

    if CGS_DataBase.EnableMacro == true then
        SaveWeaponSwapMacro(gearID)
    end
    CGS_DataBase.ActiveGear = gearID
end

function SaveWeaponSwapMacro(gearID)
    local mainhand = CGS_DataBase.Gears[gearID][MAIN_HAND_SLOT_NAME]
    local mainhandSlotID = GetInventorySlotInfo(MAIN_HAND_SLOT_NAME)
    local offhand = CGS_DataBase.Gears[gearID][OFF_HAND_SLOT_NAME]
    local offhandSlotID = GetInventorySlotInfo(OFF_HAND_SLOT_NAME)
    local macroName = gearID .. "_cgs"

    local macroIndex = GetMacroIndexByName(macroName)
    local macroHeader = "#showtooltip"
    local macro_text = ""

    if mainhand ~= EMPTY_ITEM_SLOT then
        mainhand = GetItemInfo(mainhand)
        macro_text = macro_text .. format("\n/equipslot 16 %s", mainhand)
    end
    if offhand ~= EMPTY_ITEM_SLOT then
        offhand = GetItemInfo(offhand)
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
            body = strsub(body, 1, tmpIdx - 2)
            EditMacro(macroIndex, macroName, iconTexture, body .. macro_text, 1, 1)
        else
            print(format("Sorry, unable to update macro '%s' (maybe deleting it will solve the issue)", macroName))
        end
    end
end


-- Delete function
function ClassicGearSet.DeleteGear(gearID)
    if CGS_DataBase.Gears[gearID] ~= nil then
        ClassicGearSet.CopyGearInVolatileDatabase(gearID)
        CGS_DataBase.Gears[gearID] = nil
        CGS_DataBase.GearsCount = CGS_DataBase.GearsCount - 1
        if CGS_DataBase.ActiveGear == gearID then
            CGS_DataBase.ActiveGear = nil
        end
        print(format("Gear set '%s' has been deleted", gearID))
    end
end


-- Load function
function ClassicGearSet.LoadGear(gearID)
    if InCombatLockdown() == false then
        print("Loading gear set:", gearID)
        if CGS_DataBase.Gears[gearID] ~= nil then
            local currentGear = ClassicGearSet.ListCurrentGear()

            local freeSlots = ClassicGearSet.NumberOfFreeSlotInBags()
            local requiredFreeSlots = ClassicGearSet.CountRequiredFreeBagSlots(currentGear, CGS_DataBase.Gears[gearID])

            if requiredFreeSlots <= freeSlots then
                for k,v in pairs(CGS_DataBase.Gears[gearID]) do
                    if v ~= EMPTY_ITEM_SLOT then
                        if (currentGear[k] ~= v) then
                            local SlotID = GetInventorySlotInfo(k)
                            EquipItemByName(v, SlotID)
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
                CGS_DataBase.ActiveGear = gearID
                print(format("Gear set '%s' has been loaded", gearID))
            else
                print(format("Not enough space in bags to equip selected gear (Required: %d, Free slots in bag: %d)", requiredFreeSlots, freeSlots))
            end
        else
            print(format("No gear set is named '%s'", gearID))
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

-- Cancel handling
function ClassicGearSet.CopyGearInVolatileDatabase(gearID)
    if CGS_DataBase.Gears[gearID] ~= nil then
        CGS_Volatile_DataBase.gearID = gearID
        CGS_Volatile_DataBase.Gear = CGS_DataBase.Gears[gearID]
    end
end

function ClassicGearSet.CancelSaveOrDelete()
    ClassicGearSet.SaveGearAux(CGS_Volatile_DataBase.gearID, CGS_Volatile_DataBase.Gear, true)
    print(format("Gear set '%s' has been restored", CGS_Volatile_DataBase.gearID))
    CGS_Volatile_DataBase.gearID = nil
    CGS_Volatile_DataBase.Gear = nil
end



-- SlashCmdList
function ClassicGearSet.PrintHelp()
    print("ClassicGearSet Usage:")
    print("/cgs - Show this message")
    print("/cgs help - Show this message")
    print("/cgs load <gear name> - Load the gear set (the gear name may contain spaces) and set the saved gear as active")
    print("/cgs save <gear name> - Save the gear set (the gear name may contain spaces) and set the saved gear as active")
    print("Note: the save and load commands can be used without a <gear name> to save/load the active gear (be careful with this feature)")
    print("/cgs delete <gear name> - Delete the gear set (the gear name may contain spaces)")
    print("/cgs cancel - Revert a save or delete made by mistake")
    print("/cgs macro <true|false> - enable or disable creation/update of weaponswap macro on save (the macro is NEVER deleted automatically)")
    print("/cgs list - List the saved gear sets")
end

SlashCmdList['CLASSICGEARSET'] = function(msg)
    local tbl = { strsplit(" ", msg, 2) }
    local tblCount = ClassicGearSet.Tablelength(tbl)

    local showHelp = true

    if tblCount > 0 then
        if tbl[1] == "list" then
            showHelp = false
            ClassicGearSet.ListGears()
        elseif tbl[1] == "load" then
            if tblCount == 2 then
                showHelp = false
                ClassicGearSet.LoadGear(tbl[2])
            elseif CGS_DataBase.ActiveGear ~= nil then
                showHelp = false
                ClassicGearSet.LoadGear(CGS_DataBase.ActiveGear)
            end
        elseif tbl[1] == "save" then
            if tblCount == 2 then
                showHelp = false
                ClassicGearSet.SaveGear(tbl[2])
            elseif CGS_DataBase.ActiveGear ~= nil then
                showHelp = false
                ClassicGearSet.SaveGear(CGS_DataBase.ActiveGear)
            end
        elseif tbl[1] == "delete" then
            if tblCount == 2 then
                showHelp = false
                ClassicGearSet.DeleteGear(tbl[2])
            end
        elseif tbl[1] == "macro" then
            if tblCount == 2 then
                showHelp = false
                ClassicGearSet.MacroHandling(tbl[2])
            end
        elseif tbl[1] == "cancel" then
            showHelp = false
            ClassicGearSet.CancelSaveOrDelete()
        end
    end

    if showHelp == true then
        ClassicGearSet.PrintHelp()
    end
end
SLASH_CLASSICGEARSET1 = '/classicgearset'
SLASH_CLASSICGEARSET2 = '/cgs'
