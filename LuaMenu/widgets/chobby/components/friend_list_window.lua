FriendListWindow = ListWindow:extends{}

-----------------------------
-- FriendListWindow functions
-----------------------------

function FriendListWindow:CompareItems(userName1, userName2)
	return userName1:lower() < userName2:lower()
end

function FriendListWindow:AddFriendRequest(userName)
	local userControl = WG.UserHandler.GetFriendRequestUser(userName)
	userControl:SetPos(0, 0, 250, 80)
	local lblFriendRequest = Label:New {
		x = 0,
		y = 0,
		width = 100,
		height = 30,
		caption = i18n("friend_request"),
		objectOverrideFont = WG.Chobby.Configuration:GetFont(1, "friend_request", {color = { 0.5, 0.5, 0.5, 1 }}),
	}
	lblFriendRequest.font.color = { 0.5, 0.5, 0.5, 1 }
	lblFriendRequest:Invalidate()
	local btnAccept = Button:New {
		x = 10,
		y = 50,
		width = 100,
		height = 30,
		caption = i18n("accept"),
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		classname = "option_button",
		OnClick = {
			function()
				-- self:RemoveRow(userName)
				lobby:AcceptFriendRequest(userName)
			end
		},
	}
	local btnDecline = Button:New {
		x = 250 - 100 - 10,
		y = 50,
		width = 100,
		height = 30,
		caption = i18n("decline"),
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		classname = "negative_button",
		OnClick = {
			function()
				-- self:RemoveRow(userName)
				lobby:DeclineFriendRequest(userName)
			end
		},
	}
	self:AddRow({lblFriendRequest, btnAccept, btnDecline, userControl}, userName)
end

function FriendListWindow:AddFriend(userName)
	local userControl = WG.UserHandler.GetFriendUser(userName)
	--userControl:SetPos(0, 0, 250, 80)
	self:AddRow({userControl}, userName)
end

function FriendListWindow:AddOutgoingFriendRequest(userName)
	local userControl = WG.UserHandler.GetFriendRequestUser(userName)
	userControl:SetPos(0, 0, 250, 80)
	local lblFriendRequest = Label:New {
		x = 0,
		y = 0,
		width = 100,
		height = 30,
		caption = i18n("friend_request_out"),
		objectOverrideFont = WG.Chobby.Configuration:GetFont(1, "friend_request", {color = { 0.5, 0.5, 0.5, 1 }}),
	}
	lblFriendRequest.font.color = { 0.5, 0.5, 0.5, 1 }
	lblFriendRequest:Invalidate()
	local btnRescind = Button:New {
		x = 10,
		y = 50,
		width = 100,
		height = 30,
		caption = i18n("cancel"),
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		classname = "option_button",
		OnClick = {
			function()
				-- self:RemoveRow(userName)
				lobby:RescindFriendRequest(userName)
			end
		},
	}

	self:AddRow({lblFriendRequest, btnRescind, userControl}, userName)
end

---------------------
-- listener functions
---------------------

function FriendListWindow:OnAddUser(userName)
	local userInfo = lobby:TryGetUser(userName)
	if userInfo.isFriend then
		if WG.Chobby.Configuration.friendsFilterOnline then
			self:AddFriend(userInfo.userName)
		end
		if WG.Chobby.Configuration:AllowNotification(userName) then
			local userControl = WG.UserHandler.GetNotificationUser(userName)
			userControl:SetPos(30, 30, 250, 80)
			Chotify:Post({
				title = i18n("user_online"),
				body  = userControl,
			})
		end
	elseif userInfo.hasOutgoingFriendRequest then
		self:AddOutgoingFriendRequest(userInfo.userName)
	elseif userInfo.hasFriendRequest then
		self:AddFriendRequest(userInfo.userName)
	end
end

function FriendListWindow:OnRemoveUser(userName)
	if lobby.status ~= "connected" then
		return
	end
	local userInfo = lobby:GetUser(userName)
	if not userInfo then
		return
	end
	if (WG.Chobby.Configuration.friendsFilterOnline and userInfo.isFriend) or userInfo.hasOutgoingFriendRequest or userInfo.hasFriendRequest then
		self:RemoveRow(userInfo.userName)
	end
	if userInfo.isFriend and WG.Chobby.Configuration:AllowNotification(userName) then
		local userControl = WG.UserHandler.GetNotificationUser(userName)
		userControl:SetPos(30, 30, 250, 80)
		Chotify:Post({
			title = i18n("user_offline"),
			body  = userControl,
		})
	end
end

function FriendListWindow:OnFriend(userName)
	if WG.Chobby.Configuration.friendActivityNotification then
		interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	end

	if WG.Chobby.Configuration.friendsFilterOnline then
		local userInfo = lobby:GetUser(userName)
		if not userInfo or userInfo.isOffline then
			return
		end
	end
	self:AddFriend(userName)
end

function FriendListWindow:OnUnfriendByID(userID, userName)
-- 	interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	self:RemoveRow(userName)
end

function FriendListWindow:OnFriendList(friends)
	if WG.Chobby.Configuration.friendActivityNotification then
		interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	end
	for _, userName in pairs(friends) do
		self:AddFriend(userName)
	end
end

function FriendListWindow:OnFriendRequest(userName)
	if WG.Chobby.Configuration.friendActivityNotification then
		interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	end

	local userInfo = lobby:GetUser(userName)
	if not userInfo then
		return
	end

	self:AddFriendRequest(userName)
end

function FriendListWindow:OnOutgoingFriendRequest(userName)

	local userInfo = lobby:GetUser(userName)
	if not userInfo then
		return
	end

	self:AddOutgoingFriendRequest(userName)
end

function FriendListWindow:RemoveFriendRequestByID(userID, userName)
	if WG.Chobby.Configuration.friendActivityNotification then
		interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	end
	self:RemoveRow(userName)
end

function FriendListWindow:OnRemoveOutgoingFriendRequestByID(userID, userName)
	self:RemoveRow(userName)
end

function FriendListWindow:OnFriendRequestList(friendRequests)
	if WG.Chobby.Configuration.friendActivityNotification then
		interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	end
	for _, userName in pairs(friendRequests) do
		self:AddFriendRequest(userName)
	end
end

function FriendListWindow:OnAccepted()
	self:Clear()
	--lobby:FriendList()
	--lobby:FriendRequestList()
end

function FriendListWindow:OnNewFriendRequestByID(userID, userName)
	if WG.Chobby.Configuration:AllowNotification() then
		local userControl = WG.UserHandler.GetNotificationUser(userName)
		userControl:SetPos(20, 40, 250, 80)
		Chotify:Post({
			title = i18n("friend_request_new"),
			body  = userControl,
		})
	end
end

function FriendListWindow:OnFriendRequestAcceptedByID(userID, userName)
	if WG.Chobby.Configuration:AllowNotification() then
		local userControl = WG.UserHandler.GetNotificationUser(userName)
		userControl:SetPos(20, 40, 250, 80)
		Chotify:Post({
			title = i18n("friend_request_accepted"),
			body  = userControl,
		})
	end
end

function FriendListWindow:HideOfflineFriends()
	local friends = lobby:GetFriends()
	for _, userName in pairs(friends) do
		local userInfo = lobby:GetUser(userName)
		if not userInfo or userInfo.isOffline then
			self:RemoveRow(userName)
		end
	end
end

function FriendListWindow:ShowAllFriends()
	self:Clear()

	local outFriendRequests = lobby:GetOutgoingFriendRequestsByID()
	for _, userID in pairs(outFriendRequests) do
		local userInfo = lobby:GetUserByID(userID)
		self:AddOutgoingFriendRequest(userInfo.userName)
	end

	local friendRequests = lobby:GetFriendRequests()
	for _, userName in pairs(friendRequests) do
		self:AddFriendRequest(userName)
	end

	local friends = lobby:GetFriends()
	for _, userName in pairs(friends) do
		self:AddFriend(userName)
	end
end

function FriendListWindow:init(parent)
	self:super("init", parent, i18n("friends"), true, nil, true)

	self:SetMinItemWidth(240)
	self.columns = 3
	self.itemHeight = 82
	self.itemPadding = 0

	self.btnSteamFriends = Button:New {
		right = 101,
		y = 7,
		width = 180,
		height = 45,
		caption = i18n("invite_friends"),
		objectOverrideFont = WG.Chobby.Configuration:GetFont(3),
		classname = "option_button",
		parent = self.window,
		OnClick = {
			function ()
				WG.SteamHandler.OpenFriendList()
			end
		},
	}

	if WG.Chobby.Configuration.addFriendWindowButton then
		local addFriendEditBox = EditBox:New {
			right = 440,
			width = 130,
			y = 15,
			height = 30,
			text = "",
			objectOverrideFont = WG.Chobby.Configuration:GetFont(1),
			objectOverrideHintFont = WG.Chobby.Configuration:GetFont(1),
			useIME = false,
			parent = self.window,
			tooltip = "Name of new friend",
		}

		local addFriendButton = Button:New {
			right = 310,
			width = 120,
			y = 15,
			height = 30,
			caption = "Add Friend",
			objectOverrideFont = WG.Chobby.Configuration:GetFont(1),
			classname = "option_button",
			tooltip = "Send a friend request to the entered username",
			parent = self.window,
			OnClick = {
				function()
					lobby:FriendRequest(addFriendEditBox.text)
				end
			},
		}
	end

	self.checkOnlineOnly = Checkbox:New {
		right = 165,
		width = 120,
		y = 15,
		height = 30,
		boxalign = "left",
		boxsize = 20,
		caption = i18n("friend_filter_online"),
		checked = false,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		OnClick = {function (obj)
			WG.Chobby.Configuration:SetConfigValue("friendsFilterOnline", obj.checked)
		end},
		parent = self.window,
		tooltip = "Shows online friends only",
	}

	self.makePartyButton = Button:New {
		right = 20,
		width = 120,
		y = 15,
		height = 30,
		caption = "Make Party",
		objectOverrideFont = WG.Chobby.Configuration:GetFont(1),
		classname = "option_button",
		parent = self.window,
		tooltip = "Opens the party manager on BAR server website in your browser",
		OnClick = {
			function()
				WG.BrowserHandler.OpenUrl("https://server4.beyondallreason.info/teiserver/account/parties")
			end
		},
	}

	self.btnSteamFriends:SetVisibility(Configuration.canAuthenticateWithSteam)
	local function onConfigurationChange(listener, key, value)
		if key == "canAuthenticateWithSteam" then
			self.btnSteamFriends:SetVisibility(value)
		elseif key == "friendsFilterOnline" then
			-- user config is loaded after friend_list_window was initialized, so we toggle this checkbox accordingly when the config value arrives
			if self.checkOnlineOnly.checked ~= value then
				self.checkOnlineOnly:SetToggle(value)
			end
			
			if value then
				self:HideOfflineFriends()
			else
				self:ShowAllFriends()
			end
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)

	lobby:AddListener("OnAddUser",                         function(listener, ...) self:OnAddUser(...) end)
	lobby:AddListener("OnRemoveUser",                      function(listener, ...) self:OnRemoveUser(...) end)
	lobby:AddListener("OnFriend",                          function(listener, ...) self:OnFriend(...) end)
	lobby:AddListener("OnUnfriendByID",                    function(listener, ...) self:OnUnfriendByID(...) end)
	lobby:AddListener("OnFriendRequest",                   function(listener, ...) self:OnFriendRequest(...) end)
	lobby:AddListener("OnRemoveFriendRequestByID",         function(listener, ...) self:RemoveFriendRequestByID(...) end)
	lobby:AddListener("OnAccepted",                        function(listener, ...) self:OnAccepted(...) end)
      
	lobby:AddListener("OnNewFriendRequestByID",            function(listener, ...) self:OnNewFriendRequestByID(...) end)
	lobby:AddListener("OnFriendRequestAcceptedByID",       function(listener, ...) self:OnFriendRequestAcceptedByID(...) end)
	lobby:AddListener("OnOutgoingFriendRequest",           function(listener, ...) self:OnOutgoingFriendRequest(...) end)

	lobby:AddListener("OnRemoveOutgoingFriendRequestByID", function(listener, ...) self:OnRemoveOutgoingFriendRequestByID(...) end)

	-- following lead to duplicate updates
	-- lobby:AddListener("OnFriendList",                function(listener, ...) self:OnFriendList(...) end)
	-- lobby:AddListener("OnFriendRequestList",         function(listener, ...) self:OnFriendRequestList(...) end)
end

function FriendListWindow:RemoveListeners()
	--[[
	Removing them is not possible here, because anonymous functions were added as listeners
	But it's ok, because there won't be more than 1 friend_window and we can easily clear it by clear() instead of reinitializing.
	
	A solution would be to move all these listener functions to gui_friend_window and add them to the instantiated friend_listwindow => WG.FriendWindow
	This way local functions could serve as listeners and call the WG.Friendwindow.XYZ functions, which then could use "self"
	
	Reason for this construction is:
	You can't add arguments to listeners while adding them.
	So you can't tell: Add this functionXY as listener, but call it like "functionXY(self, ...)" with self as first argument (which is the unshortened form of self:functionXY())

	lobby:RemoveListener("OnFriend",            OnFriend)
	lobby:RemoveListener("OnFriendList",        OnFriendList)
	lobby:RemoveListener("OnFriendRequest",     OnFriendRequest)
	lobby:RemoveListener("OnFriendRequestList", OnFriendRequestList)
	lobby:RemoveListener("OnAccepted",          OnAccepted)
	--]]
end
