FROM julia:latest

RUN julia -e 'using Pkg; Pkg.add("Pluto")'

WORKDIR /notebooks

COPY promethee.jl /notebooks/

EXPOSE 1234

CMD julia -e 'import Pluto; Pluto.run(host="0.0.0.0")'
