-- Keep in sync with "## Version:" in FishInfo2CN.toc. WoW 1.12 has no
-- GetAddOnMetadata(), so this constant cannot be read back out of the TOC and
-- the version necessarily lives in two places. Bump both together.
FISHINFO2_VERSION = "V10beta";

-- Localization: only Simplified Chinese (zhCN) and English are maintained.
-- The deDE / zhTW / frFR branches were removed: every locale other than
-- zhCN now falls through to the English branch at the bottom, so a German,
-- French or Traditional Chinese client no longer sees Chinese labels.
--
-- Keep this file UTF-8 without BOM: the zhCN strings below are UTF-8.
if GetLocale() == "zhCN" then

  --
  -- 简体中文 (Simplified Chinese)
  --
  FISHINFO2 = "Fish Info 2 CN";
  FISHINFO2_LOADED = " 已载入。";

  -- MyAddons
  FISHINFO2_MYADDONS_DESCRIPTION = "何处可以钓到这种鱼类？";

  FISHINFO2_MYADDONS_HELP1 = NORMAL_FONT_COLOR_CODE .. "聊天命令";
  FISHINFO2_MYADDONS_HELP2 = LIGHTYELLOW_FONT_COLOR_CODE .. "你也可以设置快捷键来显示/隐藏这个窗口。";
  FISHINFO2_MYADDONS_HELP3 = NORMAL_FONT_COLOR_CODE .. "提示: " .. LIGHTYELLOW_FONT_COLOR_CODE .. "在鱼类名称前加上前缀 '%'，搜索列表将以百分比显示。";

  -- Titan Panel
  FISHINFO2_TITAN_TOOLTIP1 = GREEN_FONT_COLOR_CODE .. "提示: 左键点击关闭窗口。"
  -- 第 1 个参数: 区域, 第 2 个参数: 子区域
  FISHINFO2_TITAN_TOOLTIP2 = GREEN_FONT_COLOR_CODE .. "提示: 左键点击显示在\n" .. GREEN_FONT_COLOR_CODE .. "'%s (%s)' 所捕获的鱼种。";
  FISHINFO2_TITAN_MENU_TOGGLE = "切换显示";

  -- 第 1 个参数: 鱼名, 第 2 个参数: 区域, 第 3 个参数: 子区域
  FISHINFO2_DBUPDATE = "增加鱼种 '%s' (%s - %s)。";
  FISHINFO2_NODATA = " 无资料 / 无搜索结果!";
  -- 第 1 个参数: 被清理的损坏记录条数
  FISHINFO2_DB_CLEANED = "存档校验:已清理 %d 条损坏的渔获记录。"
  -- 第 1 个参数: 结果条数
  FISHINFO2_RESULTS1 = LIGHTYELLOW_FONT_COLOR_CODE .. "检索到%d 条结果：";
  -- 第 1 个参数: 查询字符串
  FISHINFO2_RESULTS2 = LIGHTYELLOW_FONT_COLOR_CODE .. "'" .. NORMAL_FONT_COLOR_CODE .. "%s" .. LIGHTYELLOW_FONT_COLOR_CODE .. "'"
  FISHINFO2_RESULTS3 = LIGHTYELLOW_FONT_COLOR_CODE .. "显示所有渔获，按区域排序"
  FISHINFO2_RESULTS4 = LIGHTYELLOW_FONT_COLOR_CODE .. "显示所有渔获，按百分比排序"

  FISHINFO2_ALL_SUBZONES = "所有区域";
  FISHINFO2_LIST_SUBZONES = "在此捕获:";

  FISHINFO2_LOCATION = "区域";
  FISHINFO2_NAME = "检索";
  FISHINFO2_CLOSE = "关闭窗口";
  FISHINFO2_INCLUDE_OTHERS = "由其他角色导入渔获统计信息";

  -- Bindings
  BINDING_HEADER_FISHINFO2 = FISHINFO2;
  BINDING_NAME_TOGGLE_FISHINFO2 = "切换显示";

  -- Chat
  FISHINFO2_CHATHELP1 = HIGHLIGHT_FONT_COLOR_CODE .. "/fi2" .. LIGHTYELLOW_FONT_COLOR_CODE .. " - 显示 " .. FISHINFO2 .. " 窗口。"
  FISHINFO2_CHATHELP2 = HIGHLIGHT_FONT_COLOR_CODE .. "/fi2 nopreselect" .. LIGHTYELLOW_FONT_COLOR_CODE .. " - 显示窗口，但不自动选择当前区域。"
  FISHINFO2_CHATHELP3 = HIGHLIGHT_FONT_COLOR_CODE .. "/fi2 tooltip on/off" .. LIGHTYELLOW_FONT_COLOR_CODE .. " - 开启/关闭提示。"
  FISHINFO2_TOOLTIP_STATUS = {
    [true] = "当前设置: " .. HIGHLIGHT_FONT_COLOR_CODE .. "提示已开启。",
    [false] = "当前设置: " .. HIGHLIGHT_FONT_COLOR_CODE .. "提示已关闭。"
  };

else

  --
  -- English (also the fallback for deDE / frFR / zhTW / every other locale)
  --
  FISHINFO2 = "Fish Info 2 CN";
  FISHINFO2_LOADED = " loaded.";

  -- MyAddons
  FISHINFO2_MYADDONS_DESCRIPTION = "Where I catched that fish?";

  FISHINFO2_MYADDONS_HELP1 = NORMAL_FONT_COLOR_CODE .. "Slash commands";
  FISHINFO2_MYADDONS_HELP2 = LIGHTYELLOW_FONT_COLOR_CODE .. "You can also bind a key to show/hide the window.";
  FISHINFO2_MYADDONS_HELP3 = NORMAL_FONT_COLOR_CODE .. "Hint: " .. LIGHTYELLOW_FONT_COLOR_CODE .. "Prefix the fish name with a '%'. Then the result list will be sorted by percent.";

  -- Titan Panel
  FISHINFO2_TITAN_TOOLTIP1 = GREEN_FONT_COLOR_CODE .. "Hint: Left-click to close the window."
  -- 1st Parameter: Zone, 2nd Parameter: SubZone
  FISHINFO2_TITAN_TOOLTIP2 = GREEN_FONT_COLOR_CODE .. "Hint: Left-click to show catched fishes at\n" .. GREEN_FONT_COLOR_CODE .. "'%s (%s)'.";
  FISHINFO2_TITAN_MENU_TOGGLE = "Toggle display";

  -- 1st Paramter: Fishname, 2nd Parameter: Zone, 3rd Paramter: SubZone
  FISHINFO2_DBUPDATE = "Added fish '%s' (%s - %s).";
  FISHINFO2_NODATA = " No data / No search results!";
  -- 1st Paramter: number of damaged entries that were dropped
  FISHINFO2_DB_CLEANED = "Database check: dropped %d damaged entry/entries."
  -- 1st Paramter: number of hits
  FISHINFO2_RESULTS1 = LIGHTYELLOW_FONT_COLOR_CODE .. "%d results found:";
  -- 1st Paramter: Query string
  FISHINFO2_RESULTS2 = LIGHTYELLOW_FONT_COLOR_CODE .. "'" .. NORMAL_FONT_COLOR_CODE .. "%s" .. LIGHTYELLOW_FONT_COLOR_CODE .. "'"
  FISHINFO2_RESULTS3 = LIGHTYELLOW_FONT_COLOR_CODE .. "Listing all catches, sorted by zone"
  FISHINFO2_RESULTS4 = LIGHTYELLOW_FONT_COLOR_CODE .. "Listing all catches, sorted by percentage"

  FISHINFO2_ALL_SUBZONES = "All subzones";
  FISHINFO2_LIST_SUBZONES = "Fish catched in:";

  FISHINFO2_LOCATION = "Location";
  FISHINFO2_NAME = "Name";
  FISHINFO2_CLOSE = "Close";
  FISHINFO2_INCLUDE_OTHERS = "Include catches from my other characters";

  -- Bindings
  BINDING_HEADER_FISHINFO2 = FISHINFO2;
  BINDING_NAME_TOGGLE_FISHINFO2 = "Toggle display";

  -- Chat
  FISHINFO2_CHATHELP1 = HIGHLIGHT_FONT_COLOR_CODE .. "/fi2" .. LIGHTYELLOW_FONT_COLOR_CODE .. " - show " .. FISHINFO2 .. " window."
  FISHINFO2_CHATHELP2 = HIGHLIGHT_FONT_COLOR_CODE .. "/fi2 nopreselect" .. LIGHTYELLOW_FONT_COLOR_CODE .. " - show window and do not select the current zone / subzone for me."
  FISHINFO2_CHATHELP3 = HIGHLIGHT_FONT_COLOR_CODE .. "/fi2 tooltip on/off" .. LIGHTYELLOW_FONT_COLOR_CODE .. " - enable / disable tooltips."
  FISHINFO2_TOOLTIP_STATUS = {
    [true] = "Present setup: " .. HIGHLIGHT_FONT_COLOR_CODE .. "Tooltips are shown.",
    [false] = "Present setup: " .. HIGHLIGHT_FONT_COLOR_CODE .. "Tooltips are not shown."
  };

end

-- myAddOns expects a string (or function) for X-Help, not a table
FISHINFO2_MYADDONS_XHELP = FISHINFO2_MYADDONS_HELP1 .. "\n\n" ..
  FISHINFO2_CHATHELP1 .. "\n\n" ..
  FISHINFO2_CHATHELP2 .. "\n\n" ..
  FISHINFO2_CHATHELP3 .. "\n\n" ..
  FISHINFO2_MYADDONS_HELP2 .. "\n\n\n" ..
  FISHINFO2_MYADDONS_HELP3;
