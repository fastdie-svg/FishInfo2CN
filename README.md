# Fish Info 2 CN
原版《魔兽世界》钓鱼插件，在原作者的基础上修补BUG并完成中文本地化，版本号：V10-release 。
# 函数 
对于每个区域，它都会记录你在那里钓到的鱼。这基本上是“Impp's Fishing Info”的翻版。 
# 如何访问 
* 在聊天中输入 <code>/fi2</code> 命令。 
* 分配一个键来切换显示。 
* 通过“Titan Panel”，启用“Fish Info 2”按钮。点击该按钮，将显示您在当前子区域捕获的所有鱼类。再次点击可隐藏该窗口。  
按<kbd>Esc</kbd>键或点击“关闭”按钮可隐藏窗口。您可以移动该窗口。  
请注意：如果您进入一个子区域（小地图文本会发生变化），并且您是第一次在此子区域中打开该窗口，则脚本会为您预选当前区域/子区域。如果您不喜欢这样，请使用“/fi2 nopreselect”聊天命令来打开窗口。 
# 如何使用 
首先，去抓些鱼吧:) 数据库在初次启动时是空的。 
它有两种模式： 
* 从标有“区域”的下拉列表中选择一个区域和一个子区域。该列表包含您曾去钓鱼的所有区域/子区域。脚本会列出您在该子区域捕获的所有鱼类。列表按鱼类名称排序。 
* 在标有“名称”的编辑框中输入鱼名，然后按下<kbd>Enter</kbd>键。脚本会列出你钓到该鱼的所有区域。列表按区域名称排序。在鱼名前加上%前缀，结果列表将按百分比排序。  
提示：留空并按<kbd>Enter</kbd>键可列出所有鱼类。只需输入一个%并按<kbd>Enter</kbd>键，即可查看按百分比排序的所有鱼类。 
结果列表中的图标上有两个数字覆盖层： 
* 右上角：你在该子区域捕到鱼的频率。 
* 底部：该子区域的百分比。 
# 局限性 
* 区域和子区域名称完全按照客户端在当前客户端语言环境（例如，zhTW语言环境中的中文名称）中的显示方式进行存储。更改客户端语言或对区域文本进行任何更改（例如，服务器内容补丁）都会导致之前存储的条目不再匹配。 
* 每个角色的数据都以“角色名称 | 服务器”为键进行存储。重命名角色或更改服务器会创建一个全新的数据库。 
“包含我的其他角色数据”功能会读取存储在此账户共享的SavedVariables文件中的所有角色数据库；这些角色必须属于同一账户。（备注：WTF/Account/playername/SavedVariables/）

----------------------------------------------------------------------------------------------------------

# Fish Info 2
Vanilla World of Warcraft Fishing Addon 

# Functions
For every zone, it stores what fishes you caught there. It is basically a remake of 'Impp's Fishing Info'.

# How to access it
* Enter <code>/fi2</code> or <code>/fishinfo2</code> command in the chat.
* Assign a key to toggle display.
* Via Titan Panel, enable the Fish Info 2 button. If you click the button it will show all fishes you caught in the current subzone. Click again to hide the window. 

Press <kbd>Esc</kbd> or the Close button to hide the window. You can move the window. 

Please note: if you enter a subzone (minimap text changes) and you open the window for the first time in this subzone, the script preselect the current zone/subzone for you. If you don't like this, use "/fi2 nopreselect" chat command to open the window.

# How to use it
First, go catch some fish :) . At first startup there is nothing in the database.

It has two modes:
* Select a zone and a subzone from the dropdown lists labeled with 区域. It contains all zones/subzones where you were gone fishing. The script list then all fishes you caught in that subzone. The list is sorted by fish name.
* Enter a fish name in the editbox labeled with Name and press <kbd>Enter</kbd>. The script list then all zones in which you caught that fish. The list is sorted by zone name. Prefix a fish name with % to sort the result list by percentage. 

Hint: leave blank and press <kbd>Enter</kbd> to list all fish. Just write a % and press <kbd>Enter</kbd> so see all fish sorted by percentage.

The icons in the result list have two number overlays:
* top right: how often you caught the fish in this subzone.
* bottom: percentage for this subzone.

# Limitations
* Zone and subzone names are stored exactly as the client displays them in the current client locale (e.g. Chinese names for the zhTW locale). Changing the client language, or any change to zone text (e.g. a server content patch), makes previously stored entries stop matching.
* Per-character data is keyed by "character name | realm". Renaming a character or changing the realm starts a fresh database.
* The "include data from my other characters" feature reads all character databases stored in this account's shared SavedVariables file; the characters must belong to the same account.
