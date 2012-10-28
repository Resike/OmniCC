--[[
	cooldown.lua
		initializes OmniCC
--]]

local Cooldown = OmniCC:New('Cooldown')
local Timer = OmniCC.Timer


--[[ Control ]]--

function Cooldown:Start(...)
	if Cooldown.CanShow(self, ...) then
		if not self.omnicc then
			Cooldown.Setup(self)
		end

		local timer = Timer:Get(self) or Timer:New(self)
		timer:Start(...)
	else
		Cooldown.Stop(self)
	end
end

function Cooldown:Stop()
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer:Stop()
	end
end

function Cooldown:Setup()
	self:HookScript('OnShow', Cooldown.OnShow)
	self:HookScript('OnHide', Cooldown.OnHide)
	self:HookScript('OnSizeChanged', Cooldown.OnSizeChanged)
	self.omnicc = true
end


--[[ Frame Events ]]--

function Cooldown:OnShown()
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		if timer:GetRemain() > 0 then
			timer.visible = true
			timer:UpdateShown()
		else
			timer:Stop()
		end
	end
end

function Cooldown:OnHide()
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer.visible = nil
		timer:Hide()
	end
end

function Cooldown:OnSizeChanged(...)
	local width = ...
	if self.omniccw ~= width then
		self.omniccw = width
		
		local timer = Timer:Get(self)
		if timer then
			timer:UpdateFontSize(...)
		end
	end
end


--[[ Queries ]]--

local function Cooldown:CanShow(start, duration)
	if self.noCooldownCount or not (start and duration) or Cooldown.HasCharges(self) then
		return
	end
	
	local sets = OmniCC:GetGroupSettings(OmniCC:GetGroup(self)) 
	self:SetAlpha(sets.showCooldownModels and 1 or 0)
	
	if start > 0 and duration >= sets.minDuration and sets.enabled then
		return true
	end
end

local function Cooldown:HasCharges()
	local action = self.omniccAction or Cooldown.GetAction(self)
	return action and GetActionCharges(action) ~= 0
end

local function Cooldown:GetAction()
	local parent = self:GetParent()
	return parent and parent:GetAttribute('action')
end