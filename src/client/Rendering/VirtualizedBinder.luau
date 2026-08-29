--!strict

local VirtualizedBinder = {}

function VirtualizedBinder.visibleRange(
	totalItems: number,
	cellHeight: number,
	viewportHeight: number,
	scrollOffset: number,
	overscan: number
): any
	assert(totalItems >= 0 and totalItems % 1 == 0, "P002-VIRTUAL-001 total invalid")
	assert(cellHeight > 0, "P002-VIRTUAL-002 cell height invalid")
	assert(viewportHeight >= 0, "P002-VIRTUAL-003 viewport invalid")
	assert(scrollOffset >= 0, "P002-VIRTUAL-004 offset invalid")
	assert(overscan >= 0 and overscan % 1 == 0, "P002-VIRTUAL-005 overscan invalid")
	if totalItems == 0 then
		return { first = 0, last = 0, count = 0 }
	end
	local firstVisible = math.floor(scrollOffset / cellHeight) + 1
	local lastVisible = math.ceil((scrollOffset + viewportHeight) / cellHeight)
	local first = math.max(1, firstVisible - overscan)
	local last = math.min(totalItems, math.max(first, lastVisible + overscan))
	return { first = first, last = last, count = last - first + 1 }
end

function VirtualizedBinder.project(items: { any }, range: any): { any }
	local result = {}
	for index = range.first, range.last do
		if index > 0 and items[index] ~= nil then
			table.insert(result, { index = index, item = items[index] })
		end
	end
	return result
end

return table.freeze(VirtualizedBinder)
