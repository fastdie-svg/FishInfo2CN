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

# 致谢原作者

本插件是 **Bastian Pflieger (wbb)** 所创作的 *Fish Info 2* 的简体中文汉化修复版，
原作者邮箱 wbb1977@gmail.com，原作初版于 2007 年 7 月 4 日，最后一个上游版本为
2018 年 12 月 27 日的 v10。而 *Fish Info 2* 本身又是对 *Impp's Fishing Info 1.2*
的重新实现。

**衷心感谢 Bastian Pflieger (wbb) 在长达十余年间无偿创作并维护这个插件。**
本插件的一切基础设计与实现都归功于他，本版本只是在原作之上修补缺陷、完成中文
本地化。原作者的署名信息保留在 `FishInfo2CN.toc` 的 `## Author:` 字段与
`FishInfo2.lua` 的文件头注释中，未作任何改动。

# 开源许可证

本项目以 **GNU General Public License v3.0 或更新版本（GPL-3.0-or-later）** 发布，
许可证完整正文见根目录 [`LICENSE`](LICENSE) 文件，版权归属、上游传承、本版本改动
清单与原作者鸣谢详见 [`NOTICE`](NOTICE) 文件。

    Copyright (C) 2026  fastdie-svg
    Copyright (C) 2007-2018  Bastian Pflieger (wbb)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

需要说明的是：据本仓库维护者所知，原版 *Fish Info 2* 并未附带明确的许可证文件，
以 GPL-3.0-or-later 发布是维护者主动选择的授权方式，也以此明确表达对原作者的
署名与感谢。若原作者对此有任何异议或希望改用其他许可证，请通过上方邮箱或本仓库
Issue 联系，我们会立即配合调整。

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

# Credits

This addon is a Simplified-Chinese localization and bugfix fork of
**Fish Info 2**, originally created by **Bastian Pflieger (wbb)**
<wbb1977@gmail.com>. The original was first released on July 4, 2007, with its
last upstream version v10 dated December 27, 2018. *Fish Info 2* is itself a
remake of *Impp's Fishing Info 1.2*.

**Heartfelt thanks to Bastian Pflieger (wbb) for creating and maintaining this
addon on a voluntary basis for more than a decade.** All of the underlying
design and implementation is his work; this fork only fixes defects and adds
Simplified-Chinese localization on top of it. His attribution is preserved
untouched in the `## Author:` field of `FishInfo2CN.toc` and in the file header
comment of `FishInfo2.lua`.

# License

This project is released under the **GNU General Public License v3.0 or later
(GPL-3.0-or-later)**. The full license text is in the [`LICENSE`](LICENSE)
file; the copyright ownership, upstream lineage, list of modifications made in
this fork, and credits to the original author are documented in the
[`NOTICE`](NOTICE) file.

    Copyright (C) 2026  fastdie-svg
    Copyright (C) 2007-2018  Bastian Pflieger (wbb)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Note: to the best of the maintainer's knowledge, the original *Fish Info 2* was
distributed without an explicit license file. Releasing this fork under
GPL-3.0-or-later is the maintainer's own choice, made in order to credit the
original author explicitly. If the original author disagrees with this
licensing or prefers another license, please contact us via the email above or
through a repository issue and we will adjust promptly.
