--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootstrapContract = require(ReplicatedStorage.Shared.BootstrapContract)

script.Parent:SetAttribute("BootstrapContractVersion", BootstrapContract.contractVersion)
script.Parent:SetAttribute("BootstrapState", "ready")
