### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 2f883160-7934-11ee-0dd3-d983d541dae0
begin
	using DataFrames, PlutoUI, Random
	import PlutoUI: combine
end

# ╔═╡ f5dae227-a340-4e52-b531-e01460fe6782
md"""
# TODO:

- Convertir `alternatives` y el resto en `Vector{Float64}`
- Implementar los otros metodos y pedir el ingreso de P y Q (max/min)
- Agregar promethee2, no 1
- Agregar explicacion teorica
- Auto-normalizacion de pesos
"""

# ╔═╡ 5a57206b-5362-4891-95f4-b7e17edc91b8
function criteria_input(quantity)
	return combine() do Child
		inputs = [
			md""" Name of the criterion $order: $(
				Child(randstring(), TextField())
			) $(
				Child(randstring(), Select(
					["Criterion", "Lineal", "Level", "Only P", "Only Q"]
				))
			)"""

			for order in string.(1:quantity)
		]

		md"""$(inputs)"""
	end
end

# ╔═╡ e40f509b-68a3-4421-8b34-307d1f9388c1
function names_input(quantity)
	return combine() do Child
		inputs = [
			md""" Name of the alternative $order: $(
				Child(randstring(), TextField())
			)"""

			for order in string.(1:quantity)
		]

		md"""$(inputs)"""
	end
end

# ╔═╡ 26254e6e-94dc-42a8-bb44-8fef37addcb6
function preferences_input()
end

# ╔═╡ d827f5b0-0f1b-4e70-a78d-a3c2f0dc6d78
md"
# Promethee
"

# ╔═╡ 6b7a4adb-9a23-46a9-b29f-b32afae0a047
md"## Criteria"

# ╔═╡ dba59597-1d75-4ada-8fc3-774fc1de1303
md"
Quantity of criteria:
$(@bind criteria_count confirm(NumberField(1:7)))
"

# ╔═╡ d3d9fb23-765b-40ec-ab0f-834ae74a5182
if criteria_count > 7
	md"""!!! warning "Atencion"
		No se recomienda utilizar mas de 7 criterios
	"""
end

# ╔═╡ 201027b9-e6b8-4bef-b71e-1041a0fd2492
md"### Names"

# ╔═╡ f8e30065-cf82-402f-9d90-dd4e954312b2
@bind criteria_tuple confirm(criteria_input(criteria_count))

# ╔═╡ a75c01e1-a4a1-4d58-a18f-0b8e24e9aa4e
begin
	odd_indices = [i for (i, _) in enumerate(keys(criteria_tuple)) if isodd(i)]
	even_indices = [i for (i, _) in enumerate(keys(criteria_tuple)) if iseven(i)]

	criteria = [criteria_tuple[symbol] for symbol in odd_indices]
	funcs = [criteria_tuple[symbol] for symbol in even_indices]
end;

# ╔═╡ a2c51850-fc8a-49b2-8907-0327759724ec
function alternatives_input(quantity)
	return combine() do Child
		inputs = [
			md""" $criterion $order: $(
				Child(randstring(), NumberField(0.0:1000.0))
			)"""

			for criterion in criteria
			for order in string.(1:quantity)
		]

		md"""$(inputs)"""
	end
end

# ╔═╡ 1fef8729-943f-4e62-9bf7-db327c438e39
function weights_input(quantity)
	return combine() do Child
		inputs = [
			md""" $criterion weight: $(
				Child(randstring(), NumberField(0.0:0.1:1.0))
			)"""

			for criterion in criteria
		]

		md"""$(inputs)"""
	end
end

# ╔═╡ 155d39b1-51b1-40d7-bb4a-8145e64b57f8
md"## Alternatives"

# ╔═╡ aa77cde1-c70c-46bc-9db8-70ef1f9049f2
md"
Quantity of alternatives:
$(@bind alternatives_count confirm(NumberField(1:10)))
"

# ╔═╡ 14035f7f-74ce-49a2-b40e-e8a58308d9c6
md"### Names"

# ╔═╡ 0c04df4e-356a-4250-82ba-66625a3d2830
@bind names_tuple confirm(names_input(alternatives_count))

# ╔═╡ 328fc097-53d5-493e-ab46-8c47281dacfe
names = collect(names_tuple);

# ╔═╡ 614dabc5-e1a7-4a55-9bc2-72cf65d26e4d
md"### Values"

# ╔═╡ 069ad953-2166-4eaf-85b7-b5cdf30127b7
@bind alternatives_tuple confirm(alternatives_input(alternatives_count))

# ╔═╡ 0e29d307-3bb2-45c8-8253-1ea66335dd28
alternatives = reshape(collect(alternatives_tuple)', (alternatives_count, criteria_count))';

# ╔═╡ 110ae537-5e73-4a03-b58d-f748dda91b32
md"### Weights"

# ╔═╡ 1217b527-3870-46c3-a602-3d48c1ee97ce
@bind weights_tuple confirm(weights_input(alternatives_count))

# ╔═╡ f2f27761-9ee1-43ec-a01a-00b81ac9e135
begin
	weights = collect(weights_tuple);
	
	if sum(weights) != 1
		md"""!!! warning "Weights not balanced" """
	else
		md"""!!! note "Weights are balanced" """
	end
end

# ╔═╡ 6e5ac813-9db7-4935-8638-5c391a32c9d5
md"### Preferences"

# ╔═╡ 9887ee9c-28f4-4097-86a9-30f7fa2b5c1e
@bind preferences_tuple confirm(preferences_input())

# ╔═╡ fbbbe745-c55f-4ba4-8e5b-56f3ab0d08f5
# preferences = collect(preferences_tuple);
weights_tuple;

# ╔═╡ b1dd1ec3-861a-4e9b-bb91-7f719892edd7
md"## Result"

# ╔═╡ 9e71fa90-4bbf-46fa-9f41-28ec4f1d4231
function normalize(values::Vector{Float64})::Matrix{Float64}
	len = length(values)
	normalison = zeros(Float64, len, len)
	for i in 1:len
		for j in 1:len
			if values[i] > values[j]
				normalison[i, j] = 1
			end
		end
	end

	return normalison
end

# ╔═╡ 5953ccdf-980c-4936-a0ac-9fe43eb75093
function ponderate(matrix, weight::Float64)::Matrix{Float64}
    return [element * weight for element in matrix]
end

# ╔═╡ efd04d51-fd38-4928-b69d-5d73663206d6
function combinate(matrices::Vector{Matrix{Float64}})
    rows = size(matrices[1], 1)
    combination = zeros(Float64, rows, rows)

    for matrix in matrices
        combination .+= matrix
    end

    return combination
end

# ╔═╡ d8be6c44-2878-4229-9b18-ffa0b49a04a9
function flows(matrix::Matrix{Float64})::Tuple{Vector{Float64}, Vector{Float64}}
	rows, cols = size(matrix)

    positive_flow = [sum(row) for row in eachrow(matrix)]
    negative_flow = [sum(matrix[:, j]) for j in 1:cols]

    return positive_flow, negative_flow
end

# ╔═╡ 331fdeb6-b1ae-4f12-92bf-662925593188
@bind skidaddle Button("Skeedaddle")

# ╔═╡ eec544e6-bb8c-4539-bea3-786affb1d0a1
begin
	skidaddle
	
	normalized::Vector{Matrix{Float64}} = []
	ponderated::Vector{Matrix{Float64}} = []

	for i in 1:size(alternatives, 1)
		push!(normalized, normalize(alternatives[i, :]))
	end
	
	for i in 1:length(normalized)
		push!(ponderated, ponderate(normalized[i], weights[i]))
	end

	combination = combinate(ponderated)

	positive_flow, negative_flow = flows(combination)

	results = [p - n for (p, n) in zip(positive_flow, negative_flow)]

	df = DataFrame(Alternatives = names, Results = results)

	df_sorted = sort(df, :Results, rev=true)

	df_sorted
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
DataFrames = "~1.6.1"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "f1626228c716a5606285cdc0f023f79a5f3cff19"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "6842ce83a836fbbc0cfeca0b5a4de1a4dcbdb8d1"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.8"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "5165dfb9fd131cf0c6957a3a7605dede376e7b63"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─f5dae227-a340-4e52-b531-e01460fe6782
# ╟─2f883160-7934-11ee-0dd3-d983d541dae0
# ╟─5a57206b-5362-4891-95f4-b7e17edc91b8
# ╟─e40f509b-68a3-4421-8b34-307d1f9388c1
# ╟─a2c51850-fc8a-49b2-8907-0327759724ec
# ╟─1fef8729-943f-4e62-9bf7-db327c438e39
# ╟─26254e6e-94dc-42a8-bb44-8fef37addcb6
# ╟─d827f5b0-0f1b-4e70-a78d-a3c2f0dc6d78
# ╟─6b7a4adb-9a23-46a9-b29f-b32afae0a047
# ╟─dba59597-1d75-4ada-8fc3-774fc1de1303
# ╟─d3d9fb23-765b-40ec-ab0f-834ae74a5182
# ╟─201027b9-e6b8-4bef-b71e-1041a0fd2492
# ╟─f8e30065-cf82-402f-9d90-dd4e954312b2
# ╟─a75c01e1-a4a1-4d58-a18f-0b8e24e9aa4e
# ╟─155d39b1-51b1-40d7-bb4a-8145e64b57f8
# ╟─aa77cde1-c70c-46bc-9db8-70ef1f9049f2
# ╟─14035f7f-74ce-49a2-b40e-e8a58308d9c6
# ╟─0c04df4e-356a-4250-82ba-66625a3d2830
# ╟─328fc097-53d5-493e-ab46-8c47281dacfe
# ╟─614dabc5-e1a7-4a55-9bc2-72cf65d26e4d
# ╟─069ad953-2166-4eaf-85b7-b5cdf30127b7
# ╟─0e29d307-3bb2-45c8-8253-1ea66335dd28
# ╟─110ae537-5e73-4a03-b58d-f748dda91b32
# ╟─1217b527-3870-46c3-a602-3d48c1ee97ce
# ╟─f2f27761-9ee1-43ec-a01a-00b81ac9e135
# ╟─6e5ac813-9db7-4935-8638-5c391a32c9d5
# ╟─9887ee9c-28f4-4097-86a9-30f7fa2b5c1e
# ╟─fbbbe745-c55f-4ba4-8e5b-56f3ab0d08f5
# ╟─b1dd1ec3-861a-4e9b-bb91-7f719892edd7
# ╟─9e71fa90-4bbf-46fa-9f41-28ec4f1d4231
# ╟─5953ccdf-980c-4936-a0ac-9fe43eb75093
# ╟─efd04d51-fd38-4928-b69d-5d73663206d6
# ╟─d8be6c44-2878-4229-9b18-ffa0b49a04a9
# ╟─331fdeb6-b1ae-4f12-92bf-662925593188
# ╟─eec544e6-bb8c-4539-bea3-786affb1d0a1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
