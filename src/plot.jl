export plot_field, plot_device

using PyPlot, PyCall

"    plot_field(field::Field; cbar::Bool=false, funcz=real)"
function plot_field(field::Field; cbar::Bool=false, funcz=real)
	fig, ax = subplots(1);
	plot_field(ax, field; cbar=cbar, funcz=funcz);
	return ax
end

"    plot_field(ax::PyObject, field::Field; cbar::Bool=false, funcz=real)"
function plot_field(ax::PyObject, field::Field; cbar::Bool=false, funcz=real)
	isa(field, FieldTM) && (Z = funcz.(field.Ez).');
	isa(field, FieldTE) && (Z = funcz.(field.Hz).');

	if funcz == abs
		vmin = 0;
		vmax = +maximum(abs.(Z));
		cmap = "magma";
	elseif funcz == real
		Zmx  = maximum(abs.(Z));
		vmin = -maximum(Zmx);
		vmax = +maximum(Zmx);
		cmap = "RdBu";
	else
		error("Unknown function specified.");
	end

	extents = [ field.grid.bounds[1][1], field.grid.bounds[2][1], 
	            field.grid.bounds[1][2], field.grid.bounds[2][2] ];
	
	mappable = ax[:imshow](Z, cmap=cmap, extent=extents, origin="lower", vmin=vmin, vmax=vmax);
	cbar && colorbar(mappable, ax=ax, label=L"$\vert E \vert$");
	ax[:set_xlabel](L"$x$");
	ax[:set_ylabel](L"$y$");
end

"    plot_device(device::AbstractDevice; outline::Bool=false)"
function plot_device(device::AbstractDevice; outline::Bool=false)
	fig, ax = subplots(1);
	plot_device(ax, device; outline=outline);
	return ax
end

"    plot_device(ax::PyObject, device::AbstractDevice; outline::Bool=false, lc::String=\"k\")"
function plot_device(ax::PyObject, device::AbstractDevice; outline::Bool=false, lc::String="k")
	Z = real.(device.ϵᵣ)';

	if outline
		ax[:contour](xc(device.grid), yc(device.grid), Z, levels=1, linewidths=0.5, colors=lc);
		axis("image");
	else
		extents = [ device.grid.bounds[1][1], device.grid.bounds[2][1], 
		            device.grid.bounds[1][2], device.grid.bounds[2][2] ];
		ax[:imshow](Z, extent=extents, origin="lower");
	end
	ax[:set_xlabel](L"$x$");
	ax[:set_ylabel](L"$y$");
end