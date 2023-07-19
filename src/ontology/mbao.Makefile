## Customize Makefile settings for mbao
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile
# MBA : 1
# DMBA : 17
# HBA : 10
# DHBA : 16
# PBA : 8
URIBASE = https://purl.brain-bican.org/ontology

JOBS = 1 # 17 10 16 8
BRIDGES = aba mba
TARGETS = mba # dmba

LINKML = linkml-data2owl

STRUCTURE_GRAPHS = $(patsubst %, sources/%.json, $(JOBS))
ALL_GRAPH_ONTOLOGIES = $(patsubst sources/%.json,sources/%.ofn,$(STRUCTURE_GRAPHS))
ALL_BRIDGES = $(patsubst %, sources/uberon-bridge-to-%.obo, $(BRIDGES))
SOURCE_TEMPLATES = $(patsubst %, ../robot_templates/%_CCF_to_UBERON_source.tsv, $(TARGETS))
NEW_BRIDGES = $(patsubst %, new-bridges/new-uberon-bridge-to-%.owl, $(TARGETS))


.PHONY: $(COMPONENTSDIR)/all_templates.owl
$(COMPONENTSDIR)/all_templates.owl: clean_files dependencies $(COMPONENTSDIR)/linkouts.owl $(COMPONENTSDIR)/sources_merged.owl
	$(ROBOT) merge -i $(COMPONENTSDIR)/linkouts.owl -i $(COMPONENTSDIR)/sources_merged.owl annotate --ontology-iri $(URIBASE)/$@ convert -f ofn -o $@
.PRECIOUS: $(COMPONENTSDIR)/all_templates.owl

# Installing depedencies so it can run in ODK container
.PHONY: dependencies
dependencies:
	pip3 install -r ../../requirements.txt


LOCAL_CLEAN_FILES = $(ALL_GRAPH_ONTOLOGIES) $(ALL_BRIDGES) $(TMPDIR)/tmp.json $(TMPDIR)/tmp.owl $(COMPONENTSDIR)/sources_merged.owl $(COMPONENTSDIR)/linkouts.owl $(TEMPLATEDIR)/linkouts.tsv

# clean previous build files
.PHONY: clean_files
clean_files:
	rm -f $(LOCAL_CLEAN_FILES)

sources/%.json:
	curl -o $@ $(subst %,$(subst sources/,,$@),"http://api.brain-map.org/api/v2/structure_graph_download/%")

../linkml/data/template_%.tsv: sources/%.json
	python3 $(SCRIPTSDIR)/structure_graph_template.py -i $< -o $@
.PRECIOUS: ../linkml/data/template_%.tsv:
# TODO delete

sources/%.ofn: ../linkml/data/template_%.tsv
	$(LINKML) -C Class -s ../linkml/structure_graph_schema.yaml $< -o $@
.PRECIOUS: sources/%.ofn

# download bridges
sources/uberon-bridge-to-aba.obo:
	curl -o sources/uberon-bridge-to-aba.obo "https://raw.githubusercontent.com/obophenotype/uberon/master/src/ontology/bridge/uberon-bridge-to-aba.obo"

sources/uberon-bridge-to-dhba.obo:
	curl -o sources/uberon-bridge-to-dhba.obo "https://raw.githubusercontent.com/obophenotype/uberon/master/src/ontology/bridge/uberon-bridge-to-dhba.obo"

sources/uberon-bridge-to-dmba.obo:
	curl -o sources/uberon-bridge-to-dmba.obo "https://raw.githubusercontent.com/obophenotype/uberon/master/src/ontology/bridge/uberon-bridge-to-dmba.obo"

sources/uberon-bridge-to-hba.obo:
	curl -o sources/uberon-bridge-to-hba.obo "https://raw.githubusercontent.com/obophenotype/uberon/master/src/ontology/bridge/uberon-bridge-to-hba.obo"

sources/uberon-bridge-to-mba.obo:
	curl -o sources/uberon-bridge-to-mba.obo "https://raw.githubusercontent.com/obophenotype/uberon/master/src/ontology/bridge/uberon-bridge-to-mba.obo"

sources/uberon-bridge-to-pba.obo:
	curl -o sources/uberon-bridge-to-pba.obo "https://raw.githubusercontent.com/obophenotype/uberon/master/src/ontology/bridge/uberon-bridge-to-pba.obo"

# TODO handle legacy mapings

#all_bridges:
#	make sources/uberon-bridge-to-aba.obo sources/uberon-bridge-to-mba.obo -B

# Merge sources. # crudely listing dependencies for now - but could switch to using pattern expansion
#sources_merged.owl: all_bridges
#	robot merge --input sources/1.ofn --input sources/17.ofn --input sources/10.ofn --input sources/16.ofn --input sources/8.ofn --input sources/uberon-bridge-to-aba.obo --input sources/uberon-bridge-to-dhba.obo --input sources/uberon-bridge-to-dmba.obo --input sources/uberon-bridge-to-hba.obo --input sources/uberon-bridge-to-mba.obo --input sources/uberon-bridge-to-pba.obo annotate --ontology-iri $(URIBASE)/$@ -o $@

$(COMPONENTSDIR)/sources_merged.owl: $(ALL_GRAPH_ONTOLOGIES) $(ALL_BRIDGES)
	$(ROBOT) merge $(patsubst %, -i %, $^) relax annotate --ontology-iri $(URIBASE)/$@ -o $@

# merge uberon + sources, reason & relax (EC -> SC)
$(TMPDIR)/tmp.owl: $(SRC) $(COMPONENTSDIR)/sources_merged.owl
	robot merge $(patsubst %, -i %, $^) relax annotate --ontology-iri $(URIBASE)/$@ -o $@

# Make a json file for use in geneating ROBOT template
$(TMPDIR)/tmp.json: $(TMPDIR)/tmp.owl
	$(ROBOT) convert --input $< -f json -o $@

# Build robot  template - with linkouts and prefLabels
$(TEMPLATEDIR)/linkouts.tsv: $(TMPDIR)/tmp.json
	python $(SCRIPTSDIR)/gen_linkout_template.py $<

# generate OWL from template
$(COMPONENTSDIR)/linkouts.owl: $(TMPDIR)/tmp.owl $(TEMPLATEDIR)/linkouts.tsv
	$(ROBOT) template --template $(word 2, $^) --input $< --add-prefixes template_prefixes.json -o $@


