# Generate JSON config from YAML

all: builder/build_ubuntu.json builder/build_centos.json

builder/build_ubuntu.json: builder/build_ubuntu.yml
	ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('builder/build_ubuntu.yml'))" > builder/build_ubuntu.json

builder/build_centos.json: builder/build_centos.yml
	ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('builder/build_centos.yml'))" > builder/build_centos.json

builder/build_docker.json: builder/build_docker.yml
	ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('builder/build_docker.yml'))" > builder/build_docker.json
