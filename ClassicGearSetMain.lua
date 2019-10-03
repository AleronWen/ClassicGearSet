ClassicGearSet = {}
ClassicGearSet.Gears = {}
ClassicGearSet.GearsCount = 0

-- Utility functions
function ClassicGearSet.Tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- List function
function ClassicGearSet.ListGears()
    print("List of gears:", ClassicGearSet.GearsCount)
    if ClassicGearSet.GearsCount > 0 then
        for k,_ in pairs(ClassicGearSet.Gears) do
            print("-", k)
        end
    else
        print("No gear found")
    end
end
-- Saving functions
function ClassicGearSet.SaveGear(gearId)
    print("Saving " .. gearId)
    if ClassicGearSet.Gears[gearId] == nil then
        ClassicGearSet.GearsCount = ClassicGearSet.GearsCount + 1
    end
    ClassicGearSet.Gears[gearId] = {"A big axe", "A shield"}
end

-- Loading functions
function ClassicGearSet.LoadGear(gearId)
    if ClassicGearSet.Gears[gearId] ~= nil then
        print("Loading", gearId)
        for _,v in pairs(ClassicGearSet.Gears[gearId]) do
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
