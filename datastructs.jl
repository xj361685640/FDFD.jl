export Geometry, Geometry1D, Geometry2D
export M, dx, dy, xc, yc, xe, ye, coord2ind

abstract type Geometry end

mutable struct Geometry1D <: Geometry
	N::Integer
	xrange::Tuple{Real,Real}
	ϵᵣ::Array{Complex,1}

	function Geometry1D(xrange::Tuple{Real,Real}, ϵᵣ::Array{Complex,1})
		return new(length(ϵᵣ), xrange, ϵᵣ)
	end
	
	function Geometry1D(dh::Real, xrange::Tuple{Real,Real})
		Nx = Int64(round((xrange[2]-xrange[1])/dh));
		ϵᵣ = ones(Complex128, Nx);
		println("# Geometry: grid size of ", Nx);
		return new(Nx, xrange, ϵᵣ)
	end
end

mutable struct Geometry2D <: Geometry
	N::Tuple{Integer,Integer}
	Npml::Tuple{Integer,Integer}
	xrange::Tuple{Real,Real}
	yrange::Tuple{Real,Real}
	ϵᵣ::Array{Complex,2}
	src::Array{Complex,2}

	function Geometry2D(N::Tuple{Integer,Integer}, Npml::Tuple{Integer,Integer}, xrange::Tuple{Real,Real}, yrange::Tuple{Real,Real})
		ϵᵣ = ones(Complex128, N);
		src = zeros(Complex128, N);
		return new(N, Npml, xrange, yrange, ϵᵣ, src)
	end

	function Geometry2D(N::Tuple{Integer,Integer}, xrange::Tuple{Real,Real}, yrange::Tuple{Real,Real})
		return Geometry2D(N, (0, 0), xrange, yrange)
	end

	function Geometry2D(dh::Real, Npml::Tuple{Integer,Integer}, xrange::Tuple{Real,Real}, yrange::Tuple{Real,Real})
		Nx = Int64(round((xrange[2]-xrange[1])/dh));
		Ny = Int64(round((yrange[2]-yrange[1])/dh));
		N = (Nx, Ny);
		println("# Geometry: grid size of ", N);
		return Geometry2D(N, Npml, xrange, yrange);
	end

	function Geometry2D(dh::Real, xrange::Tuple{Real,Real}, yrange::Tuple{Real,Real})
		return Geometry2D(dh, (0, 0), xrange, yrange);
	end	
end

function M(geom::Geometry)
	return prod(geom.N)
end

function dx(geom::Geometry)
	return (geom.xrange[2]-geom.xrange[1])/geom.N[1]
end

function dy(geom::Geometry2D)
	return (geom.yrange[2]-geom.yrange[1])/geom.N[2]
end

function xc(geom::Geometry)
	return geom.xrange[1]+dx(geom)*(0.5:1:geom.N[1])
end

function yc(geom::Geometry2D)
	return geom.yrange[1]+dy(geom)*(0.5:1:geom.N[2])
end

xc(geom::Geometry, i::CartesianIndex{2}) = xc(geom)[i.I[1]];
yc(geom::Geometry, i::CartesianIndex{2}) = yc(geom)[i.I[2]];
xc(geom::Geometry, i::Int64) = xc(geom)[ind2sub(geom.N, i)[1]];
yc(geom::Geometry, i::Int64) = yc(geom)[ind2sub(geom.N, i)[2]];

function xe(geom::Geometry)
	return geom.xrange[1]+dx(geom)*(0:1:geom.N[1])
end

function ye(geom::Geometry2D)
	return geom.yrange[1]+dy(geom)*(0:1:geom.N[2])
end

xe(geom::Geometry, i::CartesianIndex{2}) = xe(geom)[i.I[1]];
ye(geom::Geometry, i::CartesianIndex{2}) = ye(geom)[i.I[2]];
xe(geom::Geometry, i::Int64) = xe(geom)[ind2sub(geom.N, i)[1]];
ye(geom::Geometry, i::Int64) = ye(geom)[ind2sub(geom.N, i)[2]];

function coord2ind(geom::Geometry, xy)
    indx = Int64(round((xy[1]-geom.xrange[1])/(geom.xrange[2]-geom.xrange[1])*geom.N[1])+1);
    if typeof(geom) == Geometry1D
    	return indx
    else
    	indy = Int64(round((xy[2]-geom.yrange[1])/(geom.yrange[2]-geom.yrange[1])*geom.N[2])+1);
	end
    return (indx, indy)
end
