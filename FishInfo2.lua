--
-- FishInfo2 (v10)
-- based on Impp's Fishing Info 1.2
--
-- by Bastian Pflieger <wbb1977@gmail.com>
--
-- Created: July 4, 2007
--
-- supports "myAddOns" up to v2.6: https://wow.curseforge.com/projects/my-add-ons
-- supports "Titan Panel" up to 2.20.0.11200: https://wow.curseforge.com/projects/titan-panel

-- December 27, 2018:
-- clean up for private server WoW Vanialla 1.12

-- Changes since testversion8x:
--   -updated toc file for 2.1
--   - myaddons support moved to toc file
--
-- Changes since testversion7:
--   - updated toc file for 1.7 / 1.10
--   - myaddon code corrected
--
-- Changes since testversion6:
--
-- August 25:
--   - Zone summary display improved, more compact if same fish catched in multiple subzones.
--   - Click fish icon to initiate a search for that fish.
--
-- Changes since testversion5:
--
-- July 23:
--   - Added french translation (contributed by Corwin Whitehorn).
--
-- July 21:
--   - Added tooltips
--
-- Changes since testversion4:
--
-- July 16:
--   - Added myAddOns 2.0 support
--
-- July 14:
--   - Added option to sort search results by percent.
--
-- Changes since testversion3:
--
-- July 12:
--   - Added pseudo sub zone "All fish of this zone". It is automatically
--     selected at the "zone" click event.
--
-- Changes since testversion2:
--
-- July 10:
--   - GUI tweaking
--   - Better chat command function added.
--
-- July 09:
--   - Modified <OnShow> behaviour, preselect only if it is first show after a subzone change.
--   - Added chat paramter "nopreselect" to disable preselection, eg "/fi2 nopreselect".
--
-- July 08:
--   - Completed code to handle multiple fish databases (from other characters).
--   - Changed framestrata to HIGH.
--   - Modified Titan Panel support (better tooltip, removed button text function).
--   - On first <OnShow> event, preselect current zone / subzone.
--
-- July 07:
--   - Import function modified for Emerald-UI.
--   - Added checkbox "Take the data from my other characters into account".
--
-- Changes since testversion1:
--
-- July 05:
--   - Added subzone dropdown list.
--     Database format changed to reflect this, renamed database variable to avoid conflict with testversion1.
--     Data from testversion1 thereforce lost.
--   - Added Titan Panel right-click menu.
--   - Two lines to display search criteria.
--
-- July 04:
--   - Fixed minor error in myAddons support.
--   - Added round function for percent display.
--

FISHINFO2_SCROLLHEIGHT = 42;
FISHINFO2_TITAN_ID = "FishInfo2";
-- Bumped whenever the stored database layout changes. FishInfo2.Setup()
-- records it in the per-character preference table so that a future format
-- change can be migrated instead of silently dropping data (audit M1).
FISHINFO2_SCHEMA_VERSION = 1;

-- Everything this addon implements lives inside this one table. Only a few
-- globals remain in the shared 1.12 namespace: the XML frame names, the Titan
-- callbacks (Titan resolves those by name), the slash commands and the
-- localization strings. Fields are resolved at call time, so the definition
-- order inside this file does not matter.
FishInfo2 = {};

local db;
local dbUser;
local dbOthers;
local results = {};
local linkCache = {};
local fullLinkCache = {};

-- Composite keys. Concatenating the fields with no separator made
-- (fish="AB", zone="C", sub="D") and (fish="A", zone="BC", sub="D") produce
-- the same key, silently dropping one result row (audit M2). "\1" cannot
-- occur inside a fish, zone or subzone name, so the key is unambiguous.
local KEYSEP = "\1";
local function FishKey(name, zone, subZone)
  return name .. KEYSEP .. zone .. KEYSEP .. subZone;
end
local function ZoneKey(zone, subZone)
  return zone .. KEYSEP .. subZone;
end

-- store user input for this session
local lastSearchFunc = nil;
local lastSortFunc = nil;
local lastQuery = "";
local selectedZone = nil;
local selectedSubZone = nil;
local isFirstView = true;
local isEnableFirstViewOnHide = false;

-- Resolve and call a client API defensively (used by the loot branch).
-- The global is looked up at CALL time, never captured at load time: a
-- load-time capture freezes whatever value existed then, so an API that is
-- missing while this file loads stays nil forever even if it appears later.
-- A non-function API, or one whose hook throws, degrades to nil instead of
-- crashing the addon. Deliberately avoids varargs and pcall's multi-returns
-- so it behaves identically on Lua 5.0 (WoW 1.12) and Lua 5.1.
local function CallClientApi(apiName, arg1)
  local api = getglobal(apiName);
  if type(api) ~= "function" then
    return nil;
  end
  local result = {};
  local ok = pcall(function()
    result[1], result[2], result[3], result[4] = api(arg1);
  end);
  if not ok then
    return nil;
  end
  return result[1], result[2], result[3], result[4];
end;

------------------------------------------------------------------------------
-- Core                                                                     --
------------------------------------------------------------------------------
function FishInfo2.OnLoad()
  this:RegisterEvent("VARIABLES_LOADED");
  this:RegisterEvent("LOOT_OPENED");
  this:RegisterEvent("ZONE_CHANGED");
  this:RegisterEvent("ZONE_CHANGED_NEW_AREA");

  SlashCmdList["FISHINFO2"] = FishInfo2.ChatCommand;
  SLASH_FISHINFO21 = "/fi2";
  SLASH_FISHINFO22 = "/fishinfo2";

  table.insert(UISpecialFrames, "FishInfo2Frame");

  FishInfo2DataSub = FishInfo2DataSub or {};
  if type(FishInfo2DataSub) ~= "table" then
    -- a corrupt SavedVariables file may have replaced it with anything
    FishInfo2DataSub = {};
  end
end

-- Structural validation ------------------------------------------------------
-- A half-written or hand-edited SavedVariables file used to make pairs() and
-- the nested zone/subZone indexing throw at runtime (audit M1). Instead of
-- trusting the stored shape, walk it once at login and drop whatever cannot be
-- used. Deleting the key currently being visited is explicitly allowed while
-- traversing with pairs(), so this needs no temporary table.
function FishInfo2.ValidateDatabase(chardb, dropped)
  local zones;
  for name, fishdata in pairs(chardb) do
    if type(fishdata) ~= "table" then
      chardb[name] = nil;
      dropped = dropped + 1;
    else
      zones = fishdata["zones"];
      if type(zones) ~= "table" then
        chardb[name] = nil;
        dropped = dropped + 1;
      else
        -- optional fields must never reach SetTexture / ITEM_QUALITY_COLORS
        if type(fishdata["texture"])  ~= "string" then fishdata["texture"]  = nil; end
        if type(fishdata["rarity"])   ~= "number" then fishdata["rarity"]   = nil; end
        if type(fishdata["link"])     ~= "string" then fishdata["link"]     = nil; end
        if type(fishdata["fullLink"]) ~= "string" then fishdata["fullLink"] = nil; end
        for zone, subZones in pairs(zones) do
          if type(subZones) ~= "table" then
            zones[zone] = nil;
            dropped = dropped + 1;
          else
            for subZone, amount in pairs(subZones) do
              if type(amount) ~= "number" then
                subZones[subZone] = nil;
                dropped = dropped + 1;
              end
            end
          end
        end
      end
    end
  end
  return dropped;
end

-- Validates every stored character database once per login. The "...|User"
-- preference tables hold flags rather than fish data and are skipped.
function FishInfo2.ValidateAllDatabases()
  local dropped = 0;
  for dbName, chardb in pairs(FishInfo2DataSub) do
    if type(dbName) == "string" and string.find(dbName, "|User", 1, true) == nil then
      if type(chardb) ~= "table" then
        FishInfo2DataSub[dbName] = nil;
        dropped = dropped + 1;
      else
        dropped = FishInfo2.ValidateDatabase(chardb, dropped);
      end
    end
  end
  return dropped;
end

function FishInfo2.Setup()
  FishInfo2DataSub = FishInfo2DataSub or {};
  if type(FishInfo2DataSub) ~= "table" then
    FishInfo2DataSub = {};
  end

  local playerName = UnitName("player");
  local realmName = GetCVar("realmName");
  if type(playerName) ~= "string" or type(realmName) ~= "string" then
    -- client not ready yet: leave db/dbUser nil so the next call retries
    return;
  end

  local databaseName = playerName .. "|" .. realmName; --"AllCharacters";
  local userDatabaseName = databaseName .. "|User";

  -- Repair the character/preference slots before validating: a corrupt file
  -- can leave a string or number where a table belongs.
  local dropped = 0;
  if FishInfo2DataSub[databaseName] ~= nil and type(FishInfo2DataSub[databaseName]) ~= "table" then
    dropped = dropped + 1;
  end
  if FishInfo2DataSub[userDatabaseName] ~= nil and type(FishInfo2DataSub[userDatabaseName]) ~= "table" then
    dropped = dropped + 1;
  end
  if type(FishInfo2DataSub[databaseName]) ~= "table" then
    FishInfo2DataSub[databaseName] = {};
  end
  if type(FishInfo2DataSub[userDatabaseName]) ~= "table" then
    FishInfo2DataSub[userDatabaseName] = {};
  end

  dropped = FishInfo2.ValidateAllDatabases() + dropped;

  db = FishInfo2DataSub[databaseName];
  dbUser = FishInfo2DataSub[userDatabaseName];
  dbOthers = FishInfo2.CollectDatabasesFromOtherCharacters(databaseName);

  -- Default is to include data from other characters.
  if dbUser["IsIncludeOthers"] == nil then
    dbUser["IsIncludeOthers"] = true;
  end
  if dbUser["IsTooltipEnabled"] == nil then
    dbUser["IsTooltipEnabled"] = true;
  end

  -- Schema version. The header records that the database format already
  -- changed once ("testversion1 -> 2") and lost data doing so; recording a
  -- version makes the next change migratable instead of silent.
  if dbUser["SchemaVersion"] ~= FISHINFO2_SCHEMA_VERSION then
    -- future migrations step through the versions here
    dbUser["SchemaVersion"] = FISHINFO2_SCHEMA_VERSION;
  end

  if dropped > 0 then
    FishInfo2.Message(string.format(FISHINFO2_DB_CLEANED, dropped));
  end
end

-- Entry points can run before VARIABLES_LOADED (a slash command, or another
-- addon forcing the frame to Show() during login). Build the pointers on
-- demand so those paths can never index a nil db/dbUser (audit M4).
function FishInfo2.EnsureSetup()
  if db == nil or dbUser == nil then
    FishInfo2.Setup();
  end
  -- Setup declines while the client still does not know the player name; fall
  -- back to throwaway tables so the caller degrades instead of erroring. The
  -- real database replaces these when VARIABLES_LOADED arrives.
  if db == nil then db = {}; end
  if dbUser == nil then dbUser = {}; end
  if dbOthers == nil then dbOthers = {}; end
end

function FishInfo2.OnEvent(event)
  if event == "VARIABLES_LOADED"  then
    FishInfo2.Setup();
    FishInfo2.Message(FISHINFO2_VERSION .. FISHINFO2_LOADED);
  elseif event == "LOOT_OPENED" and CallClientApi("IsFishingLoot") then
    -- 1.12 signature: lootIcon, lootName, lootQuantity, lootQuality, ...
    -- The icon is the FIRST return value; dropping it shifted name/count/quality.
    local texture, name, count, quality = CallClientApi("GetLootSlotInfo", 1);
    -- Defensive: modified clients (e.g. Turtle WoW) or addons hooking the
    -- loot APIs may return nil or non-numeric values; normalize them so the
    -- quantity arithmetic in FishInfo2.UpdateDatabase can never crash.
    if type(name) ~= "string" or name == "" then
      return;
    end
    count = tonumber(count) or 1;
    quality = tonumber(quality);
    -- Use the loot icon straight from GetLootSlotInfo. Do NOT re-derive it
    -- with GetItemIcon(name): that API (where it exists at all) expects an
    -- item id/link. A nil texture is rendered later with the default fallback.
    if type(texture) ~= "string" or texture == "" then
      texture = nil;
    end
    local link = CallClientApi("GetLootSlotLink", 1);
    if type(link) ~= "string" or link == "" then
      link = nil;
    end
    FishInfo2.UpdateDatabase(true, GetZoneText(), GetMinimapZoneText(), link, texture, name, count, quality);
    if FishInfo2Frame:IsVisible() then
      FishInfo2.UpdateGui();
    end
  elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
    if FishInfo2Frame:IsVisible() then
      -- preselect current zone/subzone not immediately, wait until window is reopened.
      isEnableFirstViewOnHide = true;
    else
      isFirstView = true;
    end
  end
end

function FishInfo2.UpdateDatabase(showMsg, zone, subZone, link, texture, name, quantity, rarity)
  FishInfo2.EnsureSetup();

  -- Defensive: a modified client or a corrupted caller must never be able to
  -- poison the database with a non-string key or a non-numeric count (M1/M4).
  if type(name) ~= "string" or name == "" then
    return;
  end
  if type(zone) ~= "string" then zone = ""; end
  if type(subZone) ~= "string" then subZone = ""; end
  quantity = tonumber(quantity) or 1;
  if type(texture) ~= "string" or texture == "" then texture = nil; end
  if type(rarity) ~= "number" then rarity = nil; end

  if db[name] == nil then
    local fishdata = { texture = texture, rarity = rarity, zones = {} };
    db[name] = fishdata;
  end

  if db[name]["zones"][zone] == nil then
    db[name]["zones"][zone] = {}
  end

  if db[name]["zones"][zone][subZone] == nil then
    if showMsg then
      FishInfo2.Message(string.format(FISHINFO2_DBUPDATE, name, zone, subZone));
    end
    db[name]["zones"][zone][subZone] = 0;
  end

  db[name]["zones"][zone][subZone] = db[name]["zones"][zone][subZone] + quantity;

  -- Optional gametooltip link. Two values are kept because two different APIs
  -- consume them: a clean itemString for GetItemInfo(), and the complete
  -- original hyperlink for GameTooltip:SetHyperlink(). The old code stored
  -- "item:...|h[name]|h|r", which is neither a valid itemString nor a valid
  -- hyperlink (audit M3). string.find() is used with a capture, not
  -- string.match(), because string.match does not exist on Lua 5.0 / WoW 1.12.
  if db[name]["fullLink"] == nil and link then
    local _, _, itemString = string.find(link, "(item:[%d:]+)");
    if itemString ~= nil then
      itemString = string.gsub(itemString, ":$", "");
      db[name]["link"] = itemString;
      db[name]["fullLink"] = link;
    end
  end
end

function FishInfo2.ChatCommand(msg)
  FishInfo2.EnsureSetup();
  msg = string.lower(msg);
  if msg == "help" or msg == "hilfe" then
    FishInfo2.Message(FISHINFO2_CHATHELP1);
    FishInfo2.Message(FISHINFO2_CHATHELP2);
    FishInfo2.Message(FISHINFO2_CHATHELP3);
    FishInfo2.Message(FISHINFO2_TOOLTIP_STATUS[dbUser["IsTooltipEnabled"]]);
  elseif msg == "nopreselect" then
    isFirstView = false;
    FishInfo2Frame:Show();
  elseif msg == "tooltip on" or msg == "tooltip off" then
    dbUser["IsTooltipEnabled"] =  msg == "tooltip on";
    FishInfo2.Message(FISHINFO2_TOOLTIP_STATUS[dbUser["IsTooltipEnabled"]]);
  else
    FishInfo2Frame:Show();
  end
end


------------------------------------------------------------------------------
-- Search + Sort Function                                                   --
------------------------------------------------------------------------------
function FishInfo2.Search(matchFunc, sortFunc, query)

  lastSearchFunc = matchFunc;
  lastSortFunc = sortFunc;
  lastQuery = query;

  results = {};

  if sortFunc ~=nil and matchFunc ~= nil then
    FishInfo2.DatabaseFunction(matchFunc, nil, nil, results);
    FishInfo2.AddStats();
    table.sort(results, sortFunc);
  end

  getglobal("FishInfo2ScrollScrollBar"):SetValue(0);
  FishInfo2.UpdateResults();
end

-- One traversal of every database builds all the totals at once, instead of
-- re-scanning the entire database for every result row. The old code was
-- O(result rows x stored fish) and re-scanned everything for each row of an
-- "all catches" listing (audit M5). Semantics are unchanged: counts still sum
-- the current character plus the other characters when that option is on.
function FishInfo2.AccumulateStats(name, fishdata, cache)
  local zones = fishdata["zones"];
  if type(zones) ~= "table" then
    return;
  end
  for zone, subZones in pairs(zones) do
    if type(subZones) == "table" then
      local zoneTotal = 0;
      for subZone, amount in pairs(subZones) do
        if type(amount) == "number" then
          local fishSubKey = FishKey(name, zone, subZone);
          local zoneSubKey = ZoneKey(zone, subZone);
          cache.fishSub[fishSubKey] = (cache.fishSub[fishSubKey] or 0) + amount;
          cache.zoneSub[zoneSubKey] = (cache.zoneSub[zoneSubKey] or 0) + amount;
          zoneTotal = zoneTotal + amount;
        end
      end
      local fishZoneKey = FishKey(name, zone, "");
      cache.fishZone[fishZoneKey] = (cache.fishZone[fishZoneKey] or 0) + zoneTotal;
      cache.zone[zone] = (cache.zone[zone] or 0) + zoneTotal;
    end
  end
end

function FishInfo2.AddStats()
  local cache = { fishSub = {}, fishZone = {}, zoneSub = {}, zone = {} };
  FishInfo2.DatabaseFunction(FishInfo2.AccumulateStats, nil, nil, cache);

  local count;
  local totalCount;

  for index, resultdata in ipairs(results) do

    local name = resultdata["name"];
    local zone = resultdata["zone"];
    -- in zone-summary mode subZone holds the aggregated subzone list, so the
    -- per-zone totals are looked up with an empty subzone component
    local subZone = resultdata["subZone"];

    if FishInfo2.IsZoneSummary() then
      count = cache.fishZone[FishKey(name, zone, "")] or 0;
      totalCount = cache.zone[zone] or 0;
    else
      count = cache.fishSub[FishKey(name, zone, subZone)] or 0;
      totalCount = cache.zoneSub[ZoneKey(zone, subZone)] or 0;
    end

    results[index]["count"] = count;
    results[index]["totalCount"] = totalCount;
    results[index]["percent"] = FishInfo2.Round(count * 100 / totalCount);
  end
end

function FishInfo2.MatchZone(name, fishdata, results)
  local selectedZone = UIDropDownMenu_GetText(FishInfo2ZoneFrame);
  local selectedSubZone = UIDropDownMenu_GetText(FishInfo2SubZoneFrame);

  if results[name] == nil and fishdata["zones"][selectedZone] ~= nil and fishdata["zones"][selectedZone][selectedSubZone] ~= nil then
    table.insert(results, { ["name"] = name,
                            ["zone"] = selectedZone,
                            ["subZone"] = selectedSubZone,
                            ["rarity"] = fishdata["rarity"],
                            ["texture"] = fishdata["texture"] } );
    results[name] = true;
  end
end

function FishInfo2.MatchFish(name, fishdata, results)
  local searchPattern = FishInfo2Edit:GetText();

  if string.sub(searchPattern, 1, 1) == "%" then
    searchPattern = string.sub(searchPattern, 2);
  end

  if string.find(string.lower(name), string.lower(searchPattern), 1, true) ~= nil then
    for zone, subZones in pairs(fishdata["zones"]) do
      for subZone in pairs(subZones) do
        if results[FishKey(name, zone, subZone)] == nil then
          table.insert(results, { ["name"] = name,
                                  ["zone"] = zone,
                                  ["subZone"] = subZone,
                                  ["rarity"] = fishdata["rarity"],
                                  ["texture"] = fishdata["texture"] } );
          results[FishKey(name, zone, subZone)] = true;
        end
      end
    end
  end
end

function FishInfo2.MatchEntireZone(name, fishdata, results)
  local selectedZone = UIDropDownMenu_GetText(FishInfo2ZoneFrame);

  if fishdata["zones"][selectedZone] ~= nil then
    if results[name] == nil then
      local row = { ["name"] = name,
                    ["zone"] = selectedZone,
                    ["subZone"] = "",
                    ["rarity"] = fishdata["rarity"],
                    ["texture"] = fishdata["texture"] };
      table.insert(results, row);
      results[name] = { row = row, subs = {} };
    end

    local box = results[name];
    local added = false;
    for subZone in pairs(fishdata["zones"][selectedZone]) do
      if box.subs[subZone] == nil then
        box.subs[subZone] = true;
        table.insert(box.subs, subZone);
        added = true;
      end
    end
    -- Sort once per call instead of after every single insert: the old loop
    -- was O(k^2 log k) for k subzones (audit M5).
    if added then
      table.sort(box.subs);
      box.row["subZone"] = table.concat(box.subs, ", ");
    end
  end
end

function FishInfo2.SortFishProcent(data1, data2)
  if string.lower(data1["name"]) == string.lower(data2["name"]) then
    if data1["percent"] == data2["percent"] then
      return data1["zone"] .. data1["subZone"] < data2["zone"] .. data2["subZone"]
    else
      return data1["percent"] >  data2["percent"]
    end
  else
    return string.lower(data1["name"]) < string.lower(data2["name"])
  end
end

function FishInfo2.SortZone(data1, data2)
  return data1["zone"] .. data1["subZone"] .. string.lower(data1["name"]) < data2["zone"] .. data2["subZone"] .. string.lower(data2["name"]);
end

function FishInfo2.SortFish(data1, data2)
  return string.lower(data1["name"]) < string.lower(data2["name"]);
end


------------------------------------------------------------------------------
-- GUI                                                                      --
------------------------------------------------------------------------------
function FishInfo2.UpdateResults()

  FauxScrollFrame_Update(FishInfo2Scroll, table.getn(results), 5, FISHINFO2_SCROLLHEIGHT);

  for i = 1, 5 do
    local index = i + FauxScrollFrame_GetOffset(FishInfo2Scroll);

    -- to make the following code easier to maintain
    local frame = getglobal("FishInfo2Row" .. i);
    -- remember the visible row number for OnEnter/OnMouseUp handlers
    frame.rowIndex = i;
    local icon = getglobal("FishInfo2Row" .. i .. "Icon");
    local nameText = getglobal("FishInfo2Row" .. i .. "Name");
    local zoneText = getglobal("FishInfo2Row" .. i .. "Zone");
    local procentText = getglobal("FishInfo2Row" .. i .. "Percent");
    local countText = getglobal("FishInfo2Row" .. i .. "Count");

    if index <= table.getn(results) then
      local fishdata = results[index];

      -- fill in info about fish
      icon:SetTexture(fishdata["texture"] or "Interface\\Icons\\INV_Misc_Fish_01");
      icon:SetAlpha(0.65);
      nameText:SetText(fishdata["name"]);
      local quality = ITEM_QUALITY_COLORS[fishdata["rarity"]] or ITEM_QUALITY_COLORS[0];
      nameText:SetTextColor(quality.r, quality.g, quality.b);

      if FishInfo2.IsZoneSummary() then
        zoneText:SetText(fishdata["subZone"]);
      else
        zoneText:SetText(fishdata["zone"] .. " - " .. fishdata["subZone"]);
      end

      -- fill in stats
      countText:SetText(fishdata["count"]);
      procentText:SetText(fishdata["percent"] .. "%");

      frame:Show();
    else
      frame:Hide();
    end
  end

  if table.getn(results) == 0 then
    FishInfo2InfoText:SetText(FISHINFO2_NODATA);
    FishInfo2InfoText:SetTextColor(1.0, 0.5, 0.5);
    FishInfo2InfoText2:SetText("");
  else
    FishInfo2InfoText:SetText(string.format(FISHINFO2_RESULTS1, table.getn(results)));
    if lastQuery == "" and lastSearchFunc ~= nil then
      FishInfo2InfoText2:SetText(FISHINFO2_RESULTS3);
    elseif lastQuery == "%" and lastSearchFunc ~= nil then
      FishInfo2InfoText2:SetText(FISHINFO2_RESULTS4);
    else
      FishInfo2InfoText2:SetText(string.format(FISHINFO2_RESULTS2, lastQuery));
    end
  end
end

function FishInfo2.UpdateGui()
  FishInfo2.EnsureSetup();

  if isFirstView then
    selectedZone = GetZoneText();
    selectedSubZone = GetMinimapZoneText();
    lastSearchFunc = FishInfo2.MatchZone;
    lastSortFunc = FishInfo2.SortFish;
    lastQuery = selectedZone .. " (" .. selectedSubZone .. ")";
  end

  UIDropDownMenu_Initialize(FishInfo2ZoneFrame, FishInfo2.UpdateZoneList);
  UIDropDownMenu_Initialize(FishInfo2SubZoneFrame, FishInfo2.UpdateSubZoneList);

  if FishInfo2.IsIncludeOthers() then
    FishInfo2CheckOthers:SetChecked(1);
  else
    FishInfo2CheckOthers:SetChecked(0);
  end

  FishInfo2.Search(lastSearchFunc, lastSortFunc, lastQuery);

  if isFirstView then
    -- In case zone or subZone is not in database the text gets deleted.
    -- To give visual feedback, we just display them again.
    UIDropDownMenu_SetText(selectedZone, FishInfo2ZoneFrame);
    UIDropDownMenu_SetText(selectedSubZone, FishInfo2SubZoneFrame);
    isFirstView = false;
  end
end

function FishInfo2.FillInZones(name, fishdata, zones)
  for zone in pairs(fishdata["zones"]) do
    if zones[zone] == nil then
      zones[zone] = true;
      table.insert(zones, zone);
    end
  end
end

function FishInfo2.UpdateZoneList()
  local zones = {};

  FishInfo2.DatabaseFunction(FishInfo2.FillInZones, nil, nil, zones);
  table.sort(zones);

  for index, zone in ipairs(zones) do
    -- fresh info table per button: AddButton keeps a reference to it
    local info = { func = FishInfo2.ZoneClicked, text = zone, value = zone };
    UIDropDownMenu_AddButton(info);
  end

  if zones[selectedZone] ~= nil then
    UIDropDownMenu_SetSelectedValue(FishInfo2ZoneFrame, selectedZone);
  else
    UIDropDownMenu_SetSelectedValue(FishInfo2ZoneFrame, nil);
    UIDropDownMenu_SetText("", FishInfo2ZoneFrame);
  end
end

function FishInfo2.FillInSubZones(name, fishdata, subZones, forZone)
  if fishdata["zones"][forZone] ~= nil then
    for subZone in pairs(fishdata["zones"][forZone]) do
      if subZones[subZone] == nil then
        subZones[subZone] = true;
        table.insert(subZones, subZone);
      end
    end
  end
end

function FishInfo2.UpdateSubZoneList()
  local subZones = {};

  FishInfo2.DatabaseFunction(FishInfo2.FillInSubZones, nil, nil, subZones, UIDropDownMenu_GetText(FishInfo2ZoneFrame));
  table.sort(subZones);

  -- fill in subzone combobox
  local subzonesCount = 0;
  for index, subZone in ipairs(subZones) do
    -- fresh info table per button: AddButton keeps a reference to it
    local info = { func = FishInfo2.StartZoneSearch, text = subZone, value = subZone };
    UIDropDownMenu_AddButton(info);
    subzonesCount = subzonesCount + 1;
  end

  if subzonesCount > 0 then
    local info = { func = FishInfo2.StartZoneSearch, text = FISHINFO2_ALL_SUBZONES, value = FISHINFO2_ALL_SUBZONES };
    UIDropDownMenu_AddButton(info);
  end

  if subZones[selectedSubZone] or (selectedSubZone == FISHINFO2_ALL_SUBZONES and subzonesCount > 0) then
    UIDropDownMenu_SetSelectedValue(FishInfo2SubZoneFrame, selectedSubZone);
  else
    UIDropDownMenu_SetSelectedValue(FishInfo2SubZoneFrame, nil);
    UIDropDownMenu_SetText("", FishInfo2SubZoneFrame);
  end
end


------------------------------------------------------------------------------
-- GUI Event handlers                                                       --
------------------------------------------------------------------------------

-- called when a zone is selected
function FishInfo2.ZoneClicked()
  UIDropDownMenu_SetSelectedID(FishInfo2ZoneFrame, this:GetID())
  selectedZone = UIDropDownMenu_GetText(FishInfo2ZoneFrame);

  -- reset subzone combobox
  selectedSubZone = FISHINFO2_ALL_SUBZONES;
  UIDropDownMenu_SetSelectedValue(FishInfo2SubZoneFrame, FISHINFO2_ALL_SUBZONES);
  UIDropDownMenu_SetText(FISHINFO2_ALL_SUBZONES, FishInfo2SubZoneFrame);

  FishInfo2.Search(FishInfo2.MatchEntireZone, FishInfo2.SortFish,
                   UIDropDownMenu_GetText(FishInfo2ZoneFrame) .. " (" .. FISHINFO2_ALL_SUBZONES .. ")");
end

-- called when a subzone is selected
function FishInfo2.StartZoneSearch()
  UIDropDownMenu_SetSelectedID(FishInfo2SubZoneFrame, this:GetID())
  selectedSubZone = UIDropDownMenu_GetText(FishInfo2SubZoneFrame)

  -- Start zone search
  if selectedSubZone == FISHINFO2_ALL_SUBZONES then
    FishInfo2.Search(FishInfo2.MatchEntireZone, FishInfo2.SortFish,
                     UIDropDownMenu_GetText(FishInfo2ZoneFrame) .. " (" .. UIDropDownMenu_GetText(FishInfo2SubZoneFrame) .. ")");
  else
    FishInfo2.Search(FishInfo2.MatchZone, FishInfo2.SortFish,
                     UIDropDownMenu_GetText(FishInfo2ZoneFrame) .. " (" .. UIDropDownMenu_GetText(FishInfo2SubZoneFrame) .. ")");
  end
end

-- called from OnEnterPressed (editbox)
function FishInfo2.StartFishSearch()
  -- Start fish name search
  if FishInfo2Edit:GetText() ~= "" then
    FishInfo2Edit:AddHistoryLine(FishInfo2Edit:GetText());
  end
  if string.sub(FishInfo2Edit:GetText(), 1, 1) == "%" then
    FishInfo2.Search(FishInfo2.MatchFish, FishInfo2.SortFishProcent, FishInfo2Edit:GetText());
  else
    FishInfo2.Search(FishInfo2.MatchFish, FishInfo2.SortZone, FishInfo2Edit:GetText());
  end
end

function FishInfo2.IconClicked()
  local index = this.rowIndex + FauxScrollFrame_GetOffset(FishInfo2Scroll);
  GameTooltip:Hide();
  FishInfo2Edit:SetText("%" .. results[index]["name"]);
  FishInfo2.StartFishSearch();
end

------------------------------------------------------------------------------
-- Helper Functions                                                         --
------------------------------------------------------------------------------
function FishInfo2.IsZoneSummary()
  return lastSearchFunc == FishInfo2.MatchEntireZone;
end

function FishInfo2.UpdateGametooltip()
  FishInfo2.EnsureSetup();
  if dbUser["IsTooltipEnabled"] then
    local index = this.rowIndex + FauxScrollFrame_GetOffset(FishInfo2Scroll);
    local name = results[index]["name"];

    if linkCache[name] == nil then
      linkCache[name] = FishInfo2.DatabaseFunction(FishInfo2.FindLink, FishInfo2.KeepFirst, nil, name);
    end
    if fullLinkCache[name] == nil then
      fullLinkCache[name] = FishInfo2.DatabaseFunction(FishInfo2.FindFullLink, FishInfo2.KeepFirst, nil, name);
    end

    if linkCache[name] and GetItemInfo(linkCache[name]) then
      GameTooltip:SetOwner(this, "ANCHOR_LEFT");
      -- SetHyperlink wants a complete hyperlink; the stored itemString is only
      -- guaranteed to satisfy GetItemInfo (audit M3).
      GameTooltip:SetHyperlink(fullLinkCache[name] or linkCache[name]);

      if FishInfo2.IsZoneSummary() then
        local tooltipLines = GameTooltip:NumLines();
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine(FISHINFO2_LIST_SUBZONES, 1.0, 1.0, 1.0);
        for index, subZone in ipairs(results[name].subs) do
          GameTooltip:AddLine(subZone);
          -- change width if necessary
          local strwidth = getglobal("GameTooltipTextLeft" .. GameTooltip:NumLines()):GetStringWidth() + 20;
          if strwidth > GameTooltip:GetWidth() then
            GameTooltip:SetWidth(strwidth);
          end
        end
        GameTooltip:SetHeight(GameTooltip:GetHeight() + 14 * (GameTooltip:NumLines() - tooltipLines));
      end
    end
  end
end

function FishInfo2.FindLink(name, fishdata, matchName)
  if name == matchName and fishdata["link"] then
    return fishdata["link"];
  else
    return nil;
  end
end

-- The complete original hyperlink, kept alongside the itemString for
-- GameTooltip:SetHyperlink (audit M3).
function FishInfo2.FindFullLink(name, fishdata, matchName)
  if name == matchName and fishdata["fullLink"] then
    return fishdata["fullLink"];
  else
    return nil;
  end
end

function FishInfo2.GetSubzoneCount(name, fishdata, matchName, matchZone, matchSubZone)
  if name == matchName then
    return FishInfo2.GetTotalSubzoneCount(name, fishdata, matchZone, matchSubZone);
  else
    return 0;
  end
end

function FishInfo2.GetTotalSubzoneCount(name, fishdata, matchZone, matchSubZone)
  if fishdata["zones"][matchZone] ~= nil and fishdata["zones"][matchZone][matchSubZone] ~= nil then
    return fishdata["zones"][matchZone][matchSubZone];
  else
    return 0;
  end
end

function FishInfo2.GetSubzonesCount(name, fishdata, matchName, matchZone)
  if name == matchName then
    return FishInfo2.GetTotalZoneCount(name, fishdata, matchZone);
  else
    return 0;
  end;
end

function FishInfo2.GetTotalZoneCount(name, fishdata, matchZone)
  local count = 0;
  if fishdata["zones"][matchZone] ~= nil then
    for subZone in pairs(fishdata["zones"][matchZone]) do
      count = count + fishdata["zones"][matchZone][subZone];
    end
  end
  return count;
end

function FishInfo2.Round(number)
  -- guard against nil-like results: NaN (0/0) and non-positive values show as 0
  if number ~= number or number <= 0 then
    return 0;
  end
  return math.max(1, math.floor(number + 0.5));
end

function FishInfo2.IsIncludeOthers()
  return dbUser["IsIncludeOthers"];
end

function FishInfo2.SetIncludeOthers(isIncludeOthers)
  if isIncludeOthers then
    dbUser["IsIncludeOthers"] = true;
  else
    dbUser["IsIncludeOthers"] = false;
  end
end

function FishInfo2.Message(msg)
  ChatFrame1:AddMessage(NORMAL_FONT_COLOR_CODE .. "FishInfo2: " .. LIGHTYELLOW_FONT_COLOR_CODE.. msg);
end

function FishInfo2.OnHide()
  if isEnableFirstViewOnHide then
    isFirstView = true;
    isEnableFirstViewOnHide = false;
  end
end

------------------------------------------------------------------------------
-- Database functions, helps managing multiple databases                    --
------------------------------------------------------------------------------

-- find databases from other characters and save the pointers
function FishInfo2.CollectDatabasesFromOtherCharacters(excludeDatabaseName)
  local databases = { };
  -- the loop variable is deliberately NOT named "db": it used to shadow the
  -- file-level current-character database, which read as if this loop walked
  -- the current character's data (audit M6).
  for dbName, dbOther in pairs(FishInfo2DataSub) do
    if type(dbName) == "string" and dbName ~= excludeDatabaseName and string.find(dbName, "|User", 1, true) == nil then
      databases[dbName] = dbOther;
    end
  end
  return databases;
end

-- collects data via 'func'/'funcReturn' within the current character database or within all.
function FishInfo2.DatabaseFunction(func, funcReturn, returnDefault, arg1, arg2, arg3)
  FishInfo2.EnsureSetup();
  local returnValue = returnDefault;
  local addValue;
  -- execute 'func' for current character database
  for name, fishdata in pairs(db) do
    addValue = func(name, fishdata, arg1, arg2, arg3);
    if funcReturn ~= nil then
      returnValue = funcReturn(returnValue, addValue);
    end
  end
  -- execute 'func' for databases from other characters (if enabled)
  if FishInfo2.IsIncludeOthers() then
    for dbName, dbOther in pairs(dbOthers) do
      for name, fishdata in pairs(dbOther) do
        addValue = func(name, fishdata, arg1, arg2, arg3);
        if funcReturn ~= nil then
          returnValue = funcReturn(returnValue, addValue);
        end
      end
    end
  end
  return returnValue;
end

--
function FishInfo2.AddNumbers(num1, num2)
  return num1 + num2;
end

function FishInfo2.KeepFirst(obj1, obj2)
  if obj1 ~= nil then
    return obj1;
  end

  if obj2 ~= nil then
    return obj2;
  end

  return nil;
end

------------------------------------------------------------------------------
-- Titan Panel support                                                      --
------------------------------------------------------------------------------
function TitanPanelFishInfo2Button_OnLoad()
  this.registry = {
    id = FISHINFO2_TITAN_ID,
    menuText = FISHINFO2,
    buttonTextFunction = nil,
    tooltipTitle = FISHINFO2,
    tooltipTextFunction = "TitanPanelFishInfo2Button_GetTooltipText",
    frequency = 0,
    icon = "Interface\\Icons\\INV_Misc_Fish_03"
  };
end

function TitanPanelFishInfo2Button_GetTooltipText()
  if FishInfo2Frame:IsVisible() then
    return FISHINFO2_TITAN_TOOLTIP1;
  else
    return string.format(FISHINFO2_TITAN_TOOLTIP2, GetZoneText(), GetMinimapZoneText());
  end
end

function TitanPanelFishInfo2Button_OnClick(arg1)
  if arg1 == "LeftButton" then
    if FishInfo2Frame:IsVisible() then
      FishInfo2Frame:Hide();
    else
      isFirstView = true;
      FishInfo2Frame:Show();
    end
  end
end

function TitanPanelRightClickMenu_PrepareFishInfo2Menu()
  TitanPanelRightClickMenu_AddTitle(TitanPlugins[FISHINFO2_TITAN_ID].menuText);
  TitanPanelRightClickMenu_AddSpacer();
  TitanPanelRightClickMenu_AddCommand(FISHINFO2_TITAN_MENU_TOGGLE, nil, "TitanPanelFishInfo2Toggle");
  TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, FISHINFO2_TITAN_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

function TitanPanelFishInfo2Toggle()
  if FishInfo2Frame:IsVisible() then
    FishInfo2Frame:Hide();
  else
    FishInfo2Frame:Show()
  end
end
