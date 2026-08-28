--!strict

export type BootstrapContract = {
	contractVersion: number,
	projectName: string,
}

local contract: BootstrapContract = {
	contractVersion = 1,
	projectName = "InfiniteCardCollector",
}

return table.freeze(contract)
