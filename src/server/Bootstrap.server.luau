--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BootstrapContract = require(ReplicatedStorage.Shared.BootstrapContract)

local serverRoot = ServerScriptService.Server
serverRoot:SetAttribute("BootstrapContractVersion", BootstrapContract.contractVersion)
serverRoot:SetAttribute("BootstrapState", "ready")
