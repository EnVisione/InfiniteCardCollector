--!strict

local CardRenderer3D = {}

CardRenderer3D.version = 1

function CardRenderer3D.render(viewModel: any): any
	local children = {}
	for index, layer in viewModel.layers do
		children[index] = {
			className = if layer.id == "status" then "StatusBillboard" else "Layer3D",
			layerId = layer.id,
			valueId = layer.valueId,
			text = layer.text,
			values = layer.values,
			animated = viewModel.settings.animated,
			flashing = viewModel.settings.flashing,
		}
	end
	return {
		adapterVersion = CardRenderer3D.version,
		className = "CardModel3D",
		instanceId = viewModel.instanceId,
		accessibleName = viewModel.accessibleName,
		semanticLayers = viewModel.layers,
		children = children,
	}
end

return table.freeze(CardRenderer3D)
