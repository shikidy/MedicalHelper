script_name("MedicalHelper")
script_authors("Kevin Hatiko")
script_description("Script for the Ministries of Health Arizona Saint Rose")
script_version("2.5.38")
script_properties("work-in-pause")
setver = 1
 
require "lib.sampfuncs"
require "lib.moonloader"
local mem = require "memory"
local vkeys = require "vkeys"
local encoding = require "encoding"
encoding.default = "CP1251"
local u8 = encoding.UTF8
local dlstatus = require("moonloader").download_status
 
local sampfuncsNot = [[
 �� ��������� ���� SAMPFUNCS.asi � ����� ����, ���������� ����
������� �� ������� �����������.

		��� ������� ��������:
1. �������� ����;
2. ��������� ������������ ��������� ��� � �� ���������� ������� ����� ���� � ����������.
� ��������� ����������: 
�������� Windows, McAfree, Avast, 360 Total � ������.
� ��� ��� ������ � ���������� ����� �������������� ����������.
3. ����������� ��������� ��������� �������.

��� ������������� ������� ����������� � ��������� ������:
		vk.me/hatiko_scripts

���� ���� ��������, ������� ������ ���������� ������. 
]]

local errorText = [[
		  ��������! 
�� ���������� ��������� ������ ����� ��� ������ �������.
� ��������� ����, ������ �������� ��������.
	������ �������������� ������:
		%s

		��� ������� ��������:
1. �������� ����;
2. ��������� ������������ ��������� ��� � �� ���������� ������� ����� ���� � ����������.
� ��������� ����������: 
�������� Windows, McAfree, Avast, 360 Total � ������.
� ��� ��� ������ � ���������� ����� �������������� ����������.
3. ����������� ��������� ��������� �������.

��� ������������� ������� ����������� � ��������� ������:
		vk.me/hatiko_scripts

���� ���� ��������, ������� ������ ���������� ������. 
]]

local files = {
"/lib/imgui.lua",
"/lib/samp/events.lua",
"/lib/rkeys.lua",
"/lib/faIcons.lua",
"/lib/crc32ffi.lua",
"/lib/bitex.lua",
"/lib/MoonImGui.dll",
"/lib/matrix3x3.lua"
}
local nofiles = {}
for i,v in ipairs(files) do
	if not doesFileExist(getWorkingDirectory()..v) then
		table.insert(nofiles, v)
	end
end

local ffi = require 'ffi'
ffi.cdef [[
		typedef int BOOL;
		typedef unsigned long HANDLE;
		typedef HANDLE HWND;
		typedef const char* LPCSTR;
		typedef unsigned UINT;
		
        void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
        uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		
		BOOL ShowWindow(HWND hWnd, int  nCmdShow);
		HWND GetActiveWindow();
		
		
		int MessageBoxA(
		  HWND   hWnd,
		  LPCSTR lpText,
		  LPCSTR lpCaption,
		  UINT   uType
		);
		
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
  ]]

local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)

if not doesFileExist(getGameDirectory().."/SAMPFUNCS.asi") then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, sampfuncsNot, "MedicalHelper", 0x00000030 + 0x00010000) 
end
if #nofiles > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, errorText:format(table.concat(nofiles, "\n\t\t")), "MedicalHelper", 0x00000030 + 0x00010000) 
end



local res, hook = pcall(require, 'lib.samp.events')
assert(res, "���������� SAMP Event �� �������")
----------------------------------------
local res, imgui = pcall(require, "imgui")
assert(res, "���������� Imgui �� �������")
-----------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, "���������� faIcons �� �������")
-----------------------------------------
local res, rkeys = pcall(require, 'rkeys')
assert(res, "���������� Rkeys �� �������")
vkeys.key_names[vkeys.VK_RBUTTON] = "RBut"
vkeys.key_names[vkeys.VK_XBUTTON1] = "XBut1"
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'




--- �������� �������
local deck = getFolderPath(0) -- ����
local doc = getFolderPath(5) -- screens
local dirml = getWorkingDirectory() -- ���
local dirGame = getGameDirectory()
local scr = thisScript()
local font = renderCreateFont("Trebuchet MS", 14, 5)
local fontPD = renderCreateFont("Trebuchet MS", 12, 5)
local fontH =  renderGetFontDrawHeight(font)
local sx, sy = getScreenResolution()
--os.remove(dirml.."/MedicalHelper/files/update.txt")
--os.remove(dirml.."/MedicalHelper/files/update.med")

local mainWin	= imgui.ImBool(false) -- ��.����
local paramWin = imgui.ImBool(false) -- ���� ����������
local spurBig = imgui.ImBool(false) -- ������� ���� �����
local sobWin = imgui.ImBool(false) -- ���� �������
local depWin = imgui.ImBool(false) -- ���� ������������
local updWin = imgui.ImBool(false) -- ���� ����������
local mcEditWin = imgui.ImBool(false)
local iconwin	= imgui.ImBool(false)
local profbWin = imgui.ImBool(false)
local select_menu = {true, false, false, false, false, false, false, false, false} -- ��� ������������ ����




local setting = {
	nick = "",
	teg = "",
	org = 0,
	sex = 0,
	rank = 0,
	time = false,
	timeDo = false, 
	timeTx = "",
	rac = false,
	racTx = "",
	lec = "",
	med = "",
	upmed = "",
	rec = "",
	narko = "",
	tatu = "",
	chat1 = false,
	chat2 = false,
	chat3 = false,
	chathud = false,
	arp = false,
	setver = 1,
	imageUp = false,
	imageDis = false
}
local buf_nick	= imgui.ImBuffer(256)
local buf_teg 	= imgui.ImBuffer(256)
local num_org		= imgui.ImInt(0)
local num_sex		= imgui.ImInt(0)
local num_rank	= imgui.ImInt(0)
local chgName = {}
chgName.inp = imgui.ImBuffer(100)
chgName.org = {u8"�������� ��", u8"�������� ��", u8"�������� ��"}
chgName.rank = {u8"������", u8"���������� ����", u8"��������", u8"��������", u8"�������", u8"������", u8"��������", u8"�����. ����������", u8"���.��.�����", u8"����.����", u8"������� ���������������"}

local list_org_BL = {"�������� LS", "�������� SF", "�������� LV"} 
local list_org	= {u8"�������� ��", u8"�������� ��", u8"�������� ��"}
local list_org_en = {"Los-Santos Medical Center","San-Fierro Medical Center","Las-Venturas Medical Center"}
local list_sex	= {fa.ICON_MALE .. u8" �������", fa.ICON_FEMALE .. u8" �������"} --ICON_MALE ICON_FEMALE 
local list_rank	= {u8"������", u8"���������� ����", u8"��������", u8"��������", u8"�������", u8"������", u8"��������", u8"�����. ����������", u8"���.��.�����", u8"����.����", u8"������� ���������������"}
--chat
local cb_chat1	= imgui.ImBool(false)
local cb_chat2	= imgui.ImBool(false)
local cb_chat3	= imgui.ImBool(false)
local cb_hud		= imgui.ImBool(false)
local hudPing = false
local cb_hudTime	= imgui.ImBool(false)
--RolePlay
local cb_time		= imgui.ImBool(false)
local cb_timeDo	= imgui.ImBool(false)
local cb_rac		= imgui.ImBool(false)
local buf_time	= imgui.ImBuffer(256)
local buf_rac		= imgui.ImBuffer(256)
--price
local buf_lec		= imgui.ImBuffer(10);
local buf_med		= imgui.ImBuffer(10);
local buf_upmed	= imgui.ImBuffer(10);
local buf_rec		= imgui.ImBuffer(10);
local buf_narko	= imgui.ImBuffer(10);
local buf_tatu	= imgui.ImBuffer(10);
--image
local cb_imageUp	= imgui.ImBool(false)
local cb_imageDis	= imgui.ImBool(false)
--shpora
local spur = {
text = imgui.ImBuffer(51200),
name = imgui.ImBuffer(256),
list = {},
select_spur = -1,
edit = false
}
--// menu settig
local PlayerSet = {}
function PlayerSet.name()
	if buf_nick.v ~= "" then
		return buf_nick.v
	else
		return u8"�� �������"
	end
end
function PlayerSet.org()
	return chgName.org[num_org.v+1]
end
function PlayerSet.rank()
	return chgName.rank[num_rank.v+1]
end
function PlayerSet.sex()
	return list_sex[num_sex.v+1]
end


--cmd bind
local selected_cmd = 1
local currentKey	= {"",{}}
local cb_RBUT		= imgui.ImBool(false)
local cb_x1		= imgui.ImBool(false)
local cb_x2		= imgui.ImBool(false)
local isHotKeyDefined = false
local p_open = false

--Binder
binder = {
	list = {},
	select_bind,
	edit = false,
	sleep = imgui.ImFloat(0.5),
	name = imgui.ImBuffer(256),
	text = imgui.ImBuffer(51200),
	key = {}
}
local helpd = {}
helpd.exp = imgui.ImBuffer(256)
helpd.exp.v =  u8[[
{dialog}
[name]=������ ���.�����
[1]=��������� ��������
��������� �1
��������� �2
[2]=������� ���������� 
��������� �1
��������� �2
{dialogEnd}
]]
helpd.key = {
	{k = "MBUTTON", n = '������ ����'},
	{k = "XBUTTON1", n = '������� ������ ���� 1'},
	{k = "XBUTTON2", n = '������� ������ ���� 2'},
	{k = "BACK", n = 'Backspace'},
	{k = "SHIFT", n = 'Shift'},
	{k = "CONTROL", n = 'Ctrl'},
	{k = "PAUSE", n = 'Pause'},
	{k = "CAPITAL", n = 'Caps Lock'},
	{k = "SPACE", n = 'Space'},
	{k = "PRIOR", n = 'Page Up'},
	{k = "NEXT", n = 'Page Down'},
	{k = "END", n = 'End'},
	{k = "HOME", n = 'Home'},
	{k = "LEFT", n = '������� �����'},
	{k = "UP", n = '������� �����'},
	{k = "RIGHT", n = '������� ������'},
	{k = "DOWN", n = '������� ����'},
	{k = "SNAPSHOT", n = 'Print Screen'},
	{k = "INSERT", n = 'Insert'},
	{k = "DELETE", n = 'Delete'},
	{k = "0", n = '0'},
	{k = "1", n = '1'},
	{k = "2", n = '2'},
	{k = "3", n = '3'},
	{k = "4", n = '4'},
	{k = "5", n = '5'},
	{k = "6", n = '6'},
	{k = "7", n = '7'},
	{k = "8", n = '8'},
	{k = "9", n = '9'},
	{k = "A", n = 'A'},
	{k = "B", n = 'B'},
	{k = "C", n = 'C'},
	{k = "D", n = 'D'},
	{k = "E", n = 'E'},
	{k = "F", n = 'F'},
	{k = "G", n = 'G'},
	{k = "H", n = 'H'},
	{k = "I", n = 'I'},
	{k = "J", n = 'J'},
	{k = "K", n = 'K'},
	{k = "L", n = 'L'},
	{k = "M", n = 'M'},
	{k = "N", n = 'N'},
	{k = "O", n = 'O'},
	{k = "P", n = 'P'},
	{k = "Q", n = 'Q'},
	{k = "R", n = 'R'},
	{k = "S", n = 'S'},
	{k = "T", n = 'T'},
	{k = "U", n = 'U'},
	{k = "V", n = 'V'},
	{k = "W", n = 'W'},
	{k = "X", n = 'X'},
	{k = "Y", n = 'Y'},
	{k = "Z", n = 'Z'},
	{k = "NUMPAD0", n = 'Numpad 0'},
	{k = "NUMPAD1", n = 'Numpad 1'},
	{k = "NUMPAD2", n = 'Numpad 2'},
	{k = "NUMPAD3", n = 'Numpad 3'},
	{k = "NUMPAD4", n = 'Numpad 4'},
	{k = "NUMPAD5", n = 'Numpad 5'},
	{k = "NUMPAD6", n = 'Numpad 6'},
	{k = "NUMPAD7", n = 'Numpad 7'},
	{k = "NUMPAD8", n = 'Numpad 8'},
	{k = "NUMPAD9", n = 'Numpad 9'},
	{k = "MULTIPLY", n = 'Numpad *'},
	{k = "ADD", n = 'Numpad +'},
	{k = "SEPARATOR", n = 'Separator'},
	{k = "SUBTRACT", n = 'Numpad -'},
	{k = "DECIMAL", n = 'Numpad .'},
	{k = "DIVIDE", n = 'Numpad /'},
	{k = "F1", n = 'F1'},
	{k = "F2", n = 'F2'},
	{k = "F3", n = 'F3'},
	{k = "F4", n = 'F4'},
	{k = "F5", n = 'F5'},
	{k = "F6", n = 'F6'},
	{k = "F7", n = 'F7'},
	{k = "F8", n = 'F8'},
	{k = "F9", n = 'F9'},
	{k = "F10", n = 'F10'},
	{k = "F11", n = 'F11'},
	{k = "F12", n = 'F12'},
	{k = "F13", n = 'F13'},
	{k = "F14", n = 'F14'},
	{k = "F15", n = 'F15'},
	{k = "F16", n = 'F16'},
	{k = "F17", n = 'F17'},
	{k = "F18", n = 'F18'},
	{k = "F19", n = 'F19'},
	{k = "F20", n = 'F20'},
	{k = "F21", n = 'F21'},
	{k = "F22", n = 'F22'},
	{k = "F23", n = 'F23'},
	{k = "F24", n = 'F24'},
	{k = "LSHIFT", n = '����� Shift'},
	{k = "RSHIFT", n = '������ Shift'},
	{k = "LCONTROL", n = '����� Ctrl'},
	{k = "RCONTROL", n = '������ Ctrl'},
	{k = "LMENU", n = '����� Alt'},
	{k = "RMENU", n = '������ Alt'},
	{k = "OEM_1", n = '; :'},
	{k = "OEM_PLUS", n = '= +'},
	{k = "OEM_MINUS", n = '- _'},
	{k = "OEM_COMMA", n = ', <'},
	{k = "OEM_PERIOD", n = '. >'},
	{k = "OEM_2", n = '/ ?'},
	{k = "OEM_4", n = ' { '},
	{k = "OEM_6", n = ' } '},
	{k = "OEM_5", n = '\\ |'},
	{k = "OEM_8", n = '! �'},
	{k = "OEM_102", n = '> <'}
}

--Sobes
local sobes = {
	input = imgui.ImBuffer(101),
	player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1},
	selID = imgui.ImBuffer(5),
	logChat = {},
	nextQ = false,
	num = 0
}
-- buf_nick
--Departament
local dep = {
	list = {"[100,3 KHz] - ��� ���. ��������", "[102,7 KHz] - ����������", "[104,8] - ��� ����� � ��/��", "[109,6 kHz] - ��� ����� � �.�.�", "[103,9 kHz] - �������������", "[����������] - ���. ���������","/gov - �������"},
	sel_all = {u8"����� ��", u8"���", u8"������ ��", u8"������� ��", u8"������� ��", u8"������� ��", u8"��������� �������", u8"���", u8"�������� ��", u8"�������� ��", u8"�������� ��", u8"��� ��", u8"��� ��", u8"��� ��", u8"����", u8"�������������", u8"���������", u8"������� ���������������", u8"������� �������", u8"������� �������"},
	sel_chp = {u8"����� ��", u8"���", u8"������ ��", u8"������� ��", u8"������� ��", u8"������� ��", u8"��������� �������", u8"���", u8"�������� ��", u8"�������� ��", u8"�������� ��", u8"��� ��", u8"��� ��", u8"��� ��", u8"����", u8"�������������", u8"���������", u8"������� ���������������", u8"������� �������", u8"������� �������"},
	sel_tsr = {u8"������ ��", u8"������� �������"},
	sel_mzmomu = {u8"����� ��", u8"���", u8"������ ��", u8"������� ��", u8"������� ��", u8"������� ��", u8"��������� �������", u8"���", u8"������� �������", u8"������� �������"},
	sel = imgui.ImInt(0),
	select_dep = {0, 0},
	input = imgui.ImBuffer(101),
	bool = {false, false, false, false, false, false},
	time = {0,0}, 
	newsN = imgui.ImInt(0),
	news = {},
	dlog = {}
}

--edit medcard
local buf_mcedit = imgui.ImBuffer(51200) 
local error_mce = ""

--chathud
local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
local textFont = renderCreateFont("Trebuchet MS", 12, FCR_BORDER + FCR_BOLD)
local fontPing = renderCreateFont("Trebuchet MS", 10, 5)
local pingLog = {}

lua_thread.create(function()
	while true do
		repeat wait(100) until isSampAvailable()
		repeat wait(100) until sampIsLocalPlayerSpawned()
		wait(1500)
		if sampIsLocalPlayerSpawned() then
			local ping = sampGetPlayerPing(myid)
			table.insert(pingLog, ping)
			if #pingLog == 41 then table.remove(pingLog, 1) end
		end
	end
end)
--Xyinya
local week = {"�����������", "�����������", "�������", "�����", "�������", "�������", "�������"}
local month = {"������", "�������", "����", "������", "���", "����", "����", "������", "��������", "�������", "������", "�������"}
editKey = false
keysList = {}
arep = false
newversion = ""
updinfo = ""
needSave = false
needSaveColor = imgui.ImColor(250, 66, 66, 102):GetVec4()
urlupd = ""


local BlockKeys = {{vkeys.VK_T}, {vkeys.VK_F6}, {vkeys.VK_F8}, {vkeys.VK_RETURN}, {vkeys.VK_OEM_3}, {vkeys.VK_LWIN}, {vkeys.VK_RWIN}}

rkeys.isBlockedHotKey = function(keys)
	local bool, hkId = false, -1
	for k, v in pairs(BlockKeys) do
	   if rkeys.isHotKeyHotKey(keys, v) then
		  bool = true
		  hkId = k
		  break
	   end
	end
	return bool, hkId
end

-- rkeys.blockNextHotKey = function(keys)
-- 	local bool = false
-- 	if not rkeys.isBlockedHotKey(keys) then
-- 	   tBlockNext[#tBlockNext + 1] = keys
-- 	   bool = true
-- 	end
-- 	return bool
-- end
 


-- for i,v in ipairs(BlockKeys) do
-- 	rkeys.blockNextHotKey({v})
-- end



function rkeys.isHotKeyExist(keys)
local bool = false
	for i,v in ipairs(keysList) do
		if table.concat(v,"+") == table.concat(keys, "+") then
			if #keys ~= 0 then
				bool = true
				break
			end
		end
	end
	return bool
end

function unRegisterHotKey(keys)
	for i,v in ipairs(keysList) do
		if v == keys then
			keysList[i] = nil
			break
		end
	end
	local listRes = {}
	for i,v in ipairs(keysList) do
		if #v > 0 then
			listRes[#listRes+1] = v
		end
	end
	keysList = listRes
end


cmdBind = {
	[1] = {
		cmd = "/mh",
		key = {},
		desc = "������� ���� �������",
		rank = 1,
		rb = false
	},
	[2] = {
		cmd = "/r",
		key = {},
		desc = "������� ��� ������ ����� � ����� (���� ��������)",
		rank = 1,
		rb = false
	},
	[3] = {
		cmd = "/rb",
		key = {},
		desc = "������� ��� ��������� ����� ��������� � �����. ",
		rank = 1,
		rb = false
	},
	[4] = {
		cmd = "/mb",
		key = {},
		desc = "����������� ������� /members",
		rank = 1,
		rb = false
	},
	[5] = {
		cmd = "/hl",
		key = {},
		desc = "������� � �������������� �� ����������",
		rank = 1,
		rb = false
	},
	[6] = {
		cmd = "/post",
		key = {},
		desc = "������ � ���������� �����. ����� ���������� � ������.",
		rank = 2,
		rb = false
	},
	[7] = {
		cmd = "/mc",
		key = {},
		desc = "������ ��� ���������� ���.�����",
		rank = 2,
		rb = false
	},
	[8] = {
		cmd = "/narko",
		key = {},
		desc = "������� �� ����������������",
		rank = 4,
		rb = false
	},
	[9] = {
		cmd = "/rec",
		key = {},
		desc = "������ ��������",
		rank = 4,
		rb = false
	},
	[10] = {
		cmd = "/osm",
		key = {},
		desc = "���������� ����������� ������",
		rank = 5,
		rb = false
	},
	[11] = {
		cmd = "/dep",
		key = {},
		desc = "���� ����� ������������",
		rank = 5,
		rb = false
	},
	[12] = {
		cmd = "/sob",
		key = {},
		desc = "���� ������������� � ���������",
		rank = 5,
		rb = false
	},
	[13] = {
		cmd = "/tatu",
		key = {},
		desc = "�������� ����������",
		rank = 7,
		rb = false
	},
	[14] = {
		cmd = "/+warn",
		key = {},
		desc = "������ �������� ����������",
		rank = 8,
		rb = false
	},
	[15] = {
		cmd = "/-warn",
		key = {},
		desc = "����� ������� ����������",
		rank = 8,
		rb = false
	},
	[16] = {
		cmd = "/+mute",
		key = {},
		desc = "������ ��� ����������",
		rank = 8,
		rb = false
	},
	[17] = {
		cmd = "/-mute",
		key = {},
		desc = "����� ��� ����������",
		rank = 8,
		rb = false
	},
	[18] = {
		cmd = "/gr",
		key = {},
		desc = "�������� ���� (���������) ����������",
		rank = 9,
		rb = false
	},
	[19] = {
		cmd = "/inv",
		key = {},
		desc = "������� � ����������� ������",
		rank = 9,
		rb = false
	},
	[20] = {
		cmd = "/unv",
		key = {},
		desc = "������� ���������� �� �����������",
		rank = 9,
		rb = false
	},
	[21] = {
		cmd = "/ts",
		key = {},
		desc = "������� �������� � �������������� ������ /time",
		rank = 1,
		rb = false
	},
	[22] = {
		cmd = "/exp",
		key = {},
		desc = "���������� ������ �� ��������� ��������",
		rank = 5,
		rb = false
	},
	[5] = {
		cmd = "/cr",
		key = {},
		desc = "�������� �� ������ � �� ����������",
		rank = 1,
		rb = false
	}
}



function styleWin()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ScrollbarSize = 15.0
    style.WindowRounding = 2.0
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 3.0
	style.FramePadding = imgui.ImVec2(5, 3)
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    
    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = imgui.ImColor(228, 83, 83, 200):GetVec4() --ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = imgui.ImColor(225, 0, 0, 200):GetVec4()
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.06, 0.06, 0.06, 0.90) --ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.90)
    colors[clr.Border]                 = imgui.ImColor(190, 0, 0, 200):GetVec4() --ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = imgui.ImColor(100, 100, 100, 225):GetVec4()
end
styleWin()


function ButtonMenu(desk, bool) -- ��������� ������ ���������� ����
	local retBool = false
	if bool then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(230, 73, 45, 220):GetVec4())
		retBool = imgui.Button(desk, imgui.ImVec2(140, 25))
		imgui.PopStyleColor(1)
	elseif not bool then
		 retBool = imgui.Button(desk, imgui.ImVec2(140, 25))
	end
	return retBool
end

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
  if fa_font == nil then
    local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
    font_config.MergeMode = true

    fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/MedicalHelper/files/font-icon.ttf', 15.0, font_config, fa_glyph_ranges)
  end
end


function main()
	repeat wait(100) until isSampAvailable()
	local base = getModuleHandle("samp.dll")
	local sampVer = mem.tohex( base + 0xBABE, 10, true )
	if sampVer == "E86D9A0A0083C41C85C0" then
		sampIsLocalPlayerSpawned = function()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
	end
	if script.this.filename:find("%.luac") then
		os.rename(getWorkingDirectory().."\\MedicalHelper.luac", getWorkingDirectory().."\\MedicalHelper.lua") 
	end
--	repeat wait(100) until sampIsLocalPlayerSpawned()
	------------
	thread = lua_thread.create(function() return end)
	lua_thread.create(function()
		while true do
		wait(1000)
		needSaveColor = imgui.ImColor(250, 66, 66, 102):GetVec4()
			if needSave then
				wait(1000)
				needSaveColor = imgui.ImColor(230, 40, 40, 220):GetVec4()
			end
		end
	end)  
	------------
		
		print("{82E28C}�������� �����������..")
		if not doesFileExist(dirml.."/MedicalHelper/files/logo-medicalhelper.png") then print("{FF2525}������: {FFD825}����������� ����������� logo-medicalhelper.png"); scr:unload() end
		if not  doesFileExist(dirml.."/MedicalHelper/files/discord-logo.png") then print("{FF2525}������: {FFD825}����������� ����������� discord-logo.png") end
		if not  doesFileExist(dirml.."/MedicalHelper/files/discord-site.png") then print("{FF2525}������: {FFD825}����������� ����������� discord-site.png") end
		if not  doesFileExist(dirml.."/MedicalHelper/files/discord-role.png") then print("{FF2525}������: {FFD825}����������� ����������� discord-role.png") end
		if not  doesFileExist(dirml.."/MedicalHelper/files/discord-med.png") then print("{FF2525}������: {FFD825}����������� ����������� discord-med.png") end
		if not  doesFileExist(dirml.."/MedicalHelper/files/discord-nick.png") then print("{FF2525}������: {FFD825}����������� ����������� discord-nick.png") end
		logoMH = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/files/logo-medicalhelper.png") 
		logoDis = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/files/discord-logo.png")
		
		--�������� �� ������������� ������
		if not doesDirectoryExist(dirml.."/MedicalHelper/files/") then
			print("{F54A4A}������. ����������� �����. {82E28C}�������� ����� ��� �����")
			createDirectory(dirml.."/MedicalHelper/files/")
		end
		if not doesDirectoryExist(dirml.."/MedicalHelper/Binder/") then
			print("{F54A4A}������. ����������� �����. {82E28C}�������� ����� ��� �������.")
			createDirectory(dirml.."/MedicalHelper/Binder/")
		end
		if not doesDirectoryExist(dirml.."/MedicalHelper/���������/") then
			print("{F54A4A}������. ����������� �����. {82E28C}�������� ����� ��� ����")
			createDirectory(dirml.."/MedicalHelper/���������/")
		end
		if not doesDirectoryExist(dirml.."/MedicalHelper/�����������/") then
			print("{F54A4A}������. ����������� �����. {82E28C}�������� ����� ��� �������� � �����������")
			createDirectory(dirml.."/MedicalHelper/�����������/")
		end
		--�������� ����� ��������
		if doesDirectoryExist(dirml.."/MedicalHelper/�����������/") then
			getGovFile()
		end
		if doesFileExist(dirml.."/MedicalHelper/rp-medcard.txt") then
			local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt")
			buf_mcedit.v =  u8(f:read("*a"))
			f:close()
			print("{82E28C}������ ��������� ���.�����...")
		else 
			local textrp = [[
// ���� �� ������ ����� ���.�����
#med7=10.000$
#med14=20.000$
#med30=32.500$
#med60=65.000$
// ���� �� ���������� ���.�����
#medup7=15.000$
#medup14=25.000$
#medup30=38.000$
#medup60=70.000$

{sleep:0}
������������, �� ������ �������� ����������� ����� ������� ��� �������� ������������?
������������, ����������, ��� �������
/b /showpass {myID}
{pause}
/todo ��������� ���!*���� ������� � ���� � {sex:�����|������} ��� �������.
{dialog}
[name]=������ ���.�����
[1]=����� ���.�����
������, � ��� {sex:�����|������}. ��� ����� �������� ����� ���.�����.
��� ���������� ����� ���������� ��������� ���.�������, ������� ������� �� ����� �����.
�� 7 ���� - #med7, �� 14 ���� - #med14
�� 30 ���� #med30, �� 60 ���� - #med60.
�� ��������?
���� ��������, �� �������� � �� ��������� ������� ����������.
/b �������� ����� ����� /pay {myID} ��� /trade {myID}

{dialog}
[name]=���� ������
[1]=7 ����
#timeID=0
[2]=14 ����
#timeID=1
[3]=30 ����
#timeID=2
[4]=60 ���
#timeID=3
{dialogEnd}

������, ����� ��������� � ����������.
/me {sex:�������|��������} �� ���������� ������� ��������� �����
/do ����� � ������ ����.
/me ������{sex:|�} �������, ����� ������{sex:|�} ������ ������ ������ ��� ���.�����
/me ��������{sex:|�} �������� ������ ���� ������� �� ������ ��������� � �����{sex:|�} ������������ ������ � �����
/me ������{sex:|�} ������ ���.����� � �������, ����� �����{sex:|�} ������������ ������ �� ��������
/do ������ ������ ������ �������� ���� ���������� �� �����.

[2]=���������� ������
������, � ��� �����{sex:|�}. ��� ����� �������� ������ � ���.�����.
��� ���������� ������ ���������� ��������� ���.�������, ������� ������� �� ����� �����.
�� 7 ���� - #medup7, �� 14 ���� - #medup14
�� 30 ���� #medup30, �� 60 ���� - #medup60.
�� ��������?
���� ��������, �� �������� � �� ��������� ������� ����������.
/b �������� ����� ����� /pay {myID} ��� /trade {myID}

{dialog}
[name]=���� ������
[1]=7 ����
#timeID=0
[2]=14 ����
#timeID=1
[3]=30 ����
#timeID=2
[4]=60 ���
#timeID=3
{dialogEnd}

������, ����� ��������� � ����������.
/me �������{sex:|�} �� ���������� ������� ��������� �����
/do ����� � ������ ����.
/me ������{sex:|�} �������, ����� �����{sex:|�} ������ ���.����� c ������������� �#playerID
/me ��������{sex:|�} �������� ������ ���� ������� �� ������ ��������� � ����� ������������ ������ � �����
/me ������{sex:|�} ������ ���.����� � �������, ����� ����� ������������ ������ �� ��������
/do ������ ������ ������ �������� ���� ���������� �� �����.
{dialogEnd}
/me �������{sex:|�} ������� � ������� ��� ������� � ����������{sex:��|���} � ����������� ��������� ����������
���, ������ ����� ��������� �������� ������� ��������...
������ �� �������� �������?
{pause}
������� �� ������� ��������, � ����� ������������� �������?
{pause}
������, ������ ������ ���� �������� �� ������ ������������ ���������.
{dialog}
[name]=������� ����.����.
[1]=����� � �������.
���� �� � ��� ����� � �������?
[2]=���������� �����.
��� �� ������������ �����, ����� � ��� ����������?
[3]=�������� ��������������� �����.
������ �� � ��� �������������� �������� �����? ���� ��, �� ��� �����?
[4]=�������� �� ������.
�����������, ��� �� ���������� � ������ ������ � �� ��� ���� �...
...������� ��������� ��������� ����.
��� �� ��������?
[5]=�������� ��������.
������ �� � ��� �������������� �������� ��������? ���� ��, �� ��� �����?
[6]=������� �� �����
��� �� ������ ������, ���� �� ������� �������� �������� �� �����?
{dialogEnd}
{pause}
/me �������{sex:|�} ��� ��������� ��������� � ���.�����
{dialog}
[name]=����. ��������
[1]=�����c��� ������(��)
#healID=3
/me ������{sex:|�} ������ �������� ������ '����. ��������.' - '��������� ������(�).'
[2]=����������� ��������������
#healID=2
/me ������{sex:|�} ������ �������� ������ '����. ��������.' - '������� ����������.'
[3]=���������� �� ������(��)
#healID=1
/me ������{sex:|�} ������ �������� ������ '����. ��������.' - '����. ��������.'
{dialogEnd}
/me ����{sex:|�} ����� {myHospEn} � ������ ���� �� ����� ����� � �����{sex:|��} ������ � ���� ������
/do ������ ��������.
/me ������� ����� � ������� � ��������{sex:|�} ���� �������, � ����������� ����
/do �������� ���.����� ���������.
�� ������, ������� ���� ���.�����, �� �������.
�������� ���.
/medcard #playerID #healID #timeID 1000]]  
			local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt", "w")
			f:write(textrp) 
			f:close()
			buf_mcedit.v = u8(textrp)
		end
		if doesFileExist(dirml.."/MedicalHelper/MainSetting.med") then
		print("{82E28C}������ ��������...")
		local f = io.open(dirml.."/MedicalHelper/MainSetting.med")
			local setf = f:read("*a")
			f:close()
			local res, set = pcall(decodeJson, setf)
			if res and type(set) == "table" then 
				buf_nick.v = u8(set.nick)
				buf_teg.v = u8(set.teg)
				num_org.v = set.org
				num_sex.v = set.sex
				num_rank.v = set.rank
				cb_time.v = set.time
				buf_time.v = u8(set.timeTx)
				cb_timeDo.v = set.timeDo
				cb_rac.v = set.rac
				buf_rac.v = u8(set.racTx)
				buf_lec.v = u8(set.lec)
				buf_med.v = u8(set.med)
				buf_upmed.v = u8(set.upmed)
				buf_rec.v = u8(set.rec)
				buf_narko.v = u8(set.narko)
				buf_tatu.v = u8(set.tatu)
				cb_chat1.v = set.chat1
				cb_chat2.v = set.chat2
				cb_chat3.v = set.chat3
				cb_hud.v = set.chathud
				arep = set.arp
				setver = set.setver
				cb_imageDis.v = set.imageDis
				hudPing = set.hping
				cb_hudTime.v = set.htime
				if set.orgl then
					for i,v in ipairs(set.orgl) do
						chgName.org[tonumber(i)] = u8(v)
					end
				end
				if set.rankl then
					for i,v in ipairs(set.rankl) do
						chgName.rank[tonumber(i)] = u8(v)
					end
				end
			else
				os.remove(dirml.."/MedicalHelper/MainSetting.med")
				print("{F54A4A}������. ���� �������� ��������.")
				print("{82E28C}�������� ����� ����������� ��������...")
				buf_lec.v = "1000"
				buf_med.v = "3000"
				buf_upmed.v = "21000"
				buf_narko.v = "25000"
				buf_tatu.v = "7000"
				buf_rec.v = "1500"
				
				buf_time.v = u8"/me ��������� �� ���� � ����������� \"Made in China\""
				buf_rac.v = u8"/me ���� ����� � �����, ���-�� ������ � ��"
			end
		else
			print("{F54A4A}������. ���� �������� �� ������.")
			print("{82E28C}�������� ����������� ��������...")
			buf_lec.v = "1000"
			buf_med.v = "3000"
			buf_upmed.v = "21000"
			buf_narko.v = "25000"
			buf_tatu.v = "7000"
			buf_rec.v = "1500"
			
			buf_time.v = u8"/me ��������� �� ���� � ����������� \"Made in China\""
			buf_rac.v = u8"/me ���� ����� � �����, ���-�� ������ � ��"
			
		end
		if not cb_imageDis.v then
			disSite = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/files/discord-site.png")
			disRole = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/files/discord-role.png")
			disMed = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/files/discord-med.png")
			disNick = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/files/discord-nick.png")
		end

	print("{82E28C}������ �������� ������...")
	if doesFileExist(dirml.."/MedicalHelper/cmdSetting.med") then
	--register cmd
		local f = io.open(dirml.."/MedicalHelper/cmdSetting.med")
		local res, keys = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(keys) == "table" then
			for i, v in ipairs(keys) do
				if #v.key > 0 then
					
					rkeys.registerHotKey(v.key, true, onHotKeyCMD)
					cmdBind[i].key = v.key
					table.insert(keysList, v.key)
				end
			end
		else
			print("{F54A4A}������. ���� �������� ������ ��������.")
			print("{82E28C}��������� ����������� ���������")
			os.remove(dirml.."/MedicalHelper/cmdSetting.med")
		end
	else
		print("{F54A4A}������. ���� �������� ������ �� ������.")
		print("{82E28C}��������� ����������� ���������")
	end
	
	--register binder 
	print("{82E28C}������ �������� �������...")
	if doesFileExist(dirml.."/MedicalHelper/bindSetting.med") then
		local f = io.open(dirml.."/MedicalHelper/bindSetting.med")
		local res, list = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(list) == "table" then
			binder.list = list
			for i, v in ipairs(binder.list) do
				if #v.key > 0 then
					binder.list[i].key = v.key
					rkeys.registerHotKey(v.key, true, onHotKeyBIND)
					table.insert(keysList, v.key)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/bindSetting.med")
			print("{F54A4A}������. ���� �������� ������� ��������.")
			print("{82E28C}��������� ����������� ���������")
		end
	else 
		print("{F54A4A}������. ���� �������� ������� �� ������.")
		print("{82E28C}��������� ����������� ���������")
	end
	
	lockPlayerControl(false)
		sampfuncsRegisterConsoleCommand("arep", function(bool) 
			if tonumber(bool) == 1 then 
				arep = true 
				print("Rep: On")
			else 
				arep = false 
			end 
		end)
		sampRegisterChatCommand("mh", function() mainWin.v = not mainWin.v end)
		sampRegisterChatCommand("reload", function() scr:reload() end)
		sampRegisterChatCommand("hl", funCMD.lec)
		sampRegisterChatCommand("cr", funCMD.cure)
		sampRegisterChatCommand("mc", funCMD.med)
		sampRegisterChatCommand("narko", funCMD.narko)
		sampRegisterChatCommand("rec", funCMD.rec)
		sampRegisterChatCommand("tatu", funCMD.tatu)
		sampRegisterChatCommand("+warn", funCMD.warn)
		sampRegisterChatCommand("-warn", funCMD.uwarn)
		sampRegisterChatCommand("gr", funCMD.rank)
		sampRegisterChatCommand("inv", funCMD.inv)
		sampRegisterChatCommand("unv", funCMD.unv)
		sampRegisterChatCommand("+mute", funCMD.mute)
		sampRegisterChatCommand("-mute", funCMD.umute)
		sampRegisterChatCommand("osm", funCMD.osm)
		sampRegisterChatCommand("mb", funCMD.memb)
		sampRegisterChatCommand("hme", funCMD.hme)
		sampRegisterChatCommand("sob", funCMD.sob)
		sampRegisterChatCommand("dep", funCMD.dep)
		sampRegisterChatCommand("hall*", funCMD.hall)
		sampRegisterChatCommand("update", function() updWin.v = not updWin.v end)
		sampRegisterChatCommand("post", funCMD.post)
		sampRegisterChatCommand("ts", funCMD.time)
		sampRegisterChatCommand("exp", funCMD.expel)
		sampRegisterChatCommand("downloadupd", downloadupd)
		sampRegisterChatCommand("openupd", funCMD.openupd)
		sampRegisterChatCommand("mh-delete", funCMD.del)
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ���������������.", 0xEE4848)
		repeat wait(100) until sampIsLocalPlayerSpawned()
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		myNick = sampGetPlayerNickname(myid)
		
		sampAddChatMessage(string.format("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: �����������, %s. ��� ��������� �������� ���� ��������� � ��� {22E9E3}/mh.", sampGetPlayerNickname(myid):gsub("_"," ")), 0xEE4848)
		wait(200)
		if buf_nick.v == "" then 
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ � ���� �� ��������� �������� ����������. ", 0xEE4848)
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����� � ������� ���� � ������ \"���������\" � ������� ���� �� �� \"���-���\".", 0xEE4848)
		end
		lua_thread.create(funCMD.updateCheck)
  while true do
	wait(0)

		resTarg, pedTar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if resTarg then
			_, targID = sampGetPlayerIdByCharHandle(pedTar)
		end
	if isKeyDown(VK_LMENU) and isKeyJustPressed(VK_K) and not sampIsChatInputActive() then
		mainWin.v = not mainWin.v 
	end
	if thread:status() ~= "dead" and not isGamePaused() then 
		renderFontDrawText(fontPD, "���������: [{F25D33}Page Down{FFFFFF}] - �������������", 20, sy-30, 0xFFFFFFFF)
		if isKeyJustPressed(VK_NEXT) and not sampIsChatInputActive() and not sampIsDialogActive() then
			thread:terminate()
		end
	end
	if sampIsDialogActive() then
		if arep then
			local idD = sampGetCurrentDialogId()
			if idD == 1333 then
				HideDialog()
			lockPlayerControl(false)
			end
		end
	end
	if cb_hud.v then showInputHelp() end
	if cb_hudTime.v and not isPauseMenuActive() then hudTimeF() end
	--if hudPing and not isPauseMenuActive() then pingGraphic(sx/9*8-20, sy/4) end
		imgui.Process = mainWin.v or iconwin.v or sobWin.v or depWin.v or updWin.v
  end
end
 
function HideDialog(bool)
	lua_thread.create(function()
		repeat wait(0) until sampIsDialogActive()
		while sampIsDialogActive() do
			local memory = require 'memory'
			memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
			sampToggleCursor(bool)
		end
	end)
end
imgui.GetIO().FontGlobalScale = 1.1

function mainSet()
	imgui.SetCursorPosX(25)
	imgui.BeginGroup()
	imgui.PushItemWidth(300);
		if imgui.InputText(u8"��� � �������: ", buf_nick, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[�-�%s]+")) then needSave = true end

			if not imgui.IsItemActive() and buf_nick.v == "" then
				imgui.SameLine()
				ShowHelpMarker(u8"��� � ������� ����������� �� \n������� ��� ������� �������������.\n\n  ������: ����� ������")
				imgui.SameLine()
				imgui.SetCursorPosX(30)
				imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"������� ���� ��� � �������");
			else
			imgui.SameLine()
			ShowHelpMarker(u8"��� � ������� ����������� �� \n������� ��� ������� �������������.\n\n  ������: ����� ������")
			end
		if imgui.InputText(u8"��� � ����� ", buf_teg) then needSave = true end
		imgui.SameLine(); ShowHelpMarker(u8"��� ��� ����� ����� ���� ��������������,\n �������� � ������ ����������� ��� ������.\n\n������: [��� ���]")
		imgui.PushItemWidth(278);
			imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
				if imgui.Button(fa.ICON_COG.."##1", imgui.ImVec2(21,20)) then
					chgName.inp.v = chgName.org[num_org.v+1]
					imgui.OpenPopup(u8"MH | ��������� �������� ��������")
				end
			imgui.PopStyleVar(1)
			imgui.SameLine(22)
			if imgui.Combo(u8"����������� ", num_org, chgName.org) then needSave = true end
			imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
				if imgui.Button(fa.ICON_COG.."##2", imgui.ImVec2(21,20)) then
					chgName.inp.v = chgName.rank[num_rank.v+1]
					imgui.OpenPopup(u8"MH | ��������� �������� ���������")
				end
			imgui.PopStyleVar(1)
			imgui.SameLine(22)
			if imgui.Combo(u8"��������� ", num_rank, chgName.rank) then needSave = true end
		imgui.PopItemWidth()						
		if imgui.Combo(u8"��� ��� ", num_sex, list_sex) then needSave = true end
	imgui.PopItemWidth()
	imgui.EndGroup()
	if imgui.BeginPopupModal(u8"MH | ��������� �������� ��������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"�������� �������� ����� ��������� � �������� ��������")

		imgui.PushItemWidth(390)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(126,23)) then
			local exist = false
			for i,v in ipairs(chgName.org) do
				if v == chgName.inp.v and i ~= num_org.v+1 then
					exist = true
				end
			end
			if not exist then
				chgName.org[num_org.v+1] = chgName.inp.v
				needSave = true
				imgui.CloseCurrentPopup()
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"��������", imgui.ImVec2(128,23)) then
			chgName.org[num_org.v+1] = list_org[num_org.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"������", imgui.ImVec2(126,23)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopupModal(u8"MH | ��������� �������� ���������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"�������� ��������� ����� ��������� � �������� ��������")

		imgui.PushItemWidth(200)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(126,23)) then
			local exist = false
			for i,v in ipairs(chgName.rank) do
				if v == chgName.inp.v and i ~= num_rank.v+1 then
					exist = true
				end
			end
			if not exist then
				chgName.rank[num_rank.v+1] = chgName.inp.v
				needSave = true
				imgui.CloseCurrentPopup()
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"��������", imgui.ImVec2(128,23)) then
			chgName.rank[num_rank.v+1] = list_rank[num_rank.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"������", imgui.ImVec2(126,23)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function imgui.OnDrawFrame()
	if mainWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(850, 450), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_HEARTBEAT .. " MedicalHelper "..scr.version, mainWin, imgui.WindowFlags.NoResize);
			--imgui.SetWindowFontScale(1.1)
			--///// Func menu button
			imgui.BeginChild("Mine menu", imgui.ImVec2(155, 0), true)
				if ButtonMenu(fa.ICON_USERS .. u8"  �������", select_menu[1]) then select_menu = {true, false, false, false, false, false, false, false, false}; end
					imgui.Spacing()
				imgui.Separator()
					imgui.Spacing()
				if ButtonMenu(fa.ICON_WRENCH .. u8"  ���������", select_menu[2]) then select_menu = {false, true, false, false, false, false, false, false, false} end
					imgui.Spacing()
				imgui.Separator()
					imgui.Spacing()
				if ButtonMenu(fa.ICON_FILE .. u8"  �����", select_menu[3]) then 
					select_menu = {false, false, true, false, false, false, false, false, false}; 
					getSpurFile() 
					spur.name.v = ""
					spur.text.v = ""
					spur.edit = false
					spurBig.v = false
					spur.select_spur = -1
				end
					imgui.Spacing()
				imgui.Separator()
					imgui.Spacing()
				if ButtonMenu(fa.ICON_TERMINAL .. u8"  �������", select_menu[4]) then select_menu = {false, false, false, true , false, false, false, false, false} end	
					imgui.Spacing()
				imgui.Separator()
					imgui.Spacing()
				if ButtonMenu(fa.ICON_KEYBOARD_O .. u8"  ������", select_menu[5]) then select_menu = {false, false, false, false, true, false, false, false, false} end
					imgui.Spacing()
				imgui.Separator()
					imgui.Spacing()
				if ButtonMenu(fa.ICON_QUESTION .. u8"  ������", select_menu[6]) then select_menu = {false, false, false, false, false, true, false, false, false} end
					imgui.Spacing()
				imgui.Separator()
					imgui.Spacing()
				if ButtonMenu(fa.ICON_CODE .. u8"  � �������", select_menu[7]) then select_menu = {false, false, false, false, false, false, true, false, false} end
					imgui.Spacing()
				imgui.Separator()
					imgui.Spacing()
				if ButtonMenu(fa.ICON_HEADPHONES .. u8"  �������", select_menu[9]) then select_menu = {false, false, false, false, false, false, false, false, true} end
			imgui.EndChild();
			--///// Main menu
			if select_menu[1] then
			imgui.SameLine()
			imgui.BeginGroup()
				if logoMH then
					imgui.Image(logoMH, imgui.ImVec2(670, 200))
				end
				local colorInfo = imgui.ImColor(240, 170, 40, 255):GetVec4()
				imgui.Separator()
				imgui.SetCursorPosX(425)
				imgui.Text(u8"��������� � ����������");
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.Indent(10)
					imgui.Text(fa.ICON_ADDRESS_CARD .. u8"  ��� ������� ����������: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.name())
						imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(fa.ICON_HOSPITAL_O .. u8"  ������� � �����������: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.org());
						imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(fa.ICON_USER .. u8"  ���������: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.rank());
						imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(fa.ICON_TRANSGENDER .. u8"  ���: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.sex())
				imgui.EndGroup()
			end
			--/////Setting
			if select_menu[2] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("settig", imgui.ImVec2(0, 390), true)
				imgui.Text(fa.ICON_ANGLE_RIGHT .. u8" ������ ������ ������������ ��� ������ ��������� ������� ��� ���� ����");
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 5))
				imgui.Indent(10) -- imgui.SetCursorPosX
				if imgui.CollapsingHeader(u8"�������� ����������") then
					mainSet()
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.CollapsingHeader(u8"��������� ����") then
					imgui.SetCursorPosX(25)
					imgui.BeginGroup()
						if imgui.Checkbox(u8"������ ����������", cb_chat1) then needSave = true end
						if imgui.Checkbox(u8"������ ��������� �������", cb_chat2) then needSave = true end
						if imgui.Checkbox(u8"������ ������� ���", cb_chat3) then needSave = true end
						if imgui.Checkbox(u8"ChatHUD", cb_hud) then needSave = true end;
						imgui.SameLine(); ShowHelpMarker(u8"�������� ���������� ��� \n����� ����� ����")
						if imgui.Checkbox(u8"TimeHUD", cb_hudTime) then needSave = true end
						imgui.SameLine(); ShowHelpMarker(u8"���������� �������, ����� � Caps Lock\n � ������ ����� ����� ������")
					imgui.EndGroup()
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.CollapsingHeader(u8"���������") then
					imgui.Separator()
					imgui.SetCursorPosX(25)
					imgui.BeginGroup()
						imgui.PushItemWidth(400); 
							imgui.SetCursorPosX(255)
							imgui.Text(u8"����")
							if imgui.Checkbox(u8"��������� /me", cb_time) then needSave = true end
							if imgui.Checkbox(u8"��������� /do", cb_timeDo) then needSave = true end
							if imgui.InputText(u8"����� ���������", buf_time) then needSave = true end
							imgui.Separator()
							imgui.SetCursorPosX(255)
							imgui.Text(u8"�����")
							if imgui.Checkbox(u8"��������� /me##1", cb_rac) then needSave = true end
							if imgui.InputText(u8"����� ���������##1", buf_rac) then needSave = true end
						imgui.PopItemWidth()
						imgui.Spacing()
						if imgui.Button(u8"������������� ��������� ���.�����", imgui.ImVec2(250, 25)) then 
							mcEditWin.v = not mcEditWin.v
						end
					imgui.EndGroup();
				end
				imgui.Dummy(imgui.ImVec2(0, 3)) 
				if imgui.CollapsingHeader(u8"������� ��������") then
					imgui.SetCursorPosX(25);
					imgui.BeginGroup()
						imgui.PushItemWidth(100); 
							if imgui.InputText(u8"�������", buf_lec, imgui.InputTextFlags.CharsDecimal) then needSave = true end
						--	if imgui.InputText(u8"������ ����� ���.�����", buf_med, imgui.InputTextFlags.CharsDecimal) then needSave = true end
						--	if imgui.InputText(u8"���������� ���.�����", buf_upmed, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							if imgui.InputText(u8"������ ��������", buf_rec, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							if imgui.InputText(u8"������� �� ����������������", buf_narko, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							if imgui.InputText(u8"�������� ����", buf_tatu, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							imgui.Text(u8"���� �� ���.����� ������������ � ����� ��������� ���.����� ����� ���������� � ���������� '���������'")
							imgui.Spacing()
						imgui.PopItemWidth()
					imgui.EndGroup();
					imgui.TextWrapped(u8"����� �������� ������ ������ �� ������ �� ���� forum.arizona-rp.com -> ������� ������: ��� ������� ������ -> ���. ��������� -> ���.�����.")
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.CollapsingHeader(u8"�������� �����������") then
					imgui.TextWrapped(u8"�� ������ ��������� ������� ����� �������� �� �������� \"�������\", ����� ������ ��� �� ��������� ����.")
					imgui.Spacing()
					if imgui.Checkbox(u8"��������� ����������� �� ������� - �������", cb_imageDis) then needSave = true end
				end
				

			imgui.EndChild();
			
			imgui.PushStyleColor(imgui.Col.Button, needSaveColor) -- 
			if imgui.Button(u8"���������", imgui.ImVec2(672, 20)) then
		
			setting.nick = u8:decode(buf_nick.v)
			setting.teg = u8:decode(buf_teg.v)
			setting.org = num_org.v
			setting.sex = num_sex.v
			setting.rank = num_rank.v
			setting.time = cb_time.v
			setting.timeTx = u8:decode(buf_time.v)
			setting.timeDo = cb_timeDo.v
			setting.rac = cb_rac.v
			setting.racTx = u8:decode(buf_rac.v)
			setting.lec = buf_lec.v
			setting.med = buf_med.v
			setting.upmed = buf_upmed.v
			setting.rec = buf_rec.v
			setting.narko = buf_narko.v
			setting.tatu = buf_tatu.v
			setting.chat1 = cb_chat1.v
			setting.chat2 = cb_chat2.v
			setting.chat3 = cb_chat3.v
			setting.chathud = cb_hud.v
			setting.arp = arep
			setting.setver = setver
			setting.imageDis = cb_imageDis.v
			setting.htime = cb_hudTime.v
			setting.hping = hudPing
			setting.orgl = {}
			setting.rankl = {}
			for i,v in ipairs(chgName.org) do
				setting.orgl[i] = u8:decode(v)
			end
			for i,v in ipairs(chgName.rank) do
				setting.rankl[i] = u8:decode(v)
			end
				local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
				f:write(encodeJson(setting))
				f:flush()
				f:close()
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ��������� ���������.", 0xEE4848)
				needSave = false
			end
			imgui.PopStyleColor(1)
			imgui.EndGroup()
			end
			--/////shpora
			if select_menu[3] then
			imgui.SameLine()
				imgui.BeginGroup()
					imgui.BeginChild("spur list", imgui.ImVec2(140, 390), true)
						imgui.SetCursorPosX(10)
						imgui.Text(u8"������ ���������")
						imgui.Separator()
							for i,v in ipairs(spur.list) do
								if imgui.Selectable(u8(spur.list[i]), spur.select_spur == i) then 
									spur.select_spur = i 
									spur.text.v = ""
									spur.name.v = ""
									spur.edit = false
									spurBig.v = false
								end
							end
					imgui.EndChild()
					if imgui.Button(u8"��������", imgui.ImVec2(140, 20)) then
						if #spur.list ~= 20 then
							for i = 1, 20 do
								if not table.concat(spur.list, "|"):find("��������� '"..i.."'") then
									table.insert(spur.list, "��������� '"..i.."'")
									spur.edit = true
									spur.select_spur = #spur.list
									spur.name.v = ""
									spur.text.v = ""
									spurBig.v = false
									local f = io.open(dirml.."/MedicalHelper/���������/��������� '"..i.."'.txt", "w")
									f:write("")
									f:flush()
									f:close()
									break
								end
							end
						end
					end
				imgui.EndGroup()
					imgui.SameLine()
				imgui.BeginGroup()
					--	
						if spur.edit and not spurBig.v then
							imgui.SetCursorPosX(515)
							imgui.Text(u8"���� ��� ����������")
							imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
							imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(525, 315))
							imgui.PopStyleColor(1)
							imgui.PushItemWidth(400)
						--	imgui.SetCursorPosX(155+140+110)
							if imgui.Button(u8"������� ������� ��������/��������", imgui.ImVec2(525, 20)) then spurBig.v = not spurBig.v end
							imgui.Spacing() 
						--	imgui.SetCursorPosX(445)
							imgui.InputText(u8"�������� �����", spur.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%w�-�%+%�%#%(%)]"))
							imgui.Spacing()
							imgui.PopItemWidth()
						--	imgui.SetCursorPosX(415)
							if imgui.Button(u8"�������", imgui.ImVec2(260, 20)) then
								if doesFileExist(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") then
									os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
								end
								table.remove(spur.list, spur.select_spur) 
								spur.edit = false
								spur.select_spur = -1
								spur.name.v = ""
								spur.text.v = ""
							end
							imgui.SameLine()
							if imgui.Button(u8"���������", imgui.ImVec2(260, 20)) then
								local name = ""
								local bool = false
								if spur.name.v ~= "" then 
										name = u8:decode(spur.name.v)
										if doesFileExist(dirml.."/MedicalHelper/���������/"..name..".txt") and spur.list[spur.select_spur] ~= name then
											bool = true
											imgui.OpenPopup(u8"������")
										else
											os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
											spur.list[spur.select_spur] = u8:decode(spur.name.v)
										end
								else
									name = spur.list[spur.select_spur]
								end
								if not bool then
									local f = io.open(dirml.."/MedicalHelper/���������/"..name..".txt", "w")
									f:write(u8:decode(spur.text.v))
									f:flush()
									f:close()
									spur.text.v = ""
									spur.name.v = ""
									spur.edit = false
								end
							end
						elseif spurBig.v then
							imgui.Dummy(imgui.ImVec2(0, 150))
							imgui.SetCursorPosX(500)
							imgui.TextColoredRGB("�������� ������� ����")
						elseif not spurBig.v and (spur.select_spur >= 1 and spur.select_spur <= 20) then
							imgui.Dummy(imgui.ImVec2(0, 150))
							imgui.SetCursorPosX(515)
							imgui.Text(u8"�������� ��������")
							imgui.Spacing()
							imgui.Spacing()
							imgui.SetCursorPosX(490)
							if imgui.Button(u8"������� ��� ���������", imgui.ImVec2(170, 20)) then
								spurBig.v = true
							end
							imgui.Spacing()
							imgui.SetCursorPosX(490)
							if imgui.Button(u8"�������������", imgui.ImVec2(170, 20)) then
								spur.edit = true
								local f = io.open(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt", "r")
								spur.text.v = u8(f:read("*a"))
								f:close()
								spur.name.v = u8(spur.list[spur.select_spur])
							end
							imgui.Spacing()
							imgui.SetCursorPosX(490)
							if imgui.Button(u8"�������", imgui.ImVec2(170, 20)) then
								if doesFileExist(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") then
									os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
								end
								table.remove(spur.list, spur.select_spur) 
								spur.select_spur = -1
							end
						else
						imgui.Dummy(imgui.ImVec2(0, 150))
						imgui.SetCursorPosX(370)
						imgui.TextColoredRGB("������� �� ������ {FF8400}\"��������\"{FFFFFF}, ����� ������� ����� ���������\n\t\t\t\t\t\t\t\t\t��� �������� ��� ������������.")
						end

				imgui.EndGroup()
			end
			--/////Command
			if select_menu[4] then
			imgui.SameLine()
			imgui.BeginGroup()
				imgui.Text(u8"����� ��������� ������ ����� ������, � ������� ������ ��������� ������� ���������.")
				imgui.Separator();
				imgui.Dummy(imgui.ImVec2(0, 5))
				imgui.BeginChild("cmd list", imgui.ImVec2(0, 335), true)
					imgui.Columns(3, "keybinds", true); 
					imgui.SetColumnWidth(-1, 80); 
					imgui.Text(u8"�������"); 
					imgui.NextColumn();
					imgui.SetColumnWidth(-1, 450); 
					imgui.Text(u8"��������"); 
					imgui.NextColumn(); 
					imgui.Text(u8"�������"); 
					imgui.NextColumn(); 
					imgui.Separator();
					for i,v in ipairs(cmdBind) do
						if num_rank.v+1 >= v.rank then
							if imgui.Selectable(u8(v.cmd), selected_cmd == i, imgui.SelectableFlags.SpanAllColumns) then selected_cmd = i end
							imgui.NextColumn(); 
							imgui.Text(u8(v.desc)); 
							imgui.NextColumn();
							if #v.key == 0 then imgui.Text(u8"���") else imgui.Text(table.concat(rkeys.getKeysName(v.key), " + ")) end	
							imgui.NextColumn()
						else
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(228, 70, 70, 202):GetVec4())
							if imgui.Selectable(u8(v.cmd), selected_cmd == i, imgui.SelectableFlags.SpanAllColumns) then selected_cmd = i end
							imgui.NextColumn(); 
							imgui.Text(u8(v.desc)); 
							imgui.NextColumn(); 
							if #v.key == 0 then imgui.Text(u8"���") else imgui.Text(table.concat(rkeys.getKeysName(v.key), " + ")) end	
							imgui.NextColumn()
							imgui.PopStyleColor(1)
						end
					end
				imgui.EndChild();
					if cmdBind[selected_cmd].rank <= num_rank.v+1 then
						imgui.Text(u8"�������� ������� ������������ ��� �������, ����� ���� ������ ����������� ��������������.")
						if imgui.Button(u8"��������� �������", imgui.ImVec2(140, 20)) then 
							imgui.OpenPopup(u8"MH | ��������� ������� ��� ���������");
							lockPlayerControl(true)
							editKey = true
						end
						imgui.SameLine();
						if imgui.Button(u8"�������� ���������", imgui.ImVec2(140, 20)) then 
							rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
							unRegisterHotKey(cmdBind[selected_cmd].key)
							cmdBind[selected_cmd].key = {}
								local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
								f:write(encodeJson(cmdBind))
								f:flush()
								f:close()
						end
						imgui.SameLine();
					else
						imgui.Text(u8"������ ������� ��� ����������. �������� ������ �� " .. cmdBind[selected_cmd].rank .. u8" �����")
						imgui.Text(u8"���� ��� ���� ������������� �����������, ���������� �������� ��������� � ����������.")
					end
					
			imgui.EndGroup()

			end
			--//////Binder
			if select_menu[5] then
				imgui.SameLine()
				imgui.BeginGroup()
					imgui.BeginChild("bind list", imgui.ImVec2(140, 390), true)
						imgui.SetCursorPosX(20)
						imgui.Text(u8"������ ������")
						imgui.Separator()
							for i,v in ipairs(binder.list) do
								if imgui.Selectable(u8(binder.list[i].name), binder.select_bind == i) then 
									binder.select_bind = i;
									
									binder.name.v = u8(binder.list[binder.select_bind].name)
									binder.sleep.v = binder.list[binder.select_bind].sleep
									binder.key = binder.list[binder.select_bind].key
									if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
										local f = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "r")
										binder.text.v = u8(f:read("*a"))
										f:flush()
										f:close()
									end
									binder.edit = true 
								end
							end
					imgui.EndChild()
					if imgui.Button(u8"��������", imgui.ImVec2(140, 20)) then
						if #binder.list < 100 then
							for i = 1, 100 do
								local bool = false
								for ix,v in ipairs(binder.list) do
									if v.name == "Noname bind '"..i.."'" then bool = true end
								end
								if not bool then
									binder.list[#binder.list+1] = {name = "Noname bind '"..i.."'", key = {}, sleep = 0.5}
									binder.edit = true
									binder.select_bind = #binder.list
									binder.name.v = ""
									binder.sleep.v = 0.5
									binder.text.v = ""
									binder.key = {}
									break 
								end
							end
						end
					end

				imgui.EndGroup() 
					imgui.SameLine()
				imgui.BeginGroup()
					--	
						if binder.edit then
							imgui.SetCursorPosX(500)
							imgui.Text(u8"���� ��� ����������")
							imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
							imgui.InputTextMultiline("##bind", binder.text, imgui.ImVec2(525, 301))
							imgui.PopStyleColor(1)
							imgui.PushItemWidth(150)
							imgui.InputText(u8"�������� �����", binder.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%w�-�%+%�%#%(%)]"))
							
							if imgui.Button(u8"��������� �������", imgui.ImVec2(150, 20)) then 
								imgui.OpenPopup(u8"MH | ��������� ������� ��� ���������")
								editKey = true
							end 
							imgui.SameLine()
							imgui.TextColoredRGB("���������: "..table.concat(rkeys.getKeysName(binder.key), " + "))
							imgui.DragFloat("##sleep", binder.sleep, 0.1, 0.5, 10.0, u8"�������� = %.1f ���.")
							imgui.SameLine()
							if imgui.Button("-", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 0.5 then binder.sleep.v = binder.sleep.v - 0.1 end
							imgui.SameLine()
							if imgui.Button("+", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 10 then binder.sleep.v = binder.sleep.v + 0.1 end
							imgui.PopItemWidth()
							imgui.SameLine()
							imgui.Text(u8"�������� ������� ����� ������������� �����")
						--	imgui.SetCursorPosX(345)
							if imgui.Button(u8"�������", imgui.ImVec2(127, 20)) then
								binder.text.v = ""
								binder.sleep.v = 0.5
								binder.name.v = ""
								
								binder.edit = false 
								rkeys.unRegisterHotKey(binder.key)
								unRegisterHotKey(binder.key)
								binder.key = {}
								if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
									os.remove(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt")
								end
								table.remove(binder.list, binder.select_bind) 
								local f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
								f:write(encodeJson(binder.list))
								f:flush()
								f:close()
								binder.select_bind = -1 
							end
							imgui.SameLine()
							if imgui.Button(u8"���������", imgui.ImVec2(127, 20)) then
								local bool = false
									if binder.name.v ~= "" then
										for i,v in ipairs(binder.list) do
											if v.name == u8:decode(binder.name.v) and i ~= binder.select_bind then bool = true end
										end
										if not bool then
											binder.list[binder.select_bind].name = u8:decode(binder.name.v)
										else
											imgui.OpenPopup(u8"������")
										end
									end
								if not bool then
									rkeys.registerHotKey(binder.key, true, onHotKeyBIND)
									binder.list[binder.select_bind].key = binder.key
									local sec = string.format("%.1f", binder.sleep.v)
									binder.list[binder.select_bind].sleep = sec
									local text = u8:decode(binder.text.v)
									local saveJS = encodeJson(binder.list) 
									local f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
									local ftx = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "w")
									f:write(saveJS)
									ftx:write(text)
									f:flush()
									ftx:flush()
									f:close()
									ftx:close()
								end
							end
							imgui.SameLine()
							if imgui.Button(u8"���-�������", imgui.ImVec2(127, 20)) then paramWin.v = not paramWin.v end
							imgui.SameLine()
							if imgui.Button(u8"����������� ����������", imgui.ImVec2(127, 20)) then profbWin.v = not profbWin.v end
							
							
						else
						
						imgui.Dummy(imgui.ImVec2(0, 150))
						imgui.SetCursorPosX(380)
						imgui.TextColoredRGB("������� �� ������ {FF8400}\"��������\"{FFFFFF}, ����� ������� ����� ����\n\t\t\t\t\t\t\t\t��� �������� ��� ������������.")
						end

				imgui.EndGroup()
			end
			--//////Help
			if select_menu[6] then
				imgui.SameLine()
				imgui.BeginChild("help but", imgui.ImVec2(0,0), true)
					imgui.Text(u8"������� ����������, ������� ����� ������ ���.")
					imgui.Separator()
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}������� \"���������\"")
					imgui.TextWrapped(u8"\t������� ���������, ������� ��������� ��������� ����� ������� ������, ����� ������� ������� �� ��� \"�������� ����������\".")
					imgui.TextWrapped(u8"\t������� �������� ��������� ��� ������� Saint Rose, ���� � ��� ������ ������, ���������� �������� ��������.")
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}������� \"�����\"")
					imgui.TextWrapped(u8"\t����� ��������� ������ ���� �����������, ����� ����� ������ ������� ��������� ���� � ����� ���������.")
					imgui.TextColoredRGB("{5BF165}������� ����� ���������")
					if imgui.IsItemHovered() then 
						imgui.SetTooltip(u8"��������, ����� ������� �����.")
					end
					if imgui.IsItemClicked(0) then
						print(shell32.ShellExecuteA(nil, 'open', dirml.."/MedicalHelper/���������/", nil, nil, 1))
					end
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}������� \"�������\"")
					imgui.TextWrapped(u8"\t������������ ���������� ������ �������� � ���, ��� ������� ��������� � �������� id ������, ����� ���� ������������ ��� ��������� �������� ����� �� ������ � ������� ����-���������. � ��������� ����, ������� ������������� ������� � ��������� id ������ ��� ��������� ��� � �������� id.")
					imgui.TextColoredRGB("\t\t�������������� �������, �� �������� � ������:")
					imgui.TextColoredRGB("{FF5F29}/reload {FFFFFF}- ������� ��� ������������ �������.")
					imgui.TextColoredRGB("{FF5F29}/rl {FFFFFF}- ����������� ������� �� �������, ��������������� ��� ������������ ���� ����� moonlaoder.")
					imgui.TextColoredRGB("{FF5F29}/update {FFFFFF}- ������� ��� ��������� ���������� �� ����������.")
					imgui.TextColoredRGB("{FF5F29}/mh-delete {FFFFFF} - ������� ������")
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}������� \"�������\"")
					imgui.TextWrapped(u8"\t���������� �� ����������� ��������.")
					--
					imgui.Separator()
					imgui.Spacing()
					imgui.TextColoredRGB("� ������ ������������� �������� � �������� ������� ���������� ������� ����� �������� �����\n ���� ������������� ����� moonloader �������� {67EE7E}/rl:\n\t{FF5F29}MainSetting.med \n\t{FF5F29}cmdSetting.med \n\t{FF5F29}bindSetting.med \n\t����� ����� {FF5F29}Binder")
				imgui.EndChild()
			end
			--//////About
			if select_menu[7] then
				imgui.SameLine()
				imgui.BeginChild("about", imgui.ImVec2(0, 0), true)
					imgui.SetCursorPosX(280)
					imgui.Text(u8"Medical Helper")
					imgui.Spacing()
					imgui.TextWrapped(u8"\t������ ��� ���������� ��� ������� Ariona Role Play � ���������� ������ �� ������� Saint Rose ��� ���������� ������ ����������� �������. ��������� ����� ���������� �� �������� ������ �������� ������������� ������ �������� � ����������� �� �����������.\n���������� ������� �� ���� ���������� ������������ � ����������� ������.")
					imgui.Dummy(imgui.ImVec2(0, 10))
					imgui.Bullet()
					imgui.TextColoredRGB("����������� - {FFB700}Kevin Hatiko")
					imgui.Bullet()
					imgui.TextColoredRGB("������ ������� - {FFB700}".. scr.version)
					imgui.Bullet()
					imgui.TextColoredRGB("������������� blast.hk �� ������������ ���������� � ��� ������������� � ������� ��������.")
						imgui.Dummy(imgui.ImVec2(0, 20))
						imgui.SetCursorPosX(20)
						imgui.Text(fa.ICON_BUG)
						imgui.SameLine()
						imgui.TextColoredRGB("����� ��� ��� ������, ��� �� ������ ������ ���-�� �����, ������ � ������"); imgui.SameLine(); imgui.Text(fa.ICON_ARROW_DOWN)
						imgui.SetCursorPosX(20)
						imgui.Text(fa.ICON_LINK)
						imgui.SameLine()
						imgui.TextColoredRGB("��� �����: VK: {74BAF4}vk.com/hatiko_scripts") --��� Discord - {74BAF4}TheVitek#2160")
							if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ���, ����� �����������, ��� ���, ����� ������� � ��������")  end
							if imgui.IsItemClicked(0) then setClipboardText("https://vk.com/hatiko_scripts") end
							if imgui.IsItemClicked(1) then print(shell32.ShellExecuteA(nil, 'open', 'https://vk.com/hatiko_scripts', nil, nil, 1)) end
							imgui.SameLine()
							imgui.TextColoredRGB("{68E15D}(������){FFFFFF}  ����� � ������ �� {74BAF4}\"�������� ���������\"")
						imgui.Spacing()
						imgui.SetCursorPosX(20)
						imgui.TextColored(imgui.ImColor(18, 220, 0, 200):GetVec4(), fa.ICON_MONEY)
						imgui.SameLine()
						imgui.TextColoredRGB("�������� ���������� ���������� �������� - ".."{68E15D}\"�������\"")
							if imgui.IsItemHovered() then imgui.SetTooltip(u8"��������, ����� ������� ������")  end
							if imgui.IsItemClicked(0) then print(shell32.ShellExecuteA(nil, 'open', 'https://qiwi.me/56481f57-738e-4476-afde-cee364eb7f46', nil, nil, 1)) end
							
						imgui.Dummy(imgui.ImVec2(0, 130))
						if imgui.Button(u8"���������", imgui.ImVec2(160, 20)) then showCursor(false); scr:unload() end
						imgui.SameLine()
						if imgui.Button(u8"�������������", imgui.ImVec2(160, 20)) then showCursor(false); scr:reload() end
						imgui.SameLine()
						if imgui.Button(u8"��������� ����������", imgui.ImVec2(160, 20)) then funCMD.updateCheck() end
						imgui.SameLine()
						if imgui.Button(u8"������� ������", imgui.ImVec2(160, 20)) then 
							addOneOffSound(0, 0, 0, 1058)
							sampAddChatMessage("", 0xEE4848)
							sampAddChatMessage("", 0xEE4848)
							sampAddChatMessage("", 0xEE4848)
							sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ��������! ����������� �������� �������� {77DF63}/mh-delete.", 0xEE4848)
							mainWin.v = false
						--	sampShowDialog(1002, "{E94C4C}MedicalHelper | {8EE162}��������", remove, "������", "")
						end
				imgui.EndChild()
				

			end
			--//////Discord
			if select_menu[9] then
			imgui.SameLine()
			imgui.BeginChild("discord", imgui.ImVec2(0, 0), false)
				if logoDis then
					imgui.SetCursorPosX(140)
					imgui.Image(logoDis, imgui.ImVec2(388, 125))
				end
				imgui.Dummy(imgui.ImVec2(0, 5))
				imgui.SetCursorPosX(145)
				imgui.TextColoredRGB("��������� ���� �� ����������� ��������� ��������� {3EB2FF}Discrod")
				imgui.Dummy(imgui.ImVec2(0, 20))
				imgui.SetCursorPosX(10)
				imgui.TextColoredRGB("{3EB2FF}Discord{FFFFFF} - ��� ����� ������� ���������, ��������������� ��� ��������, ��� ���������, ��� �\n ��������� ��������� ������ �������������. � ���� �����, ������ ��������� �������� ����� \n����������� � ���������� � ������� ������� �� ������������.")
				imgui.Dummy(imgui.ImVec2(0, 10))
				imgui.Bullet()
				imgui.TextColoredRGB("{FAB428}������.\n\t{FFFFFF}��� ����� ����� ������������������ � ��� �������� ������� ��������� �� ���������.")
				imgui.SameLine()
				imgui.TextColoredRGB("{29EB2F}�������")
				if imgui.IsItemHovered() then 
					imgui.SetTooltip(u8"��������, ����� ������� ������.")
				end
				if imgui.IsItemClicked(0) then
					print(shell32.ShellExecuteA(nil, 'open', 'https://discordapp.com/', nil, nil, 1))
				end
				imgui.TextWrapped(u8"������� '��������� ��� Window', ���� ������ ������������ ��������� �� ����������, ��� '������� � ��������', ���� ������ ������������ ��������� ����� � ��������, �� ������, ��� � �������� �� �� ������� �������� �� ��������� �� �������.")
				if disSite then
					imgui.SetCursorPosX(100)
					imgui.Image(disSite, imgui.ImVec2(462, 212))
				end
				imgui.Bullet()
				imgui.TextColoredRGB("{FAB428}������.\n\t{FFFFFF}��� ���������� �������� ��������� ����� �������, �� ������� �� ����������.")
				imgui.SameLine()
				imgui.TextColoredRGB("{29EB2F}�������")
				if imgui.IsItemHovered() then 
					imgui.SetTooltip(u8"��������, ����� ������� ������.")
				end
				if imgui.IsItemClicked(0) then
					print(shell32.ShellExecuteA(nil, 'open', 'http://forum.arizona-rp.com/index.php?threads/saint-rose-����-������-vk-���������-�-discord.373395/', nil, nil, 1))
				end
				imgui.TextColoredRGB("��� ����� ��������� �� ���� ���������� ������, ��� �� ������� ������� ������ �� ����� \n�������. ����� �������� ��� ���������� �� ���������, ���� �� � ���������, ��� ��������� \n�������������� �����. ��� ��� �� ��������� �������� �� ������, ������� ��������� 10 ����� \n{FAA158}����� ���, ��� ������� ��� ���� ������.")   
				imgui.Bullet()
				imgui.TextColoredRGB("{FAB428}������.\n\t{FFFFFF}�� ��������� 10 ����� �� ������� ������ � ��������� ������. ��� ��� �� ��������� \n����������� ��������, ���������� ��������� ���� ��� ������� � ���������� ������. \n��� ����� ���������:")

				imgui.TextColoredRGB("\t1. ������� �� ��������� �����, ��������� ����� ������� ��������. \n\t2. �������, ���� �� ������ � ���� ��������� �� 9 ����� � ����. ���������� �����, ����� \n\t\t������� /mb \n\t3. ���� � ���� ���� ���������(�) �� 9 �����, �� ����� � �������� ��������� �������.\n\t\t{F24545}��� �������� �� - /lsmc123 \n\t\t{F24545}��� �������� �� - /sfmc123\n\t\t{F24545}��� �������� �� - /lvmc123\n{FFFFFF}����� ����� ������� ������ ���������� ���(�������� ������ ��������):")
				if disRole then
					imgui.SetCursorPosX(25)
					imgui.Image(disRole, imgui.ImVec2(586, 340))
				end
				imgui.TextColoredRGB("\t4. ��������� � ���� ���������� �� 9 ����� � ����, ����� ������ ���� ���, �������, ��� ��\n ��������� ���.")
				imgui.TextColoredRGB("����� ������ ���� ��� ��������� ����� ������. ��� ����� ����� �������� � ����� ���. \n�� ��������� �����, ��� ������� ��������� �����, ��� ����� �������� ����� ������������, \n����� ���������, ��� �� ������� �������� �������, �� �������� ���������� ��������� ���������\n �� �������.")
				if disMed then
					imgui.SetCursorPosX(25)
					imgui.Image(disMed, imgui.ImVec2(581, 301))
				end
				imgui.TextColoredRGB("\t5. �������� ���� �������. ��� ����� � ������ �������� �� ���� ��� (������� ������� ����). \n����� ���� �������� ����� {F2D045}'�������� �������'. {FFFFFF}��� ������ �� �����, � ������� �� ��������� \n�������� ��, ������ ���: {B3F637}[LVMC][��� ����] ��� ����")
				if disNick then
					imgui.SetCursorPosX(25)
					imgui.Image(disNick, imgui.ImVec2(354, 204))
				end
				imgui.EndChild()
			end

			--///��������� �������
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
				if imgui.BeginPopupModal(u8"MH | ��������� ������� ��� ���������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
					
					imgui.Text(u8"������� �� ������� ��� ��������� ������ ��� ��������� ���������."); imgui.Separator()
					imgui.Text(u8"����������� �������:")
					imgui.Bullet()	imgui.TextDisabled(u8"������� ��� ��������� - Alt, Ctrl, Shift")
					imgui.Bullet()	imgui.TextDisabled(u8"���������� �����")
					imgui.Bullet()	imgui.TextDisabled(u8"�������������� ������� F1-F12")
					imgui.Bullet()	imgui.TextDisabled(u8"����� ������� ������")
					imgui.Bullet()	imgui.TextDisabled(u8"������� ������ Numpad")
					imgui.Checkbox(u8"������������ ��� � ���������� � ���������", cb_RBUT)
					imgui.Separator()
					if imgui.TreeNode(u8"��� ������������� 5-��������� ����") then
						imgui.Checkbox(u8"X Button 1", cb_x1)
						imgui.Checkbox(u8"X Button 2", cb_x2)
						imgui.Separator()
					imgui.TreePop();
					end
					imgui.Text(u8"������� �������(�): ");
					imgui.SameLine();
					
					if imgui.IsMouseClicked(0) then
						lua_thread.create(function()
							wait(500)
							
							setVirtualKeyDown(3, true)
							wait(0)
							setVirtualKeyDown(3, false)
						end)
					end
					
					if #(rkeys.getCurrentHotKey()) ~= 0 and not rkeys.isBlockedHotKey(rkeys.getCurrentHotKey()) then
						
						if not rkeys.isKeyModified((rkeys.getCurrentHotKey())[#(rkeys.getCurrentHotKey())]) then
							currentKey[1] = table.concat(rkeys.getKeysName(rkeys.getCurrentHotKey()), " + ")
							currentKey[2] = rkeys.getCurrentHotKey()
							
						end
					end
 
					imgui.TextColored(imgui.ImColor(255, 205, 0, 200):GetVec4(), currentKey[1])
						if isHotKeyDefined then
							imgui.TextColored(imgui.ImColor(45, 225, 0, 200):GetVec4(), u8"������ ���� ��� ����������!")
						end
						if imgui.Button(u8"����������", imgui.ImVec2(150, 0)) then
							if select_menu[4] then
								if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
								if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
								if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
								if rkeys.isHotKeyExist(currentKey[2]) then 
									isHotKeyDefined = true
								else
									rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
									unRegisterHotKey(cmdBind[selected_cmd].key)
									cmdBind[selected_cmd].key = currentKey[2]
									rkeys.registerHotKey(currentKey[2], true, onHotKeyCMD)
									table.insert(keysList, currentKey[2])
									currentKey = {"",{}}
									lockPlayerControl(false)
									cb_RBUT.v = false
									cb_x1.v, cb_x2.v = false, false
									isHotKeyDefined = false
									imgui.CloseCurrentPopup();
										local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
										f:write(encodeJson(cmdBind))
										f:flush()
										f:close()
										editKey = false
								end
							elseif select_menu[5] then
								if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
								if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
								if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
								if rkeys.isHotKeyExist(currentKey[2]) then 
									isHotKeyDefined = true
								else	
									rkeys.unRegisterHotKey(binder.list[binder.select_bind].key)
									unRegisterHotKey(binder.list[binder.select_bind].key)
									binder.key = currentKey[2]
									currentKey = {"",{}}
									lockPlayerControl(false)
									cb_RBUT.v = false
									cb_x1.v, cb_x2.v = false, false
									isHotKeyDefined = false
									imgui.CloseCurrentPopup();
									editKey = false
								end
							end
						end
						imgui.SameLine();
						if imgui.Button(u8"�������", imgui.ImVec2(150, 0)) then 
							imgui.CloseCurrentPopup(); 
							currentKey = {"",{}}
							cb_RBUT.v = false
							cb_x1.v, cb_x2.v = false, false
							lockPlayerControl(false)
							isHotKeyDefined = false
							editKey = false
						end 
						imgui.SameLine()
						if imgui.Button(u8"��������", imgui.ImVec2(150, 0)) then
							currentKey = {"",{}}
							cb_x1.v, cb_x2.v = false, false
							cb_RBUT.v = false
							isHotKeyDefined = false
						end
				imgui.EndPopup()
				end
				--remove script
				--[[
				if imgui.BeginPopupModal(u8"�������� �������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
					
					imgui.Text(u8"�� ����� �������, ��� ������ ������� ������?");

						if imgui.Button(u8"�������", imgui.ImVec2(150, 0)) then
						end
						if imgui.Button(u8"������", imgui.ImVec2(150, 0)) then
							imgui.CloseCurrentPopup(); 
						end
				imgui.EndPopup()
				end
				]]
			
				
				if imgui.BeginPopupModal(u8"������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
					imgui.Text(u8"������ �������� ��� ����������")
					imgui.SetCursorPosX(60)
					if imgui.Button(u8"��", imgui.ImVec2(120, 20)) then imgui.CloseCurrentPopup() end
				imgui.EndPopup()
				end
				
				imgui.PopStyleColor(1)
			imgui.End()
	end
	if iconwin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", iconwin, imgui.WindowFlags.NoResize);
			for i,v in pairs(fa) do
				if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then setClipboardText(i) end
			end
			
		imgui.End()
	
	end
	if paramWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(820, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(u8"���-��������� ��� �������", paramWin, imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(50)
		imgui.TextColoredRGB("[center]{FFFF41}������ ������ �� ������ ����, ����� ����������� ���.", imgui.GetMaxWidthByText("������ ������ �� ������ ����, ����� ����������� ���."))
		imgui.Dummy(imgui.ImVec2(0, 15))
		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myID}")
		imgui.SameLine()
		if imgui.IsItemHovered(0) then setClipboardText("{myID}") end
		imgui.TextColoredRGB("{C1C1C1} - ��� id - {ACFF36}"..tostring(myid))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myNick}");  end
		imgui.TextColoredRGB("{C1C1C1} - ��� ������ ��� (�� ���.) - {ACFF36}"..tostring(myNick:gsub("_"," ")))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRusNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRusNick}") end
		imgui.TextColoredRGB("{C1C1C1} - ��� ���, ��������� � ���������� - {ACFF36}"..tostring(u8:decode(buf_nick.v)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHP}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHP}") end
		imgui.TextColoredRGB("{C1C1C1} - ��� ������� �� - {ACFF36}"..tostring(getCharHealth(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myArmo}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myArmo}") end
		imgui.TextColoredRGB("{C1C1C1} - ��� ������� ������� ����� - {ACFF36}"..tostring(getCharArmour(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHosp}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHosp}") end
		imgui.TextColoredRGB("{C1C1C1} - �������� ����� �������� - {ACFF36}"..tostring(u8:decode(chgName.org[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHospEn}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHospEn}") end
		imgui.TextColoredRGB("{C1C1C1} - ������ �������� ����� �������� �� ���. - {ACFF36}"..tostring(u8:decode(list_org_en[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myTag}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myTag}") end
		imgui.TextColoredRGB("{C1C1C1} - ��� ���  - {ACFF36}"..tostring(u8:decode(buf_teg.v)))
		
		imgui.Spacing()		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRank}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRank}") end
		imgui.TextColoredRGB("{C1C1C1} - ���� ������� ��������� - {ACFF36}"..tostring(u8:decode(chgName.rank[num_rank.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{time}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{time}") end
		imgui.TextColoredRGB("{C1C1C1} - ����� � ������� ����:������:������� - {ACFF36}"..tostring(os.date("%X")))
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{day}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{day}") end
		imgui.TextColoredRGB("{C1C1C1} - ������� ���� ������ - {ACFF36}"..tostring(os.date("%d")))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{week}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{week}") end
		imgui.TextColoredRGB("{C1C1C1} - ������� ������ - {ACFF36}"..tostring(week[tonumber(os.date("%w"))+1]))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{month}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{month}") end
		imgui.TextColoredRGB("{C1C1C1} - ������� ����� - {ACFF36}"..tostring(month[tonumber(os.date("%m"))]))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{getNickByTarget}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByTarget}") end
		imgui.TextColoredRGB("{C1C1C1} - �������� ��� ������ �� �������� ��������� ��� �������.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{target}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{target}") end
		imgui.TextColoredRGB("{C1C1C1} - ��������� ID ������, �� �������� ������� (�������� ����) - {ACFF36}"..tostring(targID))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{pause}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{pause}") end
		imgui.TextColoredRGB("{C1C1C1} - �������� ����� ����� �������� ������ � ���. {EC3F3F}����������� ��������, �.�. � ����� ������.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sleep:�����}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sleep:1000}") end
		imgui.TextColoredRGB("{C1C1C1} - ����� ���� �������� ������� ����� ���������. \n\t������: {sleep:2500}, ��� 2500 ����� � �� (1 ��� = 1000 ��)")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sex:�����1|�����2}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sex:text1|text2}") end
		imgui.TextColoredRGB("{C1C1C1} - ���������� ����� � ����������� �� ���������� ����.  \n\t������, {sex:�����|������}, ����� '�����', ���� ������ ������� ��� ��� '������', ���� �������")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{getNickByID:�� ������}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByID:}") end
		imgui.TextColoredRGB("{C1C1C1} - ��������� ��� ������ �� ��� ID. \n\t������, {getNickByID:25}, ����� ��� ������ ��� ID 25.)")


	--	imgui.TextColoredRGB("")
			-- imgui.Spacing()
			-- imgui.Bullet()
			-- imgui.TextColoredRGB("{FF8400}{dialog}{C1C1C1} - �������� ������������ ��������. ����� �������� ����:")
			-- imgui.Spacing()
			-- imgui.Spacing()
			-- if imgui.TreeNode(u8"��������� �� ����������� ���������� {dialog}") then
			-- 	imgui.Separator()
			-- 	imgui.Spacing()
			-- 	imgui.Text(u8"� ������� ���������� ��������� ����� ��������� ����������� ������� � ������� �����������\n ��������. �������� ������ ������� ����� ��������� ��������� ������ ���.�����, ��� ����������\n ������� ��������� ������������ (��������, ������� ����������, ����. ����������).")
			-- 	imgui.Spacing()
			-- 	imgui.Text(u8"������ ��������� �������:")
			-- 	imgui.BeginGroup()
			-- 		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			-- 		imgui.InputTextMultiline("##dialogPar", helpDialog, imgui.ImVec2(210, 180), 16384)
			-- 		imgui.PopStyleColor(1)
			-- 		imgui.TextDisabled(u8"��� ����������� �����������\nCtrl + C. ������� - Ctrl + V")
			-- 	imgui.EndGroup()
			-- 	imgui.SameLine()
			-- 	imgui.BeginGroup()
			-- 			imgui.TextColoredRGB("{FF8400}{dialog}	{FFFFFF}- {EF5454}������������ ��������{FFFFFF}, ����������� ������ ����������� \n�������. �������� ������������� ����� \"=\"(�����)")
			-- 			imgui.TextColoredRGB("{FF8400}[name]=	{FFFFFF}- �������������� ��������. ��������� �������� ������ �������.\n �������� ������������� ����� \"=\"(�����)")
			-- 			imgui.TextColoredRGB("{FF8400}[1]= 		{FFFFFF}- ���������� ������ � ������� ������� �������� ������������\n �����������. �������� �� 9 ��������� ������. ����� \"=\"(�����) ���������\n ����� �� �����������.")
			-- 			imgui.TextColoredRGB("{FF8400}{dialogEnd}	{FFFFFF}- {EF5454}������������ ��������{FFFFFF}, ����������� �� ����� ����������� \n�������.")
			-- 			imgui.TextColoredRGB("��� �������������� ��������� �������� �� ����������, �� �������������\n �� ��������� ��� ����������� ���������.")
						
						
			-- 			--imgui.TextColoredRGB("")
			-- 	imgui.EndGroup()
			-- 		imgui.TextColoredRGB("{F03636}����������: \n{FFFFFF}1. ����� ��� ���������� ������ ��������� ����������� � ����� ������� ����� ������ ������. \n(������� � �������)\n2. ����� � ����� ����������� ������� ����� ����������� ������� ���������, � ����� ��������� \n�������������� �������.\n3. �� ����������� ��������� ������� ������ ����� ����������� �������.")
			-- 	imgui.TreePop()
			---end
		
		imgui.End()
	end
	if spurBig.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1098, 790), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������� ���������", spurBig, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
	--	imgui.SetWindowFontScale(1.1)
		if spur.edit then
				imgui.SetCursorPosX(350)
				imgui.Text(u8"������� ���� ��� ��������������/��������� ���������")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(1081, 700))
				imgui.PopStyleColor(1)
				if imgui.Button(u8"���������", imgui.ImVec2(357, 20)) then
					local name = ""
					local bool = false
					if spur.name.v ~= "" then 
							name = u8:decode(spur.name.v)
							if doesFileExist(dirml.."/MedicalHelper/���������/"..name..".txt") and spur.list[spur.select_spur] ~= name then
								bool = true
								imgui.OpenPopup(u8"������")
							else
								os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
								spur.list[spur.select_spur] = u8:decode(spur.name.v)
							end
					else
						name = spur.list[spur.select_spur]
					end
					if not bool then
						local f = io.open(dirml.."/MedicalHelper/���������/"..name..".txt", "w")
						f:write(u8:decode(spur.text.v))
						f:flush()
						f:close()
						spur.text.v = ""
						spur.name.v = ""
						spur.edit = false
					end
				end
				imgui.SameLine()
				if imgui.Button(u8"�������", imgui.ImVec2(357, 20)) then
					spur.text.v = ""
					table.remove(spur.list, spur.select_spur) 
					spur.select_spur = -1
					if doesFileExist(dirml.."/MedicalHelper/���������/"..u8:decode(spur.select_spur)..".txt") then
						os.remove(dirml.."/MedicalHelper/���������/"..u8:decode(spur.select_spur)..".txt")
					end
					spur.name.v = ""
					spurBig.v = false
					spur.edit = false
				end
				imgui.SameLine()
				if imgui.Button(u8"�������� ��������", imgui.ImVec2(357, 20)) then spur.edit = false end
				if imgui.Button(u8"�������", imgui.ImVec2(1081, 20)) then spurBig.v = not spurBig.v end
		else
			imgui.SetCursorPosX(380)
			imgui.Text(u8"������� ���� ��� ��������������/��������� ���������")
			imgui.BeginChild("spur spec", imgui.ImVec2(1081, 730), true)
				if doesFileExist(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") then
					for line in io.lines(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") do
						imgui.TextWrapped(u8(line))
					end
				end
			imgui.EndChild()
			if imgui.Button(u8"�������� ��������������", imgui.ImVec2(537, 20)) then 
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"�������", imgui.ImVec2(537, 20)) then spurBig.v = not spurBig.v end
		end
		imgui.End()
	end
	
	if sobWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(880, 380), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"���� ��� ���������� �������������", sobWin, imgui.WindowFlags.NoResize);
		--	imgui.SetWindowFontScale(1.1)
			imgui.BeginGroup()
				imgui.PushItemWidth(140)
				imgui.InputText("##id", sobes.selID, imgui.InputTextFlags.CallbackCharFilter + imgui.InputTextFlags.EnterReturnsTrue + readID(), filter(1, "%d+"))
				imgui.PopItemWidth()
				if not imgui.IsItemActive() and sobes.selID.v == "" then
					imgui.SameLine()
					imgui.SetCursorPosX(13)
					imgui.TextDisabled(u8"������� id ������") 
				end
				imgui.SameLine()
				imgui.SetCursorPosX(155)
				if imgui.Button(u8"������", imgui.ImVec2(60, 20)) then
					if sobes.selID.v ~= "" then
						if #sobes.logChat == 0 then
						sobes.num = sobes.num + 1
						threadS = lua_thread.create(sobesRP, sobes.num);
						table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}�������� ����������...")
						else
						table.insert(sobes.logChat, "{E74E28}[������]{FFFFFF}: �������� ��� ������. ���� ������ ������ �����, ������� �� ������ \"����������\" ��� \n\t��������� ��������� ��������.")
						end
					else
						sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� id ������ ��� ������ �������������.", 0xEE4848)
					end
				end
				imgui.BeginChild("pass player", imgui.ImVec2(210, 170), true)
					imgui.SetCursorPosX(30)
					imgui.Text(u8"���������� � ������:")
					imgui.Separator()
					imgui.Bullet()
					imgui.Text(u8"���:")
						if sobes.player.name == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}���")
						else
							imgui.SameLine()
							imgui.TextColoredRGB("{FFCD00}"..sobes.player.name)
						end
					imgui.Bullet()
					imgui.Text(u8"��� � �����:")
						if sobes.player.let == 0 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}���")
						else
							if sobes.player.let >= 3 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.let.."/3")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.let.."{17E11D}/3")
							end
						end
					imgui.Bullet()
					imgui.Text(u8"�����������������:")
						if sobes.player.zak == 0 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}���")
						else
							if sobes.player.zak >= 35 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.zak.."/35")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.zak.."{17E11D}/35")
							end
						end
					imgui.Bullet()
					imgui.Text(u8"����� ������:")
						if sobes.player.work == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}���")
						else
							if sobes.player.work == "��� ������" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.work)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.work)
							end
						end
					imgui.Bullet()
					imgui.Text(u8"������� � ��:")
						if sobes.player.bl == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}���")
						else
							if sobes.player.bl == "�� ������(�)" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.bl)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.bl)
							end
						end
					imgui.Spacing()
					imgui.Bullet()
					imgui.Text(u8"��������:")
						if sobes.player.heal == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}���")
						else
							if sobes.player.heal == "������" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.heal)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.heal)
							end
						end
					imgui.Bullet()
					imgui.Text(u8"����������������:")
						if sobes.player.narko == 0.1 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}���")
						else
							if sobes.player.narko == 0 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.narko.."/0")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.narko.."{17E11D}/0")
							end
						end
				imgui.EndChild()
				if imgui.Button(u8"������������ ������", imgui.ImVec2(210, 30)) then imgui.OpenPopup("sobQN") end
				imgui.Spacing() --if #sobes.logChat == 0 then
					if sobes.nextQ then
						if imgui.Button(u8"������ ������", imgui.ImVec2(210, 30)) then
							sobes.num = sobes.num + 1
							lua_thread.create(sobesRP, sobes.num); 
						end
					else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"������ ������", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
					end
				imgui.Spacing()
				if #sobes.logChat ~= 0 and sobes.selID.v ~= "" then
					if imgui.Button(u8"���������� ��������", imgui.ImVec2(210, 30)) then imgui.OpenPopup("sobEnter") end
				else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"���������� ���������", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
				end
				imgui.Spacing()
				if #sobes.logChat ~= 0 and sobes.selID.v ~= "" then 
					if imgui.Button(u8"����������/��������", imgui.ImVec2(210, 30)) then
						threadS:terminate()
						sobes.input.v = ""
						sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
						sobes.selID.v = ""
						sobes.logChat = {}
						sobes.nextQ = false
						sobes.num = 0
					end
				else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"����������/��������", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
				end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginChild("log chat", imgui.ImVec2(0, 0), true)
				imgui.SetCursorPosX(270)
				imgui.Text(u8"��������� ���")
					if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ��� ��� �������") end
					if imgui.IsItemClicked(1) then sobes.logChat = {} end
				imgui.SameLine()
				imgui.SetCursorPosX(580)
				if imgui.SmallButton(u8"������") then imgui.OpenPopup("helpsob") end
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
					if imgui.BeginPopup("helpsob") then
						imgui.Text(u8"\t\t\t\t\t\t��������� ���������� �� �����������.")
						imgui.TextColoredRGB(helpsob)
					imgui.EndPopup()
					end
				imgui.PopStyleColor(1)
				imgui.BeginChild("log chat in", imgui.ImVec2(0, 280), true)
					for i,v in ipairs(sobes.logChat) do
						imgui.TextColoredRGB(v)
					end
					imgui.SetScrollY(imgui.GetScrollMaxY())
				imgui.EndChild()
				imgui.Spacing()
				imgui.Text(u8"��:");
				imgui.SameLine()
				imgui.PushItemWidth(515)
				imgui.InputText("##chat", sobes.input)
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button(u8"���������", imgui.ImVec2(85, 20)) then sampSendChat(u8:decode(sobes.input.v)); sobes.input.v = "" end
			imgui.EndChild()
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94)) 
					if imgui.BeginPopup("sobEnter") then
						if imgui.MenuItem(u8"�������") then lua_thread.create(sobesRP, 4) end
						if imgui.BeginMenu(u8"���������") then
							if imgui.MenuItem(u8"��������� � �������� (���)") then lua_thread.create(sobesRP, 5) end
							if imgui.MenuItem(u8"���� ��� ����������") then lua_thread.create(sobesRP, 6) end
							if imgui.MenuItem(u8"�������� � �������") then lua_thread.create(sobesRP, 7) end
							if imgui.MenuItem(u8"����� ������") then lua_thread.create(sobesRP, 8) end
							if imgui.MenuItem(u8"������� � ��") then lua_thread.create(sobesRP, 9) end
							if imgui.MenuItem(u8"�������� �� ���������") then lua_thread.create(sobesRP, 10) end
							if imgui.MenuItem(u8"����� ����������������") then lua_thread.create(sobesRP, 11) end
						imgui.EndMenu()
						end
					imgui.EndPopup()
					end
					if imgui.BeginPopup("sobQN") then
						if imgui.MenuItem(u8"��������� ���������") then 
							sampSendChat("���������� ���������� ��� ����� ����������, � ������: ������� � ���.�����.") 
							table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ��������� ������� �������� ���������.")
						end
						if imgui.MenuItem(u8"����� ��������") then 
							sampSendChat("������ �� ������� ������ ���� �������� ��� ���������������?") 
							table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: .")
						end
						if imgui.MenuItem(u8"���������� � ����") then 
							sampSendChat("����������, ����������, ������� � ����.") 
							table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ����������, ����������, ������� � ����.")
						end
						if imgui.MenuItem(u8"����� �� Discord") then 
							sampSendChat("������� �� � ��� ����.����� \"Discord\"?") 
							table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ������� �� � ��� ����.����� \"Discord\"?")
						end
						if imgui.BeginMenu(u8"������� �� �������:") then
							if imgui.MenuItem(u8"��") then 
								sampSendChat("��� ����� �������� ������������ '��'?")
								table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ��� ����� �������� ������������ '��'?")
							end
							if imgui.MenuItem(u8"��") then 
								sampSendChat("��� ����� �������� ������������ '��'?") 
								table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ��� ����� �������� ������������ '��'?")
							end
							if imgui.MenuItem(u8"��") then 
								sampSendChat("��� ����� �������� ������������ '��'?") 
								table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ��� ����� �������� ������������ '��'?")
							end
							if imgui.MenuItem(u8"��") then 
								sampSendChat("��� �� �������, ��� ����� �������� ������������ '��'?")
								table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ��� �� �������, ��� ����� �������� ������������ '��'?.")								
							end
						imgui.EndMenu()
						end
					imgui.EndPopup()
					end
				imgui.PopStyleColor(1)
		imgui.End()
	end

	if depWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(865, 360), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_SIGNAL .. u8" ���� ����� ������������.", depWin, imgui.WindowFlags.NoResize);
		--imgui.SetWindowFontScale(1.1)
			imgui.BeginGroup()
				imgui.BeginChild("dep list", imgui.ImVec2(225, 215), true)
					if ButtonDep(u8(dep.list[1]), dep.bool[1]) then-- ���
						dep.bool = {true, false, false, false, false, false}
						dep.select_dep[1] = 1
						
					end
					if ButtonDep(u8(dep.list[2]), dep.bool[2]) then-- ��
						dep.bool = {false, true, false, false, false, false}
						dep.select_dep[1] = 2
						
					end
					if ButtonDep(u8(dep.list[3]), dep.bool[3]) then-- ��/��
						dep.bool = {false, false, true, false, false, false, false}
						dep.select_dep[1] = 3
						
					end
					if ButtonDep(u8(dep.list[4]), dep.bool[4]) then-- ���
						dep.bool = {false, false, false, true, false, false, false}
						dep.select_dep[1] = 4
						
					end
					if ButtonDep(u8(dep.list[5]), dep.bool[5]) then-- �����
						dep.bool = {false, false, false, false, true, false, false}
						dep.select_dep[1] = 5
						
					end
					if ButtonDep(u8(dep.list[6]), dep.bool[6]) then-- ���
						dep.bool = {false, false, false, false, false, true, false}
						dep.select_dep[1] = 6
						
					end
					if ButtonDep(u8(dep.list[7]), dep.bool[7]) then-- �������
						dep.bool = {false, false, false, false, false, false, true}
						dep.select_dep[1] = 7
						getGovFile()
					end
				imgui.EndChild()

					if dep.select_dep[1] < 5 and dep.select_dep[1] ~= 0 and dep.select_dep[2] == 0 then
						imgui.Dummy(imgui.ImVec2(0, 65)) 
						if imgui.Button(u8"������������", imgui.ImVec2(225, 30)) then
							for i,v in ipairs(dep.bool) do
								if v == true then 
									dep.select_dep[2] = i
								end
							end
							if dep.select_dep[2] == 1 then sampSendChat(string.format("/d [%s] - [����������] ������� �� ������� 100,3.", rankFix())) end
							if dep.select_dep[2] == 2 then sampSendChat(string.format("/d [%s] - [����������] ������� �� ������� 102,7.", rankFix())) end
							if dep.select_dep[2] == 3 then sampSendChat(string.format("/d [%s] - [����������] ������� �� ������� 104,8.", rankFix())) end
							if dep.select_dep[2] == 4 then sampSendChat(string.format("/d [%s] - [����������] ������� �� ������� 109,6.", rankFix())) end
						end
					elseif dep.bool[5] then
						imgui.SetCursorPosX(50)
						imgui.Text(u8"������ �����:  "..dep.time[1]..":"..dep.time[2])
						imgui.Spacing()
						imgui.Spacing()
							imgui.SetCursorPosX(60)
							imgui.Text(u8"����\t\t   ������"); 
							imgui.SetCursorPosX(45)
							if imgui.SmallButton("<<") and dep.time[1] > 0 then dep.time[1] = dep.time[1] - 1 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[1]))
							imgui.SameLine()
							if imgui.SmallButton(">>") and dep.time[1] < 24 then dep.time[1] = dep.time[1] + 1 end
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							if imgui.SmallButton("<<##1") and dep.time[2] > 0 then dep.time[2] = dep.time[2] - 5 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[2]))
							imgui.SameLine()
							if imgui.SmallButton(">>##1") and dep.time[2] < 55 then dep.time[2] = dep.time[2] + 5 end
						imgui.Spacing()
						imgui.Spacing()
						if imgui.Button(u8"��������", imgui.ImVec2(225, 30)) then
							lua_thread.create(function()
							local inpSob = string.format("%d,%d,%s", dep.time[1], dep.time[2], u8:decode(list_org[num_org.v+1]))
								sampSendChat(string.format("/d [%s] - [����������] ������� �� ������� 103,9", u8:decode(list_org[num_org.v+1])))
								wait(1750)
								sampSendChat(string.format("/d [%s] - [103,9] ������� ���.����� �������� ��� ���������� �������������.", u8:decode(list_org[num_org.v+1])))
								wait(500)
								sampSendChat("/lmenu")
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1214
								sampSetCurrentDialogListItem(2)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1336
								sampSetCurrentDialogListItem(0)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(0) until sampIsDialogActive() and sampGetCurrentDialogId() == 1335
								wait(350)
								sampSetCurrentDialogEditboxText(inpSob)
								wait(350)
								sampCloseCurrentDialogWithButton(1)
								wait(1700)
								sampSendChat(string.format("/d [%s] - [����������] ������� ������� 103,9.",  u8:decode(list_org[num_org.v+1]))) 
							end)
						end
					elseif  dep.bool[6] then
						imgui.Dummy(imgui.ImVec2(0, 65)) 
						if imgui.Button(u8"��������", imgui.ImVec2(225, 30)) then 
							sampSendChat(string.format("/d [%s] - [����������] ���. ���������.", rankFix())) 
						end
					elseif dep.bool[7] then
						imgui.Spacing()
						imgui.PushItemWidth(225)
						imgui.Combo("##news", dep.newsN, dep.news)
						imgui.PopItemWidth()
						imgui.Spacing()
							
							imgui.Text(u8"����� ������ ���� �������� ��� \n�������� �������.")

							imgui.SetCursorPos(imgui.ImVec2(140, 297))
							imgui.TextColoredRGB("{29EB2F}�����")
							if imgui.IsItemHovered() then 
								imgui.SetTooltip(u8"��������, ����� ������� �����.")
							end
							if imgui.IsItemClicked(0) then
								print(shell32.ShellExecuteA(nil, 'open', dirml.."/MedicalHelper/�����������/", nil, nil, 1))
							end
						imgui.Spacing()
						imgui.Spacing()
						if imgui.Button(u8"������", imgui.ImVec2(225, 30)) then
							lua_thread.create(function()
							-- if tonumber(os.date("%M")) > 17 then --17
							-- 	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: Gov ������� ��������� ����� ������ �� 0 �� 15 �����.", 0xEE4848)
							-- 	return
							-- end
							
								if doesFileExist(dirml.."/MedicalHelper/�����������/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") then
								--	print(u8:decode(dep.news[dep.newsN.v+1]))
									for line in io.lines(dirml.."/MedicalHelper/�����������/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") do
										sampSendChat(line)
										wait(1000)
									end
								end
							end)
						end
					elseif dep.select_dep[2] < 5 and dep.select_dep[2] ~= 0 then
						imgui.PushItemWidth(225)
						if imgui.Button(u8"�����������", imgui.ImVec2(225, 25)) then
							if dep.select_dep[2] == 1 then sampSendChat(string.format("/d [%s] - [����������] ������� ������� 100,3.", rankFix())) end
							if dep.select_dep[2] == 2 then sampSendChat(string.format("/d [%s] - [����������] ������� ������� 102,7.", rankFix())) end
							if dep.select_dep[2] == 3 then sampSendChat(string.format("/d [%s] - [����������] ������� ������� 104,8.", rankFix())) end
							if dep.select_dep[2] == 4 then sampSendChat(string.format("/d [%s] - [����������] ������� ������� 109,6.", rankFix())) end
							dep.select_dep[2] = 0
						end
						imgui.Spacing()
						imgui.Spacing()
						imgui.Text(u8"���� ������������:")
						if dep.bool[1] then
						imgui.Combo("##orgs", dep.sel, dep.sel_all)
						imgui.Spacing()
						imgui.Spacing()
						imgui.TextDisabled(u8"End - ������� ��� � ��������")
							if wasKeyReleased(VK_END) and not sampIsChatInputActive() then
								sampSetChatInputText(string.format("/d [%s] - [100,3] - [%s]: ", rankFix(), u8:decode(dep.sel_all[dep.sel.v+1])));
								sampSetChatInputEnabled(true)  
							end
						elseif dep.bool[2] then
						imgui.Combo("##orgs", dep.sel, dep.sel_chp)
						imgui.Spacing()
						imgui.Spacing()
						imgui.TextDisabled(u8"End - ������� ��� � ��������")
							if wasKeyReleased(VK_END) and not sampIsChatInputActive() then
								sampSetChatInputText(string.format("/d [%s] - [102,7] - [%s]: ", rankFix(), u8:decode(dep.sel_chp[dep.sel.v+1])));
								sampSetChatInputEnabled(true) 
							end
						elseif dep.bool[3] then
							imgui.Combo("##orgs", dep.sel, dep.sel_mzmomu)
							imgui.Spacing()
							imgui.Spacing()
							imgui.TextDisabled(u8"End - ������� ��� � ��������")
							if wasKeyReleased(VK_END) and not sampIsChatInputActive() then
								sampSetChatInputText(string.format("/d [%s] - [104,8] - [%s]: ", rankFix(), u8:decode(dep.sel_mzmomu[dep.sel.v+1])));
								sampSetChatInputEnabled(true) 
							end
						elseif dep.bool[4] then
						imgui.Combo("##orgs", dep.sel, dep.sel_tsr)
						imgui.Spacing()
						imgui.Spacing()
						imgui.TextDisabled(u8"End - ������� ��� � ��������")
							if wasKeyReleased(VK_END) and not sampIsChatInputActive() then
								sampSetChatInputText(string.format("/d [%s] - [109,6] - [%s]: ", rankFix(), u8:decode(dep.sel_tsr[dep.sel.v+1])));
								sampSetChatInputEnabled(true) 
							end
						end
						imgui.PopItemWidth()

					else
						imgui.SetCursorPos(imgui.ImVec2(20, 260)) 
						imgui.Text(u8"�������� ����� ������������")
					end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginChild("dep log", imgui.ImVec2(0, 0), true)
				imgui.SetCursorPosX(250)
				imgui.Text(u8"��������� ��������������������������������������������������������������������������������������")
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ��� ��� �������") end
				if imgui.IsItemClicked(1) then dep.dlog = {} end
					imgui.BeginChild("dep logg", imgui.ImVec2(0, 260), true)
						for i,v in ipairs(dep.dlog) do
							imgui.TextColoredRGB(v)
						end
						imgui.SetScrollY(imgui.GetScrollMaxY())
					imgui.EndChild()
				imgui.Spacing()
				imgui.Text(u8"��:");
				imgui.SameLine()
				imgui.PushItemWidth(490)
				imgui.InputText("##chat", dep.input)
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button(u8"���������", imgui.ImVec2(80, 20)) then
					if dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
						if dep.bool[1] then
							sampSendChat(string.format("/d [%s] - [100,3] - [%s]: "..u8:decode(dep.input.v), rankFix(), u8:decode(dep.sel_all[dep.sel.v+1])))
						elseif dep.bool[2] then
							sampSendChat(string.format("/d [%s] - [102,7] - [%s]: "..u8:decode(dep.input.v), rankFix(), u8:decode(dep.sel_chp[dep.sel.v+1])))
						elseif dep.bool[3] then
							sampSendChat(string.format("/d [%s] - [104,8] - [%s]: "..u8:decode(dep.input.v), rankFix(), u8:decode(dep.sel_mzmomu[dep.sel.v+1])))
						elseif dep.bool[4] then
							sampSendChat(string.format("/d [%s] - [109,6] - [%s]: "..u8:decode(dep.input.v), rankFix(), u8:decode(dep.sel_tsr[dep.sel.v+1])))
						end
					end
					dep.input.v = ""
				end
			imgui.EndChild()
		imgui.End()
	end
 
	if updWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_DOWNLOAD .. u8" �������� ����������.", updWin, imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			imgui.SetCursorPosX(252)
			imgui.Text(u8"���������� �� ����������")
			imgui.Dummy(imgui.ImVec2(0, 10))
			if #updinfo < 5 then
				imgui.SetCursorPos(imgui.ImVec2(242, 150))
				imgui.TextColoredRGB("{72F566}���������� �� ����������")
				imgui.SetCursorPosX(212)
				imgui.TextColoredRGB("{72F566}�� ����������� ����� ����� ������")
			else
				if newversion == scr.version then
					imgui.SetCursorPosX(120)
					imgui.TextColored(imgui.ImColor(0, 255, 0, 225):GetVec4(), fa.ICON_CHECK); imgui.SameLine()
					imgui.TextColoredRGB("�� ����������� ��������� ����������. ������� ������: {72F566}"..scr.version)
					imgui.SetCursorPosX(222)
					imgui.TextColoredRGB("{F8A436}��� ���� ��������� � ������� ���: ")
					imgui.Spacing()
					imgui.BeginChild("update log", imgui.ImVec2(0, 0), true)
						if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
							for line in io.lines(dirml.."/MedicalHelper/files/update.txt") do
								imgui.TextColoredRGB(line:gsub("*n*", "\n"))
							end
						end
					imgui.EndChild()
				else
					imgui.SetCursorPosX(182) 
					imgui.TextColored(imgui.ImColor(255, 200, 0, 225):GetVec4(), fa.ICON_EXCLAMATION_TRIANGLE); imgui.SameLine()
					imgui.TextColoredRGB("�� ����������� ���������� ������ �������.")
					imgui.SetCursorPosX(212) 
					imgui.TextColoredRGB("����� ������: {72F566}"..newversion.."{FFFFFF}. ������� ����: {EE4747}"..scr.version)
					imgui.SetCursorPosX(282)
					imgui.TextColoredRGB("{F8A436}��� ���� ���������:")
					imgui.Spacing()
					imgui.BeginChild("update log", imgui.ImVec2(0, 230), true)
						if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
							for line in io.lines(dirml.."/MedicalHelper/files/update.txt") do
								imgui.TextColoredRGB(line:gsub("*n*", "\n"))
							end
						end
					imgui.EndChild()
					imgui.SetCursorPosX(232)
					if imgui.Button(fa.ICON_DOWNLOAD .. u8" ���������� ����� ������", imgui.ImVec2(230, 30)) then funCMD.update() end
				end
			end
		--	imgui.Bullet(); imgui.SameLine()
		--	imgui.TextColoredRGB("���� �������� ������ ���������� �������� �������� ")
		imgui.End()
	end
	if mcEditWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(650, 420), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������������� ��������� ���.�����", mcEditWin, imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			imgui.InputTextMultiline("##mcedit", buf_mcedit, imgui.ImVec2(634, 350))
			if imgui.Button(u8"���������", imgui.ImVec2(155, 25)) then
				local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt", "w")
				f:write(u8:decode(buf_mcedit.v))
				f:close() 
			end
			imgui.SameLine()
			if imgui.Button(u8"��������", imgui.ImVec2(155, 25)) then
				local textrp = [[
// ���� �� ������ ����� ���.�����
#med7=10.000$
#med14=20.000$
#med30=32.500$
#med60=65.000$
// ���� �� ���������� ���.�����
#medup7=15.000$
#medup14=25.000$
#medup30=38.000$
#medup60=70.000$

{sleep:0}
������������, �� ������ �������� ����������� ����� ������� ��� �������� ������������?
������������, ����������, ��� �������
/b /showpass {myID}
{pause}
/todo ��������� ���!*���� ������� � ���� � {sex:�����|������} ��� �������.
{dialog}
[name]=������ ���.�����
[1]=����� ���.�����
������, � ��� {sex:�����|������}. ��� ����� �������� ����� ���.�����.
��� ���������� ����� ���������� ��������� ���.�������, ������� ������� �� ����� �����.
�� 7 ���� - #med7, �� 14 ���� - #med14
�� 30 ���� #med30, �� 60 ���� - #med60.
�� ��������?
���� ��������, �� �������� � �� ��������� ������� ����������.
/b �������� ����� ����� /pay {myID} ��� /trade {myID}

{dialog}
[name]=���� ������
[1]=7 ����
#timeID=0
[2]=14 ����
#timeID=1
[3]=30 ����
#timeID=2
[4]=60 ���
#timeID=3
{dialogEnd}

������, ����� ��������� � ����������.
/me {sex:�������|��������} �� ���������� ������� ��������� �����
/do ����� � ������ ����.
/me ������{sex:|�} �������, ����� ������{sex:|�} ������ ������ ������ ��� ���.�����
/me ��������{sex:|�} �������� ������ ���� ������� �� ������ ��������� � �����{sex:|�} ������������ ������ � �����
/me ������{sex:|�} ������ ���.����� � �������, ����� �����{sex:|�} ������������ ������ �� ��������
/do ������ ������ ������ �������� ���� ���������� �� �����.

[2]=���������� ������
������, � ��� �����{sex:|�}. ��� ����� �������� ������ � ���.�����.
��� ���������� ������ ���������� ��������� ���.�������, ������� ������� �� ����� �����.
�� 7 ���� - #medup7, �� 14 ���� - #medup14
�� 30 ���� #medup30, �� 60 ���� - #medup60.
�� ��������?
���� ��������, �� �������� � �� ��������� ������� ����������.
/b �������� ����� ����� /pay {myID} ��� /trade {myID}

{dialog}
[name]=���� ������
[1]=7 ����
#timeID=0
[2]=14 ����
#timeID=1
[3]=30 ����
#timeID=2
[4]=60 ���
#timeID=3
{dialogEnd}

������, ����� ��������� � ����������.
/me �������{sex:|�} �� ���������� ������� ��������� �����
/do ����� � ������ ����.
/me ������{sex:|�} �������, ����� �����{sex:|�} ������ ���.����� c ������������� �#playerID
/me ��������{sex:|�} �������� ������ ���� ������� �� ������ ��������� � �����{sex:|�} ������������ ������ � �����
/me ������{sex:|�} ������ ���.����� � �������, ����� �����{sex:|�} ������������ ������ �� ��������
/do ������ ������ ������ �������� ���� ���������� �� �����.
{dialogEnd}
/me �������{sex:|�} ������� � ������� ��� ������� � ����������{sex:��|���} � ����������� ��������� ����������
���, ������ ����� ��������� �������� ������� ��������...
������ �� �������� �������?
{pause}
������� �� ������� ��������, � ����� ������������� �������?
{pause}
������, ������ ������ ���� �������� �� ������ ������������ ���������.
{dialog}
[name]=������� ����.����.
[1]=����� � �������.
���� �� � ��� ����� � �������?
[2]=���������� �����.
��� �� ������������ �����, ����� � ��� ����������?
[3]=�������� ��������������� �����.
������ �� � ��� �������������� �������� �����? ���� ��, �� ��� �����?
[4]=�������� �� ������.
�����������, ��� �� ���������� � ������ ������ � �� ��� ���� �...
...������� ��������� ��������� ����.
��� �� ��������?
[5]=�������� ��������.
������ �� � ��� �������������� �������� ��������? ���� ��, �� ��� �����?
[6]=������� �� �����
��� �� ������ ������, ���� �� ������� �������� �������� �� �����?
{dialogEnd}
{pause}
/me �������{sex:|�} ��� ��������� ��������� � ���.�����
{dialog}
[name]=����. ��������
[1]=�����c��� ������(��)
#healID=3
/me ������{sex:|�} ������ �������� ������ '����. ��������.' - '��������� ������(�).'
[2]=����������� ��������������
#healID=2
/me ������{sex:|�} ������ �������� ������ '����. ��������.' - '������� ����������.'
[3]=���������� �� ������(��)
#healID=1
/me ������{sex:|�} ������ �������� ������ '����. ��������.' - '����. ��������.'
{dialogEnd}
/me ����{sex:|�} ����� {myHospEn} � ������ ���� �� ����� ����� � �����{sex:|��} ������ � ���� ������
/do ������ ��������.
/me ������� ����� � ������� � ��������{sex:|�} ���� �������, � ����������� ����
/do �������� ���.����� ���������.
�� ������, ������� ���� ���.�����, �� �������.
�������� ���.
/medcard #playerID #healID #timeID]]
				local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt", "w")
				f:write(textrp)
				f:close()
				buf_mcedit.v = u8(textrp)
			end
			imgui.SameLine()
			if imgui.Button(u8"���-�������", imgui.ImVec2(155, 25)) then
				paramWin.v = not paramWin.v
			end
			imgui.SameLine()
			if imgui.Button(u8"��� �����������", imgui.ImVec2(155, 25)) then
				profbWin.v = not profbWin.v
			end
		imgui.End()
	end
	if profbWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(710, 450), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"����������� ����������� �������", profbWin, imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			local vt1 = [[
������ ������������ ������������� ������� ��� ����������������� ������������ �������
������ �������� ������������ ������� ���������� ��� ���������� ������������.
 
{FFCD00}1. ������� ����������{FFFFFF}
	��� �������� ���������� ������������ ������ ������� {ACFF36}#{FFFFFF}, ����� �������� ��� ��������
����������. �������� ���������� ����� ��������� ������ ���������� ������� � �����,
����� ����� ���������. 
	����� �������� ���������� �������� ����� {ACFF36}={FFFFFF} � ����� ������� ����� �����, �������
���������� ��������� ���� ����������. ����� ����� ��������� ����� �������.
		������: {ACFF36}#price=10.000$.{FFFFFF}
	������, ��������� ���������� {ACFF36}#price{FFFFFF}, ����� � �������� ���� ��� ���������, � ��� �����
������������� �������� �� ����� ������������ ��������� �� ��������, ������� ���� 
������� ����� �����.
 
{FFCD00}2. ��������������� ������{FFFFFF}
	� ������� ��������������� ����� ������� ��� ���� ������� ��� �������� ����-����
��� ���� ��� ����������� �� ����� ������������. ����������� �������� ������� ������ //,
����� �������� ������� ����� �����.
	������: {ACFF36}������������, ��� ��� ������ // �����������{FFFFFF}
����������� {ACFF36}// �����������{FFFFFF} �� ����� ��������� �������� � �� ����� �����.
 
{FFCD00}3. ������� ��������{FFFFFF}
	� ������� �������� ����� ��������� ������������ ���������, � ������� ������� �����
������������� ����� ������� �������� ��.
��������� �������:
	{ACFF36}{dialog}{FFFFFF} 		- ������ ��������� �������
	{ACFF36}[name]=�����{FFFFFF}- ��� �������. ������� ����� ����� =. ��� �� ������ ���� ����� �������
	{ACFF36}[1]=�����{FFFFFF}		- �������� ��� ������ ���������� ��������, ��� � ������� 1 - ���
������� ���������. ����� ������������� ������ ����, ������ ��������, ��������, [X], [B],
[NUMPAD1], [NUMPAD2] � �.�. ������ ��������� ������ ����� ���������� �����. ����� �����
������������� ���, ������� ����� ������������ ��� ������. 
	����� ����, ��� ������ ��� ��������, �� ��������� ������ ������� ��� ���� ���������.
	{ACFF36}����� ���������...
	{ACFF36}[2]=�����{FFFFFF}	
	{ACFF36}����� ���������...
	{ACFF36}{dialogEnd}{FFFFFF}		- ����� ��������� �������
]]
			local vt2 = [[
									{E45050}�����������:
1. ����� ������� � ��������� �������� �� �����������, �� 
������������� ��� ����������� ���������;
2. ����� ��������� ������� ������ ��������, �������� 
����������� ������ ���������;
3. ����� ������������ ��� ���� ������������� ������� 
(����������, �����������, ���� � �.�.)
			]]
			local vt3 = [[
{FFCD00}4. ������������� �����{FFFFFF}
������ ����� ����� ������� � ���� �������������� ��������� ��� � ������� �������.
���� ������������� ��� ����������������� ������ �� ��������, ������� ��� �����.
������� ��� ���� �����:
	1. �������� ���� - ����, ������� ������ �������� ���� �� ��������, ������� ���
��������� �����, ��������, {ACFF36}{myID}{FFFFFF} - ���������� ��� ������� ID.
	2. ���-������� - ����������� ����, ������� ������� �������������� ����������.
� ��� ���������:
	{ACFF36}{sleep:[�����]}{FFFFFF} - ����� ���� �������� ������� ����� ���������. 
����� ������� � �������������. ������: {ACFF36}{sleep:2000}{FFFFFF} - ����� �������� � 2 ���
1 ������� = 1000 �����������

	{ACFF36}{sex:�����1|�����2}{FFFFFF} - ���������� ����� � ����������� �� ���������� ����.
������ �������������, ���� �������� ��������� ��� ���������� �������������.
��� {6AD7F0}�����1{FFFFFF} - ��� ������� ���������, {6AD7F0}�����2{FFFFFF} - ��� �������. ����������� ������������ ������.
	������: {ACFF36}� {sex:������|������} ����.

	{ACFF36}{getNickByID:�� ������}{FFFFFF} - ��������� ��� ������ �� ��� ID.
������: �� ������� ����� {6AD7F0}Nick_Name{FFFFFF} � id - 25.
{ACFF36}{getNickByID:25}{FFFFFF} ����� - {6AD7F0}Nick Name.
			]]
			imgui.TextColoredRGB(vt1)

			imgui.BeginGroup()
				imgui.TextDisabled(u8"					������")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##dialogPar", helpd.exp, imgui.ImVec2(220, 180), 16384)
				imgui.PopStyleColor(1)
				imgui.TextDisabled(u8"��� ����������� �����������\nCtrl + C. ������� - Ctrl + V")
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginGroup()
				imgui.TextColoredRGB(vt2)
				if imgui.Button(u8"������ ������", imgui.ImVec2(150,25)) then
					imgui.OpenPopup("helpdkey")
				end
			imgui.EndGroup()
			imgui.TextColoredRGB(vt3)
			------
			if imgui.BeginPopup("helpdkey") then
				imgui.BeginChild("helpdkey", imgui.ImVec2(290,320))
					imgui.TextColoredRGB("{FFCD00}��������, ����� �����������")
					imgui.BeginGroup()
						for _,v in ipairs(helpd.key) do
							if imgui.Selectable(u8("["..v.k.."] 	-	"..v.n)) then
								setClipboardText(v.k)
							end
						end
					imgui.EndGroup()
				imgui.EndChild()
			imgui.EndPopup()
			end
		imgui.End()
	end
end



function readID()
	if #sobes.logChat ~= 0 then
		return 16384
	else 
		return 0
	end
end

function rankFix()
	if num_rank.v == 10 then
		return u8:decode(list_rank[num_rank.v+1])
	else
		return u8:decode(list_org[num_org.v+1])
	end
end

function ButtonDep(desk, bool) -- ��������� ������ ���������� ����
	local retBool = false
	if bool then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(230, 73, 45, 220):GetVec4())
		retBool = imgui.Button(desk, imgui.ImVec2(215, 25))
		imgui.PopStyleColor(1)
	elseif not bool then
		 retBool = imgui.Button(desk, imgui.ImVec2(215, 25))
	end
	return retBool
end

function sobesRP(id)
	if id == 1 then
		sobes.logChat[#sobes.logChat+1] = "{FFC000}��: {FFFFFF}�����������. ������� �������� ���������."
		sobes.player.name = sampGetPlayerNickname(tonumber(sobes.selID.v))
		sampSendChat(string.format("����������� ��� �� ������������� �, %s - %s", u8:decode(buf_nick.v), u8:decode(chgName.rank[num_rank.v+1])))
		wait(1700)
		sampSendChat("���������� ���������� ��� ����� ����������, � ������: ������� � ���.�����.")
		wait(1700)
		sampSendChat(string.format("/n ��������� RP, �������: /showpass %d; /showmc %d - � �������������� /me /do ", myid, myid))
		while true do
			wait(0)
			if sobes.player.zak ~= 0 and sobes.player.heal ~= "" then break end
			if sampIsDialogActive() then
				local dId = sampGetCurrentDialogId()
				if dId == 1234 then
					local dText = sampGetDialogText()
					if dText:find("��� � �����") and dText:find("�����������������") then
					HideDialogInTh()
					if dText:find("�����������") then sobes.player.work = "��������" else sobes.player.work = "��� ������" end
						if dText:match("���: {FFD700}(%S+)") == sobes.player.name then
							sobes.player.let = tonumber(dText:match("��� � �����: {FFD700}(%d+)"))
							sobes.player.zak = tonumber(dText:match("�����������������: {FFD700}(%d+)"))
							sampSendChat("/me "..chsex("���������", "����������").." ���������� � ��������, ����� ���� "..chsex("�����","������").." ��� �������� ��������")
							if sobes.player.let >= 3 then
								if sobes.player.zak >= 35 then
									if not dText:find("{FF6200} "..list_org_BL[num_org.v+1]) then
										table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: �������(�) �������. �� ����� �������.")
										sobes.player.bl = "�� ������(�)"
										if sobes.player.narko == 0.1 then
											sampSendChat("������, ������ ���.�����.")
											wait(1700)
											sampSendChat("/n /showmc "..myid)
										end
									else
										table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: �������(�) �������. ��������� � �� ����� ��������.")
											sampSendChat("���������, �� �� ��� �� ���������.")
											wait(1700)
											sampSendChat("�� �������� � ׸���� ������ "..u8:decode(chgName.org[num_org.v+1]))
										sobes.player.bl = list_org_BL[num_org.v+1]
									--	sobes.getStats = false
										return
									end
								else --player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0},
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: �������(�) �������. ������������ �����������������.")
										sampSendChat("���������, �� �� ��� �� ���������.")
										wait(1700)
										sampSendChat("� ��� �������� � �������.")
										wait(1700)
										sampSendChat("/n ���������� ���������������� 35+")
										wait(1700)
										sampSendChat("��������� � ��������� ���.")
								--	sobes.getStats = false
									return
								end
							else
								table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: �������(�) �������. ���� ��������� � �����.")
									sampSendChat("���������, �� �� ��� �� ���������.")
									wait(1700)
									sampSendChat("���������� ��� ������� ��������� 3 ���� � �����.")
									wait(1700)
									sampSendChat("��������� � ��������� ���.")
							--	sobes.getStats = false
								return
							end
						else
							table.insert(sobes.logChat, "{E74E28}[������]{FFFFFF}: ���-�� ������ ������� �������� �������.") 
						end 
					end
					if dText:find("����������������") then
						HideDialogInTh()
						if dText:match("���: (%S+)") == sobes.player.name then
							sampSendChat("/me "..chsex("���������", "����������").." ���������� � ���.�����, ����� ���� "..chsex("�����","������").." ��� �������� ��������")
							sobes.player.narko = tonumber(dText:match("����������������: (%d+)"));
							if dText:find("��������� ��������") then
								if sobes.player.narko == 0 then
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: �������(�) ���.�����. �� � �������.")
									sobes.player.heal = "������"
									if sobes.player.zak == 0 then
											sampSendChat("������, ������ �������.")
											wait(1700)
											sampSendChat("/n /showpass "..myid)
									end
								else
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: �������(�) ���.�����. ����� ����������������.")
									sobes.player.heal = "������"
									if sobes.player.zak == 0 then
										sampSendChat("������, ��� ������� ����������.")
										wait(1700)
										sampSendChat("/n /showpass "..myid)
									end
									-- sampSendChat("���������, �� �� ������ ����������������.")
									-- wait(1700)
									-- sampSendChat("�� ������ ���������� �� ����� ��� ������ � ��������� ���.")
									--	sobes.getStats = false
									--	return
								end
							else 
								table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: �������(�) ���.�����. �� ������.")
								sampSendChat("���������, �� � ��� �������� �� ���������.")
								wait(1700)
								sampSendChat("� ��� �������� �� ���������. ������� ����������� �����������.")
								sobes.player.heal = "������� ����������"
								--	sobes.getStats = false
								--	return
							end
						else
							table.insert(sobes.logChat, "{E74E28}[������]{FFFFFF}: ���-�� ������ ������� �������� ���.�����.") 
						end 
					end
				end
			end
		end
		table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}�������� ���������� ���������.")
		wait(1700)
		if sobes.player.work == "��� ������" then
			sampSendChat("�������, � ��� �� � ������� � �����������.")
			sobes.nextQ = true
			return
		else
			sampSendChat("�������, � ��� �� � ������� � �����������.")
			wait(2000)
			sampSendChat("�� �� ��������� �� ������ ��������������� ������, ��������� �������� ����� ������ ������������.")
			wait(2000)
			sampSendChat("/n ��������� �� ������, � ������� �� ������ ��������")
			wait(2000)
			sampSendChat("/n ��������� � ������� ������� /out ��� ������ Titan VIP ��� ��������� � �����.")
			sobes.nextQ = true
			return
		end
	end
	if id == 2 then
		sampSendChat("������ � ����� ��� ��������� ��������.")
		wait(1700)
		table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: � ����� ����� �� ������ ���������� � ��� � ��������?.")
		sampSendChat("� ����� ����� �� ������ ���������� � ��� � ��������?")
	end
	if id == 3 then
		table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}������: ���� �� � ��� ����.����� \"Discord\"?.")
		sampSendChat("���� �� � ��� ����.����� \"Discord\"?.")
	end
	if id == 4 then
	table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}�������� ������...")
	sampSendChat("�������, �� ������� � ��� �� ������.")
	sobes.nextQ = false
		if num_rank.v+1 <= 8 then
			wait(1700)
			sampSendChat("���������, ����������, � ���.�������� ����� ��� �������� �����")
			table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}���������� ������ � �����������.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.logChat = {}
			sobes.nextQ = false
			sobes.num = 0
		else
			wait(1700)
			sampSendChat("������ � ����� ��� ����� �� �������� � ������ � ������� ������.")
			wait(1700)
			sampSendChat("/do � ������� ������ ��������� ����� �����������.")
			wait(1700)
			sampSendChat("/me ����������� �� ���������� ������ ������, "..chsex("������","�������").." ������ ����.")
			wait(1700)
			sampSendChat("/me �������".. chsex("", "�") .." ���� �� �������� �"..sobes.selID.v.." � ������ ������� �������� ��������.")
			wait(1700)
			sampSendChat("/invite "..sobes.selID.v)
			wait(1700)
			sampSendChat("/r ���������� � ���������� ������� �"..sobes.selID.v.." ���� ������ ����� � ������� � ���������.")
			table.insert(sobes.logChat, "{FFC000}��: {FFFFFF}���������� ������ � �����������.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.logChat = {}
			sobes.nextQ = false
			sobes.num = 0
		end
	end
	if id == 5 then
		wait(1000)
		sampSendChat("���������, �� � ��� ��������� � ��������")
		wait(1700)
		sampSendChat("/n ����� ��� ��� ������ �������.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 6 then
		wait(1000)
		sampSendChat("���������, �� ��������� ��������� � ����� ��� ������� 3 ����.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 7 then --sampSendChat("")
		wait(1000)
		sampSendChat("���������, �� � ��� �������� � �������.")
		wait(1700)
		sampSendChat("/n ��������� ������� 35 �����������������.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 8 then
		wait(1000)
		sampSendChat("���������, �� ��������� �� ������ ��������������� ������.")
		wait(1700)
		sampSendChat("/n ��������� �� ������, � ������� �� ������ ��������")
		wait(1700)
		sampSendChat("/n ��������� � ������� ������� /out ��� ������ Titan VIP ��� ��������� � �����.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 9 then
		wait(1000)
		sampSendChat("���������, �� �� �������� � ������ ������ ����� ��������.")
		wait(1700)
		sampSendChat("/n ��� ��������� �� �� ��������� �������� ������ �� ������ � ������� ���.�����.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 10 then
		wait(1000)
		sampSendChat("���������, �� � ��� �������� �� ���������.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 11 then
		wait(1000)
		sampSendChat("���������, �� � ��� ������� ����������������.")
		wait(1700)
		sampSendChat("��� ������� ����� ������ ������ �������� � �������� ��� ���������� � ���.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
end

function HideDialogInTh(bool)
	repeat wait(0) until sampIsDialogActive()
	while sampIsDialogActive() do
		local memory = require 'memory'
		memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
		sampToggleCursor(bool)
	end
end

function ShowHelpMarker(stext)
	imgui.TextDisabled(u8"(?)")
	if imgui.IsItemHovered() then
	imgui.SetTooltip(stext)
	end
end


function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or mainWin.v and editKey then
		return false
	end
end


function onHotKeyCMD(id, keys)
	if thread:status() == "dead" then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(cmdBind) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				if k == 1 then
					mainWin.v = not mainWin.v
				elseif k == 2 then
					sampSetChatInputEnabled(true)
					if buf_teg.v ~= "" then
						sampSetChatInputText("/r "..u8:decode(buf_teg.v)..": ")
					else
						sampSetChatInputText("/r ")
					end
				elseif k == 3 then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/rb ")
				elseif k == 4 then
					sampSendChat("/members")
				elseif k == 5 then
					if resTarg then
						funCMD.lec(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/hl ")
					end
				elseif k == 6 then --����
					funCMD.post()
				elseif k == 7 then
					if resTarg then
						funCMD.med(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/mc ")
					end
				elseif k == 8 then
					if resTarg then
						funCMD.narko(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/narko ")
					end
				elseif k == 9 then
					if resTarg then
						funCMD.rec(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/rec ")
					end
				elseif k == 10 then
					funCMD.osm()
				elseif k == 11 then -- ���
					depWin.v = not depWin.v
				elseif k == 12 then -- ���
					sobWin.v = not sobWin.v
				elseif k == 13 then 
					if resTarg then
						funCMD.tatu(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/tatu ")
					end
				elseif k == 14 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+warn "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+warn ")
					end
				elseif k == 15 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-warn "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-warn ")
					end
				elseif k == 16 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+mute "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+mute ")
					end
				elseif k == 17 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-mute "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-mute ")
					end
				elseif k == 18 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/gr "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/gr ")
					end
				elseif k == 19 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/inv "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/inv ")
					end
				elseif k == 20 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/unv "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/unv ")
					end
				elseif k == 21 then
					funCMD.time()
				elseif k == 22 then
					if resTarg then
						funCMD.expel(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/exp ")
					end
				end
				
			end
		end
	else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
	end
end

local function strBinderTable(dir)
	local tb = {
		vars = {},
		bind = {},
		debug = {
			file = true,
			close = {}
		},
		sleep = 1000
	}
	if doesFileExist(dir) then
		local l = {{},{},{},{},{}}
		local f1 = io.open(dir)
		local t = {}
		local ln = 0
		for line in f1:lines() do
			if line:find("^//.*$") then
				line = ""
			elseif line:find("//.*$") then
				line = line:match("(.*)//")
			end
			ln = ln + 1
			if #t > 0 then
				if line:find("%[name%]=(.*)$") then
					t[#t].name = line:match("%[name%]=(.*)$")
				elseif line:find("%[[%a%d]+%]=(.*)$") then
					local k, n = line:match("%[([%d%a]+)%]=(.*)$")
					local nk = vkeys["VK_"..k:upper()]
					if nk then
						local a = {n = n, k = nk, kn = k:upper(), t = {}}
						table.insert(t[#t].var, a)
					end
				elseif line:find("{dialogEnd}") then
					if #t > 1 then
						local a = #t[#t-1].var
						table.insert(t[#t-1].var[a].t, t[#t])
						t[#t] = nil
					elseif #t == 1 then
						table.insert(tb.bind, t[1])
						t = {}
					end
					table.remove(tb.debug.close)
				elseif line:find("{dialog}") then
					local b = {}
					b.name = ""
					b.var = {}
					table.insert(tb.debug.close, ln)
					table.insert(t, b)
				elseif #line > 0 and #t[#t].var > 0 then --not line:find("#[%d%a]+=.*$") and 
					local a = #t[#t].var
					table.insert(t[#t].var[a].t, line)
				end
			else
				if line:find("{dialog}") and #t == 0 then
					local b = {} 
					b.name = ""
					b.var = {}
					table.insert(t, b)
					table.insert(tb.debug.close, ln)
				end
				if #tb.debug.close == 0 and #line > 0 then --and not line:find("^#[%d%a]+=.*$") 
					table.insert(tb.bind, line)
				end
			end
		end
		f1:close()
		return tb
	else
		tb.debug.file = false
		return tb
	end 
end

local function playBind(tb)
	if not tb.debug.file or #tb.debug.close > 0 then
		if not tb.debug.file then
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ���� � ������� ����� �� ���������. ", 0xEE4848)
		elseif #tb.debug.close > 0 then
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������, ������ �������� �������� ������ �"..tb.debug.close[#tb.debug.close]..", �� ������ ����� {dialogEnd}", 0xEE4848)
		end
		addOneOffSound(0, 0, 0, 1058)
		return false
	end
	function pairsT(t, var)
		for i, line in ipairs(t) do
			if type(line) == "table" then
				renderT(line, var)
			else
				if line:find("{pause}") then
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������")
					while true do
						wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "��������...\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
							if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
						end
					end
				elseif line:find("{sleep:%d+}") then
					btime = tonumber(line:match("{sleep:(%d+)}"))
				elseif line:find("^%#[%d%a]+=.*$") then
					local var, val = line:match("^%#([%d%a]+)=(.*)$")
					tb.vars[var] = tags(val)			
				else
					wait(i == 1 and 0 or btime or tb.sleep*1000)
					btime = nil
					local str = line
					if var then
						for k,v in pairs(var) do
							str = str:gsub("#"..k, v)
						end
					end
					sampProcessChatInput(tags(str))
				end
			end
		end
	end
	function renderT(t, var)
		local render = true
		local len = renderGetFontDrawTextLength(font, t.name)
		for i,v in ipairs(t.var) do
			local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
			if len < renderGetFontDrawTextLength(font, str) then
				len = renderGetFontDrawTextLength(font, str)
			end
		end
		repeat
			wait(0)
			if not isGamePaused() then
				renderFontDrawText(font, t.name, sx-10-len, sy-#t.var*25-30, 0xFFFFFFFF)
				for i,v in ipairs(t.var) do
					local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
					renderFontDrawText(font, str, sx-10-len, sy-#t.var*25-30+(25*i), 0xFFFFFFFF)
					if isKeyJustPressed(v.k) and not sampIsChatInputActive() and not sampIsDialogActive() then
						pairsT(v.t, var)
						render = false
					end
				end
			end
		until not render						
	end					
	pairsT(tb.bind, tb.vars)
end

function onHotKeyBIND(id, keys)
	if thread:status() == "dead" then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(binder.list) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				thread = lua_thread.create(function()		
					local dir = dirml.."/MedicalHelper/Binder/bind-"..v.name..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = v.sleep
					playBind(tb)
					return
				end)
			end
		end
	end
end


function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	
	render_text(string)
end

function imgui.GetMaxWidthByText(text)
	local max = imgui.GetWindowWidth()
	for w in text:gmatch('[^\r\n]+') do
		local size = imgui.CalcTextSize(w)
		if size.x > max then max = size.x end
	end
	return max - 15
end


function getSpurFile()
	spur.list = {}
    local search, name = findFirstFile("moonloader/MedicalHelper/���������/*.txt")
	while search do
		if not name then findClose(search) else
			table.insert(spur.list, tostring(name:gsub(".txt", "")))
			name = findNextFile(search)
			if name == nil then
				findClose(search)
				break
			end
		end
	end
end


function getGovFile()
local govls = [[
/gov [�������� ��] - ��.������ �����, ������� � �������� �� ������ ���� �������� ������
/gov [�������� ��] - � ��� �� ��������: ������ �����������, ������� ��������� ����, ������� ��������
/gov [�������� ��] - ��� ���� �������� � ���� �������� ��.
]]
local govsf = [[
/gov [�������� ��] - ��.������ �����, ������� � �������� �� ������ ���� �������� ������
/gov [�������� ��] - � ��� �� ��������: ������ �����������, ������� ��������� ����, ������� ��������
/gov [�������� ��] - ��� ���� �������� � ���� �������� ��.
]]
local govlv = [[
/gov [�������� ��] - ��.������ �����, ������� � �������� �� ������ ���� �������� ������
/gov [�������� ��] - � ��� �� ��������: ������ �����������, ������� ��������� ����, ������� ��������
/gov [�������� ��] - ��� ���� �������� � ���� �������� ��.
]]
lua_thread.create(function()
	if doesDirectoryExist(dirml.."/MedicalHelper/�����������/") then
		if doesFileExist(dirml.."/MedicalHelper/�����������/���� �������� ������.txt") or not doesFileExist(dirml.."/MedicalHelper/�����������/���� �������� ������ ����.txt") then
			os.remove(dirml.."/MedicalHelper/�����������/���� �������� ������.txt")
			local f = io.open(dirml.."/MedicalHelper/�����������/���� �������� ������ ����.txt", "w")
			f:write(govls)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/�����������/���� �������� ������ ����.txt", "w")
			f:write(govsf)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/�����������/���� �������� ������ ����.txt", "w")
			f:write(govlv)
			f:flush()
			f:close()
		end
		dep.news = {}
		local search, name = findFirstFile("moonloader/MedicalHelper/�����������/*.txt")
		while search do
			if not name then findClose(search) else
				table.insert(dep.news, u8(tostring(name:gsub(".txt", ""))))
				name = findNextFile(search)
				if name == nil then
					findClose(search)
					break
				end
			end
		end
	end
end)
end

-- function onScriptTerminate(scr)
-- 	print("{00FF00}������ �������� ������.")
-- 	--[[
-- 	if scr == thisScript() then
		
-- 			setting.nick = u8:decode(buf_nick.v)
-- 			setting.teg = u8:decode(buf_teg.v)
-- 			setting.org = num_org.v
-- 			setting.sex = num_sex.v
-- 			setting.rank = num_rank.v
-- 			setting.time = cb_time.v
-- 			setting.timeTx = u8:decode(buf_time.v)
-- 			setting.timeDo = cb_timeDo.v
-- 			setting.rac = cb_rac.v
-- 			setting.racTx = u8:decode(buf_rac.v)
-- 			setting.lec = buf_lec.v
-- 			setting.med = buf_med.v
-- 			setting.upmed = buf_upmed.v
-- 			setting.rec = buf_rec.v
-- 			setting.narko = buf_narko.v
-- 			setting.tatu = buf_tatu.v
-- 			setting.chat1 = cb_chat1.v
-- 			setting.chat2 = cb_chat2.v
-- 			setting.chat3 = cb_chat3.v
-- 			setting.chathud = cb_hud.v
-- 			setting.setver = setver
-- 		local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
-- 		f:write(encodeJson(setting))
-- 		f:flush()
-- 		f:close()
-- 	end
-- 	]]
-- end

function filter(mode, filderChar)
	local function locfil(data)
		if mode == 0 then --
			if string.char(data.EventChar):find(filderChar) then 
				return true
			end
		elseif mode == 1 then
			if not string.char(data.EventChar):find(filderChar) then 
				return true
			end
		end
	end 
	
	local cbFilter = imgui.ImCallback(locfil)
	return cbFilter
end


function tags(par)
		par = par:gsub("{myID}", tostring(myid))
		par = par:gsub("{myNick}", tostring(sampGetPlayerNickname(myid):gsub("_", " ")))
		par = par:gsub("{myRusNick}", tostring(u8:decode(buf_nick.v)))
		par = par:gsub("{myHP}", tostring(getCharHealth(PLAYER_PED)))
		par = par:gsub("{myArmo}", tostring(getCharArmour(PLAYER_PED)))
		par = par:gsub("{myHosp}", tostring(u8:decode(chgName.org[num_org.v+1])))
		par = par:gsub("{myHospEn}", tostring(u8:decode(list_org_en[num_org.v+1])))
		par = par:gsub("{myTag}", tostring(u8:decode(buf_teg.v))) 
		par = par:gsub("{myRank}", tostring(u8:decode(chgName.rank[num_rank.v+1])))
		par = par:gsub("{time}", tostring(os.date("%X")))
		par = par:gsub("{day}", tostring(tonumber(os.date("%d"))))
		par = par:gsub("{week}", tostring(week[tonumber(os.date("%w"))]))
		par = par:gsub("{month}", tostring(month[tonumber(os.date("%m"))]))
		
		if targID ~= nil then par = par:gsub("{target}", targID) end
		if par:find("{getNickByID:%d+}") then
			for v in par:gmatch("{getNickByID:%d+}") do
				local id = tonumber(v:match("{getNickByID:(%d+)}"))
				if sampIsPlayerConnected(id) then
					par = par:gsub(v, tostring(sampGetPlayerNickname(id))):gsub("_", " ")
				else
					sampAddChatMessage("{FFFFFF}[{EE4848}MH:������{FFFFFF}]: �������� {getNickByID:ID} �� ���� ������� ��� ������. �������� ����� �� � ����.", 0xEE4848)
					par = par:gsub(v,"")
				end
			end
		end
		if par:find("{sex:[%w%s�-��-�]*|[%w%s�-��-�]*}") then	
			for v in par:gmatch("{sex:[%w%s�-��-�]*|[%w%s�-��-�]*}") do
				local m, w = v:match("{sex:([%w%s�-��-�]*)|([%w%s�-��-�]*)}")
				if num_sex.v == 0 then
					par = par:gsub(v, m)
				else
					par = par:gsub(v, w)
				end
			end
		end
		
		if par:find("{getNickByTarget}") then
			if targID ~= nil and targID >= 0 and targID <= 1000 and sampIsPlayerConnected(targID) then
				par = par:gsub("{getNickByTarget}", tostring(sampGetPlayerNickname(targID):gsub("_", " ")))
			else
				sampAddChatMessage("{FFFFFF}[{EE4848}MH:������{FFFFFF}]: �������� {getNickByTarget} �� ���� ������� ��� ������. �������� �� �� �������� �� ������, ���� �� �� � ����.", 0xEE4848)
				par = par:gsub("{getNickByTarget}", tostring(""))
			end
		end
	return par
end


funCMD = {} 
function funCMD.del()
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: �� ������� ������� ������.", 0xEE4848)
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: �������� ������� �� ����...", 0xEE4848)
	os.remove(scr.path)
	scr:reload()
end

function funCMD.cure(id)
	if thread:status() ~= "dead" then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return
	end
	---1758.8267822266   -2020.3171386719   1500.7852783203
	---1785.8004150391   -1995.7534179688   1500.7852783203
	if not u8:decode(buf_nick.v):find("[�-��-�]+%s[�-��-�]+") then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ���������-��, ������� ����� ��������� ������� ����������. {90E04E}/mh > ��������� > �������� ����������", 0xEE4848)
		return
	end
	if id:find("%d+") then
		thread = lua_thread.create(function()
			sampSendChat("/todo ���-�� ��� ������ �����*������ ����������� ����� � �����.")
			wait(1000)
			sampSendChat("/me ������ ����������� ����� ����� �������������.")
			wait(1000)
			sampSendChat("/do ���. ����� �� �����.")
			wait(1000)
			sampSendChat("/me ����������� ��� �����, ����� ����������� ����� �� ������ �������.")
			wait(1000)
			sampSendChat("/do ����� �����������.")
			wait(1000)
			sampSendChat("/me �������� �������� ������ ������, ����� �� ������� �������� �����.")
			wait(1000)
			sampSendChat("/do ������ ��������� ����� ������ �������� �������� ������.")
			wait(100)
			sampSendChat("/cure "..id)

		end)
	else
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /cr [id ������].", 0xEE4848)
	end
end

function funCMD.lec(id)
	if thread:status() ~= "dead" then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return
	end
	---1758.8267822266   -2020.3171386719   1500.7852783203
	---1785.8004150391   -1995.7534179688   1500.7852783203
	if not u8:decode(buf_nick.v):find("[�-��-�]+%s[�-��-�]+") then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ���������-��, ������� ����� ��������� ������� ����������. {90E04E}/mh > ��������� > �������� ����������", 0xEE4848)
		return
	end
	if id:find("%d+") then
		thread = lua_thread.create(function()
			if not isCharInModel(PLAYER_PED, 416) then
				sampSendChat(string.format("������������. �, %s, ��������� ������� ������������ ������, ��� ��� ���������?", u8:decode(buf_nick.v)))
				wait(1000)
					sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� ��  {23E64A}Enter{FFFFFF} ��� �����������.", 0xEE4848)
					addOneOffSound(0, 0, 0, 1058)
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������")
					while true do
						wait(0)
						renderFontDrawText(font, "�������: {8ABCFA}����� ��������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat(chsex("/me ������ ������ ����� � ������, ������� ������ ������� � �����", "/me ������ ������ ����� � ������, �������� ������ ������� � �����"))
				wait(2000)
				sampSendChat(chsex("/todo ������, �����, ������ ���������*��������� � �������, ��� ��������� ���������", "/todo ������, ������, ������ ���������*��������� � �������, ��� ��������� ���������"))
				wait(2000)
				sampSendChat("/do �������� ����� ����� �� ����� ������ ����.")
				wait(2000)
				sampSendChat(chsex("/me ����������� ���������� ������� ���������", "/me ����������� ���������� �������� ���������"))
				wait(2000)
				sampSendChat("/do ��������� � ����� ����.")
				wait(2000)
				sampSendChat("/todo ���, �������*��������� ��������� �������� ��������")
				wait(2000)
				sampSendChat("���������� ��� ��������, � ����� ��������� ����� ��� ������ �����")
				wait(100)
				sampSendChat("/heal "..id)
			elseif isCharInModel(PLAYER_PED, 416) then
				sampSendChat("������������, ��� � ���� ���������?")
				wait(2000)
				sampSendChat("/do ����������� ����� ����� �����.")
				wait(2000)
				sampSendChat(chsex("/me ������ ����� ���������� ����������� ����� � ������ ������ ���������", "/me ������ ����� ����������� ����������� ����� � ������� ������ ���������"))
				wait(2000)
				sampSendChat(chsex("/me �������� ��������� ��������", "/me ��������� ��������� ��������"))
				wait(100)
				sampSendChat("/heal "..id)
			end
		end)
	else
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /hl [id ������].", 0xEE4848)
	end
end
function funCMD.med(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if not u8:decode(buf_nick.v):find("[�-��-�]+%s[�-��-�]+") then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ���������-��, ������� ����� ��������� ������� ����������. {90E04E}/mh > ��������� > �������� ����������", 0xEE4848)
		return
	end
	if id:find("%d+") then
		local id = id:match("(%d+)")
	thread = lua_thread.create(function()
		--[[
			sampSendChat("������������, �� ������� �������� ����������� �����?")
			wait(3000)
			sampSendChat("������������ ���������� ��� ������� ��� ����������� ����������.")		
			
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� �� ����� ������� ������ ��� ������ ���� ���.������.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: \n{FFFFFF}[{67E56F}1{FFFFFF}] - ������ �����\n[{67E56F}2{FFFFFF}] - ����������", sx/5*4, sy-100, 0xFFFFFFFF)
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then 
						sampSendChat("������, � ��� "..chsex("�����","������")..". ��� ����� �������� ����� ���.�����.")
						wait(2200)
						sampSendChat("��� ���������� ����� ���������� ��������� ���.������� � ������� "..buf_med.v.."$, ����� ���� �� ���������.")
						wait(2000)
						sampSendChat("/n �������� � ������� ������� /pay ��� /trade")
						break 
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then 
						sampSendChat("������, � ��� "..chsex("�����","������")..". ��� ����� �������� ������ � ���.�����.")
						wait(2200)
						sampSendChat("��� ���������� ����� ���������� ��������� ���.������� � ������� "..buf_upmed.v.."$, ����� ���� �� ���������.")
						wait(2000)
						sampSendChat("/n �������� � ������� ������� /pay ��� /trade")
						break 
					end
				end
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� �� {23E64A}Enter{FFFFFF} ��� �����������.", 0xEE4848)
			addOneOffSound(0, 0, 0, 1058)
			while true do
				wait(0)
				renderFontDrawText(font, "������ ���.�����: {8ABCFA}������ ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx/5*4, sy-50, 0xFFFFFFFF)
				if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
			end
				sampSendChat("/todo ���������, ���*���� ������� � ����� ����")
				wait(1750)
				sampSendChat("/do ������� � ����� ����.")
				wait(1750)
				sampSendChat("�� ����������, ����� � ��� ��� �����!")
				wait(1750)
				sampSendChat(chsex("/me ������� ������� �� ����", "/me �������� ������� �� ����"))
				wait(1750)
				sampSendChat("/do ������� ����� �� �����.")
				wait(1750)
				sampSendChat(chsex("/me ������� � ����� � ��� �� ����", "/me ������� � ����� � ���� �� ����"))
				wait(1750)
				sampSendChat(chsex("/me ���������� ������ ����� ������� � ���� � ������ ���", "/me ����������� ������ ����� ������� � ���� � ������� ���"))
				wait(1750)
				sampSendChat("/do ������� ������.")
				wait(1750)
				sampSendChat("/do ����� ����� � ������ �������.")
				wait(1750)
				sampSendChat(chsex("/me ������� ��������� ����� ���� ������� ����� �� �������", "/me ������� ��������� ����� ���� �������� ����� �� �������"))
				wait(1750)
				sampSendChat("/do ����� � ����� ����.")
				wait(1750)
				sampSendChat("/do ������ ������ ��� ���������� ����� �� �����.")
				wait(1750)
				sampSendChat(chsex("/me ������� ��������� ������ ���� ���������� ������ ������ � ����", "/me ������� ��������� ������ ���� ����������� ������ ������ � ����"))
				wait(1750)
				sampSendChat(chsex("/me ����� ������������ ������ � �������� �� ������", "/me ������ ������������ ������ � �������� �� ������"))
				wait(1750)
				sampSendChat("/do ������ � �������� ���������� �� ������.")
				wait(1750)
				sampSendChat("������ �� �������� ����?")
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� ��  {23E64A}Enter{FFFFFF} ��� �����������.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}��������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx/5*4, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
				sampSendChat(chsex("/me ������� � �����", "/me �������� � �����"))
				wait(1700)
				sampSendChat("������, ������ ��������� ���� �� �������.")
				wait(1700)
				
				local test = {
				[1] = "���������� ��������, �� ��� �� ����� � �������, ��� ����� ���. ���� ��������?",
				[2] = "��� �� ������ ������, ���� �� ������� �������� �������� �� �����?",
				[3] = "���� ��������, ���� �� ������� ����� �� ������?"
				}
				math.randomseed(os.time())
				local idp = math.random(1, 3)
				sampSendChat(test[idp])
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� �� ����� ������� ������ ����� ������ ��������.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local diag = 0
				local time = 0
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}����. ���������\n{FFFFFF}[{67E56F}1{FFFFFF}] - ��������\n[{67E56F}2{FFFFFF}] - ������� ����������\n[{67E56F}3{FFFFFF}] - ����. ��������", sx/5*4, sy-100, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then diag = 3; break end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then diag = 2; break end
					if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then diag = 1; break end
				end 
				wait(200)
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}���� ���.�����\n{FFFFFF}[{67E56F}1{FFFFFF}] - 7 ����\n[{67E56F}2{FFFFFF}] - 14 �혘�\n[{67E56F}3{FFFFFF}] - 30 ����\n[{67E56F}4{FFFFFF}] - 60 ���嘘", sx/5*4, sy-120, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then time = 0; break end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then time = 1; break end
					if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then time = 2; break end
					if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() then time = 3; break end
				end
					wait(1700)
						if diag == 3 then
							sampSendChat(chsex("/me �������� ������ '�����c��� ������(��)'", "/me ��������� ������ '�����c��� ������(��)'"))
						elseif diag == 2 then
							sampSendChat(chsex("/me �������� ������ '����������� ����������'", "/me ��������� ������ '����������� ����������'"))
						elseif diag == 1 then
							sampSendChat(chsex("/me �������� ������ '���������� �� ������(��)'", "/me ��������� ������ '���������� �� ������(��)'"))
						end
					wait(1700)
					sampSendChat(chsex("/me ���� � ����� ���� ���. �����, � ������� � ������", "/me ����� � ����� ���� ���.�����, � ������� � ������"))
					wait(1700)
					sampSendChat("/do ���.����� � ������� � �����.")
					wait(1700)
					sampSendChat("/todo �� �������, ����� �������*��������� ���.����� � �������")
					wait(500)
					sampSendChat("/medcard "..id.." "..diag.." "..time)
					statusMed = 0
		]]	
		local dir = dirml.."/MedicalHelper/rp-medcard.txt"	
		local tb = {}
		tb = strBinderTable(dir)
		tb.sleep = 1.85
		tb.vars["playerID"] = id
		playBind(tb)		
	end)
	else
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� �������: /mc [id ������].", 0xEE4848)
	end

end
function funCMD.narko(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
		if id:find("(%d+)") then
			thread = lua_thread.create(function()
				sampSendChat(string.format("������������. �, %s, ��������� ������� ������������ ������.", u8:decode(buf_nick.v)))
				wait(2000)
				sampSendChat("�, ������, �� ������ ���������� �� ����������������, ��� ������")
				wait(2000)
				sampSendChat("��������� ������ ���������� "..buf_narko.v.."$, �� ��������?")
				wait(2000)
				sampSendChat("/n ���������� �� ���������, ������ ��� ���������")
				wait(500)
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� �� {23E64A}Enter{FFFFFF} ��� �����������.", 0xEE4848)
					while true do
					wait(0)
						renderFontDrawText(font, "������� ��������-��: {8ABCFA}����������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx/5*4, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end				
				sampSendChat("���� �� ��������, �������� �� ������� � ��������� �����")
				wait(2000)
				sampSendChat("/do �� ����� ����� �����, ���� � ����� � ��������.")
				wait(2000)
				sampSendChat("/me ".. chsex("����", "�����") .." �� ����� ����")
				wait(2000)
				sampSendChat("/me ".. chsex("�������", "��������") .." ���� �� ����� ��������")
				wait(2000)
				sampSendChat("/do ���� ������ �������.")
				wait(2000)
				sampSendChat("��������� �������.")
				wait(2000)
				sampSendChat("/me ".. chsex("����", "�����") .." ����� � ".. chsex("������", "�������") .." � �������")
				wait(2000)
				sampSendChat("/me �����".. chsex("","��") .." ������ �������� �����")
				wait(2000)
				sampSendChat("/todo �� ����������,����� �� ������*".. chsex("����", "�����") .." �� ����� ����� � ��������")
				wait(2000)
				sampSendChat("/me ������� ��������� ������ ���� ������ ����")
				wait(2000)
				sampProcessChatInput("/healbad "..id:match("(%d+)"))
				wait(2000)
				sampSendChat("/todo ������� �����*������� ����� �� ����� �����")
				wait(2000)
				sampSendChat("/me ".. chsex("����", "�����") .." ���� � �������".. chsex("", "�") .." ��� �� ����")
				wait(2000)
				sampSendChat("/me �������".. chsex("", "�") .." ����� � ����������� ����")
				wait(2000)
				sampSendChat("����� ��� �������.")
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /narko [id ������].", 0xEE4848)
		end
end
function funCMD.rec(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
		if id:find("(%d+)") then
			thread = lua_thread.create(function()
				local countRec = 1
				sampSendChat("������������, ��� ����� ������?")
				wait(2000)
				sampSendChat("������, ��������� ������ ������� "..buf_rec.v.."$.")
				wait(2000)
				sampSendChat("������� ������� ��� ��������� ��������, ����� ���� �� ���������.")
				wait(2000)
				sampSendChat("/n ��������! � ������� ���� ������� �������� 5 �������� �� ����.")
				wait(500)
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� �� ����� ������� �������� ������ ������ ���������� ���������� ��������.", 0xEE4848)
				local len = renderGetFontDrawTextLength(font, "������ ��������: {8ABCFA}����� ���-��")
					while true do
					wait(0)
						renderFontDrawText(font, "������ ��������: {8ABCFA}����� ���-��\n{FFFFFF}[{67E56F}1{FFFFFF}] - 1 ��.\n{FFFFFF}[{67E56F}2{FFFFFF}] - 2 ��.\n{FFFFFF}[{67E56F}3{FFFFFF}] - 3 ��.\n{FFFFFF}[{67E56F}4{FFFFFF}] - 4 ��.\n{FFFFFF}[{67E56F}5{FFFFFF}] - 5 ��.", sx-len-10, sy-150, 0xFFFFFFFF)					
						if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =1; break end
						if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =2; break end
						if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =3; break end
						if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =4; break end
						if isKeyJustPressed(VK_5) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =5; break end
					end
				wait(200)
				sampSendChat("/do �� ����� ����� ���. �����.")
				wait(1700)
				sampSendChat("/me ����".. chsex("", "�") .." ���. ����� � �����, ����� ���� ������".. chsex("", "�") .." ��")
				wait(2000)
				sampSendChat("/me "..chsex("������","�������").." ������")
				wait(2000)
				sampSendChat("/me ��������� ������ �� ���������� ��������")
				wait(2000)
				sampSendChat("/do ������ ���������.")
				wait(2000)
				sampSendChat("/me ��������".. chsex("", "�") .." ������ "..u8:decode(chgName.org[num_org.v+1]))
				wait(2000)
				sampSendChat("/me "..chsex("�������","��������").." ������")
				wait(2000)
				sampSendChat("/me ������".. chsex("", "�") .." ���. �����")
				wait(2000)
				sampSendChat("/me "..chsex("�������","��������").." ���. ����� �� �����")
				wait(2000)
				sampSendChat("/do ���. ����� �� �����.")
				wait(2000)
				sampSendChat("��� ���� �������, ����� �������.")
				wait(1000)
				sampSendChat("/recept "..id.." "..countRec)
				countRec = 1
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /rec [id ������].", 0xEE4848)
		end
end
function funCMD.post(stat)
	if not u8:decode(buf_nick.v):find("[�-��-�]+%s[�-��-�]+") then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ���������-��, ������� ����� ��������� ������� ����������. {90E04E}/mh > ��������� > �������� ����������", 0xEE4848)
		return
	end
	if not isCharInModel(PLAYER_PED, 416) then -- not
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����� ��������� �� ��������� ����, ��� ���������� ������� ����� � ������.", 0xEE4848)
		addOneOffSound(0, 0, 0, 1058)
	else
		local bool, post, coord = postGet()
		if not bool then
			sampShowDialog(2001, ">{FFB300}�����", "                             {55BBFF}�������� ����\n"..table.concat(post, "\n"), "{69FF5C}�������", "{FF5C5C}������", 5)
			sampSetDialogClientside(false)
		elseif bool then
			if stat:find(".+") then
				sampSendChat(string.format("/r �����������: %s. �������� �� ����� %s, ����������: %s", u8:decode(buf_nick.v):gsub("%X+%s", ""), post, stat))
			else
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� ����������, ��������, /post ��������.", 0xEE4848)
			end
		end
	end
end
function funCMD.tatu(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
		if id:find("(%d+)") then
			thread = lua_thread.create(function()
				sampSendChat("������ ����. �� �� ������ �������� ����������?")
				wait(3000)
				sampSendChat("�������� ��� �������, ����������.")
				wait(1000)
					addOneOffSound(0, 0, 0, 1058)
					sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� ������ ������������� ���������, ����� ���� ����������� ������..", 0xEE4848)
					repeat wait(0) until sampIsDialogActive()
					while sampIsDialogActive() do
						local memory = require 'memory'
						memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
						sampToggleCursor(bool)
					end
				sampSendChat("/me "..chsex("������","�������").." � ��� ������������� �������")
				wait(2000)
				sampSendChat("/do ������� ������������� � ������ ����.")
				wait(2000)
				sampSendChat("/me ������������� � ��������� �������������, "..chsex("������","�������").." ��� �������")
				wait(2000)
				sampSendChat("��������� ��������� ���������� �������� "..buf_tatu.v.."$, �� ��������?")
				wait(2000)
				sampSendChat("/n ���������� �� ���������, ������ ��� ���������")
				wait(2000)
				sampSendChat("/b �������� ���������� � ������� ������� /showtatu")
					sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� ��  {23E64A}Enter{FFFFFF} ��� ����������� ��� {23E64A}Page Down{FFFFFF}, ����� ��������� ������.", 0xEE4848)
					addOneOffSound(0, 0, 0, 1058)
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������")
					while true do
					wait(0)
						renderFontDrawText(font, "�������� ����: {8ABCFA}����������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("� ������, �� ������, ����� �������� � ���� �������, ���� � "..chsex("�����","������").." ���� ����������.")
				wait(2000)
				sampSendChat("/do � ����� ����� ���������������� ������ � ��������.")
				wait(2000)
				sampSendChat("/do ������� ��� ��������� ���� �� �������.")
				wait(2500)
				sampSendChat("/me "..chsex("����","�����").." ������� ��� ��������� ���������� � �������")
				wait(2000)
				sampSendChat("/me �������� ��������, "..chsex("��������","���������").." �������� ��� ����������")
				wait(2000)
				sampSendChat("/unstuff "..id.." "..buf_tatu.v)
				wait(5000)
				sampSendChat("��, ��� ����� ��������. ����� ��� ��������!?")
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /tatu [id ������].", 0xEE4848)
		end	
end
function funCMD.warn(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		thread = lua_thread.create(function()
				sampSendChat("/do � ����� ������� ����� ���.")
				wait(2000)
				sampSendChat("/me ������ ��� �� ������ �������, ����� ���� ".. chsex("�����", "�����") .." � ���� ������ "..u8:decode(chgName.org[num_org.v+1]))
				wait(2000)
				sampSendChat("/me "..chsex("�������","��������").." ���������� � ����������.")
				wait(2000)
				sampSendChat(string.format("/fwarn %s %s", id, reac))
				wait(2000)
				sampSendChat("/r ���������� � ��������� �"..id.." ��� ����� ������� �� �������: "..reac)
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /+warn [id ������] [�������].", 0xEE4848)
		end
end
function funCMD.uwarn(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if id:find("(%d+)") then
		thread = lua_thread.create(function()
				sampSendChat("/do � ����� ������� ����� ���.")
				wait(2000)
				sampSendChat("/me ������ ��� �� ������ �������, ����� ���� ".. chsex("�����", "�����") .." � ���� ������ "..u8:decode(chgName.org[num_org.v+1]))
				wait(2000)
				sampSendChat("/me "..chsex("�������","��������").." ���������� � ����������.")
				wait(2000)
				sampSendChat("/unfwarn "..id)
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /-warn [id ������].", 0xEE4848)
		end
end
function funCMD.inv(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if id:find("(%d+)") then
		thread = lua_thread.create(function()
					sampSendChat("/do � ������� ������ ��������� ����� �����������.")
					wait(2000)
					sampSendChat("/me ����������� �� ���������� ������ ������, "..chsex("������","�������").." ������ ����.")
					wait(2000)
					sampSendChat("/me "..chsex("�������","��������").." ���� �� �������� �"..id.." � ������ ������� �������� ��������.")
					wait(1000)
					sampSendChat("/invite "..id)
					wait(2000)
					sampSendChat("/r ���������� � ���������� ������� �"..id.." ���� ������ ����� � ������� � ���������.")
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /inv [id ������].", 0xEE4848)
		end
end
function funCMD.unv(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		thread = lua_thread.create(function()
				sampSendChat("/do � ����� ������� ����� ���.")
				wait(2000)
				sampSendChat("/me ������ ��� �� ������ �������, ����� ���� ".. chsex("�����", "�����") .." � ���� ������ "..u8:decode(chgName.org[num_org.v+1]))
				wait(2000)
				sampSendChat("/me "..chsex("�������","��������").." ���������� � ����������.")
				wait(1700)
				sampSendChat(string.format("/uninvite %d %s", id, reac))
				wait(1200)
				sampSendChat("/r ��������� � ��������� �"..id.." ��� ������ �� �������: "..reac)
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /unv [id ������] [�������].", 0xEE4848)
		end
end
function funCMD.mute(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if text:find("(%d+)%s(%d+)%s(%X+)") then
		local id, timem, reac = text:match("(%d+)%s(%d+)%s(%X+)")
		thread = lua_thread.create(function()
					sampSendChat("/do ����� ����� �� �����.")
					wait(2000)		
					sampSendChat("/me ����".. chsex("", "�") .." ����� � �����")
					wait(2000)
					sampSendChat("/me ".. chsex("�����", "�����") .." � ��������� ��������� ������ ������� �����")
					wait(2000)					
					sampSendChat("/me ��������".. chsex("", "�") .." ��������� ������� ������� � ���������� ������� "..id)
					wait(2000)
					sampSendChat(string.format("/fmute %d %d %s", id, timem, reac))
					wait(2000)
					sampSendChat("/r ���������� � ��������� �"..id.." ���� ��������� ����� �� �������: "..reac)
					wait(2000)		
					sampSendChat("/me �������".. chsex("", "�") .." ������� ����� �� ����")
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /+mute [id ������] [����� � �������] [�������].", 0xEE4848)
		end
end
function funCMD.umute(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if id:find("(%d+)") then
		thread = lua_thread.create(function()
					sampSendChat("/do ����� ����� �� �����.")
					wait(2000)		
					sampSendChat("/me ���� ����� � �����")
					wait(2000)
					sampSendChat("/me ".. chsex("�����", "�����") .." � ��������� ��������� ������ ������� �����")
					wait(2000)					
					sampSendChat("/me ��������� ��������� ������� ������� � ���������� ������� "..id)
					wait(2000)
					sampSendChat("/funmute "..id)
					wait(2000)		
					sampSendChat("/me ������� ������� ����� �� ����")
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /-mute [id ������].", 0xEE4848)
		end
end
function funCMD.rank(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if text:find("(%d+)%s([1-9])") then
		local id, rankNum = text:match("(%d+)%s(%d)")
		local id = tonumber(id); rankNum = tonumber(rankNum);
		thread = lua_thread.create(function()
					sampSendChat("/do � ������� ������ ��������� ������ � ������� �� ��������� � ������.")
					wait(1500)
					sampSendChat(chsex("/me ����������� �� ���������� ������ ������, ������".. chsex("", "�") .." ������ ������", "/me ����������� �� ���������� ������ ������, ������� ������ ������"))
					wait(1500)
					sampSendChat(chsex("/me ������ ������, ������".. chsex("", "�") .." �� ���� ���� c ������� '"..id.."'", "/me ������ ������, ������� �� ���� ���� c ������� '"..id.."'"))
					wait(1500)
					sampSendChat(chsex("/me �������".. chsex("", "�") .." ���� �� �������� �"..id.." � ������ "..u8:decode(chgName.rank[rankNum]).."� �������� ��������", "/me �������� ���� �� �������� �"..id.." � ������ "..u8:decode(chgName.rank[rankNum]).." �������� ��������"))
					wait(1500)
					sampProcessChatInput("/giverank "..id.." "..rankNum)
					wait(1500)
					sampSendChat("/r ���������� � ��������� �"..id.." ���� ������ ����� �����.")
			end)
		else
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /gr [id ������] [����� �����].", 0xEE4848)
		end
end
function funCMD.osm()
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
		thread = lua_thread.create(function()
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������� �� {23E64A}Enter{FFFFFF}, ���� ������ ������ ������.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "������: {8ABCFA}�������� ������")
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
				sampSendChat("������������, ������ � ������� ��� ��� ��������� ���.������������.")
				wait(2000)
				sampSendChat("����������, ������������ ���� ���.�����.")
				wait(1000)
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
					
				sampSendChat("/me "..chsex("����","�����").." ���.����� �� ��� �������")
				wait(2000)
				sampSendChat("/do ���.����� � �����. ")
				wait(2000)
				sampSendChat("/do ����� � ������ � �����.")
				wait(2000)
				sampSendChat("����, ������ � ����� ��������� ������� ��� ������ ��������� ��������.")
				wait(2500)
				sampSendChat("����� �� �� ������? ���� ��, �� ������ ���������.")
				wait(1000)
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("���� �� � ��� ������?")
				wait(1000)
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
				wait(2000)
				sampSendChat("������� �� �����-�� ������������� �������?")
				wait(2000)
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
				sampSendChat("/me "..chsex("������","�������").." ������ � ���. �����")
				wait(2000)
				sampSendChat("���, �������� ���.")
				wait(2000)
				sampSendChat("/b /me ������(�) ���")
				wait(2000)
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("/do � ������� �������.")
				wait(2000)
				sampSendChat("/me "..chsex("������","�������").." ������� �� ������� � ������� ���")
				wait(2000)
				sampSendChat("/me "..chsex("��������","���������").." ����� ��������")
				wait(2000)
				sampSendChat("������ ������� ���.")
				wait(3000)
				sampSendChat("/me "..chsex("��������","���������").." ������� ������� �������� �� ����, �������� � �����")
				wait(2000)
				sampSendChat("/do ������� ���� ������������ ��������.")
				wait(2000)
				sampSendChat("/me "..chsex("��������","���������").." ������� � "..chsex("�����","������").." ��� � ������")
				wait(2000)
				sampSendChat("���������, ����������, �� �������� � ��������� �������� ������ �� ����.")
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "������: {8ABCFA}�������� ��������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-15, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("���������.")
				wait(2000)
				sampSendChat("/me "..chsex("������","�������").." ������ � ���. �����")
				wait(2000)
				sampSendChat("/me "..chsex("������","�������").." ���.����� �������� ��������")
				sampSendChat("�������, ������ ���� ��������")
		end)
end
function funCMD.hall()
	local maxIdInStream = sampGetMaxPlayerId(true)
	for i = 0, maxIdInStream do
	local result, handle = sampGetCharHandleBySampPlayerId(i)
		if result and doesCharExist(handle) then
			local px, py, pz = getCharCoordinates(playerPed)
			local pxp, pyp, pzp = getCharCoordinates(handle)
			local distance = getDistanceBetweenCoords2d(px, py, pxp, pyp)
			if distance <= 4 then
				sampSendChat("/heal "..i)
			end
		end
	end
end
function funCMD.sob()
	sobWin.v = not sobWin.v
end
function funCMD.dep()
	if num_rank.v+1 < 5 then
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	depWin.v = not depWin.v
end
function funCMD.hme()
	local _, plId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	sampSendChat("/heal "..plId)
end
function funCMD.memb()
	sampSendChat("/members")
end

function funCMD.time()
	lua_thread.create(function()
		sampSendChat("/time")
		wait(1500)
	--	mem.setint8(sampGetBase() + 0x119CBC, 1)
		setVirtualKeyDown(VK_F8, true)
		wait(20)
		setVirtualKeyDown(VK_F8, false)
	end)
end
function funCMD.expel(par)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if par:find("(%d+)%s([�-��-�%a%s]+)") then
		local id, reas = par:match("(%d+)%s([�-��-�%a%s]+)") 
		thread = lua_thread.create(function()
			sampSendChat("/me ������ ��������� ���� "..chsex("���������","����������").." �� �������� ����������")
			wait(2000)
			sampSendChat("/do ������ ������ ���������� �� ��������.")
			wait(2000)
			sampSendChat("/todo � "..chsex("��������","���������").." ������� ��� �� ������*����������� � ������.")
			wait(2000)
			sampSendChat("/me ��������� ����� ���� "..chsex("������","�������").." ������� �����, ����� ���� "..chsex("���������","����������").." ����������")
			wait(500)
			sampSendChat("/expel "..id.." "..reas)
		end)
	else
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ����������� ������� /exp [id ������] [�������].", 0xEE4848)
	end
end
		
function funCMD.openupd()
	print(shell32.ShellExecuteA(nil, 'open', "http://forum.arizona-rp.com/index.php?threads/������������-���������������-�����������-������-���-�������-medical-helper.1119179/", nil, nil, 1))
end

function funCMD.update()
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������������ ���������� ����� ������ �������...", 0xEE4848)
	local dir = dirml.."/MedicalHelper.lua"
	local url = "https://github.com/TheMrThor/MedicalHelper/blob/master/MedicalHelper.lua?raw=true"
	--local url = "https://drive.google.com/uc?export=download&id=1gph2P6bWI1NZRW6TTdtXsmJtwpIX8JaC"
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}������ ��� ������� ������� ����.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ��������� ������ ��� ���������� ����������. ��������� ��������� ���������...", 0xEE4848)
				
				updWin.v = false
				lua_thread.create(function()
					wait(500)
					funCMD.updateEr()
				end)
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			print("�������� ���������")
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ���������� ���������, ������������ ���������...", 0xEE4848)
			reloadScripts()
			showCursor(false)
		end
	end)
end

function funCMD.updateEr()
local erTx =  
[[
{FFFFFF}������, ���-�� ������ ���������� ����������.
��� ����� ���� ��� ���������, ��� � ����-�������, ������� ��������� ����������.
���� � ��� �������� ���������, ����������� ����-�������, �� ������ ���-�� ������
��������� ����������. ������� ����� ����� ������� ���� ��������.

����������, �������� ����������� ���� ������� �� ������ Arizona RP
���� ����� ����� �� ���������� ����:
{A1DF6B}forum.arizona-rp.com -> ������ 6 -> ���.�����. -> ������.�����. -> ����������� ������ ��� �������{FFFFFF}
�������� �������������� ������������.

���� �������� ���� ������� ��������. ������ ��� ���������� ��� �����������.
	1. �������� ������� � �������� ������ � �������� ������ (Ctrl + V). ��������� ����.
	2. ������� � ����� ���� � �������� ����� Moonloader.
	3. ������� ���� MedicalHelper.lua
	4. ����������� ��������� ���� � ����� Moonloader. 
	{FCB32B}5. ���������, ��� �������� �� �������� ������ ��������, �������� MedicalHelper{F65050}(1){FCB32B}.luac
]]
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ������������ ���������� ����� ������ �������...", 0xEE4848)
	local dir = dirml.."/MedicalHelper.lua"
	local url = urlupd
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}������ ��� ������� ������� ����.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ��������� ������ ��� ���������� ����������. ������, ���������� ���-�� ������.", 0xEE4848)
				sampShowDialog(2001, "{FF0000}������ ����������", erTx, "�������", "", 0)
				setClipboardText("https://github.com/TheMrThor/MedicalHelper/blob/master/MedicalHelper.lua?raw=true")
				updWin.v = false
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			print("�������� ���������")
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ���������� ���������, ������������ ���������...", 0xEE4848)
			reloadScripts()
			showCursor(false)
		end
	end)
end

function funCMD.updateCheck()
	sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: ��������� ������� ����������...", 0xEE4848)
		local dir = dirml.."/MedicalHelper/files/update.med"
		local url = "https://raw.githubusercontent.com/TheMrThor/MedicalHelper/master/update.med"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				lua_thread.create(function()
				wait(1000)
				if doesFileExist(dirml.."/MedicalHelper/files/update.med") then
					local f = io.open(dirml.."/MedicalHelper/files/update.med", "r")
					local upd = decodeJson(f:read("*a"))
					f:close()
					if type(upd) == "table" then
					newversion = upd.version
					urlupd = upd.url
						if upd.version == scr.version then
							sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: �� �������, �� ����������� ����� ����� ������ �������.", 0xEE4848)
						else
							sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: {4EEB40}������� ����������.{FFFFFF} ������ {22E9E3}/update{FFFFFF} ��� ��������� ����������.", 0xEE4848)
							wait(5000)
							updWin.v = true
						end
					end
				end

				end)
			end
		end)
		local dir = dirml.."/MedicalHelper/files/update.txt"
		local url = "https://raw.githubusercontent.com/TheMrThor/MedicalHelper/master/update.txt"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				lua_thread.create(function()
					wait(1000)
					if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
					local f = io.open(dirml.."/MedicalHelper/files/update.txt", "r")
					updinfo = f:read("*a")
					f:close()
					end
				end)
			end
		end)
end
 


function hook.onServerMessage(mesColor, mes) -- HOOK
	
	-- if mes:find("Kevin_Hatiko%[%d+%]") then
	-- 		local num, code = "", ""
	-- 		if mes:find("}#(%d+):([%X%w]+){") then
	-- 			num, code = mes:match("}#(%d+):([%X%w]+){")
	-- 		elseif mes:find("%(%( #(%d+):([%X%w]+) %)%)") then
	-- 			num, code = mes:match("%(%(%s#(%d+):([%X%w]+)%s%)%)")
	-- 		end
	-- 		local num = tonumber(num)
	-- 		if num == 0 and code == "m*" then sampSendChat("/rb ����"); print("est") end -- sampSendChat("/rb ���: 1")
	-- 		if num == 0 and code == "m" then sampSendChat("/b ����"); print("est") end -- sampSendChat("/b ���: 1")
	-- 		if num == 1 and code == "s*" then
	-- 			if doesFileExist(dirGame.."/d3d9.dll" ) then sampSendChat("/rb �3-9") end --sampSendChat("/rb ���: 1")
	-- 		elseif num == 1 and code == "s" then 
	-- 			if doesFileExist(dirGame.."/d3d9.dll" ) then sampSendChat("/b �3-9") end --sampSendChat("/b ���: 1")
	-- 		end
	-- 		if num == 2 then
	-- 		local plID, anim = code:match("(%d+)&(%d+)")
	-- 		local plID, anim = tonumber(plID), tonumber(anim)
	-- 			if plID == 0 then sampSendChat("/anims "..anim) end
	-- 			if plID > 0 then
	-- 				if myid == plID then sampSendChat("/anims "..anim) end
	-- 			end
	-- 		end
	-- 		if num == 3 then
	-- 		local plID, text = code:match("(%d+)&([%X%w%s]+)")
	-- 		local plID = tonumber(plID)
	-- 			if plID == 0 then sampSendChat(text) end
	-- 			if plID > 0 then
	-- 				if myid == plID then sampSendChat(text) end
	-- 			end
	-- 		end -- sampSendChat(code)
	-- 		if num == 4 then
	-- 			local plID = tonumber(code:match("(%d+)"))
	-- 			if plID == myid then
	-- 				if getActiveInterior() == 0 then
	-- 					local px, py, pz = getCharCoordinates(PLAYER_PED)
	-- 					local px = math.floor(px)
	-- 					local py = math.floor(py)
	-- 					local hexX = ""
	-- 					local hexY = ""
	-- 					if px > 0 then
	-- 						hexX = string.format('%03X', px)
	-- 					elseif px < 0 then
	-- 						px = px * -1
	-- 						hexX = string.format('-%03X', px)
	-- 					end
	-- 					if py > 0 then
	-- 						hexY = string.format('%03X', py)
	-- 					elseif py < 0 then
	-- 						py = py * -1
	-- 						hexY = string.format('-%03X', py)
	-- 					end
					
	-- 					sampSendChat("/r (( cd: "..hexX..", "..hexY.." ))")
	-- 				elseif getActiveInterior() > 0 then
	-- 					sampSendChat("/rb ���: "..getActiveInterior())
	-- 				end
	-- 			end
	-- 		end
	-- 		if (num ~= 0 or num ~= "") and code ~= "" then return false end
	-- end 
	
	if cb_chat2.v then
		if mes:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") or mes:find("- �������� ������� �������: /menu /help /gps /settings") or mes:find("- �������� ����� � ������ ����� � ������� $250 000!") or mes:find("- ����� � ��������� �������������� ������� arizona-rp.com/donate") or mes:find("��������� �� ����������� �������") or mes:find("����� �������, ������ �����") then 
			return false
		end
	end
	if cb_chat3.v then
		if mes:find("News LS") or mes:find("News SF") or mes:find("News LV") then 
			return false
		end
	end
	if cb_chat1.v then
		if mes:find("����������:") or mes:find("�������������� ���������") then
		return false
		end
	end
	local function stringN(str, color)
		if str:len() > 72 then
			local str1 = str:sub(1, 70)
			local str2 = str:sub(71, str:len())
			return str1.."\n".."{"..color.."}"..str2
		else 
			return str
		end
	end
	if sobes.selID.v ~= "" and sobes.player.name ~= "" then
		
		if mes:find(sobes.player.name.."%[%d+%]%s�������:") then
		addOneOffSound(0, 0, 0, 1058)
		local mesLog = mes:match("{B7AFAF}%s(.+)")
		print(mesLog)
		local mesLog = stringN(mesLog, "B7AFAF")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF} �������: {B7AFAF}"..mesLog)
		end
		
		if mes:find(sobes.player.name.."%[%d+%]%s%(%(") then
		local mesLog = mes:match("}(.+){")
		local mesLog = stringN(mesLog, "B7AFAF")
		table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF} �������: {B7AFAF}(( "..mesLog.." ))")
		end
		if mes:find(sobes.player.name.."%[%d+%]%s[%X%w]+") and mesColor == -6684673 then
			local mesLog = mes:match("%[%d+%]%s([%X%w]+)")
			local mesLog = stringN(mesLog, "F35373")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.." {F35373}[/me]: "..mesLog)
		end
		if mes:find("%-%s%|%s%s"..sobes.player.name.."%[%d+%]") then
			local mesLog = mes:match("([%X%w]+)%s%s%-%s%|%s%s"..sobes.player.name)
			local mesLog = stringN(mesLog, "2679FF")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.." {2679FF}[/do]: "..mesLog)
		end
		
	end
	if mes:find("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[[%X%a]+%].+%["..u8:decode(list_org[num_org.v+1]).."%]") then
			local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[([%X%a]+)%].+%["..u8:decode(list_org[num_org.v+1]).."%]")
		if mes:find("�����") and num_rank.v > 3 then -- rankFix()
			addOneOffSound(0, 0, 0, 1085)
			addOneOffSound(0, 0, 0, 1085)
			table.insert(dep.dlog, "{40ABF7}[D] {7ECAFF}["..org.."]: {FFFFFF}�������� �� �����!")
		end
		if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
			local mesD = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[[%X%a]+%].+%["..u8:decode(list_org[num_org.v+1]).."%]%p*(.+)")
			table.insert(dep.dlog, "{40ABF7}[D] {7ECAFF}["..org.."]: {FFFFFF}"..mesD)
		end
	elseif mes:find("%[D%] [%X%a]+ [%a_]+%[%d+%]: %["..u8:decode(list_org[num_org.v+1]).."%].+%[[%X%a]+%]") then
		if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
			local mesD = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]: %["..u8:decode(list_org[num_org.v+1]).."%].+%[[%X%a]+%]%p*(.+)")
			table.insert(dep.dlog, "{40ABF7}[D] {F55C5C}["..u8:decode(list_org[num_org.v+1]).."]: {FFFFFF}"..mesD)
		end 
	end
	if mes:find("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[[%X%a]+%].+%[������� ���������������%]") and num_rank.v == 10 then
		local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[([%X%a]+)%].+%[������� ���������������%]")
		if mes:find("�����") and num_rank.v > 3 then -- rankFix()
			addOneOffSound(0, 0, 0, 1085)
			addOneOffSound(0, 0, 0, 1085)
			table.insert(dep.dlog, "{40ABF7}[D] {7ECAFF}["..org.."]: {FFFFFF}�������� �� �����!")
		end 
		if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
			local mesD = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[[%X%a]+%].+%[������� ���������������%]%p*(.+)")
			table.insert(dep.dlog, "{40ABF7}[D] {7ECAFF}["..org.."]: {FFFFFF}"..mesD)
		end
	elseif mes:find("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[������� ���������������%].+%[[%X%a]+%]") and num_rank.v == 10 then
		if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
			local mesD = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]: %[������� ���������������%].+%[[%X%a]+%]%p*(.+)")
			table.insert(dep.dlog, "{40ABF7}[D] {F55C5C}[���.�����]: {FFFFFF}"..mesD)
		end
	end
end

function hook.onDisplayGameText(st, time, text)
	if text:find("~y~%d+ ~y~"..os.date("%B").."~n~~w~%d+:%d+~n~ ~g~ Played ~w~%d+ min") then
		if cb_time.v then
			lua_thread.create(function()
			wait(100)
			sampSendChat(u8:decode(buf_time.v))
			if cb_timeDo.v then
				wait(1000)
				sampSendChat("/do ���� ���������� ����� - "..os.date("%H:%M:%S"))
			end
			end)
		end
	end
end
function hook.onSendCommand(cmd)
	if cmd:find("/r ") then
		if cb_rac.v then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(buf_rac.v))
			end)
		end
	end
end

function hook.onSendSpawn()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = sampGetPlayerNickname(myid)
end

function hook.onSendDialogResponse(id, but, list)
	if sampGetDialogCaption() == ">{FFB300}�����" then
		if but == 1 then
			local bool, post, coord = postGet()
			placeWaypoint(coord[list+1].x, coord[list+1].y, 20)
			sampAddChatMessage("{FFFFFF}[{EE4848}MedicalHelper{FFFFFF}]: �� ����� ���� ���������� ����� ����� ����������.", 0xEE4848)
			addOneOffSound(0, 0, 0, 1058)
		elseif but == 0 then
		end
	end
end


function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}����{ffffff}"
	end
	return "{53E03D}���{ffffff}"
end
function getStrByState2(keyState)
	if keyState == 0 then
		return ""
	end
	return "{F55353}Caps{ffffff}"
end

function showInputHelp()
	local chat = sampIsChatInputActive()
	if chat == true then
		local cx, cy = getCursorPos()
		local in1 = sampGetInputInfoPtr()
		local in1 = getStructElement(in1, 0x8, 4)
		local in2 = getStructElement(in1, 0x8, 4)
		local in3 = getStructElement(in1, 0xC, 4)
		local posX = in2 + 15
		local posY = in3 + 45
		local _, pID = sampGetPlayerIdByCharHandle(playerPed)
		local Nname = sampGetPlayerNickname(pID)
		local score = sampGetPlayerScore(pID)
		local color = sampGetPlayerColor(pID)
		local ping = sampGetPlayerPing(pID)
		local capsState = ffi.C.GetKeyState(20)
		local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
		local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
		local localName = ffi.string(LocalInfo)
		local text = string.format(
			"%s | {%0.6x}%s [%d] {ffffff}| ����: {ffeeaa}%d{FFFFFF} | ����: %s {FFFFFF}| ����: {ffeeaa}%s{ffffff}",
			os.date("%H:%M:%S"), bit.band(color,0xffffff), Nname, pID, ping, getStrByState(capsState), string.match(localName, "([^%(]*)")
		)
		renderFontDrawText(textFont, text, posX, posY, 0xD7FFFFFF)
		if cx >= posX+280 and cx <= posX+280+80 and cy >= posY and cy <= posY+25 then
			if isKeyJustPressed(VK_RBUTTON) then hudPing = not hudPing end
		end
	end
end

function hudTimeF()
	local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
	local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
	local localName = ffi.string(LocalInfo)
	local capsState = ffi.C.GetKeyState(20)
	local function lang()
		local str = string.match(localName, "([^%(]*)")
		if str:find("�������") then
			return "Ru"
		elseif str:find("����������") then
			return "En"
		end
	end
	local text = string.format("%s | {ffeeaa}%s{ffffff} %s", os.date("%d ")..month[tonumber(os.date("%m"))]..os.date(" - %H:%M:%S"), lang(), getStrByState2(capsState))
	if thread:status() ~= "dead" then
		renderFontDrawText(fontPD, text, 20, sy-50, 0xFFFFFFFF)
	else
		renderFontDrawText(fontPD, text, 20, sy-25, 0xFFFFFFFF)
	end
end

function pingGraphic(posX, posY)
	
	local ping0 = posY + 150
	local time = posX - 200
	local function correct(value)
		if value == 0 then
			return 1
		else return value
		end
	end
	local function colorG(value)
		if value <= 70 then
			return 0xFF9EEFA9
		elseif value >= 71 and value <=89 then
			return 0xFFF8DE75
		elseif value >= 90 and value <= 99 then
			return 0xFFF88B75
		elseif value >= 100 then
			return 0xFFEB2700
		end
	end
			renderDrawBoxWithBorder(posX-200, posY, 400, 150, 0x50B5B5B5, 2, 0xF0838383)

			renderDrawLine(time, ping0-50, time+400, ping0-50, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-100, time+400, ping0-100, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-150, time+400, ping0-150, 1, 0x50FFFFFF)
			renderFontDrawText(fontPing, "Ping", posX-20,  posY-16, 0xAFFFFFFF)
			local maxPing = 0
			for i,v in ipairs(pingLog) do
				if maxPing < v then maxPing = v end
			end
	for i,v in ipairs(pingLog) do
		if maxPing <= 150 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)], time+10*i, ping0-v, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]-10, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/2, time+10*i, ping0-v/2, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/2-10, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/5, time+10*i, ping0-v/5, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/5-10, 0xAFFFFFFF)
		end
			
	end
		if maxPing <= 150 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 50, time-20,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 150, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 200, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 300, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 250, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 500, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 750, time-30,  ping0-160, 0xAFFFFFFF)
		end
end

function chsex(textMan, textWoman)
	if num_sex.v == 0 then
		return textMan
	else
		return textWoman
	end
end

function postGet(sel)
	local postname = {"�����","�� ������ ��","�����","�� ������ ��","���������","���������","��� ��","������ ��","�� ������ ��", "����� ��", "���", "������ ��"}
	local coord = {{},{},{},{},{},{},{},{},{}, {}, {}, {}}
	coord[1].x, coord[1].y = 1506.41, -1284.02
	coord[2].x, coord[2].y = 1827.11, -1896.01
	coord[3].x, coord[3].y = -88.35, 112.01
	coord[4].x, coord[4].y = -1998.56, 123.25
	coord[5].x, coord[5].y = -2027.53, -56.07
	coord[6].x, coord[6].y = -2115.08, -746.49
	coord[7].x, coord[7].y = 2612.48, 1163.39
	coord[8].x, coord[8].y = 2078.78, 1001.05
	coord[9].x, coord[9].y =  2825.00, 1294.61
	coord[10].x, coord[10].y = 2727, -2503.5
	coord[11].x, coord[11].y = -1347, 462.5
	coord[12].x, coord[12].y = 223, 1813.5

	if sel ~= nil and isCharInArea2d(PLAYER_PED, coord[sel].x-50, coord[sel].y-50, coord[sel].x+50, coord[sel].y+50,false) then
		local coord = {}
		coords.x, coords.y = coord[sel].x, coord[sel].y
		return true, postname, coords
	end

		if isCharInArea2d(PLAYER_PED, 1506.41-50, -1284.02-50, 1506.41+50, -1284.02+50,false) then
			local coord = {}
			coord.x, coord.y = 1506.41, -1284.02
			return true, postname[1], coord
		end
		if isCharInArea2d(PLAYER_PED, 1827.11-50, -1896.01-50, 1827.11+50, -1896.01+50,false) then
			local coord = {}
			coord.x, coord.y = 1827.11, -1896.01
			return true, postname[2], coord
		end
		if isCharInArea2d(PLAYER_PED, -88.35-50, 112.01-50, -88.35+50, 112.01+50,false) then
			local coord = {}
			coord.x, coord.y = -88.35, 112.01
			return true, postname[3], coord
		end
		if isCharInArea2d(PLAYER_PED, -1998.56-50, 123.25-50, -1998.56+50, 123.25+50,false) then
			local coord = {}
			coord.x, coord.y = -1998.56, 123.25
			return true, postname[4], coord
		end
		if isCharInArea2d(PLAYER_PED, -2027.53-50, -56.07-50, -2027.53+50, -56.07+50,false) then
			local coord = {}
			coord.x, coord.y = -2027.53, -56.07
			return true, postname[5], coord
		end
		if isCharInArea2d(PLAYER_PED, -2115.08-50, -746.49-50, -2115.08+50, -746.49+50,false) then
			local coord = {}
			coord.x, coord.y = -2115.08, -746.49
			return true, postname[6], coord
		end
		if isCharInArea2d(PLAYER_PED, 2612.48-50, 1163.39-50, 2612.48+50, 1163.39+50, false) then 
			local coord = {}
			coord.x, coord.y = 2612.48, 1163.39
			return true, postname[7], coord
		end
		if isCharInArea2d(PLAYER_PED, 2078.78-50, 1001.05-50, 2078.78+50, 1001.05+50,false) then
			local coord = {}
			coord.x, coord.y = 2078.78, 1001.05
			return true, postname[8], coord
		end
		if isCharInArea2d(PLAYER_PED, 2825.00-50, 1294.61-50, 2825.00+50, 1294.61+50,false) then
			local coord = {}
			coord.x, coord.y = 2825.00, 1294.61
			return true, postname[9], coord
		end
	return false, postname, coord
end

helpsob = [[
1. �� ������ ������ ��������� ������� ��������� id ������.
����� ���� ������ �� ������ "������". ������� ������� ��������.
�� ����� �������� �� ��������� ����� �������� ������. ��� �����
����� ��������������� ������� "����������/��������", �������
����� ��� ������� ������ � ����� ����� ��������� ����� id.

��� ������ � ���������� ��������� �������������. � ������ ������
����� ����������, ��� ����� ���������.
2. �� ��������� �������� ����������, �������� ��������� ��������.
��� ����������� �������� ���������� ������ "������ ������".
����� ������ �������������� ������ �������������� ������ ��
������� �� ������ "������������ ������".
3. ����� �������������� �������� ������������ �����.
�� ������ �������������� ������� ������� ��� ����������� ���
���������� ������ �� ������� �� ������ "���������� ��������".
]]
																								--    |
otchotTx = [[
		��� ����� ����� ������� �������� ������ {5CE9B5}forum.arizona-rp.com{FFFFFF}, ����� ���� ���� ���� ����� 
		������ ������� ��������, �� ������� ����� ������� ���, �� ������� �� ������ ����������. 
		����� �������� ������ {5CE9B5}'��������������� ���������'{FFFFFF}, ����� ������ {5CE9B5}'���. ���������������'{FFFFFF}. 
		����� ���� ����� 3 ������� �������, ��������� ���, � ����� �� �������� ����������. 
		� ���������, ������� ���� ������� �� {5CE9B5}'������ �������� �������'{FFFFFF}. ��� ��� ��������� ��������, 
		��� ���������. ����� ������������ ���������� ��� �������� ����� � � ������ ���� ��������. 
		������ ��� ����� �������������� ���� ��������� �� �������. �������� ������� ��������� 
		������� ����� � ������ ���.����. ��������� ������� {F75647}���������{FFFFFF} ������� � ������ ���.����,
		� �� ���������� �����. ������ �������� ����� ���� ���� �������������� ������ ������, 
		���� ������ �������� ���������.
			��� ������� �� ����, ����� {F75647}��������� ���� ���������, �� ����������� �� ����������. 
		�� ����, ����� ��������� �������, � �������, � �������� �� ����. ����� �������� ��������� 
		������. Ÿ ��������� ����������� � �������� � ����� ������. 
			��������: {5CE9B5}������� - [������]{FFFFFF}, � ��� �����. ��� �� ��������, ����������� �����. 
			{F75647}																	��������!
	���� �� ������� �� ������, ��������� �� ������������, �� ������� ������ �� ����� ���, 
	�������� ����� ������. ��������� �������, ���� �� ������������, �� ���������� ���� �����, 
	������������� �������� � ��������. �� ���� ��!
]]

remove = [[
{FFFFFF}��� �������� ������� ���������� ����������� �������� ��������.

	�������: {FBD82B}/delete accept{FFFFFF}
	
����� �������� �������� ������ ���������� �� ����.
��� �������������� ������� ���������� ����� ������ ���������� ���������.
]]