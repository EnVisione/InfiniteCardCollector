--!strict

local InventoryStore = {}

function InventoryStore.new(): any
	local store = {}

	function store:getCard(profile: any, uid: string): any?
		return profile.cards[uid]
	end

	function store:putCard(profile: any, card: any): boolean
		if profile.cards[card.uid] ~= nil then
			return false
		end
		profile.cards[card.uid] = card
		return true
	end

	function store:removeCard(profile: any, uid: string): any?
		local card = profile.cards[uid]
		if card == nil then
			return nil
		end
		profile.cards[uid] = nil
		return card
	end

	function store:getJoker(profile: any, uid: string): any?
		return profile.jokers[uid]
	end

	function store:putJoker(profile: any, joker: any): boolean
		if profile.jokers[joker.uid] ~= nil then
			return false
		end
		profile.jokers[joker.uid] = joker
		return true
	end

	function store:containsUid(profile: any, uid: string): boolean
		return profile.cards[uid] ~= nil or profile.jokers[uid] ~= nil
	end

	function store:listCards(profile: any): { any }
		local cards = {}
		for _, card in profile.cards do
			table.insert(cards, card)
		end
		table.sort(cards, function(left, right)
			return left.uid < right.uid
		end)
		return cards
	end

	function store:listJokers(profile: any): { any }
		local jokers = {}
		for _, joker in profile.jokers do
			table.insert(jokers, joker)
		end
		table.sort(jokers, function(left, right)
			return left.uid < right.uid
		end)
		return jokers
	end

	return store
end

return table.freeze(InventoryStore)
