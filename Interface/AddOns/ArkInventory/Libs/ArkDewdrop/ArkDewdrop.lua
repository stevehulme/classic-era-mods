--[[

Name: ArkDewdrop
Description: A library to provide a dropdown menu interface.

License: LGPL v2.1 (this file specifically)
]]

--[[
ORIGINAL ACE2 BASED LIBRAY
Name: Dewdrop-2.0
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Documentation: http://wiki.wowace.com/index.php/Dewdrop-2.0
SVN: http://svn.wowace.com/root/trunk/DewdropLib/Dewdrop-2.0
Dependencies: AceLibrary
License: LGPL v2.1
]]

local libname = "ArkDewdrop"
local libversion = 30111
local lib = LibStub:NewLibrary( libname, libversion )

if not lib then
	return -- existing or newer library version already loaded
end

local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT

function lib:SetStandardFont( path, height )
	STANDARD_TEXT_FONT = path or STANDARD_TEXT_FONT
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = height or UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
end

local function new( ... )
	local t = { }
	for i = 1, select( '#', ... ), 2 do
		local k = select( i, ... )
		if k then
			t[k] = select( i + 1, ... )
		else
			break
		end
	end
	return t
end

local tmp
do
	local t = { }
	function tmp( ... )
		for k in pairs( t ) do
			t[k] = nil
		end
		for i = 1, select( '#', ... ), 2 do
			local k = select( i, ... )
			if k then
				t[k] = select( i + 1, ... )
			else
				break
			end
		end
		return t
	end
end

local tmp2
do
	local t = { }
	function tmp2( ... )
		for k in pairs( t ) do
			t[k] = nil
		end
		for i = 1, select( '#', ... ), 2 do
			local k = select( i, ... )
			if k then
				t[k] = select( i + 1, ... )
			else
				break
			end
		end
		return t
	end
end


local function setTexture( o, t, r, g, b, a )
	
	if ( not o ) then
		return
	end
	
	if t == true then
		o:SetColorTexture( r, g, b, a )
	else
		o:SetTexture( t )
	end
	
	if r and g and b then
		o:SetVertexColor( r, g, b )
	end
	
end



local CLOSE = "Close"
local CLOSE_DESC = "Close the menu."
local VALIDATION_ERROR = "Validation error."
local USAGE_TOOLTIP = "Usage: %s."
local RANGE_TOOLTIP = "Note that you can scroll your mouse wheel while over the slider to step by one."
local RESET_KEYBINDING_DESC = "Hit escape to clear the keybinding."
local KEY_BUTTON1 = "Left Mouse"
local KEY_BUTTON2 = "Right Mouse"
local DISABLED = "Disabled"
local DEFAULT_CONFIRM_MESSAGE = "Are you sure you want to perform `%s'?"

if GetLocale() == "deDE" then
	CLOSE = "Schlie\195\159en"
	CLOSE_DESC = "Men\195\188 schlie\195\159en."
	VALIDATION_ERROR = "Validierungsfehler."
	USAGE_TOOLTIP = "Benutzung: %s."
	RANGE_TOOLTIP = "Beachte das du mit dem Mausrad scrollen kannst solange du mit dem Mauszeiger \195\188ber dem Schieberegler bist, um feinere Spr\195\188nge zu machen."
	RESET_KEYBINDING_DESC = "Escape dr\195\188cken, um die Tastenbelegung zu l\195\182schen."
	KEY_BUTTON1 = "Linke Maustaste"
	KEY_BUTTON2 = "Rechte Maustaste"
	DISABLED = "Deaktiviert"
	DEFAULT_CONFIRM_MESSAGE = "Bist du sicher das du `%s' machen willst?"
elseif GetLocale() == "koKR" then
	CLOSE = "닫기"
	CLOSE_DESC = "메뉴를 닫습니다."
	VALIDATION_ERROR = "오류 확인."
	USAGE_TOOLTIP = "사용법: %s."
	RANGE_TOOLTIP = "알림 : 슬라이더 위에서 마우스 휠을 사용하면 한단계씩 조절할 수 있습니다."
	RESET_KEYBINDING_DESC = "단축키를 해제하려면 ESC키를 누르세요."
	KEY_BUTTON1 = "왼쪽 마우스"
	KEY_BUTTON2 = "오른쪽 마우스"
	DISABLED = "비활성화됨"
	DEFAULT_CONFIRM_MESSAGE = "정말로 `%s' 실행을 하시겠습니까 ?"
elseif GetLocale() == "frFR" then
	CLOSE = "Fermer"
	CLOSE_DESC = "Ferme le menu."
	VALIDATION_ERROR = "Erreur de validation."
	USAGE_TOOLTIP = "Utilisation : %s."
	RANGE_TOOLTIP = "Vous pouvez aussi utiliser la molette de la souris pour pour modifier progressivement."
	RESET_KEYBINDING_DESC = "Appuyez sur la touche Echappement pour effacer le raccourci."
	KEY_BUTTON1 = "Clic gauche"
	KEY_BUTTON2 = "Clic droit"
	DISABLED = "D\195\169sactiv\195\169"
	DEFAULT_CONFIRM_MESSAGE = "\195\138tes-vous s\195\187r de vouloir effectuer '%s' ?"
elseif GetLocale() == "esES" then
	CLOSE = "Cerrar"
	CLOSE_DESC = "Cierra el menú."
	VALIDATION_ERROR = "Error de validación."
	USAGE_TOOLTIP = "Uso: %s."
	RANGE_TOOLTIP = "Puedes desplazarte verticalmente con la rueda del ratón sobre el desplazador."
	RESET_KEYBINDING_DESC = "Pulsa Escape para borrar la asignación de tecla."
	KEY_BUTTON1 = "Clic Izquierdo"
	KEY_BUTTON2 = "Clic Derecho"
	DISABLED = "Desactivado"
	DEFAULT_CONFIRM_MESSAGE = "¿Estás seguro de querer realizar `%s'?"
elseif GetLocale() == "zhTW" then
	CLOSE = "關閉"
	CLOSE_DESC = "關閉選單。"
	VALIDATION_ERROR = "驗證錯誤。"
	USAGE_TOOLTIP = "用法: %s。"
	RANGE_TOOLTIP = "你可以在捲動條上使用滑鼠滾輪來捲動。"
	RESET_KEYBINDING_DESC = "按Esc鍵清除快捷鍵。"
	KEY_BUTTON1 = "滑鼠左鍵"
	KEY_BUTTON2 = "滑鼠右鍵"
	DISABLED = "停用"
	DEFAULT_CONFIRM_MESSAGE = "是否執行「%s」?"
elseif GetLocale() == "zhCN" then
	CLOSE = "关闭"
	CLOSE_DESC = "关闭菜单"
	VALIDATION_ERROR = "验证错误."
	USAGE_TOOLTIP = "用法: %s."
	RANGE_TOOLTIP = "你可以在滚动条上使用鼠标滚轮来翻页."
	RESET_KEYBINDING_DESC = "按ESC键清除按键绑定"
	KEY_BUTTON1 = "鼠标左键"
	KEY_BUTTON2 = "鼠标右键"
	DISABLED = "禁用"
	DEFAULT_CONFIRM_MESSAGE = "是否执行'%s'?"
elseif GetLocale() == "ruRU" then
	CLOSE = "Закрыть"
	CLOSE_DESC = "Закрыть меню."
	VALIDATION_ERROR = "Ошибка проверки данных."
	USAGE_TOOLTIP = "Используйте: %s."
	RANGE_TOOLTIP = "Используйте колесо мыши для прокрутки ползунка."
	RESET_KEYBINDING_DESC = "Нажмите клавишу Escape для очистки клавиши."
	KEY_BUTTON1 = "ЛКМ"
	KEY_BUTTON2 = "ПКМ"
	DISABLED = "Отключено"
	DEFAULT_CONFIRM_MESSAGE = "Вы уверены что вы хотите выполнять `%s'?"
end

lib.KEY_BUTTON1 = KEY_BUTTON1
lib.KEY_BUTTON2 = KEY_BUTTON2

local levels
local buttons

-- Secure frame handling:
-- Rather than using secure buttons in the menu (has problems), we have one
-- master secureframe that we pop onto menu items on mouseover. This requires
-- some dark magic with OnLeave etc, but it's not too bad.

local secureFrame = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
secureFrame:Hide()

local function secureFrame_Show(frame)
	local owner = frame.owner
	
	if frame.secure then	-- Leftovers from previos owner, clean up! ("Shouldn't" happen but does..)
		for k,v in pairs(frame.secure) do
			frame:SetAttribute(k, nil)
		end
	end
	frame.secure = owner.secure;	-- Grab hold of new secure data
	
	local scale = owner:GetEffectiveScale()

	frame:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", owner:GetLeft() * scale, owner:GetTop() * scale)
	frame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMLEFT", owner:GetRight() * scale, owner:GetBottom() * scale)
	frame:EnableMouse(true)
	for k,v in pairs(frame.secure) do
		frame:SetAttribute(k, v)
	end
	
	secureFrame:SetFrameStrata(owner:GetFrameStrata())
	secureFrame:SetFrameLevel(owner:GetFrameLevel()+1)
	
	frame:Show()
end

local function secureFrame_Hide(frame)
	frame:Hide()
	if frame.secure then
		for k,v in pairs(frame.secure) do
			frame:SetAttribute(k, nil)
		end
	end
	frame.secure = nil
end

secureFrame:SetScript("OnLeave",
	function(self)
		local owner=self.owner
		self:Deactivate()
		owner:GetScript("OnLeave")
	end
)

secureFrame:HookScript("OnClick",
	function(self,...)
		self.owner:GetScript("OnClick")(self,...)
	end
)

function secureFrame:IsOwnedBy(frame)
	return self.owner == frame
end

function secureFrame:Activate(owner)
	if self.owner then		-- "Shouldn't" happen but apparently it does and I cba to troubleshoot...
		if not InCombatLockdown( ) then
			secureFrame_Hide(self)
		end
	end
	self.owner = owner
	if not InCombatLockdown( ) then
		secureFrame_Show(self)
	end
end

function secureFrame:Deactivate()
	if not InCombatLockdown( ) then
		secureFrame_Hide(self)
	end
	self.owner = nil
end

-- END secure frame utilities


-- Underline on mouseover - use a single global underline that we move around, no point in creating lots of copies
local underlineFrame = CreateFrame( "Frame" )
underlineFrame.tx = underlineFrame:CreateTexture( )
setTexture(underlineFrame.tx, true, 1, 1, 0.5, 0.75)
underlineFrame:SetScript( "OnHide",
	function( self )
		self:Hide( )
	end
)
underlineFrame:SetScript( "OnShow",
	function( self ) -- change sizing on the fly to catch runtime uiscale changes
		self.tx:SetPoint( "TOPLEFT", -1, -2 / self:GetEffectiveScale( ) )
		self.tx:SetPoint( "RIGHT", 1, 0 )
		self.tx:SetHeight( 0.6 / self:GetEffectiveScale( ) )
	end
)
underlineFrame:SetHeight( 1 )
-- END underline on mouseover


local function GetScaledCursorPosition()
	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	return x / scale, y / scale
end

local function StartCounting(level)
	for i = level, 1, -1 do
		if levels[i] then
			levels[i].count = 5
		end
	end
end

local function StopCounting(level)
	for i = level, 1, -1 do
		if levels[i] then
			levels[i].count = nil
		end
	end
end

local function OnUpdate(self, elapsed)
	for _,level in ipairs(levels) do
		local count = level.count
		if count then
			count = count - elapsed
			if count < 0 then
				level.count = nil
				lib:Close(level.num)
			else
				level.count = count
			end
		end
	end
end

local function CheckDualMonitor(frame)
	if true then return end
	local ratio = GetScreenWidth() / GetScreenHeight()
	if ratio >= 2.4 and frame:GetRight() > GetScreenWidth() / 2 and frame:GetLeft() < GetScreenWidth() / 2 then
		ArkInventory.Output( "check dual monitor" )
		local offsetx
		if GetCursorPosition() / GetScreenHeight() * 768 < GetScreenWidth() / 2 then
			offsetx = GetScreenWidth() / 2 - frame:GetRight()
		else
			offsetx = GetScreenWidth() / 2 - frame:GetLeft()
		end
		ArkInventory.Output( "dual monitor offset" )
		local point, parent, relativePoint, x, y = frame:GetPoint(1)
		frame:SetPoint(point, parent, relativePoint, (x or 0) + offsetx, y or 0)
	end
end

local function CheckSize(level)
	if not level.buttons then
		return
	end
	local height = 20
	for _, button in ipairs(level.buttons) do
		height = height + button:GetHeight()
	end
	level:SetHeight(height)
	local width = 0
	local e1, e2
	for _, button in ipairs(level.buttons) do
		if ( not e1 ) and ( button.hasArrow or button.hasColorSwatch ) then
			e1 = 16
		end
		if ( not e2 ) and ( not button.notCheckable ) then
			e2 = 24
		end
		button.text:SetFont(STANDARD_TEXT_FONT, button.textHeight)
		if button.text:GetStringWidth() > width then
			width = button.text:GetStringWidth()
		end
	end
	level:SetWidth(width + (e1 or 0) + (e2 or 0) + 20)
	if level:GetLeft() and level:GetRight() and level:GetTop() and level:GetBottom() and (level:GetLeft() < 0 or level:GetRight() > GetScreenWidth() or level:GetTop() > GetScreenHeight() or level:GetBottom() < 0) then
		level:ClearAllPoints()
		local parent = level.parent or level:GetParent()
		if type(parent) ~= "table" then
			parent = UIParent
		end
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
			else
				level:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
			else
				level:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
			end
		end
	end
	local dirty = false
	if not level:GetRight() then
		lib:Close()
		return
	end
	if level:GetRight() > GetScreenWidth() and level.lastDirection == "RIGHT" then
		level.lastDirection = "LEFT"
		dirty = true
	elseif level:GetLeft() < 0 and level.lastDirection == "LEFT" then
		level.lastDirection = "RIGHT"
		dirty = true
	end
	if level:GetTop() > GetScreenHeight() and level.lastVDirection == "UP" then
		level.lastVDirection = "DOWN"
		dirty = true
	elseif level:GetBottom() < 0 and level.lastVDirection == "DOWN" then
		level.lastVDirection = "UP"
		dirty = true
	end
	if dirty then
		level:ClearAllPoints()
		local parent = level.parent or level:GetParent()
		if type(parent) ~= "table" then
			parent = UIParent
		end
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
			else
				level:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
			else
				level:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
			end
		end
	end
	if level:GetTop() > GetScreenHeight() then
		local top = level:GetTop()
		local point, parent, relativePoint, x, y = level:GetPoint(1)
		level:ClearAllPoints()
		level:SetPoint(point, parent, relativePoint, x or 0, (y or 0) + GetScreenHeight() - top)
	elseif level:GetBottom() < 0 then
		local bottom = level:GetBottom()
		local point, parent, relativePoint, x, y = level:GetPoint(1)
		level:ClearAllPoints()
		level:SetPoint(point, parent, relativePoint, x or 0, (y or 0) - bottom)
	end
	CheckDualMonitor(level)
	if mod(level.num, 5) == 0 then
		local left, bottom = level:GetLeft(), level:GetBottom()
		level:ClearAllPoints()
		level:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	end
end

local Open
local OpenSlider
local OpenEditBox
local Refresh
local Clear
local function ReleaseButton(level, index)
	if not level.buttons then
		return
	end
	if not level.buttons[index] then
		return
	end
	local button = level.buttons[index]
	button:ClearAllPoints( )
	button:Hide()
	if button.highlight then
		button.highlight:Hide()
	end
--	button.arrow:SetVertexColor(1, 1, 1)
--	button.arrow:SetHeight(16)
--	button.arrow:SetWidth(16)
	table.remove(level.buttons, index)
	buttons[#buttons + 1] = button
	for k in pairs(button) do
		if k ~= 0 and k ~= "text" and k ~= "check" and k ~= "arrow" and k ~= "colorSwatch" and k ~= "highlight" and k ~= "radioHighlight" then
			button[k] = nil
		end
	end
	return true
end

local function Scroll(level, down)
	if down then
		if level:GetBottom() < 0 then
			local point, parent, relativePoint, x, y = level:GetPoint(1)
			level:SetPoint(point, parent, relativePoint, x, y + 50)
			if level:GetBottom() > 0 then
				level:SetPoint(point, parent, relativePoint, x, y + 50 - level:GetBottom())
			end
		end
	else
		if level:GetTop() > GetScreenHeight() then
			local point, parent, relativePoint, x, y = level:GetPoint(1)
			level:SetPoint(point, parent, relativePoint, x, y - 50)
			if level:GetTop() < GetScreenHeight() then
				level:SetPoint(point, parent, relativePoint, x, y - 50 + GetScreenHeight() - level:GetTop())
			end
		end
	end
end

local function getArgs(t, str, num, ...)
	local x = t[str .. num]
	if x == nil then
		return ...
	else
		return x, getArgs(t, str, num + 1, ...)
	end
end

local sliderFrame
local editBoxFrame

local normalFont
local lastSetFont
local justSetFont = false
local regionTmp = {}
local function fillRegionTmp(...)
	for i = 1, select('#', ...) do
		regionTmp[i] = select(i, ...)
	end
end

local function showGameTooltip(self)
	if self.tooltipTitle or self.tooltipText then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		local disabled = not self.isTitle and self.disabled
		if self.tooltipTitle then
			if disabled then
				GameTooltip:SetText(self.tooltipTitle, 0.5, 0.5, 0.5, 1)
			else
				GameTooltip:SetText(self.tooltipTitle, 1, 1, 1, 1)
			end
			if self.tooltipText then
				if disabled then
					GameTooltip:AddLine(self.tooltipText, (NORMAL_FONT_COLOR.r + 0.5) / 2, (NORMAL_FONT_COLOR.g + 0.5) / 2, (NORMAL_FONT_COLOR.b + 0.5) / 2, 1)
				else
					GameTooltip:AddLine(self.tooltipText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
				end
			end
		else
			if disabled then
				GameTooltip:SetText(self.tooltipText, 0.5, 0.5, 0.5, 1)
			else
				GameTooltip:SetText(self.tooltipText, 1, 1, 1, 1)
			end
		end
		GameTooltip:Show()
	end
	if self.tooltipLink then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetHyperlink(self.tooltipLink)
		GameTooltip:Show()
	end
	if self.tooltipFunc then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
		self.tooltipFunc(getArgs(self, 'tooltipArg', 1))
		GameTooltip:Show()
	end
end

local tmpt = setmetatable({}, {mode='v'})
local numButtons = 0
local function AcquireButton( level )
	if not levels[level] then
		return
	end
	level = levels[level]
	if not level.buttons then
		level.buttons = { }
	end
	local button
	if #buttons == 0 then
		numButtons = numButtons + 1
		button = CreateFrame("Button")
		button:SetFrameStrata("FULLSCREEN_DIALOG")
		button:SetHeight(16)
		local highlight = button:CreateTexture(nil, "BACKGROUND")
		setTexture(highlight, [[Interface\QuestFrame\UI-QuestTitleHighlight]] )
		button.highlight = highlight
		highlight:SetBlendMode("ADD")
		highlight:SetAllPoints(button)
		highlight:Hide()
		local check = button:CreateTexture(nil, "ARTWORK")
		button.check = check
		setTexture(check,[[Interface\Buttons\UI-CheckBox-Check]])
		check:SetPoint("CENTER", button, "LEFT", 12, 0)
		check:SetWidth(24)
		check:SetHeight(24)
		local radioHighlight = button:CreateTexture(nil, "ARTWORK")
		button.radioHighlight = radioHighlight
		setTexture(radioHighlight,[[Interface\Buttons\UI-RadioButton]])
		radioHighlight:SetAllPoints(check)
		radioHighlight:SetBlendMode("ADD")
		radioHighlight:SetTexCoord(0.5, 0.75, 0, 1)
		radioHighlight:Hide()
		button:SetScript("OnEnter", function(self)
			if (sliderFrame and sliderFrame:IsShown() and sliderFrame.mouseDown and sliderFrame.level == self.level.num + 1) or (editBoxFrame and editBoxFrame:IsShown() and editBoxFrame.mouseDown and editBoxFrame.level == self.level.num + 1) then
				for i = 1, self.level.num do
					Refresh(levels[i])
				end
				return
			end
			lib:Close(self.level.num + 1)
			if not self.disabled then
				if self.secure then
					secureFrame:Activate(self)
				elseif self.hasSlider then
					OpenSlider(self)
				elseif self.hasEditBox then
					OpenEditBox(self)
				elseif self.hasArrow then
					Open(self, nil, self.level.num + 1, self.value)
				end
			end
			if not self.level then -- button reclaimed
				return
			end
			StopCounting(self.level.num + 1)
			if not self.disabled then
				highlight:Show()
				if self.isRadio then
					button.radioHighlight:Show()
				end
				if self.mouseoverUnderline then
					underlineFrame:SetParent(self)
					underlineFrame:SetPoint("BOTTOMLEFT",self.text,0,0)
					underlineFrame:SetWidth(self.text:GetWidth())
					underlineFrame:Show()
				end
			end
			showGameTooltip(self)
		end)
		button:SetScript("OnHide", function(self)
			if self.secure and secureFrame:IsOwnedBy(self) then
				secureFrame:Deactivate()
			end
		end)
		button:SetScript("OnLeave", function(self)
			if self.secure and secureFrame:IsShown() then
				return;	-- it's ok, we didn't actually mouse out of the button, only onto the secure frame on top of it
			end
			underlineFrame:Hide()
			if not self.selected then
				highlight:Hide()
			end
			button.radioHighlight:Hide()
			if self.level then
				StartCounting(self.level.num)
			end
			GameTooltip:Hide()
		end)
		local first = true
		button:SetScript("OnClick", function(self)
			if not self.disabled then
				if self.hasColorSwatch then
					
					local func = button.colorFunc
					local info = { }
					info.r = self.r
					info.g = self.g
					info.b = self.b
					info.hasOpacity = self.hasOpacity
					info.opacity = self.hasOpacity and self.opacity or 1
					info.extraInfo = nil
					
					info.swatchFunc = function()
						if func then
							local r,g,b = ColorPickerFrame:GetColorRGB()
							local a = info.hasOpacity and ColorPickerFrame:GetColorAlpha() or 1
							func(r,g,b,a)
						end
					end
					
					info.opacityFunc = function() end
					
					info.cancelFunc = function()
						if func then
							local r,g,b,a = ColorPickerFrame:GetPreviousValues()
							func(r,g,b,a)
						end
					end
					
					lib:Close(1)
					
					ColorPickerFrame:SetupColorPickerAndShow(info)
					ShowUIPanel(ColorPickerFrame)
					
				elseif self.func then
					local level = self.level
					if type(self.func) == "string" then
						if type(self.arg1[self.func]) ~= "function" then
							self:error("Cannot call method %q", self.func)
						end
						self.arg1[self.func](self.arg1, getArgs(self, 'arg', 2))
					else
						self.func(getArgs(self, 'arg', 1))
					end
					if self.closeWhenClicked then
						lib:Close()
					elseif level:IsShown() then
						for i = 1, level.num do
							Refresh(levels[i])
						end
						local value = levels[level.num].value
						for i = level.num-1, 1, -1 do
							local level = levels[i]
							local good = false
							for _,button in ipairs(level.buttons) do
								if button.value == value then
									good = true
									break
								end
							end
							if not good then
								lib:Close(i+1)
							end
							value = levels[i].value
						end
					end
				elseif self.closeWhenClicked then
					lib:Close()
				end
			end
		end)
		local text = button:CreateFontString(nil, "ARTWORK")
		button.text = text
		text:SetFontObject(GameFontHighlightSmall)
		button.text:SetFont(STANDARD_TEXT_FONT, UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)
		button:SetScript("OnMouseDown", function(self)
			if not self.disabled and (self.func or self.colorFunc or self.closeWhenClicked) then
				text:SetPoint("LEFT", button, "LEFT", self.notCheckable and 1 or 25, -1)
			end
		end)
		button:SetScript("OnMouseUp", function(self)
			if not self.disabled and (self.func or self.colorFunc or self.closeWhenClicked) then
				text:SetPoint("LEFT", button, "LEFT", self.notCheckable and 0 or 24, 0)
			end
		end)
		local arrow = button:CreateTexture(nil, "ARTWORK")
		button.arrow = arrow
		arrow:SetPoint("LEFT", button, "RIGHT", -16, 0)
		arrow:SetWidth(16)
		arrow:SetHeight(16)
		setTexture(arrow,[[Interface\ChatFrame\ChatFrameExpandArrow]])
		local colorSwatch = button:CreateTexture(nil, "ARTWORK")
		button.colorSwatch = colorSwatch
		colorSwatch:SetWidth(20)
		colorSwatch:SetHeight(20)
		setTexture(colorSwatch,[[Interface\ChatFrame\ChatFrameColorSwatch]])
		local texture = button:CreateTexture(nil, "OVERLAY")
		colorSwatch.texture = texture
		setTexture(texture,[[Interface\Buttons\WHITE8X8]])
		texture:SetWidth(11.5)
		texture:SetHeight(11.5)
		texture:Show()
		texture:SetPoint("CENTER", colorSwatch, "CENTER")
		colorSwatch:SetPoint("RIGHT", button, "RIGHT", 0, 0)
	else
		button = table.remove(buttons)
	end
	button:ClearAllPoints()
	button:SetParent(level)
	button:SetFrameStrata(level:GetFrameStrata())
	button:SetFrameLevel(level:GetFrameLevel() + 1)
	button:SetPoint("LEFT", level, "LEFT", 10, 0)
	button:SetPoint("RIGHT", level, "RIGHT", -10, 0)
	if #level.buttons == 0 then
		button:SetPoint("TOP", level, "TOP", 0, -10)
	else
		button:SetPoint("TOP", level.buttons[#level.buttons], "BOTTOM", 0, 0)
	end
	button.text:SetPoint("LEFT", button, "LEFT", 24, 0)
	button:Show()
	button.level = level
	level.buttons[#level.buttons + 1] = button
	if not level.parented then
		level.parented = true
		level:ClearAllPoints()
		if level.num == 1 then
			if level.parent ~= UIParent and type(level.parent) == "table" then
				level:SetPoint("TOPRIGHT", level.parent, "TOPLEFT")
			else
				level:SetPoint("CENTER", UIParent, "CENTER")
			end
		else
			if level.lastDirection == "RIGHT" then
				if level.lastVDirection == "DOWN" then
					level:SetPoint("TOPLEFT", level.parent, "TOPRIGHT", 5, 10)
				else
					level:SetPoint("BOTTOMLEFT", level.parent, "BOTTOMRIGHT", 5, -10)
				end
			else
				if level.lastVDirection == "DOWN" then
					level:SetPoint("TOPRIGHT", level.parent, "TOPLEFT", -5, 10)
				else
					level:SetPoint("BOTTOMRIGHT", level.parent, "BOTTOMLEFT", -5, -10)
				end
			end
		end
		level:SetFrameStrata("FULLSCREEN_DIALOG")
	end
	button:SetAlpha(1)
	return button
end

local numLevels = 0
local function AcquireLevel(level)
	if not levels[level] then
		for i = #levels + 1, level, -1 do
			local i = i
			numLevels = numLevels + 1
			local frame = CreateFrame("Button")
			if i == 1 then
				local old_CloseSpecialWindows = CloseSpecialWindows
				function CloseSpecialWindows()
					local found = old_CloseSpecialWindows()
					if levels[1]:IsShown() then
						lib:Close()
						return 1
					end
					return found
				end
			end
			levels[i] = frame
			frame.num = i
			frame:SetParent(UIParent)
			frame:SetFrameStrata("FULLSCREEN_DIALOG")
			frame:Hide()
			frame:SetWidth(180)
			frame:SetHeight(10)
			frame:SetFrameLevel(i * 3)
			frame:SetScript("OnHide", function()
				lib:Close(level + 1)
			end)
			if frame.SetTopLevel then
				frame:SetTopLevel(true)
			end
			frame:EnableMouse(true)
			frame:EnableMouseWheel(true)
			
			local backdrop = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
			backdrop:SetAllPoints(frame)
			backdrop:SetBackdrop(tmp(
				'bgFile', [[Interface\Tooltips\UI-Tooltip-Background]],
				'edgeFile', [[Interface\Tooltips\UI-Tooltip-Border]],
				'tile', true,
				'insets', tmp2(
					'left', 5,
					'right', 5,
					'top', 5,
					'bottom', 5
				),
				'tileSize', 16,
				'edgeSize', 16
			))
			backdrop:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
			backdrop:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
			frame:SetScript("OnClick", function(self)
				lib:Close(i)
			end)
			frame:SetScript("OnEnter", function(self)
				StopCounting(i)
			end)
			frame:SetScript("OnLeave", function(self)
				StartCounting(i)
			end)
			frame:SetScript("OnMouseWheel", function(self, arg1)
				Scroll(self, arg1 < 0)
			end)
			if i == 1 then
				frame:SetScript("OnUpdate", function(self, elapsed)
					OnUpdate(self, elapsed)
				end)
				levels[1].lastDirection = "RIGHT"
				levels[1].lastVDirection = "DOWN"
			else
				levels[i].lastDirection = levels[i - 1].lastDirection
				levels[i].lastVDirection = levels[i - 1].lastVDirection
			end
		end
	end
	local fullscreenFrame = GetUIPanel("fullscreen")
	local l = levels[level]
	local strata, framelevel = l:GetFrameStrata(), l:GetFrameLevel()
	if fullscreenFrame then
		l:SetParent(fullscreenFrame)
	else
		l:SetParent(UIParent)
	end
	l:SetFrameStrata(strata)
	l:SetFrameLevel(framelevel)
	l:SetAlpha(1)
	return l
end

local function validateOptions(options, position, baseOptions, fromPass)
	if not baseOptions then
		baseOptions = options
	end
	if type(options) ~= "table" then
		return "Options must be a table.", position
	end
	local kind = options.type
	if type(kind) ~= "string" then
		return '"type" must be a string.', position
	elseif kind ~= "group" and kind ~= "range" and kind ~= "text" and kind ~= "execute" and kind ~= "toggle" and kind ~= "color" and kind ~= "dragLink" and kind ~= "header" then
		return '"type" must either be "range", "text", "group", "toggle", "execute", "color", "dragLink", or "header".', position
	end
	if options.aliases then
		if type(options.aliases) ~= "table" and type(options.aliases) ~= "string" then
			return '"alias" must be a table or string', position
		end
	end
	if not fromPass then
		if kind == "execute" then
			if type(options.func) ~= "string" and type(options.func) ~= "function" then
				return '"func" must be a string or function', position
			end
		elseif kind == "range" or kind == "text" or kind == "toggle" then
			if type(options.set) ~= "string" and type(options.set) ~= "function" then
				return '"set" must be a string or function', position
			end
			if kind == "text" and options.get == false then
			elseif type(options.get) ~= "string" and type(options.get) ~= "function" then
				return '"get" must be a string or function', position
			end
		elseif kind == "group" and options.pass then
			if options.pass ~= true then
				return '"pass" must be either nil, true, or false', position
			end
			if not options.func then
				if type(options.set) ~= "string" and type(options.set) ~= "function" then
					return '"set" must be a string or function', position
				end
				if type(options.get) ~= "string" and type(options.get) ~= "function" then
					return '"get" must be a string or function', position
				end
			elseif type(options.func) ~= "string" and type(options.func) ~= "function" then
				return '"func" must be a string or function', position
			end
		end
	end
	if options ~= baseOptions then
		if kind == "header" then
		elseif type(options.desc) ~= "string" then
			return '"desc" must be a string', position
		elseif options.desc:len() == 0 then
			return '"desc" cannot be a 0-length string', position
		end
	end
	if options ~= baseOptions or kind == "range" or kind == "text" or kind == "toggle" or kind == "color" then
		if options.type == "header" and not options.cmdName and not options.name then
		elseif options.cmdName then
			if type(options.cmdName) ~= "string" then
				return '"cmdName" must be a string or nil', position
			elseif options.cmdName:len() == 0 then
				return '"cmdName" cannot be a 0-length string', position
			end
			if type(options.guiName) ~= "string" then
				if not options.guiNameIsMap then
					return '"guiName" must be a string or nil', position
				end
			elseif options.guiName:len() == 0 then
				return '"guiName" cannot be a 0-length string', position
			end
		else
			if type(options.name) ~= "string" then
				return '"name" must be a string', position
			elseif options.name:len() == 0 then
				return '"name" cannot be a 0-length string', position
			end
		end
	end
	if options.guiNameIsMap then
		if type(options.guiNameIsMap) ~= "boolean" then
			return '"guiNameIsMap" must be a boolean or nil', position
		elseif options.type ~= "toggle" then
			return 'if "guiNameIsMap" is true, then "type" must be set to \'toggle\'', position
		elseif type(options.map) ~= "table" then
			return '"map" must be a table', position
		end
	end
	if options.message and type(options.message) ~= "string" then
		return '"message" must be a string or nil', position
	end
	if options.error and type(options.error) ~= "string" then
		return '"error" must be a string or nil', position
	end
	if options.current and type(options.current) ~= "string" then
		return '"current" must be a string or nil', position
	end
	if options.order then
		if type(options.order) ~= "number" or (-1 < options.order and options.order < 0.999) then
			return '"order" must be a non-zero number or nil', position
		end
	end
	if options.disabled then
		if type(options.disabled) ~= "function" and type(options.disabled) ~= "string" and options.disabled ~= true then
			return '"disabled" must be a function, string, or boolean', position
		end
	end
	if options.cmdHidden then
		if type(options.cmdHidden) ~= "function" and type(options.cmdHidden) ~= "string" and options.cmdHidden ~= true then
			return '"cmdHidden" must be a function, string, or boolean', position
		end
	end
	if options.guiHidden then
		if type(options.guiHidden) ~= "function" and type(options.guiHidden) ~= "string" and options.guiHidden ~= true then
			return '"guiHidden" must be a function, string, or boolean', position
		end
	end
	if options.hidden then
		if type(options.hidden) ~= "function" and type(options.hidden) ~= "string" and options.hidden ~= true then
			return '"hidden" must be a function, string, or boolean', position
		end
	end
	if kind == "text" then
		if type(options.validate) == "table" then
			local t = options.validate
			local iTable = nil
			for k,v in pairs(t) do
				if type(k) == "number" then
					if iTable == nil then
						iTable = true
					elseif not iTable then
						return '"validate" must either have all keys be indexed numbers or strings', position
					elseif k < 1 or k > #t then
						return '"validate" numeric keys must be indexed properly. >= 1 and <= #t', position
					end
				else
					if iTable == nil then
						iTable = false
					elseif iTable then
						return '"validate" must either have all keys be indexed numbers or strings', position
					end
				end
				if type(v) ~= "string" then
					return '"validate" values must all be strings', position
				end
			end
			if options.multiToggle and options.multiToggle ~= true then
				return '"multiToggle" must be a boolean or nil if "validate" is a table', position
			end
		elseif options.validate == "keybinding" then
			-- no other checks
		else
			if type(options.usage) ~= "string" then
				return '"usage" must be a string', position
			elseif options.validate and type(options.validate) ~= "string" and type(options.validate) ~= "function" then
				return '"validate" must be a string, function, or table', position
			end
		end
		if options.multiToggle and type(options.validate) ~= "table" then
			return '"validate" must be a table if "multiToggle" is true', position
		end
	elseif kind == "range" then
		if options.min or options.max then
			if type(options.min) ~= "number" then
				return '"min" must be a number', position
			elseif type(options.max) ~= "number" then
				return '"max" must be a number', position
			elseif options.min >= options.max then
				return '"min" must be less than "max"', position
			end
		end
		if options.step then
			if type(options.step) ~= "number" then
				return '"step" must be a number', position
			elseif options.step < 0 then
				return '"step" must be nonnegative', position
			end
		end
		if options.bigStep then
			if type(options.bigStep) ~= "number" then
				return '"bigStep" must be a number', position
			elseif options.bigStep < 0 then
				return '"bigStep" must be nonnegative', position
			end
		end
		if options.isPercent and options.isPercent ~= true then
			return '"isPercent" must either be nil, true, or false', position
		end
	elseif kind == "toggle" then
		if options.map then
			if type(options.map) ~= "table" then
				return '"map" must be a table', position
			elseif type(options.map[true]) ~= "string" then
				return '"map[true]" must be a string', position
			elseif type(options.map[false]) ~= "string" then
				return '"map[false]" must be a string', position
			end
		end
	elseif kind == "color" then
		if options.hasAlpha and options.hasAlpha ~= true then
			return '"hasAlpha" must be nil, true, or false', position
		end
	elseif kind == "group" then
		if options.pass and options.pass ~= true then
			return '"pass" must be nil, true, or false', position
		end
		if type(options.args) ~= "table" then
			return '"args" must be a table', position
		end
		for k,v in pairs(options.args) do
			if type(k) ~= "number" then
				if type(k) ~= "string" then
					return '"args" keys must be strings or numbers', position
				elseif k:len() == 0 then
					return '"args" keys must not be 0-length strings.', position
				end
			end
			if type(v) ~= "table" then
				return '"args" values must be tables', position and position .. "." .. k or k
			end
			local newposition
			if position then
				newposition = position .. ".args." .. k
			else
				newposition = "args." .. k
			end
			local err, pos = validateOptions(v, newposition, baseOptions, options.pass)
			if err then
				return err, pos
			end
		end
	elseif kind == "execute" then
		if type(options.confirm) ~= "string" and type(options.confirm) ~= "boolean" and type(options.confirm) ~= "nil" then
			return '"confirm" must be a string, boolean, or nil', position
		end
	end
	if options.icon and type(options.icon) ~= "string" then
		return'"icon" must be a string', position
	end
	if options.iconWidth or options.iconHeight then
		if type(options.iconWidth) ~= "number" or type(options.iconHeight) ~= "number" then
			return '"iconHeight" and "iconWidth" must be numbers', position
		end
	end
	if options.iconCoordLeft or options.iconCoordRight or options.iconCoordTop or options.iconCoordBottom then
		if type(options.iconCoordLeft) ~= "number" or type(options.iconCoordRight) ~= "number" or type(options.iconCoordTop) ~= "number" or type(options.iconCoordBottom) ~= "number" then
			return '"iconCoordLeft", "iconCoordRight", "iconCoordTop", and "iconCoordBottom" must be numbers', position
		end
	end
end

local validatedOptions

local values
local mysort_args
local mysort
local othersort
local othersort_validate

local baseFunc, currentLevel

local function confirmPopup(message, func, ...)
	local d = string.upper( string.format( "%s_%s_CONFIRM_DIALOG", libname, libversion ) )
	StaticPopupDialogs[d] = StaticPopupDialogs[d] or {}
	local t = StaticPopupDialogs[d]
	for k in pairs(t) do
		t[k] = nil
	end
	t.text = message
	t.button1 = ACCEPT or "Accept"
	t.button2 = CANCEL or "Cancel"
	t.OnAccept = function()
		func(unpack(t))
	end
	for i = 1, select('#', ...) do
		t[i] = select(i, ...)
	end
	t.timeout = 0
	t.whileDead = 1
	t.hideOnEscape = 1

	lib:Close()
	StaticPopup_Show(d)
end


local function getMethod(settingname, handler, v, methodName, ...)	-- "..." is simply returned straight out cause you can't do "a,b,c = 111,f(),222"
	assert(v and type(v)=="table")
	assert(methodName and type(methodName)=="string")

	local method = v[methodName]
	if type(method)=="function" then
		return method, ...
	elseif type(method)=="string" then
		if not handler then
			lib:error("[%s] 'handler' is required if providing a method name: %q", tostring(settingname), method)
		elseif not handler[method] then
			lib:error("[%s] 'handler' method %q not defined", tostring(settingname), method)
		end
		return handler[method], handler, ...
	end

	lib:error("[%s] Missing %q directive", tostring(settingname), methodName)
end

local function callMethod(settingname, handler, v, methodName, ...)
	assert(v and type(v)=="table")
	assert(methodName and type(methodName)=="string")

	local method = v[methodName]
	if type(method)=="function" then
		local success, ret,ret2,ret3,ret4 = pcall(v[methodName], ...)
		if not success then
			geterrorhandler()(ret)
			return nil
		end
		return ret,ret2,ret3,ret4

	elseif type(method)=="string" then

		local neg = method:match("^~(.-)$")
		if neg then
			method = neg
		end
		if not handler then
			lib:error("[%s] 'handler' is required if providing a method name: %q", tostring(settingname), method)
		elseif not handler[method] then
			lib:error("[%s] 'handler' (%q) method %q not defined", tostring(settingname), handler.name or "(unnamed)", method)
		end
		local success, ret,ret2,ret3,ret4 = pcall(handler[method], handler, ...)
		if not success then
			geterrorhandler()(ret)
			return nil
		end
		if neg then
			return not ret
		end
		return ret,ret2,ret3,ret4
	elseif method == false then
		return nil
	end

	lib:error("[%s] Missing %q directive in %q", tostring(settingname), methodName, v.name or "(unnamed)")
end

local function skip1Nil(...)
	if select(1,...)==nil then
		return select(2,...)
	end
	return ...
end

function lib:FeedAceOptionsTable(options, difference)
	self:argCheck(options, 2, "table")
	self:argCheck(difference, 3, "nil", "number")
	if not currentLevel then
		self:error("Cannot call 'FeedAceOptionsTable' outside of a " .. libname .. " declaration")
	end
	if not difference then
		difference = 0
	end
	if not validatedOptions then
		validatedOptions = {}
	end
	if not validatedOptions[options] then
		local err, position = validateOptions(options)

		if err then
			if position then
				self:error(position .. ": " .. err)
			else
				self:error(err)
			end
		end

		validatedOptions[options] = true
	end
	local level = levels[currentLevel]
	if not level then
		self:error("Improper level given")
	end
	if not values then
		values = {}
	else
		for k,v in pairs(values) do
			values[k] = nil
		end
	end

	local current = level
	while current do		-- this traverses from higher level numbers to lower, building "values" with leaf nodes first and trunk nodes later
		if current.num == difference + 1 then
			break
		end
		values[#values + 1] = current.value
		current = levels[current.num - 1]
	end

	local realOptions = options
	local handler = options.handler
	local passTable
	local passValue
	while #values > 0 do	-- This loop traverses values from the END (trunk nodes first, then onto leaf nodes)
		if options.pass then
			if options.get and options.set then
				passTable = options
			elseif not passTable then
				passTable = options
			end
		else
			passTable = nil
		end
		local value = table.remove(values)
		options = options.args and options.args[value]
		if not options then
			return
		end
		handler = options.handler or handler
		passValue = passTable and value or nil
	end

	if options.type == "group" then
		local hidden = options.hidden
		if type(hidden) == "function" or type(hidden) == "string" then
			hidden = callMethod(options.name or "(options root)", handler, options, "hidden", options.passValue) or false
		end
		if hidden then
			return
		end
		local disabled = options.disabled
		if type(disabled) == "function" or type(disabled) == "string" then
			disabled = callMethod(options.name or "(options root)", handler, options, "disabled", options.passValue) or false
		end
		if disabled then
			self:AddLine(
				'text', DISABLED,
				'disabled', true
			)
			return
		end
		for k in pairs(options.args) do
			values[#values + 1] = k
		end
		if options.pass then
			if options.get and options.set then
				passTable = options
			elseif not passTable then
				passTable = options
			end
		else
			passTable = nil
		end
		if not mysort then
			mysort = function(a, b)
				local alpha, bravo = mysort_args[a], mysort_args[b]
				local alpha_order = alpha.order or 100
				local bravo_order = bravo.order or 100
				local alpha_name = alpha.guiName or alpha.name
				local bravo_name = bravo.guiName or bravo.name
				if alpha_order == bravo_order then
					if not alpha_name then
						return bravo_name
					elseif not bravo_name then
						return false
					else
						return alpha_name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):upper() < bravo_name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):upper()
					end
				else
					if alpha_order < 0 then
						if bravo_order > 0 then
							return false
						end
					else
						if bravo_order < 0 then
							return true
						end
					end
					return alpha_order < bravo_order
				end
			end
		end
		mysort_args = options.args
		table.sort(values, mysort)
		mysort_args = nil
		local hasBoth = #values >= 1 and (options.args[values[1]].order or 100) > 0 and (options.args[values[#values]].order or 100) < 0
		local last_order = 1
		for _,k in ipairs(values) do
			local v = options.args[k]
			local handler = v.handler or handler
			if hasBoth and last_order > 0 and (v.order or 100) < 0 then
				hasBoth = false
				self:AddLine()
			end
			local hidden, disabled = v.guiHidden or v.hidden, v.disabled

			if type(hidden) == "function" or type(hidden) == "string" then
				hidden = callMethod(k, handler, v, "hidden", v.passValue) or false
			end
			if not hidden then
				if type(disabled) == "function" or type(disabled) == "string" then
					disabled = callMethod(k, handler, v, "disabled", v.passValue) or false
				end
				local name = (v.guiIconOnly and v.icon) and "" or (v.guiName or v.name)
				local desc = v.guiDesc or v.desc
				local iconHeight = v.iconHeight or 16
				local iconWidth = v.iconWidth or 16
				local iconCoordLeft = v.iconCoordLeft
				local iconCoordRight = v.iconCoordRight
				local iconCoordBottom = v.iconCoordBottom
				local iconCoordTop = v.iconCoordTop
				local tooltipTitle, tooltipText
				tooltipTitle = name
				if name ~= desc then
					tooltipText = desc
				end
				if type(v.usage) == "string" and v.usage:trim():len() > 0 then
					if tooltipText then
						tooltipText = tooltipText .. "\n\n" .. USAGE_TOOLTIP:format(v.usage)
					else
						tooltipText = USAGE_TOOLTIP:format(v.usage)
					end
				end
				local v_p = passTable
				if not v_p or (v.type ~= "execute" and v.get and v.set) or (v.type == "execute" and v.func) then
					v_p = v
				end
				local passValue = v.passValue or (v_p~=v and k) or nil
				if v.type == "toggle" then
					local checked = callMethod(name, handler, v_p, "get", passValue) or false
					local checked_arg = checked
					if type(v_p.get)=="string" and v_p.get:match("^~") then
						checked_arg = not checked
					end
					local func, arg1, arg2, arg3 = getMethod(name, handler, v_p, "set", skip1Nil(passValue, not checked_arg))
					if v.guiNameIsMap then
						checked = checked and true or false
						name = tostring(v.map and v.map[checked]):gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
						tooltipTitle = name
						checked = true--nil
					end
					self:AddLine(
						'text', name,
						'checked', checked,
						'isRadio', v.isRadio,
						'func', func,
						'arg1', arg1,
						'arg2', arg2,
						'arg3', arg3,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText
					)
				elseif v.type == "execute" then
					local func, arg1, arg2, arg3, arg4
					local confirm = v.confirm
					if confirm == true then
						confirm = DEFAULT_CONFIRM_MESSAGE:format(tooltipText or tooltipTitle)
						func,arg1,arg2,arg3,arg4 = confirmPopup, confirm, getMethod(name, handler, v_p, "func", passValue)
					elseif type(confirm) == "string" then
						func,arg1,arg2,arg3,arg4 = confirmPopup, confirm, getMethod(name, handler, v_p, "func", passValue)
					else
						func,arg1,arg2 = getMethod(name, handler, v_p, "func", passValue)
					end
					self:AddLine(
						'text', name,
						'checked', checked,
						'func', func,
						'arg1', arg1,
						'arg2', arg2,
						'arg3', arg3,
						'arg4', arg4,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText,
						'icon', v.icon,
						'iconHeight', iconHeight,
						'iconWidth', iconWidth,
						'iconCoordLeft', iconCoordLeft,
						'iconCoordRight', iconCoordRight,
						'iconCoordTop', iconCoordTop,
						'iconCoordBottom', iconCoordBottom
					)
				elseif v.type == "range" then
					local sliderValue
					sliderValue = callMethod(name, handler, v_p, "get", passValue) or 0
					local sliderFunc, sliderArg1, sliderArg2 = getMethod(name, handler, v_p, "set", passValue)
					if tooltipText then
						tooltipText = format("%s\n\n%s", tooltipText, RANGE_TOOLTIP)
					else
						tooltipText = RANGE_TOOLTIP
					end
					self:AddLine(
						'text', name,
						'hasArrow', true,
						'hasSlider', true,
						'sliderMin', v.min or 0,
						'sliderMax', v.max or 1,
						'sliderStep', v.step or 0,
						'sliderBigStep', v.bigStep or nil,
						'sliderIsPercent', v.isPercent or false,
						'sliderValue', sliderValue,
						'sliderFunc', sliderFunc,
						'sliderArg1', sliderArg1,
						'sliderArg2', sliderArg2,
						'fromAceOptions', true,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText,
						'icon', v.icon,
						'iconHeight', iconHeight,
						'iconWidth', iconWidth,
						'iconCoordLeft', iconCoordLeft,
						'iconCoordRight', iconCoordRight,
						'iconCoordTop', iconCoordTop,
						'iconCoordBottom', iconCoordBottom
					)
				elseif v.type == "color" then
					local r,g,b,a = callMethod(name, handler, v_p, "get", passValue)
					if not r then
						r,g,b,a = 0,0,0,0
					end
					local colorFunc, colorArg1, colorArg2 = getMethod(name, handler, v_p, "set", passValue)
					self:AddLine(
						'text', name,
						'hasArrow', true,
						'hasColorSwatch', true,
						'r', r,
						'g', g,
						'b', b,
						'opacity', v.hasAlpha and a or nil,
						'hasOpacity', v.hasAlpha,
						'colorFunc', colorFunc,
						'colorArg1', colorArg1,
						'colorArg2', colorArg2,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText
					)
				elseif v.type == "text" then
						if type(v.validate) == "table" then
						local func,arg1,arg2
						if v.onClick then
							func,arg1,arg2 = getMethod(name, handler, v, "onClick", passValue)
						end
						local checked
						if v.isChecked then
							checked = callMethod(name, handler, v, "isChecked", passValue) or false
						end
						self:AddLine(
							'text', name,
							'hasArrow', true,
							'value', k,
							'func', func,
							'arg1', arg1,
							'arg2', arg2,
							'mouseoverUnderline', func and true or nil,
							'disabled', disabled,
							'checked', checked,
							'tooltipTitle', tooltipTitle,
							'tooltipText', tooltipText,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom
						)
					else
						local editBoxText
						editBoxText = callMethod(name, handler, v_p, "get", passValue) or ""
						local editBoxFunc, editBoxArg1, editBoxArg2 = getMethod(name, handler, v_p, "set", passValue)

						local editBoxValidateFunc, editBoxValidateArg1

						if v.validate and v.validate ~= "keybinding" then
							if v.validate == "keybinding" then
								if tooltipText then
									tooltipText = format("%s\n\n%s", tooltipText, RESET_KEYBINDING_DESC)
								else
									tooltipText = RESET_KEYBINDING_DESC
								end
							else
								editBoxValidateFunc, editBoxValidateArg1 = getMethod(name, handler, v, "validate") -- no passvalue!
							end
						end

						self:AddLine(
							'text', name,
							'hasArrow', true,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom,
							'hasEditBox', true,
							'editBoxText', editBoxText,
							'editBoxFunc', editBoxFunc,
							'editBoxArg1', editBoxArg1,
							'editBoxArg2', editBoxArg2,
							'editBoxValidateFunc', editBoxValidateFunc,
							'editBoxValidateArg1', editBoxValidateArg1,
							'editBoxIsKeybinding', v.validate == "keybinding",
							'editBoxKeybindingOnly', v.keybindingOnly,
							'editBoxKeybindingExcept', v.keybindingExcept,
							'disabled', disabled,
							'tooltipTitle', tooltipTitle,
							'tooltipText', tooltipText
						)
					end
				elseif v.type == "group" then
					local func,arg1,arg2
					if v.onClick then
						func,arg1,arg2 = getMethod(name, handler, v, "onClick", passValue)
					end
					local checked
					if v.isChecked then
						checked = callMethod(name, handler, v, "isChecked", passValue) or false
					end
					self:AddLine(
						'text', name,
						'hasArrow', true,
						'value', k,
						'func', func,
						'arg1', arg1,
						'arg2', arg2,
						'mouseoverUnderline', func and true or nil,
						'disabled', disabled,
						'checked', checked,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText,
						'icon', v.icon,
						'iconHeight', iconHeight,
						'iconWidth', iconWidth,
						'iconCoordLeft', iconCoordLeft,
						'iconCoordRight', iconCoordRight,
						'iconCoordTop', iconCoordTop,
						'iconCoordBottom', iconCoordBottom
					)
				elseif v.type == "header" then
					if name == "" or not name then
						self:AddLine(
							'isTitle', true,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom
						)
					else
						self:AddLine(
							'text', name,
							'isTitle', true,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom
						)
					end
				end
			end
			last_order = v.order or 100
		end
	elseif options.type == "text" and type(options.validate) == "table" then
		local current
		local options_p = passTable
		if not options_p or (options.get and options.set) then
			options_p = options
			passTable = nil
			passValue = nil
		end
		local multiToggle = options.multiToggle
		local passValue = options.passValue or passValue
		if not multiToggle then
			current = callMethod(k, handler, options_p, "get", passValue)
		end
		local indexed = true
		for k,v in pairs(options.validate) do
			if type(k) ~= "number" then
				indexed = false
			end
			values[#values + 1] = k
		end
		if not indexed then
			if not othersort then
				othersort = function(alpha, bravo)
					return othersort_validate[alpha]:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):upper() < othersort_validate[bravo]:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):upper()
				end
			end
			othersort_validate = options.validate
			table.sort(values, othersort)
			othersort_validate = nil
		end
		for _,k in ipairs(values) do
			local v = options.validate[k]
			if type(k) == "number" then
				k = v
			end
			local func, arg1, arg2, arg3, arg4 = getMethod(k, handler, options_p, "set", skip1Nil(passValue, k))
			local checked
			if multiToggle then
				checked = callMethod(k, handler, options_p, "get", skip1Nil(passValue, k)) or false
				if arg2 == nil then
					arg2 = not checked
				elseif arg3 == nil then
					arg3 = not checked
				else
					arg4 = not checked
				end
			else
				checked = (k == current or (type(k) == "string" and type(current) == "string" and k:lower() == current:lower()))
				if checked then
					func, arg1, arg2, arg3, arg4 = nil, nil, nil, nil, nil
				end
			end
			local tooltipTitle
			local tooltipText
			if options.validateDesc then
				tooltipTitle = v
				tooltipText = options.validateDesc[k]
			else
				tooltipTitle = options.guiName or options.name
				tooltipText = v
			end
			self:AddLine(
				'text', v,
				'func', func,
				'arg1', arg1,
				'arg2', arg2,
				'arg3', arg3,
				'arg4', arg4,
				'isRadio', not multiToggle,
				'checked', checked,
				'tooltipTitle', tooltipTitle,
				'tooltipText', tooltipText
			)
		end
		for k in pairs(values) do
			values[k] = nil
		end
	else
		return false
	end
	return true
end

function lib:FeedTable(s, difference)
	self:argCheck(s, 2, "table")
	self:argCheck(difference, 3, "nil", "number")
	if not currentLevel then
		self:error("Cannot call `FeedTable' outside of a " .. libname .. " declaration")
	end
	if not difference then
		difference = 0
	end
	local level = levels[currentLevel]
	if not level then
		self:error("Improper level given")
	end
	if not values then
		values = {}
	else
		for k,v in pairs(values) do
			values[k] = nil
		end
	end
	local t = s.subMenu and s or {subMenu = s}
	local current = level
	while current do
		if current.num == difference + 1 then
			break
		end
		values[#values + 1] = current.value
		current = levels[current.num - 1]
	end

	while #values > 0 do
		local value = table.remove(values)
		t = t.subMenu and t.subMenu[value]
		if not t then
			return
		end
	end

	if t.subMenu or current.num == 1 then
		for k in pairs(t.subMenu) do
			values[#values + 1] = k
		end
		table.sort(values)
		for _,k in ipairs(values) do
			local argTable = {"value", k}
			for key, val in pairs(t.subMenu[k]) do
				argTable[#argTable + 1] = key
				argTable[#argTable + 1] = val
			end
			self:AddLine(unpack(argTable))
		end
		for k in pairs(values) do
			values[k] = nil
		end
		return false
	end
	return true
end

function Refresh(level)
	if type(level) == "number" then
		level = levels[level]
	end
	if not level then
		return
	end
	if baseFunc then
		Clear(level)
		currentLevel = level.num
		if type(baseFunc) == "table" then
			if currentLevel == 1 then
				local handler = baseFunc.handler
				if handler then
					local name = tostring(handler)
					if not name:find('^table:') and not handler.hideMenuTitle then
						name = name:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
						lib:AddLine(
							'text', name,
							'isTitle', true
						)
					end
				end
--			elseif level.parentText then
--				lib:AddLine(
--					'text', level.parentText,
--					'tooltipTitle', level.parentTooltipTitle,
--					'tooltipText', level.parentTooltipText,
--					'tooltipFunc', level.parentTooltipFunc,
--					'isTitle', true
--				)
			end
			lib:FeedAceOptionsTable(baseFunc)
			if currentLevel == 1 then
				lib:AddLine(
					'text', CLOSE,
					'tooltipTitle', CLOSE,
					'tooltipText', CLOSE_DESC,
					'closeWhenClicked', true
				)
			end
		else
--			if level.parentText then
--				lib:AddLine(
--					'text', level.parentText,
--					'tooltipTitle', level.parentTooltipTitle,
--					'tooltipText', level.parentTooltipText,
--					'tooltipFunc', level.parentTooltipFunc,
--					'isTitle', true
--				)
--			end
			baseFunc(currentLevel, level.value, levels[level.num - 1] and levels[level.num - 1].value, levels[level.num - 2] and levels[level.num - 2].value, levels[level.num - 3] and levels[level.num - 3].value, levels[level.num - 4] and levels[level.num - 4].value)
		end
		currentLevel = nil
		CheckSize(level)
	end
end

function lib:Refresh(level)
	lib:argCheck(level, 2, "number", "nil")
	if not level then
		for k,v in pairs(levels) do
			Refresh(v)
		end
	else
		Refresh(levels[level])
	end
end

function OpenSlider(parent)
	if not sliderFrame then
		
		sliderFrame = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate")
		sliderFrame:SetWidth(100)
		sliderFrame:SetHeight(170)
		sliderFrame:SetScale(UIParent:GetScale())
		sliderFrame:SetBackdrop(tmp(
			'bgFile', [[Interface\Tooltips\UI-Tooltip-Background]],
			'edgeFile', [[Interface\Tooltips\UI-Tooltip-Border]],
			'tile', true,
			'insets', tmp2(
				'left', 5,
				'right', 5,
				'top', 5,
				'bottom', 5
			),
			'tileSize', 16,
			'edgeSize', 16
		))
		sliderFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		if sliderFrame.SetTopLevel then
			sliderFrame:SetTopLevel(true)
		end
		sliderFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
		sliderFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
		sliderFrame:EnableMouse(true)
		sliderFrame:EnableMouseWheel(true)
		sliderFrame:Hide()
		sliderFrame:SetPoint("CENTER", UIParent, "CENTER")
		
		local slider = CreateFrame("Slider", nil, sliderFrame, BackdropTemplateMixin and "BackdropTemplate")
		sliderFrame.slider = slider
		slider:SetOrientation("VERTICAL")
		slider:SetMinMaxValues(0, 1)
		slider:SetValueStep(0.000000001)
		slider:SetValue(0.5)
		slider:SetWidth(16)
		slider:SetHeight(128)
		slider:SetPoint("LEFT", sliderFrame, "LEFT", 15, 0)
		slider:SetBackdrop(tmp(
			'bgFile', [[Interface\Buttons\UI-SliderBar-Background]],
			'edgeFile', [[Interface\Buttons\UI-SliderBar-Border]],
			'tile', true,
			'edgeSize', 8,
			'tileSize', 8,
			'insets', tmp2(
				'left', 3,
				'right', 3,
				'top', 3,
				'bottom', 3
			)
		))
		local texture = slider:CreateTexture()
		slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Vertical]])
		local text = slider:CreateFontString(nil, "ARTWORK")
		sliderFrame.topText = text
		text:SetFontObject(GameFontGreenSmall)
		text:SetText("100%")
		text:SetPoint("BOTTOM", slider, "TOP")
		local text = slider:CreateFontString(nil, "ARTWORK")
		sliderFrame.bottomText = text
		text:SetFontObject(GameFontGreenSmall)
		text:SetText("0%")
		text:SetPoint("TOP", slider, "BOTTOM")
		
		local editBox = CreateFrame("EditBox", nil, sliderFrame)
		sliderFrame.currentText = editBox
		editBox:SetFontObject(ChatFontNormal)
		editBox:SetHeight(13)
		editBox:SetPoint("RIGHT", sliderFrame, "RIGHT", -16, 0)
		editBox:SetPoint("LEFT", slider, "RIGHT", 12, 0)
		editBox:SetText("50%")
		editBox:SetJustifyH("CENTER")

		local width = editBox:GetWidth()/2 + 10
		local left = editBox:CreateTexture(nil, "BACKGROUND")
		setTexture(left,[[Interface\ChatFrame\UI-ChatInputBorder-Left]])
		left:SetTexCoord(0, width / 256, 0, 1)
		left:SetWidth(width)
		left:SetHeight(32)
		left:SetPoint("LEFT", editBox, "LEFT", -10, 0)
		local right = editBox:CreateTexture(nil, "BACKGROUND")
		setTexture(right,[[Interface\ChatFrame\UI-ChatInputBorder-Right]])
		right:SetTexCoord(1 - width / 256, 1, 0, 1)
		right:SetWidth(width)
		right:SetHeight(32)
		right:SetPoint("RIGHT", editBox, "RIGHT", 10, 0)

		local changed = false
		local inside = false
		slider:SetScript("OnValueChanged", function()
			if sliderFrame.changing then
				return
			end
			changed = true
			local done = false
			if sliderFrame.parent and sliderFrame.parent.sliderFunc then
				local min = sliderFrame.parent.sliderMin or 0
				local max = sliderFrame.parent.sliderMax or 1
				local step
				if sliderFrame.fineStep then
					step = sliderFrame.parent.sliderStep or (max - min) / 100
				else
					step = sliderFrame.parent.sliderBigStep or sliderFrame.parent.sliderStep or (max - min) / 100
				end
				local value = (1 - slider:GetValue()) * (max - min) + min
				if step > 0 then
					value = math.floor((value - min) / step + 0.5) * step + min
					if value > max then
						value = max
					elseif value < min then
						value = min
					end
				end
				if value == sliderFrame.lastValue then
					return
				end
				sliderFrame.lastValue = value
				local text = sliderFrame.parent.sliderFunc(getArgs(sliderFrame.parent, 'sliderArg', 1, value))
				if sliderFrame.parent.fromAceOptions then
					text = nil
				elseif type(text) == "string" or type(text) == "number" then
					sliderFrame.currentText:SetText(text)
					done = true
				end
			end
			if not done then
				local min = sliderFrame.parent.sliderMin or 0
				local max = sliderFrame.parent.sliderMax or 1
				local step
				if sliderFrame.fineStep then
					step = sliderFrame.parent.sliderStep or (max - min) / 100
				else
					step = sliderFrame.parent.sliderBigStep or sliderFrame.parent.sliderStep or (max - min) / 100
				end
				local value = (1 - slider:GetValue()) * (max - min) + min
				if step > 0 then
					value = math.floor((value - min) / step + 0.5) * step + min
					if value > max then
						value = max
					elseif value < min then
						value = min
					end
				end
				if sliderFrame.parent.sliderIsPercent then
					sliderFrame.currentText:SetText(string.format("%.0f%%", value * 100))
				else
					if step < 0.1 then
						sliderFrame.currentText:SetText(string.format("%.2f", value))
					elseif step < 1 then
						sliderFrame.currentText:SetText(string.format("%.1f", value))
					else
						sliderFrame.currentText:SetText(string.format("%.0f", value))
					end
				end
			end
		end)
		local function onEnter()
			StopCounting(sliderFrame.level)
			showGameTooltip(sliderFrame.parent)
		end
		local function onLeave()
			GameTooltip:Hide()
		end
		sliderFrame:SetScript("OnEnter", onEnter)
		sliderFrame:SetScript("OnLeave", function()
			GameTooltip:Hide()
			if changed then
				local parent = sliderFrame.parent
				local sliderFunc = parent.sliderFunc
				for i = 1, sliderFrame.level - 1 do
					Refresh(levels[i])
				end
				local newParent
				for _,button in ipairs(levels[sliderFrame.level-1].buttons) do
					if button.sliderFunc == sliderFunc then
						newParent = button
						break
					end
				end
				if newParent then
					OpenSlider(newParent)
				else
					sliderFrame:Hide()
				end
			end
		end)
		editBox:SetScript("OnEnter", onEnter)
		editBox:SetScript("OnLeave", onLeave)
		slider:SetScript("OnMouseDown", function()
			sliderFrame.mouseDown = true
			GameTooltip:Hide()
		end)
		slider:SetScript("OnMouseUp", function()
			sliderFrame.mouseDown = false
			if changed--[[ and not inside]] then
				local parent = sliderFrame.parent
				local sliderFunc = parent.sliderFunc
				for i = 1, sliderFrame.level - 1 do
					Refresh(levels[i])
				end
				local newParent
				for _,button in ipairs(levels[sliderFrame.level-1].buttons) do
					if button.sliderFunc == sliderFunc then
						newParent = button
						break
					end
				end
				if newParent then
					OpenSlider(newParent)
				else
					sliderFrame:Hide()
				end
			end
			if inside then
				showGameTooltip(sliderFrame.parent)
			end
		end)
		slider:SetScript("OnEnter", function()
			inside = true
			StopCounting(sliderFrame.level)
			showGameTooltip(sliderFrame.parent)
		end)
		slider:SetScript("OnLeave", function()
			inside = false
			GameTooltip:Hide()
			if changed and not sliderFrame.mouseDown then
				local parent = sliderFrame.parent
				local sliderFunc = parent.sliderFunc
				for i = 1, sliderFrame.level - 1 do
					Refresh(levels[i])
				end
				local newParent
				for _,button in ipairs(levels[sliderFrame.level-1].buttons) do
					if button.sliderFunc == sliderFunc then
						newParent = button
						break
					end
				end
				if newParent then
					OpenSlider(newParent)
				else
					sliderFrame:Hide()
				end

				changed = false
			end
		end)
		sliderFrame:SetScript("OnMouseWheel", function(self, arg1)
			local up = arg1 > 0
			
			local min = sliderFrame.parent.sliderMin or 0
			local max = sliderFrame.parent.sliderMax or 1
			local step = sliderFrame.parent.sliderStep or (max - min) / 100
			if step <= 0 then
				step = (max - min) / 100
			end
			
			local value = (1 - slider:GetValue()) * (max - min) + min
			if up then
				value = value + step
			else
				value = value - step
			end
			if value > max then
				value = max
			elseif value < min then
				value = min
			end
			sliderFrame.fineStep = true
			if max<=min then
				slider:SetValue(0)
			else
				slider:SetValue(1 - (value - min) / (max - min))
			end
			sliderFrame.fineStep = nil
		end)
		slider:SetScript("OnMouseWheel", sliderFrame:GetScript("OnMouseWheel"))
		editBox:SetScript("OnEnterPressed", function()
			local value = editBox:GetNumber()

			if sliderFrame.parent.sliderIsPercent then
				value = value / 100
			end

			local min = sliderFrame.parent.sliderMin or 0
			local max = sliderFrame.parent.sliderMax or 1

			if value > max then
				value = max
			elseif value < min then
				value = min
			end
			sliderFrame.fineStep = true
			if max <= min then
				slider:SetValue(0)
			else
				slider:SetValue(1 - (value - min) / (max - min))
			end
			sliderFrame.fineStep = nil

			StartCounting(sliderFrame.level)
		end)
		editBox:SetScript("OnEscapePressed", function()
			lib:Close(sliderFrame.level)
			StartCounting(sliderFrame.level)
		end)
		editBox:SetAutoFocus(false)
	end
	sliderFrame.parent = parent
	sliderFrame.level = parent.level.num + 1
	sliderFrame.parentValue = parent.level.value
	sliderFrame:SetFrameLevel(parent.level:GetFrameLevel() + 3)
	sliderFrame.slider:SetFrameLevel(sliderFrame:GetFrameLevel() + 1)
	sliderFrame.currentText:SetFrameLevel(sliderFrame:GetFrameLevel() + 1)
	sliderFrame.currentText:ClearFocus()
	sliderFrame.changing = true
	if not parent.sliderMin or not parent.sliderMax then
		return
	end

	if parent.arrow then
--		parent.arrow:SetVertexColor(0.2, 0.6, 0)
--		parent.arrow:SetHeight(24)
--		parent.arrow:SetWidth(24)
		parent.selected = true
		parent.highlight:Show()
	end

	sliderFrame:SetClampedToScreen(false)
	if not parent.sliderValue then
		parent.sliderValue = (parent.sliderMin + parent.sliderMax) / 2
	end
	if parent.sliderMax <= parent.sliderMin then
		sliderFrame.slider:SetValue(0)
	else
		sliderFrame.slider:SetValue(1 - (parent.sliderValue - parent.sliderMin) / (parent.sliderMax - parent.sliderMin))
	end
	sliderFrame.changing = false
	sliderFrame.bottomText:SetText(parent.sliderMinText or "0")
	sliderFrame.topText:SetText(parent.sliderMaxText or "1")
	local text
	if parent.sliderFunc and not parent.fromAceOptions then
		text = parent.sliderFunc(getArgs(parent, 'sliderArg', 1, parent.sliderValue))
	end
	if type(text) == "number" or type(text) == "string" then
		sliderFrame.currentText:SetText(text)
	elseif parent.sliderIsPercent then
		sliderFrame.currentText:SetText(string.format("%.0f%%", parent.sliderValue * 100))
	else
		if parent.sliderStep < 0.1 then
			sliderFrame.currentText:SetText(string.format("%.2f", parent.sliderValue))
		elseif parent.sliderStep < 1 then
			sliderFrame.currentText:SetText(string.format("%.1f", parent.sliderValue))
		else
			sliderFrame.currentText:SetText(string.format("%.0f", parent.sliderValue))
		end
	end


	sliderFrame.lastValue = parent.sliderValue

	local level = parent.level
	sliderFrame:Show()
	sliderFrame:ClearAllPoints()
	if level.lastDirection == "RIGHT" then
		if level.lastVDirection == "DOWN" then
			sliderFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
		else
			sliderFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
		end
	else
		if level.lastVDirection == "DOWN" then
			sliderFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
		else
			sliderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
		end
	end
	local dirty
	if level.lastDirection == "RIGHT" then
		if sliderFrame:GetRight() > GetScreenWidth() then
			level.lastDirection = "LEFT"
			dirty = true
		end
	elseif sliderFrame:GetLeft() < 0 then
		level.lastDirection = "RIGHT"
		dirty = true
	end
	if level.lastVDirection == "DOWN" then
		if sliderFrame:GetBottom() < 0 then
			level.lastVDirection = "UP"
			dirty = true
		end
	elseif sliderFrame:GetTop() > GetScreenWidth() then
		level.lastVDirection = "DOWN"
		dirty = true
	end
	if dirty then
		sliderFrame:ClearAllPoints()
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				sliderFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
			else
				sliderFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				sliderFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
			else
				sliderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
			end
		end
	end
	local left, bottom = sliderFrame:GetLeft(), sliderFrame:GetBottom()
	sliderFrame:ClearAllPoints()
	sliderFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	if mod(level.num, 5) == 0 then
		local left, bottom = level:GetLeft(), level:GetBottom()
		level:ClearAllPoints()
		level:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	end
	sliderFrame:SetClampedToScreen(true)
end

function OpenEditBox(parent)
	if not editBoxFrame then
		editBoxFrame = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate")
		editBoxFrame:SetWidth(200)
		editBoxFrame:SetHeight(40)
		editBoxFrame:SetScale(UIParent:GetScale())
		editBoxFrame:SetBackdrop(tmp(
			'bgFile', [[Interface\Tooltips\UI-Tooltip-Background]],
			'edgeFile', [[Interface\Tooltips\UI-Tooltip-Border]],
			'tile', true,
			'insets', tmp2(
				'left', 5,
				'right', 5,
				'top', 5,
				'bottom', 5
			),
			'tileSize', 16,
			'edgeSize', 16
		))
		editBoxFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		if editBoxFrame.SetTopLevel then
			editBoxFrame:SetTopLevel(true)
		end
		editBoxFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
		editBoxFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
		editBoxFrame:EnableMouse(true)
		editBoxFrame:EnableMouseWheel(true)
		editBoxFrame:Hide()
		editBoxFrame:SetPoint("CENTER", UIParent, "CENTER")

		local editBox = CreateFrame("EditBox", nil, editBoxFrame)
		editBoxFrame.editBox = editBox
		editBox:SetFontObject(ChatFontNormal)
		editBox:SetWidth(160)
		editBox:SetHeight(13)
		editBox:SetPoint("CENTER", editBoxFrame, "CENTER", 0, 0)

		local left = editBox:CreateTexture(nil, "BACKGROUND")
		setTexture(left,[[Interface\ChatFrame\UI-ChatInputBorder-Left]])
		left:SetTexCoord(0, 100 / 256, 0, 1)
		left:SetWidth(100)
		left:SetHeight(32)
		left:SetPoint("LEFT", editBox, "LEFT", -10, 0)
		local right = editBox:CreateTexture(nil, "BACKGROUND")
		setTexture(right,[[Interface\ChatFrame\UI-ChatInputBorder-Right]])
		right:SetTexCoord(156/256, 1, 0, 1)
		right:SetWidth(100)
		right:SetHeight(32)
		right:SetPoint("RIGHT", editBox, "RIGHT", 10, 0)

		editBox:SetScript("OnEnterPressed", function()
			if editBoxFrame.parent and editBoxFrame.parent.editBoxValidateFunc then
				local t = editBox.realText or editBox:GetText() or ""
				local result = editBoxFrame.parent.editBoxValidateFunc(getArgs(editBoxFrame.parent, 'editBoxValidateArg', 1, t))
				if not result then
					UIErrorsFrame:AddMessage(VALIDATION_ERROR, 1, 0, 0)
					return
				end
			end
			if editBoxFrame.parent and editBoxFrame.parent.editBoxFunc then
				local t
				if editBox.realText ~= "NONE" then
					t = editBox.realText or editBox:GetText() or ""
				end
				editBoxFrame.parent.editBoxFunc(getArgs(editBoxFrame.parent, 'editBoxArg', 1, t))
			end
			lib:Close(editBoxFrame.level)
			for i = 1, editBoxFrame.level - 1 do
				Refresh(levels[i])
			end
			StartCounting(editBoxFrame.level-1)
		end)
		editBox:SetScript("OnEscapePressed", function()
			lib:Close(editBoxFrame.level)
			StartCounting(editBoxFrame.level-1)
		end)
		editBox:SetScript("OnReceiveDrag", function()
			if GetCursorInfo then
				local type, alpha, bravo = GetCursorInfo()
				local text
				if type == "spell" then
					text = GetSpellName(alpha, bravo)
				elseif type == "item" then
					text = bravo
				end
				if not text then
					return
				end
				ClearCursor()
				editBox:SetText(text)
			end
		end)
		local changing = false
		local skipNext = false

		function editBox:SpecialSetText(text)
			local oldText = editBox:GetText() or ""
			if not text then
				text = ""
			end
			if text ~= oldText then
				changing = true
				self:SetText(tostring(text))
				changing = false
				skipNext = true
			end
		end

		editBox:SetScript("OnTextChanged", function()
			if skipNext then
				skipNext = false
			elseif not changing and editBoxFrame.parent and editBoxFrame.parent.editBoxChangeFunc then
				local t
				if editBox.realText ~= "NONE" then
					t = editBox.realText or editBox:GetText() or ""
				end
				local text = editBoxFrame.parent.editBoxChangeFunc(getArgs(editBoxFrame.parent, 'editBoxChangeArg', 1, t))
				if text then
					editBox:SpecialSetText(text)
				end
			end
		end)
		editBoxFrame:SetScript("OnEnter", function()
			StopCounting(editBoxFrame.level)
			showGameTooltip(editBoxFrame.parent)
		end)
		editBoxFrame:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		editBox:SetScript("OnEnter", function()
			StopCounting(editBoxFrame.level)
			showGameTooltip(editBoxFrame.parent)
		end)
		editBox:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		editBoxFrame:SetScript("OnKeyDown", function(self, arg1)
			if not editBox.keybinding then
				return
			end
			local screenshotKey = GetBindingKey("SCREENSHOT")
			if screenshotKey and arg1 == screenshotKey then
				Screenshot()
				return
			end

			if arg1 == "LeftButton" then
				arg1 = "BUTTON1"
			elseif arg1 == "RightButton" then
				arg1 = "BUTTON2"
			elseif arg1 == "MiddleButton" then
				arg1 = "BUTTON3"
			elseif arg1 == "Button4" then
				arg1 = "BUTTON4"
			elseif arg1 == "Button5" then
				arg1 = "BUTTON5"
			end
			if arg1 == "UNKNOWN" then
				return
			elseif arg1 == "SHIFT" or arg1 == "CTRL" or arg1 == "ALT" then
				return
			elseif arg1 == "ENTER" then
				if editBox.keybindingOnly and not editBox.keybindingOnly[editBox.realText] then
					return editBox:GetScript("OnEscapePressed")()
				elseif editBox.keybindingExcept and editBox.keybindingExcept[editBox.realText] then
					return editBox:GetScript("OnEscapePressed")()
				else
					return editBox:GetScript("OnEnterPressed")()
				end
			elseif arg1 == "ESCAPE" then
				if editBox.realText == "NONE" then
					return editBox:GetScript("OnEscapePressed")()
				else
					editBox:SpecialSetText(NONE or "NONE")
					editBox.realText = "NONE"
					return
				end
			elseif editBox.keybindingOnly and not editBox.keybindingOnly[arg1] then
				return
			elseif editBox.keybindingExcept and editBox.keybindingExcept[arg1] then
				return
			end
			local s = GetBindingText(arg1, "KEY_")
			if s == "BUTTON1" then
				s = KEY_BUTTON1
			elseif s == "BUTTON2" then
				s = KEY_BUTTON2
			end
			local real = arg1
			if IsShiftKeyDown() then
				s = "Shift-" .. s
				real = "SHIFT-" .. real
			end
			if IsControlKeyDown() then
				s = "Ctrl-" .. s
				real = "CTRL-" .. real
			end
			if IsAltKeyDown() then
				s = "Alt-" .. s
				real = "ALT-" .. real
			end
			if editBox:GetText() ~= s then
				editBox:SpecialSetText("-")
				editBox:SpecialSetText(s)
				editBox.realText = real
				return editBox:GetScript("OnTextChanged")()
			end
		end)
		editBoxFrame:SetScript("OnMouseDown", editBoxFrame:GetScript("OnKeyDown"))
		editBox:SetScript("OnMouseDown", function(self, ...)
			if GetCursorInfo and (CursorHasItem() or CursorHasSpell()) then
				return editBox:GetScript("OnReceiveDrag")(self, ...)
			end
			return editBoxFrame:GetScript("OnKeyDown")(self, ...)
		end)
		editBoxFrame:SetScript("OnMouseWheel", function(self, arg1)
			local up = ( arg1 > 0 ) and "MOUSEWHEELUP" or "MOUSEWHEELDOWN"
			return editBoxFrame:GetScript("OnKeyDown")(self, up)
		end)
		editBox:SetScript("OnMouseWheel", editBoxFrame:GetScript("OnMouseWheel"))
	end
	editBoxFrame.parent = parent
	editBoxFrame.level = parent.level.num + 1
	editBoxFrame.parentValue = parent.level.value
	editBoxFrame:SetFrameLevel(parent.level:GetFrameLevel() + 3)
	editBoxFrame.editBox:SetFrameLevel(editBoxFrame:GetFrameLevel() + 1)
	editBoxFrame.editBox.realText = nil
	editBoxFrame:SetClampedToScreen(false)

	editBoxFrame.editBox:SpecialSetText("")
	if parent.editBoxIsKeybinding then
		local s = parent.editBoxText
		if s == "" then
			s = "NONE"
		end
		editBoxFrame.editBox.realText = s
		if s and s ~= "NONE" then
			local alpha,bravo = s:match("^(.+)%-(.+)$")
			if not bravo then
				alpha = nil
				bravo = s
			end
			bravo = GetBindingText(bravo, "KEY_")
			if alpha then
				editBoxFrame.editBox:SpecialSetText(alpha:upper() .. "-" .. bravo)
			else
				editBoxFrame.editBox:SpecialSetText(bravo)
			end
		else
			editBoxFrame.editBox:SpecialSetText(NONE or "NONE")
		end
	else
		editBoxFrame.editBox:SpecialSetText(parent.editBoxText)
	end

	editBoxFrame.editBox.keybinding = parent.editBoxIsKeybinding
	editBoxFrame.editBox.keybindingOnly = parent.editBoxKeybindingOnly
	editBoxFrame.editBox.keybindingExcept = parent.editBoxKeybindingExcept
	editBoxFrame.editBox:EnableKeyboard(not parent.editBoxIsKeybinding)
	editBoxFrame:EnableKeyboard(parent.editBoxIsKeybinding)

	if parent.arrow then
--		parent.arrow:SetVertexColor(0.2, 0.6, 0)
--		parent.arrow:SetHeight(24)
--		parent.arrow:SetWidth(24)
		parent.selected = true
		parent.highlight:Show()
	end

	local level = parent.level
	editBoxFrame:Show()
	editBoxFrame:ClearAllPoints()
	if level.lastDirection == "RIGHT" then
		if level.lastVDirection == "DOWN" then
			editBoxFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
		else
			editBoxFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
		end
	else
		if level.lastVDirection == "DOWN" then
			editBoxFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
		else
			editBoxFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
		end
	end
	local dirty
	if level.lastDirection == "RIGHT" then
		if editBoxFrame:GetRight() > GetScreenWidth() then
			level.lastDirection = "LEFT"
			dirty = true
		end
	elseif editBoxFrame:GetLeft() < 0 then
		level.lastDirection = "RIGHT"
		dirty = true
	end
	if level.lastVDirection == "DOWN" then
		if editBoxFrame:GetBottom() < 0 then
			level.lastVDirection = "UP"
			dirty = true
		end
	elseif editBoxFrame:GetTop() > GetScreenWidth() then
		level.lastVDirection = "DOWN"
		dirty = true
	end
	if dirty then
		editBoxFrame:ClearAllPoints()
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				editBoxFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
			else
				editBoxFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				editBoxFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
			else
				editBoxFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
			end
		end
	end
	local left, bottom = editBoxFrame:GetLeft(), editBoxFrame:GetBottom()
	editBoxFrame:ClearAllPoints()
	editBoxFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	if mod(level.num, 5) == 0 then
		local left, bottom = level:GetLeft(), level:GetBottom()
		level:ClearAllPoints()
		level:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	end
	editBoxFrame:SetClampedToScreen(true)
end

function lib:EncodeKeybinding(text)
	if text == nil or text == "NONE" then
		return nil
	end
	text = tostring(text):upper()
	local shift, ctrl, alt
	local modifier
	while true do
		if text == "-" then
			break
		end
		modifier, text = strsplit('-', text, 2)
		if text then
			if modifier ~= "SHIFT" and modifier ~= "CTRL" and modifier ~= "ALT" then
				return false
			end
			if modifier == "SHIFT" then
				if shift then
					return false
				end
				shift = true
			end
			if modifier == "CTRL" then
				if ctrl then
					return false
				end
				ctrl = true
			end
			if modifier == "ALT" then
				if alt then
					return false
				end
				alt = true
			end
		else
			text = modifier
			break
		end
	end
	if not text:find("^F%d+$") and text ~= "CAPSLOCK" and text:len() ~= 1 and (text:len() == 0 or text:byte() < 128 or text:len() > 4) and not _G["KEY_" .. text] and text ~= "BUTTON1" and text ~= "BUTTON2" then
		return false
	end
	local s = GetBindingText(text, "KEY_")
	if s == "BUTTON1" then
		s = KEY_BUTTON1
	elseif s == "BUTTON2" then
		s = KEY_BUTTON2
	end
	if shift then
		s = "Shift-" .. s
	end
	if ctrl then
		s = "Ctrl-" .. s
	end
	if alt then
		s = "Alt-" .. s
	end
	return s
end

function lib:IsOpen(parent)
	self:argCheck(parent, 2, "table", "string", "nil")
	return levels[1] and levels[1]:IsShown() and (not parent or parent == levels[1].parent or parent == levels[1]:GetParent())
end

function lib:GetOpenedParent()
	return (levels[1] and levels[1]:IsShown()) and (levels[1].parent or levels[1]:GetParent())
end

function Open(parent, func, level, value, point, relativePoint, cursorX, cursorY)
	lib:Close(level)
	if type(parent) == "table" then
		parent:GetCenter()
	end
	local frame = AcquireLevel(level)
	if level == 1 then
		frame.lastDirection = "RIGHT"
		frame.lastVDirection = "DOWN"
	else
		frame.lastDirection = levels[level - 1].lastDirection
		frame.lastVDirection = levels[level - 1].lastVDirection
	end
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:ClearAllPoints()
	frame.parent = parent
	frame:SetPoint("LEFT", UIParent, "RIGHT", 10000, 0)
	frame:Show()
	if level == 1 then
		baseFunc = func
	end
	levels[level].value = value
--	levels[level].parentText = parent.text and parent.text:GetText() or nil
--	levels[level].parentTooltipTitle = parent.tooltipTitle
--	levels[level].parentTooltipText = parent.tooltipText
--	levels[level].parentTooltipFunc = parent.tooltipFunc
	if type(parent) == "table" and parent.arrow then
--		parent.arrow:SetVertexColor(0.2, 0.6, 0)
--		parent.arrow:SetHeight(24)
--		parent.arrow:SetWidth(24)
		parent.selected = true
		parent.highlight:Show()
	end
	relativePoint = relativePoint or point
	Refresh(levels[level])
	if point or (cursorX and cursorY) then
		frame:ClearAllPoints()
		if cursorX and cursorY then
			local curX, curY = GetScaledCursorPosition()
			if curY < GetScreenHeight() / 2 then
				point, relativePoint = "BOTTOM", "BOTTOM"
			else
				point, relativePoint = "TOP", "TOP"
			end
			if curX < GetScreenWidth() / 2 then
				point, relativePoint = point .. "LEFT", relativePoint .. "RIGHT"
			else
				point, relativePoint = point .. "RIGHT", relativePoint .. "LEFT"
			end
		end
		frame:SetPoint(point, type(parent) == "table" and parent or UIParent, relativePoint)
		if cursorX and cursorY then
			local left = frame:GetLeft()
			local width = frame:GetWidth()
			local bottom = frame:GetBottom()
			local height = frame:GetHeight()
			local curX, curY = GetScaledCursorPosition()
			frame:ClearAllPoints()
			relativePoint = relativePoint or point
			if point == "BOTTOM" or point == "TOP" then
				if curX < GetScreenWidth() / 2 then
					point = point .. "LEFT"
				else
					point = point .. "RIGHT"
				end
			elseif point == "CENTER" then
				if curX < GetScreenWidth() / 2 then
					point = "LEFT"
				else
					point = "RIGHT"
				end
			end
			local xOffset, yOffset = 0, 0
			if curY > GetScreenHeight() / 2 then
				yOffset = -height
			end
			if curX > GetScreenWidth() / 2 then
				xOffset = -width
			end
			frame:SetPoint(point, type(parent) == "table" and parent or UIParent, relativePoint, curX - left + xOffset, curY - bottom + yOffset)
			if level == 1 then
				frame.lastDirection = "RIGHT"
			end
		elseif cursorX then
			local left = frame:GetLeft()
			local width = frame:GetWidth()
			local curX, curY = GetScaledCursorPosition()
			frame:ClearAllPoints()
			relativePoint = relativePoint or point
			if point == "BOTTOM" or point == "TOP" then
				if curX < GetScreenWidth() / 2 then
					point = point .. "LEFT"
				else
					point = point .. "RIGHT"
				end
			elseif point == "CENTER" then
				if curX < GetScreenWidth() / 2 then
					point = "LEFT"
				else
					point = "RIGHT"
				end
			end
			frame:SetPoint(point, type(parent) == "table" and parent or UIParent, relativePoint, curX - left - width / 2, 0)
			if level == 1 then
				frame.lastDirection = "RIGHT"
			end
		elseif cursorY then
			local bottom = frame:GetBottom()
			local height = frame:GetHeight()
			local curX, curY = GetScaledCursorPosition()
			frame:ClearAllPoints()
			relativePoint = relativePoint or point
			if point == "LEFT" or point == "RIGHT" then
				if curX < GetScreenHeight() / 2 then
					point = point .. "BOTTOM"
				else
					point = point .. "TOP"
				end
			elseif point == "CENTER" then
				if curX < GetScreenHeight() / 2 then
					point = "BOTTOM"
				else
					point = "TOP"
				end
			end
			frame:SetPoint(point, type(parent) == "table" and parent or UIParent, relativePoint, 0, curY - bottom - height / 2)
			if level == 1 then
				frame.lastDirection = "DOWN"
			end
		end
		if (strsub(point, 1, 3) ~= strsub(relativePoint, 1, 3)) then
			if frame:GetBottom() < 0 then
				local point, parent, relativePoint, x, y = frame:GetPoint(1)
				local change = GetScreenHeight() - frame:GetTop()
				local otherChange = -frame:GetBottom()
				if otherChange < change then
					change = otherChange
				end
				frame:SetPoint(point, parent, relativePoint, x, y + change)
			elseif frame:GetTop() > GetScreenHeight() then
				local point, parent, relativePoint, x, y = frame:GetPoint(1)
				local change = GetScreenHeight() - frame:GetTop()
				local otherChange = -frame:GetBottom()
				if otherChange < change then
					change = otherChange
				end
				frame:SetPoint(point, parent, relativePoint, x, y + change)
			end
		end
	end
	CheckDualMonitor(frame)
	frame:SetClampedToScreen( true )
	if level ~=1 then
		frame:SetClampedToScreen( false )
	end
	StartCounting(level)
end

function lib:IsRegistered(parent)
	self:argCheck(parent, 2, "table", "string")
	return not not self.registry[parent]
end

--[[
function lib:Register(parent, ...)
	self:argCheck(parent, 2, "table", "string")
	if self.registry[parent] then
		self:Unregister(parent)
	end
	local info = new(...)
	if type(info.children) == "table" then
		local err, position = validateOptions(info.children)

		if err then
			if position then
				lib:error(position .. ": " .. err)
			else
				lib:error(err)
			end
		end
	end
	self.registry[parent] = info
	if not info.dontHook and not self.onceRegistered[parent] and type(parent) == "table" then
		if parent:HasScript("OnMouseUp") then
			local script = parent:GetScript("OnMouseUp")
			parent:SetScript("OnMouseUp", function(self, ...)
				local arg1 = ...
				if script then
					script(self, ...)
				end
				if arg1 == "RightButton" and self.registry[parent] then
					if self:IsOpen(parent) then
						lib:Close()
					else
						self:Open(parent)
					end
				end
			end)
		end
		if parent:HasScript("OnMouseDown") then
			local script = parent:GetScript("OnMouseDown")
			parent:SetScript("OnMouseDown", function(self, ...)
				if script then
					script(self, ...)
				end
				if self.registry[parent] then
					lib:Close()
				end
			end)
		end
	end
	self.onceRegistered[parent] = true
end

function lib:Unregister(parent)
	self:argCheck(parent, 2, "table", "string")
	self.registry[parent] = nil
end
]]--

function lib:Open(parent, ...)
	self:argCheck(parent, 2, "table", "string")
	local info
	local k1 = ...
	if type(k1) == "table" and k1[0] and k1.IsObjectType and self.registry[k1] then
		info = tmp(select(2, ...))
		for k,v in pairs(self.registry[k1]) do
			if info[k] == nil then
				info[k] = v
			end
		end
	else
		info = tmp(...)
		if self.registry[parent] then
			for k,v in pairs(self.registry[parent]) do
				if info[k] == nil then
					info[k] = v
				end
			end
		end
	end
	local point = info.point
	local relativePoint = info.relativePoint
	local cursorX = info.cursorX
	local cursorY = info.cursorY
	if type(point) == "function" then
		local b
		point, b = point(parent)
		if b then
			relativePoint = b
		end
	end
	if type(relativePoint) == "function" then
		relativePoint = relativePoint(parent)
	end
	Open(parent, info.children, 1, nil, point, relativePoint, cursorX, cursorY)
end

function Clear(level)
	if level then
		if level.buttons then
			for i = #level.buttons, 1, -1 do
				ReleaseButton(level, i)
			end
		end
	end
end

function lib:Close(level)
	if DropDownList1:IsShown() then
		DropDownList1:Hide()
	end
	self:argCheck(level, 2, "number", "nil")
	if not level then
		level = 1
	end
	if level == 1 and levels[level] then
		levels[level].parented = false
	end
	if level > 1 and levels[level-1].buttons then
		local buttons = levels[level-1].buttons
		for _,button in ipairs(buttons) do
--			button.arrow:SetWidth(16)
--			button.arrow:SetHeight(16)
			button.selected = nil
			button.highlight:Hide()
--			button.arrow:SetVertexColor(1, 1, 1)
		end
	end
	if sliderFrame and sliderFrame.level >= level then
		sliderFrame:Hide()
	end
	if editBoxFrame and editBoxFrame.level >= level then
		editBoxFrame:Hide()
	end
	for i = level, #levels do
		Clear(levels[level])
		levels[i]:Hide()
		levels[i]:ClearAllPoints()
		levels[i]:SetPoint("CENTER", UIParent, "CENTER")
		levels[i].value = nil
	end
end

function lib:AddSeparator(level)
	level = levels[level or currentLevel]
	if not level or not level.buttons then return; end

	local prevbutton = level.buttons[#level.buttons]
	if not prevbutton then return; end

	if prevbutton.disabled and prevbutton.text:GetText() == "" then
		return
	end
	self:AddLine("text", "", "disabled", true)
end

function lib:AddLine(...)
	local info = tmp(...)
	if info.hidden then
		return
	end
	local level = info.level or currentLevel
	info.level = nil
	local button = AcquireButton(level)
	if not next(info) then
		info.disabled = true
	end
	button.disabled = info.isTitle or info.notClickable or info.disabled or (InCombatLockdown( ) and info.secure)
	button.isTitle = info.isTitle
	button.notClickable = info.notClickable
	if button.isTitle then
		button.text:SetFontObject(GameFontNormalSmall)
	elseif button.notClickable then
		button.text:SetFontObject(GameFontHighlightSmall)
	elseif button.disabled then
		button.text:SetFontObject(GameFontDisableSmall)
	else
		button.text:SetFontObject(GameFontHighlightSmall)
	end
	if info.disabled then
		button.arrow:SetDesaturated(true)
		button.check:SetDesaturated(true)
	else
		button.arrow:SetDesaturated(false)
		button.check:SetDesaturated(false)
	end
	if info.textR and info.textG and info.textB then
		button.textR = info.textR
		button.textG = info.textG
		button.textB = info.textB
		button.text:SetTextColor(button.textR, button.textG, button.textB)
	else
		button.text:SetTextColor(button.text:GetFontObject():GetTextColor())
	end
	button.notCheckable = info.notCheckable
	button.text:SetPoint("LEFT", button, "LEFT", button.notCheckable and 0 or 24, 0)
	button.checked = not info.notCheckable and info.checked
	button.mouseoverUnderline = info.mouseoverUnderline
	button.isRadio = not info.notCheckable and info.isRadio
	if info.isRadio then
		button.check:Show()
		setTexture(button.check,info.checkIcon or [[Interface\Buttons\UI-RadioButton]])
		if button.checked then
			button.check:SetTexCoord(0.25, 0.5, 0, 1)
			button.check:SetVertexColor(1, 1, 1, 1)
		else
			button.check:SetTexCoord(0, 0.25, 0, 1)
			button.check:SetVertexColor(1, 1, 1, 0.5)
		end
		setTexture(button.radioHighlight,info.checkIcon or [[Interface\Buttons\UI-RadioButton]])
		button.check:SetWidth(16)
		button.check:SetHeight(16)
	elseif info.icon then
		button.check:Show()
		setTexture(button.check,info.icon)
		if info.iconWidth and info.iconHeight then
			button.check:SetWidth(info.iconWidth)
			button.check:SetHeight(info.iconHeight)
		else
			button.check:SetWidth(16)
			button.check:SetHeight(16)
		end
		if info.iconCoordLeft and info.iconCoordRight and info.iconCoordTop and info.iconCoordBottom then
			button.check:SetTexCoord(info.iconCoordLeft, info.iconCoordRight, info.iconCoordTop, info.iconCoordBottom)
		elseif type(info.icon) == "number" or (type(info.icon) == "string" and info.icon:find([["^Interface\Icons\]])) then
			button.check:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		else
			button.check:SetTexCoord(0, 1, 0, 1)
		end
		button.check:SetVertexColor(1, 1, 1, 1)
	else
		if button.checked then
			if info.checkIcon then
				button.check:SetWidth(16)
				button.check:SetHeight(16)
				setTexture(button.check,info.checkIcon)
				if info.checkIcon:find([[^Interface\Icons\]]) then
					button.check:SetTexCoord(0.05, 0.95, 0.05, 0.95)
				else
					button.check:SetTexCoord(0, 1, 0, 1)
				end
			else
				button.check:SetWidth(24)
				button.check:SetHeight(24)
				setTexture(button.check,[[Interface\Buttons\UI-CheckBox-Check]])
				button.check:SetTexCoord(0, 1, 0, 1)
			end
			button.check:SetVertexColor(1, 1, 1, 1)
		else
			button.check:SetVertexColor(1, 1, 1, 0)
		end
	end
	if not button.disabled then
		button.func = info.func
		button.secure = info.secure
	end
	button.hasColorSwatch = info.hasColorSwatch
	if button.hasColorSwatch then
		button.colorSwatch:Show()
		button.colorSwatch.texture:Show()
		button.r = info.r or 1
		button.g = info.g or 1
		button.b = info.b or 1
		button.hasOpacity = info.hasOpacity
		button.opacity = info.opacity or 1
		button.colorSwatch.texture:SetColorTexture(button.r, button.g, button.b, opacity)
		button.checked = false
		button.func = nil
		button.colorFunc = info.colorFunc
		local i = 1
		while true do
			local k = "colorArg" .. i
			local x = info[k]
			if x == nil then
				break
			end
			button[k] = x
			i = i + 1
		end
	else
		button.colorSwatch:Hide()
		button.colorSwatch.texture:Hide()
	end
	button.hasArrow = not button.hasColorSwatch and (info.value or info.hasSlider or info.hasEditBox) and info.hasArrow
	if button.hasArrow then
		button.arrow:SetAlpha(1)
		if info.hasSlider then
			button.hasSlider = true
			button.sliderMin = info.sliderMin or 0
			button.sliderMax = info.sliderMax or 1
			button.sliderStep = info.sliderStep or 0
			button.sliderBigStep = info.sliderBigStep or button.sliderStep
			if button.sliderBigStep < button.sliderStep then
				button.sliderBigStep = button.sliderStep
			end
			button.sliderIsPercent = info.sliderIsPercent and true or false
			button.sliderMinText = info.sliderMinText or button.sliderIsPercent and string.format("%.0f%%", button.sliderMin * 100) or button.sliderMin
			button.sliderMaxText = info.sliderMaxText or button.sliderIsPercent and string.format("%.0f%%", button.sliderMax * 100) or button.sliderMax
			button.sliderFunc = info.sliderFunc
			button.sliderValue = info.sliderValue
			button.fromAceOptions = info.fromAceOptions
			local i = 1
			while true do
				local k = "sliderArg" .. i
				local x = info[k]
				if x == nil then
					break
				end
				button[k] = x
				i = i + 1
			end
		elseif info.hasEditBox then
			button.hasEditBox = true
			button.editBoxText = info.editBoxText or ""
			button.editBoxFunc = info.editBoxFunc
			local i = 1
			while true do
				local k = "editBoxArg" .. i
				local x = info[k]
				if x == nil then
					break
				end
				button[k] = x
				i = i + 1
			end
			button.editBoxChangeFunc = info.editBoxChangeFunc
			local i = 1
			while true do
				local k = "editBoxChangeArg" .. i
				local x = info[k]
				if x == nil then
					break
				end
				button[k] = x
				i = i + 1
			end
			button.editBoxValidateFunc = info.editBoxValidateFunc
			local i = 1
			while true do
				local k = "editBoxValidateArg" .. i
				local x = info[k]
				if x == nil then
					break
				end
				button[k] = x
				i = i + 1
			end
			button.editBoxIsKeybinding = info.editBoxIsKeybinding
			button.editBoxKeybindingOnly = info.editBoxKeybindingOnly
			button.editBoxKeybindingExcept = info.editBoxKeybindingExcept
		else
			button.value = info.value
			local l = levels[level+1]
			if l and info.value == l.value then
--				button.arrow:SetWidth(24)
--				button.arrow:SetHeight(24)
				button.selected = true
				button.highlight:Show()
			end
		end
	else
		button.arrow:SetAlpha(0)
	end
	local i = 1
	while true do
		local k = "arg" .. i
		local x = info[k]
		if x == nil then
			break
		end
		button[k] = x
		i = i + 1
	end
	button.closeWhenClicked = info.closeWhenClicked
	button.textHeight = ( info.textHeight or UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT or 10 ) + ( ( info.isTitle and 2 ) or 0 )
	local font,_ = button.text:GetFont()
	button.text:SetFont(STANDARD_TEXT_FONT or [[Fonts\FRIZQT__.TTF]], button.textHeight)
	button:SetHeight(button.textHeight + 6)
	button.text:SetPoint("RIGHT", button.arrow, (button.hasColorSwatch or button.hasArrow) and "LEFT" or "RIGHT")
	button.text:SetJustifyH(info.justifyH or "LEFT")
	button.text:SetText(info.text)
	button.tooltipTitle = info.tooltipTitle
	button.tooltipText = info.tooltipText
	button.tooltipFunc = info.tooltipFunc
	button.tooltipLink = info.tooltipLink
	local i = 1
	while true do
		local k = "tooltipArg" .. i
		local x = info[k]
		if x == nil then
			break
		end
		button[k] = x
		i = i + 1
	end
	if not button.tooltipTitle and not button.tooltipText and not button.tooltipFunc and not button.tooltipLink and not info.isTitle then
		button.tooltipTitle = info.text
	end
	if type(button.func) == "string" then
		if type(button.arg1) ~= "table" then
			lib:error("Cannot call method %q on a non-table", button.func)
		end
		if type(button.arg1[button.func]) ~= "function" then
			lib:error("Method %q nonexistant.", button.func)
		end
	end
end

function lib:InjectAceOptionsTable(handler, options)
	lib:argCheck(handler, 2, "table")
	lib:argCheck(options, 3, "table")
	if tostring(options.type):lower() ~= "group" then
		lib:error('Cannot inject into options table argument #3 if its type is not "group"')
	end
	if options.handler ~= nil and options.handler ~= handler then
		lib:error("Cannot inject into options table argument #3 if it has a different handler than argument #2")
	end
	options.handler = handler
	local class = handler.class
	if not AceLibrary:HasInstance("AceOO-2.0") or not class then
		if Rock then
			-- possible Rock object
			for mixin in Rock:IterateObjectMixins(handler) do
				if type(mixin.GetAceOptionsDataTable) == "function" then
					local t = mixin:GetAceOptionsDataTable(handler)
					for k,v in pairs(t) do
						if type(options.args) ~= "table" then
							options.args = {}
						end
						if options.args[k] == nil then
							options.args[k] = v
						end
					end
				end
			end
		end
	else
		-- Ace2 object
		while class and class ~= AceLibrary("AceOO-2.0").Class do
			if type(class.GetAceOptionsDataTable) == "function" then
				local t = class:GetAceOptionsDataTable(handler)
				for k,v in pairs(t) do
					if type(options.args) ~= "table" then
						options.args = {}
					end
					if options.args[k] == nil then
						options.args[k] = v
					end
				end
			end
			local mixins = class.mixins
			if mixins then
				for mixin in pairs(mixins) do
					if type(mixin.GetAceOptionsDataTable) == "function" then
						local t = mixin:GetAceOptionsDataTable(handler)
						for k,v in pairs(t) do
							if type(options.args) ~= "table" then
								options.args = {}
							end
							if options.args[k] == nil then
								options.args[k] = v
							end
						end
					end
				end
			end
			class = class.super
		end
	end
	return options
end

function lib:OnTooltipHide()
	if lastSetFont then
		if lastSetFont == normalFont then
			lastSetFont = nil
			return
		end
		fillRegionTmp(GameTooltip:GetRegions())
		for i,v in ipairs(regionTmp) do
			if v.GetFont then
				local font,size,outline = v:GetFont()
				if font == lastSetFont then
					v:SetFont(normalFont, size, outline)
				end
			end
			regionTmp[i] = nil
		end
		lastSetFont = nil
	end
end

local function activate()
	
	local self = lib
	
	lib.registry = {}
	lib.onceRegistered = {}
	
	local WorldFrame_OnMouseDown = WorldFrame:GetScript("OnMouseDown")
	local WorldFrame_OnMouseUp = WorldFrame:GetScript("OnMouseUp")
	local oldX, oldY, clickTime
	
	WorldFrame:SetScript( "OnMouseDown",
		function( self, ... )
			oldX,oldY = GetCursorPosition( )
			clickTime = GetTime( )
			if WorldFrame_OnMouseDown then
				WorldFrame_OnMouseDown( self, ... )
			end
		end
	)
	
	WorldFrame:SetScript( "OnMouseUp",
		function( self, ... )
			local x,y = GetCursorPosition( )
			if not oldX or not oldY or not x or not y or not clickTime then
				lib:Close( )
				if WorldFrame_OnMouseUp then
					WorldFrame_OnMouseUp( self, ... )
				end
				return
			end
			local d = math.abs( x - oldX ) + math.abs( y - oldY )
			if d <= 5 and GetTime( ) - clickTime < 0.5 then
				lib:Close( )
			end
			if WorldFrame_OnMouseUp then
				WorldFrame_OnMouseUp( self, ... )
			end
		end
	)
	
	hooksecurefunc( DropDownList1, "Show",
		function( )
			if levels[1] and levels[1]:IsVisible( ) then
				lib:Close( )
			end
		end
	)
	
	hooksecurefunc( "HideDropDownMenu",
		function( )
			if levels[1] and levels[1]:IsVisible( ) then
				lib:Close( )
			end
		end
	)
	
	hooksecurefunc( "CloseDropDownMenus",
		function( )
			if levels[1] and levels[1]:IsVisible( ) then
				local stack = debugstack( )
				if not stack:find( "HandleGlobalMouseEvent" ) then
					lib:Close( )
				end
			end
		end
	)
	
	lib.frame = CreateFrame("Frame")
	lib.frame:UnregisterAllEvents( )
	lib.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	lib.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	lib.frame:SetScript( "OnUpdate",
		function( self, elapsed )
			self:Hide( )
			Refresh( 1 )
		end
	)
	
	lib.frame:Show()
	lib.hookedTooltip = true
	
	local OnTooltipHide = GameTooltip:GetScript("OnHide")
	GameTooltip:SetScript( "OnHide",
		function( self, ... )
			if OnTooltipHide then
				OnTooltipHide( self, ... )
			end
			if type( self.OnTooltipHide ) == "function" then
				self:OnTooltipHide( )
			end
		end
	)
	
	levels = {}
	buttons = {}
	
end

activate( )

function lib:argCheck(arg, num, kind, kind2, kind3, kind4, kind5)
	if type(num) ~= "number" then
		return error(self, "Bad argument #3 to `argCheck' (number expected, got %s)", type(num))
	elseif type(kind) ~= "string" then
		return error(self, "Bad argument #4 to `argCheck' (string expected, got %s)", type(kind))
	end
	arg = type(arg)
	if arg ~= kind and arg ~= kind2 and arg ~= kind3 and arg ~= kind4 and arg ~= kind5 then
		local stack = debugstack()
		local func = stack:match("`argCheck'.-([`<].-['>])")
		if not func then
			func = stack:match("([`<].-['>])")
		end
		if kind5 then
			return error(self, "Bad argument #%s to %s (%s, %s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, kind5, arg)
		elseif kind4 then
			return error(self, "Bad argument #%s to %s (%s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, arg)
		elseif kind3 then
			return error(self, "Bad argument #%s to %s (%s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, arg)
		elseif kind2 then
			return error(self, "Bad argument #%s to %s (%s or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, arg)
		else
			return error(self, "Bad argument #%s to %s (%s expected, got %s)", tonumber(num) or 0/0, func, kind, arg)
		end
	end
end

function lib:error(message, ...)
	if type(self) ~= "table" then
		return _G.error(("Bad argument #1 to `error' (table expected, got %s)"):format(type(self)), 2)
	end
	
	local stack = debugstack()
	if not message then
		local second = stack:match("\n(.-)\n")
		message = "error raised! " .. second
	else
		local arg = { ... } -- not worried about table creation, as errors don't happen often
		
		for i = 1, #arg do
			arg[i] = tostring(arg[i])
		end
		for i = 1, 10 do
			arg[#arg + 1] = "nil"
		end
		message = message:format(unpack(arg))
	end
	
	if getmetatable(self) and getmetatable(self).__tostring then
		message = ("%s: %s"):format(tostring(self), message)
	elseif type(rawget(self, 'GetLibraryVersion')) == "function" and AceLibrary:HasInstance(self:GetLibraryVersion()) then
		message = ("%s: %s"):format(self:GetLibraryVersion(), message)
	elseif type(rawget(self, 'class')) == "table" and type(rawget(self.class, 'GetLibraryVersion')) == "function" and AceLibrary:HasInstance(self.class:GetLibraryVersion()) then
		message = ("%s: %s"):format(self.class:GetLibraryVersion(), message)
	end
	
	local first = stack:gsub("\n.*", "")
	local file = first:gsub(".*\\(.*).lua:%d+: .*", "%1")
	file = file:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
	
	
	local i = 0
	for s in stack:gmatch("\n([^\n]*)") do
		i = i + 1
		if not s:find(file .. "%.lua:%d+:") and not s:find("%(tail call%)") then
			file = s:gsub("^.*\\(.*).lua:%d+: .*", "%1")
			file = file:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
			break
		end
	end
	local j = 0
	for s in stack:gmatch("\n([^\n]*)") do
		j = j + 1
		if j > i and not s:find(file .. "%.lua:%d+:") and not s:find("%(tail call%)") then
			return _G.error(message, j+1)
		end
	end
	return _G.error(message, 2)
end
