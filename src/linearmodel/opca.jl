
# solving for a dimension-reduced Y = XV', where X (n x d) is the original data, and Y (n x k) is projected 
# V (k x d) is the projection/loading matrix

type OnlinePCA{W<:Weighting} <: OnlineStat

	d::Int  # number of input vars
  k::Int  # number of principal components
  weighting::W
  n::Int

	V::MatF  # (k x d) pca loading matrix... eigvecs of cov (note: V[:,i] = v[:,i] / norm(V[:,i]))
	e::VecF	 # (k x 1) eigenvalues  (note: ith eigval ==  norm(V[:,i]))
  μs::Means{W}
 end

function OnlinePCA(d::Int, k::Int, wgt::Weighting = default(Weighting))
	OnlinePCA(d, k, wgt, 0, zeros(k,d), zeros(k), Means(d, wgt))
end


function OnlinePCA(x::VecF, k::Int, wgt::Weighting = default(Weighting))
	o = OnlinePCA(length(x), k, wgt)
	update!(o, x)
	o
end

function OnlinePCA(X::MatF, k::Int, wgt::Weighting = default(Weighting))
	o = OnlinePCA(size(X,2), k, wgt)
	update!(o, X)
	o
end



#-----------------------------------------------------------------------# state

# state vars: [normalizedBeta, rawBeta, Variance(y), Variance(x), std(ε), mostRecentEstimateOfY, nobs]
statenames(o::OnlinePCA) = [:V, :e, :μs, :nobs]
state(o::OnlinePCA) = Any[o.V, o.e, mean(o.μs), nobs(o)]


#---------------------------------------------------------------------# update!

# TODO: roughly based on Weng et al (2003): "Candid covariance-free incremental principal component analysis"
# used https://github.com/kevinhughes27/pyIPCA/blob/master/pyIPCA/ccipca.py as a reference


function update!(o::OnlinePCA, x::VecF)

	u = center!(o.μs, x)
	λ = weight(o)

	for i in 1:min(o.k, o.n)
		# if i == o.n
		if o.e[i] == 0. # this should be more robust than checking i == o.n

			# initialize ith principal component
			# o.V[:,i] = u
			row!(o.V, i, u)
			o.e[i] = norm(row(o.V, i))

		else

			# update the ith principal component
			# remember... o.e[i] == norm(o.V[:,i])
			# Vi = o.V[:,i]
			Vi = row(o.V, i)
			smooth!(Vi, u * (dot(u, Vi) / o.e[i]), λ)
			o.e[i] = norm(Vi)
			# o.V[:,i] = Vi
			row!(o.V, i, Vi)

			# TODO: which is the correct loading... Vi or Vi/ei???

			# subtract projection on ith PC
			u -= (dot(u, Vi) / o.e[i]^2) * Vi

		end
	end

	o.n += 1
	nothing
end


function update!(o::OnlinePCA, X::MatF)
	for i in 1:size(X,1)
		update!(o, vec(X[i,:]))
	end
end



function Base.empty!(o::OnlinePCA)
	o.V = zeros(o.k, o.d)
	o.e = zeros(o.k)
	o.n = 0
	o.μs = Means(o.d, o.weighting)
end

function Base.merge!(o1::OnlinePCA, o2::OnlinePCA)
	error("Merging undefined for PCA")
end


# returns a vector y = Vx
StatsBase.predict(o::OnlinePCA, x::VecF) = o.V * center(o.μs, x)


# ------------------------------------------------------------ unused

# type OnlinePCA{W<:Weighting} <: OnlineStat
# 		L::MatF  # pca loading matrix
# 		d::Int  # number of input vars
#     k::Int  # number of principal components
#     n::Int
#     weighting::W

#     # needed for update
#     e::Float64 	# ???
#     U::MatF   	# Projection matrix -- d x k/e^3... init to zeros
#     Z::MatF			# d x k/e^2... init to zeros
#     w::Float64	#          ... init to 0.0
#     wu::VecF 		# k/e^3 x 1... init to zeros
# end

# inputs:
#		X
#		k
#		e

# function getFirstEig(A::MatF)
# 	eigvals, eigvecs = eig(A)
	
# 	# resort eigvals, eigvecs and return the first
# 	sortIndices = sortperm(eigvals, rev=true)
# 	λ = eigvals[sortIndices[1]]
# 	v = eigvecs[:, sortIndices[1]]
# 	λ, v
# end

# function update!(o::OnlinePCA, x::VecF)
# 	update_algo1!(o, x)
# 	# update_algo2!(o, x)
# end

# # TODO: Based on Boutsidis et al: "Online Principal Component Analysis" - Algo #1
# function update_algo1!(o::OnlinePCA, x::VecF)
# 	norm2x = ???  # TODO some constant? how to define?
# 	l = ceil(8k / e^2)
# 	ImUU = eye(d) - U * U'  		# d x d
# 	r = ImUU * x 								# d x 1
# 	C = ImUU * (Z * Z') * ImUU 	# d x d -- covariance of residual errors

# 	# fill in for each component
# 	while norm(C + r * r') >= max(w0, w) * k / e^2
# 		λ, u = getFirstEig(C)
# 	end

# end


# # TODO: Based on Boutsidis et al: "Online Principal Component Analysis" - Algo #2
# function update_algo2!(o::OnlinePCA, x::VecF)
# 	w0 = 0.0  # do we ever need to change this??
# 	w += sumabs2(x)
# 	ImUU = eye(d) - U * U'  		# d x d
# 	r = ImUU * x 								# d x 1
# 	C = ImUU * (Z * Z') * ImUU 	# d x d

# 	# fill in for each component
# 	while norm(C + r * r') >= max(w0, w) * k / e^2
# 		λ, u = getFirstEig(C)
# 	end

# end
