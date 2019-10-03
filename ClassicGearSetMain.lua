ClassicGearSet = {}

CGS_DataBase = {}
CGS_DataBase.Gears = {}
CGS_DataBase.GearsCount = 0

-- Constants
INVENTORY_SLOT_NAME = { "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "AmmoSlot" }
EMPTY_ITEM_SLOT = "EMPTY"

-- Utility functions
function ClassicGearSet.Tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end


-- testing
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

-- Saving functions
function ClassicGearSet.ListCurrentGear()
    local currentGear = {}
    for i,v in ipairs(INVENTORY_SLOT_NAME) do
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

function ClassicGearSet.SaveGear(gearId)
    print("Saving " .. gearId)
    if CGS_DataBase.Gears[gearId] == nil then
        CGS_DataBase.GearsCount = CGS_DataBase.GearsCount + 1
    end
    CGS_DataBase.Gears[gearId] = ClassicGearSet.ListCurrentGear()
end

-- Loading functions
function ClassicGearSet.LoadGear(gearId)
    if CGS_DataBase.Gears[gearId] ~= nil then
        print("Loading", gearId)
        for _,v in pairs(CGS_DataBase.Gears[gearId]) do
            print("Equiping ", v)
        end        
    else
        print("Nothing to equip :(")
    end
end

-- SlashCmdList
function ClassicGearSet.PrintHelp()
    print("Usage:")
    print("/cgs - Show this message")
    print("/cgs help - Show this message")
    print("/cgs load <gear name> - Load the gear set (the gear name may have spaces)")
    print("/cgs save <gear name> - Save the gear set (the gear name may have spaces)")
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
        elseif tbl[1] == "test" then
            ClassicGearSet.Test()             
        elseif tblCount == 2 and tbl[1] == "load" then
            ClassicGearSet.LoadGear(tbl[2])            
        elseif tblCount == 2 and tbl[1] == "save" then
            ClassicGearSet.SaveGear(tbl[2])            
        else
            ClassicGearSet.PrintHelp()
        end
    end
end
SLASH_CLASSICGEARSET1 = '/classicgearset'
SLASH_CLASSICGEARSET2 = '/cgs'
