--!strict

local CardRenderer2D = {}

CardRenderer2D.version = 1

function CardRenderer2D.render(viewModel: any): any
	local children = {}
	for index, layer in viewModel.layers do
		children[index] = {
			className = if layer.id == "status" then "StatusGroup" else "Layer2D",
			layerId = layer.id,
			valueId = layer.valueId,
			text = layer.text,
			values = layer.values,
			animated = viewModel.settings.animated,
			flashing = viewModel.settings.flashing,
		}
	end
	return {
		adapterVersion = CardRenderer2D.version,
		className = "CardFrame2D",
		instanceId = viewModel.instanceId,
		accessibleName = viewModel.accessibleName,
		semanticLayers = viewModel.layers,
		children = children,
	}
end

return table.freeze(CardRenderer2D)
